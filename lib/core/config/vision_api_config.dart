/// Compile-time vision API configuration (dev / pre-production).
///
/// **Hong Kong:** Google Gemini API blocks HK IPs. Use one of:
///
/// 1. **Proxy** (recommended) — deploy `tool/gemini_proxy_worker.mjs` in Singapore/Taiwan:
/// ```bash
/// flutter run \
///   --dart-define=VISION_PROVIDER=proxy \
///   --dart-define=GEMINI_PROXY_URL=https://your-worker.workers.dev/gemini
/// ```
///
/// 2. **OpenRouter** — routes to Gemini from a supported region:
/// ```bash
/// flutter run \
///   --dart-define=VISION_PROVIDER=openrouter \
///   --dart-define=OPENROUTER_API_KEY=sk-or-...
/// ```
///
/// 3. **Direct Gemini** (blocked in HK):
/// ```bash
/// flutter run --dart-define=GEMINI_API_KEY=your_key_here
/// ```
abstract final class VisionApiConfig {
  static const String _geminiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String _legacyKey = String.fromEnvironment(
    'PHOTO_COACH_VISION_API_KEY',
    defaultValue: '',
  );

  static const String _openRouterKey = String.fromEnvironment(
    'OPENROUTER_API_KEY',
    defaultValue: '',
  );

  static const String _proxyToken = String.fromEnvironment(
    'GEMINI_PROXY_TOKEN',
    defaultValue: '',
  );

  static const String providerName = String.fromEnvironment(
    'VISION_PROVIDER',
    defaultValue: 'gemini',
  );

  static const String geminiModel = String.fromEnvironment(
    'GEMINI_VISION_MODEL',
    defaultValue: 'gemini-2.0-flash',
  );

  /// Override Gemini host, e.g. `https://your-proxy.workers.dev`.
  static const String geminiBaseUrl = String.fromEnvironment(
    'GEMINI_BASE_URL',
    defaultValue: '',
  );

  /// Full proxy endpoint (path included). API key may live server-side.
  static const String geminiProxyUrl = String.fromEnvironment(
    'GEMINI_PROXY_URL',
    defaultValue: '',
  );

  static const String openRouterModel = String.fromEnvironment(
    'OPENROUTER_MODEL',
    defaultValue: 'google/gemini-2.5-flash',
  );

  static VisionProvider get provider {
    switch (providerName.toLowerCase()) {
      case 'openrouter':
        return VisionProvider.openrouter;
      case 'proxy':
        return VisionProvider.proxy;
      default:
        return VisionProvider.gemini;
    }
  }

  static String? get geminiApiKey {
    if (_geminiKey.isNotEmpty) {
      return _geminiKey;
    }
    if (_legacyKey.isNotEmpty) {
      return _legacyKey;
    }
    return null;
  }

  static String? get openRouterApiKey =>
      _openRouterKey.isNotEmpty ? _openRouterKey : null;

  static String? get proxyAuthToken =>
      _proxyToken.isNotEmpty ? _proxyToken : null;

  static bool get isGeminiConfigured => geminiApiKey != null;

  static bool get isOpenRouterConfigured => openRouterApiKey != null;

  static bool get isProxyConfigured => geminiProxyUrl.isNotEmpty;

  static bool get isVisionConfigured {
    switch (provider) {
      case VisionProvider.openrouter:
        return isOpenRouterConfigured;
      case VisionProvider.proxy:
        return isProxyConfigured;
      case VisionProvider.gemini:
        return isGeminiConfigured;
    }
  }
}

enum VisionProvider {
  gemini,
  openrouter,
  proxy,
}