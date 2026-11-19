import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class PredictionResult {
  const PredictionResult({
    required this.monthlyEarningsRwf,
    required this.modelName,
  });

  final double monthlyEarningsRwf;
  final String modelName;

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final value = json['predicted_monthly_cash_rwf'];
    if (value is! num) {
      throw const FormatException(
        'The API response did not contain a valid predicted earnings value.',
      );
    }

    return PredictionResult(
      monthlyEarningsRwf: value.toDouble(),
      modelName: (json['model_name'] ?? 'Regression model').toString(),
    );
  }
}

class PredictionApiException implements Exception {
  const PredictionApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PredictionService {
  PredictionService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<PredictionResult> predict(Map<String, int> inputs) async {
    try {
      final response = await _client
          .post(
            ApiConfig.predictUri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            // The API expects lowercase NISR field names, e.g. a04 and b02b
            body: jsonEncode(inputs),
          )
          .timeout(const Duration(seconds: 90));

      final decoded = _decodeResponse(response.body);

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(decoded);
      }

      if (response.statusCode == 422) {
        throw PredictionApiException(
          _readValidationError(decoded) ?? 'The API rejected one or more values. Check the NISR code ranges and try again.',
        );
      }

      final detail = decoded['detail'];
      throw PredictionApiException(
        detail is String
            ? detail
            : 'The prediction service returned error ${response.statusCode}. Please try again.',
      );
    } on PredictionApiException {
      rethrow;
    } on FormatException catch (error) {
      throw PredictionApiException(error.message);
    } catch (error) {
      final message = error.toString();
      if (message.toLowerCase().contains('timeout')) {
        throw const PredictionApiException(
          'The API took too long to respond. Render may be waking from sleep; please try again.',
        );
      }
      throw const PredictionApiException(
        'Could not connect to the prediction service. Check your internet connection and Render API URL.',
      );
    }
  }

  Map<String, dynamic> _decodeResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'The API returned an unexpected response format.',
      );
    }
    return decoded;
  }

  String? _readValidationError(Map<String, dynamic> body) {
    final detail = body['detail'];
    if (detail is! List || detail.isEmpty) return null;

    final first = detail.first;
    if (first is! Map) return null;

    final location = first['loc'];
    final field = location is List && location.isNotEmpty
        ? location.last.toString()
        : 'input';
    final message = (first['msg'] ?? 'Invalid value').toString();
    return 'Invalid $field: $message. Please check the value and try again.';
  }

  void dispose() => _client.close();
}
