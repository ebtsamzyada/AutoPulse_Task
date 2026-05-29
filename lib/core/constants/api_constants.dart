class ApiConstants {
  static const String anthropicApiKey = 'YOUR_ANTHROPIC_API_KEY_HERE';
  static const String anthropicEndpoint =
      'https://api.anthropic.com/v1/messages';
  static const String anthropicVersion = '2023-06-01';
  static const String anthropicModel = 'claude-opus-4-20250514';
  static const int llmMaxTokens = 1024;
  static const Duration httpTimeout = Duration(seconds: 30);
}
