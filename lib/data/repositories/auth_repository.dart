import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  User? get currentAuthUser => _client.auth.currentUser;
  String? get currentEmail => currentAuthUser?.email;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register(String email, String password, {String? fullName}) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> getUserProfile(String email) async {
    final res = await _client.from('users').select().eq('email', email).maybeSingle();
    if (res == null) return null;
    return UserModel.fromJson(res);
  }

  Future<UserModel?> getCurrentProfile() async {
    final email = currentEmail;
    if (email == null) return null;
    return getUserProfile(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
