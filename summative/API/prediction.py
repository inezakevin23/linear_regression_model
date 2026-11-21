import copy
import os
from pathlib import Path
from threading import RLock
from typing import Annotated

import joblib
import numpy as np
import pandas as pd
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, ConfigDict, Field, StrictInt
from sklearn.base import clone
from sklearn.pipeline import Pipeline

API_DIR = Path(__file__).resolve().parent
MODEL_PATH = Path(os.getenv("MODEL_PATH", str(API_DIR / "best_model.pkl")))

DEFAULT_ORIGINS = (
    "https://edulabour-rwanda-api.onrender.com,"
    "http://localhost:5000,"
    "http://127.0.0.1:5000"
)
ALLOWED_ORIGINS = [
    origin.strip()
    for origin in os.getenv("ALLOWED_ORIGINS", DEFAULT_ORIGINS).split(",")
    if origin.strip()
]

EXPECTED_FEATURES = [
    "a04", "b02b", "d24", "a01", "code_ur", "province",
    "a05", "b02a", "b07", "b08", "main_sect",
]
MODEL_LOCK = RLock()
MODEL_ARTIFACT: dict | None = None

# Validating input schema
class PredictionRequest(BaseModel):
    model_config = ConfigDict(extra="forbid", strict=True)
    # Numeric predictors
    a04: Annotated[StrictInt, Field(ge=16, le=98, description="Age in years (16–98)")]
    b02b: Annotated[StrictInt, Field(ge=0, le=14, description="Completed years at reported education level (0–14)")]
    d24: Annotated[StrictInt, Field(ge=0, le=70, description="Total years of work experience (0–70)")]
    # Categorical survey codes
    a01: Annotated[StrictInt, Field(ge=1, le=2, description="Sex code (1–2)")]
    code_ur: Annotated[StrictInt, Field(ge=1, le=2, description="Residence code: 1 = Urban, 2 = Rural")]
    province: Annotated[StrictInt, Field(ge=1, le=5, description="Rwanda province code (1–5)")]
    a05: Annotated[StrictInt, Field(ge=1, le=7, description="Marital-status code (1–7)")]
    b02a: Annotated[StrictInt, Field(ge=1, le=8, description="Highest education-level code (1–8)")]
    b07: Annotated[StrictInt, Field(ge=1, le=2, description="Attending trade/technical skills school (1 = Yes, 2 = No)")]
    b08: Annotated[StrictInt, Field(ge=1, le=2, description="Completed TVET course (1 = Yes, 2 = No)")]
    main_sect: Annotated[StrictInt, Field(ge=1, le=21, description="Main economic-sector code (1–21)")]


class PredictionResponse(BaseModel):
    predicted_monthly_cash_rwf: float
    currency: str = "RWF"
    target: str = "Monthly cash earnings for employees"
    model_name: str

# loading the model artifact
def get_model_artifact() -> dict:
    global MODEL_ARTIFACT
    with MODEL_LOCK:
        if MODEL_ARTIFACT is None:
            if not MODEL_PATH.exists():
                raise HTTPException(status_code=503, detail=f"Model file not found at {MODEL_PATH}")
            artifact = joblib.load(MODEL_PATH)
            if list(artifact.get("feature_columns", [])) != EXPECTED_FEATURES:
                raise HTTPException(status_code=500, detail="Saved model features do not match API schema.")
            MODEL_ARTIFACT = artifact
        return MODEL_ARTIFACT


def predict_single_row(pipeline: Pipeline, row_dict: dict) -> float:
    row_df = pd.DataFrame([{col: row_dict[col] for col in EXPECTED_FEATURES}], columns=EXPECTED_FEATURES)
    predicted_log = pipeline.predict(row_df)
    return float(np.maximum(0.0, np.expm1(predicted_log))[0])


app = FastAPI(
    title="EduLabour Rwanda — Monthly Earnings Prediction API",
    description="Predicts monthly cash earnings (RWF) using NISR Rwanda Labour Force Survey data.",
    version="1.0.0",
)

