### 1. my mission and problem in 4 lines
my mission is to bridge the gap between education and employment in africa by enhancing workforce development. In africa, youth faces challenge of getting rewarding jobs mostly due to mismatch between their training and market-needed skills. this model will help young africans to make informed career choice and allow them to align their education with sustainable income.

### 2. brief description of dataset
**Summary:** It is data collected by National Institute of Statistics of Rwanda that covers the whole part of Rwanda from 2017 to 2024, Data were collected using Computer-Assisted Personal Interviews (CAPI) through face-to-face interviews in selected households and it includes only individuals aged 16 and above. For me I choose to work with Rwanda Labour Force Survey 2024 and Rwanda Labour Force Survey 2023. 2024 survey contains 198 columns and 102,562 rows, while 2023 has 240 columns and 71849 rows.
**Source:** National Institute of Statistics of Rwanda (NISR), Rwanda Labour Force Survey 2024 and Rwanda Labour Force Survey 2023
**link:** https://data.gov.rw/collections/47ba8734-adbf-4a38-9784-0b118eafe1e1

### 3. Public link to swagger UI
**Link:** https://edulabour-rwanda-api.onrender.com/docs

### 4. Link to video demo
**Link:** https://youtu.be/3T4fsKy7sHY?si=7RR0HhNBdznh9tk2  (shortened video to meet rubrics short video requirement).


(Note: Let me also add full video where I explained clearly without cutting video to make it shorter, **link:** https://youtu.be/bt-N9Tfd-Yw?si=si9ViGHj3TzYGkTw (27min). the required assignment video is the above short video, this second long one is just if you want clarity)


### 5. Instruction to run mobile app
#### Prerequisites
1. Flutter SDK(3.19 or higher recommended)
2. Android Studio with an Android Emulator, iOS Simulator, or a physical mobile device with USB debugging enabled
3. Internet connection (to reach the deployed Render API)

#### Setup & Run Steps

1. **go to the edulabour_rwanda app directory in FlutterApp directory :**
   ```bash
   cd summative/FlutterApp/edulabour_rwanda
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify available mobile devices/emulators:**
   ```bash
   flutter devices
   ```
   *(Make sure an emulator is listed. Do not run on a web browser.)*

4. **Run the app:**
   - Using the default deployed Render API (`https://onrender.com`):
     ```bash
     flutter run
     ```
