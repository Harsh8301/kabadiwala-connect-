class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5001',
  );

  static String get scrapDetectionUrl =>
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/api/detection/scrap';
}
