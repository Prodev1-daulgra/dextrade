import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolves Supabase config for local, APK, and Vercel static deploys.
/// Order: `.env` asset → `--dart-define` → (web only, empty fails loudly in debug).
class AppEnv {
  AppEnv._();

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: '.env', isOptional: true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AppEnv: dotenv load failed: $e');
      }
    }

    _ensure('SUPABASE_URL', const String.fromEnvironment('SUPABASE_URL'));
    _ensure('SUPABASE_ANON_KEY', const String.fromEnvironment('SUPABASE_ANON_KEY'));

    _loaded = true;
  }

  static void _ensure(String key, String fromDefine) {
    final current = dotenv.env[key];
    if (current != null && current.isNotEmpty) return;
    if (fromDefine.isNotEmpty) {
      dotenv.env[key] = fromDefine;
    }
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL']?.trim() ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get configError {
    if (isConfigured) return '';
    return 'Missing SUPABASE_URL / SUPABASE_ANON_KEY. '
        'Local: add `.env`. Vercel: set env vars and use scripts/vercel-build.sh.';
  }
}
