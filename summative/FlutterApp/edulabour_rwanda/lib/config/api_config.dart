class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://edulabour-rwanda-api.onrender.com',
  );

  static Uri get predictUri => Uri.parse('$_normalizedBaseUrl/predict');

  static String get _normalizedBaseUrl {
    var value = baseUrl.trim();
    while (value.endsWith('/')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }
}
