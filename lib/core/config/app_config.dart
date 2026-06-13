/// Uygulama genelindeki statik konfigürasyon ve anahtarları barındıran güvenli sınıf
class AppConfig {
  // Google Gemini API Key injected via --dart-define at build time (e.g., --dart-define=GEMINI_API_KEY=your_key)
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
}