# CORS Middleware Configuration:
# What we allow: only our deployed Render domain and local Flutter/FastAPI debug origins, 
# only GET and POST HTTP methods, only Content-Type and Authorization headers, 
# and credentials for those trusted origins.
# What we restrict: Blocks the wildcard origin ('*'), untrusted third-party websites, and
# unnecessary HTTP methods (PUT, DELETE, PATCH) or custom headers.
# Why: Prevents unauthorized cross-origin browser scripts from calling /predict or uploading
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type", "Authorization"],
    allow_credentials=True,
)


@app.get("/", tags=["Health"])
def root() -> dict:
    return {
        "message": "EduLabour Rwanda API is running.",
        "docs": "/docs",
        "prediction_endpoint": "/predict",
        "retraining_endpoint": "/retrain",
    }


@app.post("/predict", response_model=PredictionResponse, tags=["Prediction"])
def predict(request: PredictionRequest) -> PredictionResponse:
    artifact = get_model_artifact()
    with MODEL_LOCK:
        prediction = predict_single_row(artifact["pipeline"], request.model_dump())
        model_name = str(artifact["best_model_name"])

    return PredictionResponse(
        predicted_monthly_cash_rwf=round(prediction, 2),
        model_name=model_name,
    )


@app.post("/retrain", tags=["Model retraining"])
def retrain(file: UploadFile = File(..., description="CSV with the 11 features plus 'cash'.")) -> dict:
    if not file.filename or not file.filename.lower().endswith(".csv"):
        raise HTTPException(status_code=400, detail="Please upload a valid .csv file.")
    artifact = get_model_artifact()
    try:
        df = pd.read_csv(file.file)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=f"Could not read CSV: {exc}") from exc
    finally:
        file.file.close()

    df.columns = df.columns.astype(str).str.strip().str.lower()
    # Normalize d24 / d24a so both 2023-style (d24a) and 2024-style (d24) CSVs work
    if "d24a" in df.columns:
        if "d24" in df.columns:
            df["d24"] = df["d24"].fillna(df["d24a"])
        else:
            df = df.rename(columns={"d24a": "d24"})

    target_col = str(artifact["target_column"])
    required_cols = EXPECTED_FEATURES + [target_col]

    missing = [col for col in required_cols if col not in df.columns]
    if missing:
        raise HTTPException(status_code=422, detail=f"Missing required columns: {', '.join(missing)}")

    for col in required_cols:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    clean_df = df[required_cols].replace([np.inf, -np.inf], np.nan)
    clean_df = clean_df.loc[clean_df[target_col].notna() & (clean_df[target_col] > 0)].copy()
    if clean_df.empty:
        raise HTTPException(status_code=422, detail="CSV has no valid rows with positive cash earnings.")

    X_new = clean_df[EXPECTED_FEATURES]
    y_new = clean_df[target_col].astype(float)

    global MODEL_ARTIFACT
    with MODEL_LOCK:
        updated = copy.deepcopy(artifact)
        model_name = str(updated["best_model_name"])
        combined_X = pd.concat([updated["training_X"], X_new], ignore_index=True)
        combined_y = pd.concat([pd.Series(updated["training_y"]).astype(float), y_new], ignore_index=True)

        if model_name == "SGDRegressor":
            pipe = updated["pipeline"]
            X_new_proc = pipe.named_steps["preprocessor"].transform(X_new)
            pipe.named_steps["regressor"].partial_fit(X_new_proc, np.log1p(y_new.to_numpy(dtype=float)))
        else:
            pipe = Pipeline(steps=[
                ("preprocessor", clone(updated["pipeline"].named_steps["preprocessor"])),
                ("regressor", clone(updated["pipeline"].named_steps["regressor"])),
            ])
            pipe.fit(combined_X, np.log1p(combined_y.to_numpy(dtype=float)))

        updated["pipeline"] = pipe
        updated["training_X"] = combined_X
        updated["training_y"] = combined_y
        joblib.dump(updated, MODEL_PATH)
        MODEL_ARTIFACT = updated

    return {
        "message": "Model retrained successfully. /predict now uses the updated model.",
        "model_name": model_name,
        "new_rows_used": int(len(X_new)),
        "total_training_rows": int(len(combined_X)),
    }
