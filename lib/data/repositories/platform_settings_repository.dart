import 'package:supabase_flutter/supabase_flutter.dart';

class PlatformSettingsRepository {
  final SupabaseClient _client;

  PlatformSettingsRepository(this._client);

  Future<Map<String, dynamic>> getAllSettings() async {
    final res = await _client.from('platform_settings').select();
    final Map<String, dynamic> settings = {};
    for (var row in (res as List)) {
      settings[row['key']] = row['value'];
    }
    return settings;
  }
}
