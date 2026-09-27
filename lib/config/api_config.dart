class ApiConfig {
  const ApiConfig._();

  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://kabadiwala-backend.vercel.app',
  );

  static String get predictionUrl => predictionUrlFor(baseUrl);

  static String predictionUrlFor(String backendUrl) {
    final uri = Uri.tryParse(backendUrl);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      return '';
    }
    return uri.replace(path: '/predict').toString();
  }
}
