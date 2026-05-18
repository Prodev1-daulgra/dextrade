import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository(this._client);

  Future<List<UserModel>> getAllUsers() async {
    final res = await _client
        .from('users')
        .select()
        .order('created_at', ascending: false);
    return (res as List).map((e) => UserModel.fromJson(e)).toList();
  }

  Future<void> deleteUser(String userId) async {
    await _client.from('users').delete().eq('id', userId);
  }

  Future<void> suspendUser(String userId) async {
    await _client
        .from('users')
        .update({'status': 'suspended'})
        .eq('id', userId);
  }

  Future<void> activateUser(String userId) async {
    await _client.from('users').update({'status': 'active'}).eq('id', userId);
  }
}
