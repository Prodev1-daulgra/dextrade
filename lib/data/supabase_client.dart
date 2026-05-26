import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_env.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static String get url => AppEnv.supabaseUrl;
  static String get anonKey => AppEnv.supabaseAnonKey;

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (!AppEnv.isConfigured) {
      throw StateError(AppEnv.configError);
    }
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
}
