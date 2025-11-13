import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _userTableName = 'users';

  // -------------------- EMAIL / PASSWORD SIGNUP --------------------
  Future<UserModel?> signUp({
    required String name,
    required String password,
    required String email,
  }) async {
    try {
      final authRes = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final authUser = authRes.user;
      if (authUser == null) throw Exception("Signup failed");

      // Create or update profile
      await _client.from('users').upsert({
        'user_id': authUser.id,
        'email': email,
        'name': name,
        'password_hash': password,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      final profile = await getOrCreateUserProfile(authUser);
      await _saveUserSession(profile);

      return profile;
    } catch (e) {
      throw Exception("Signup failed: $e");
    }
  }

  // -------------------- EMAIL / PASSWORD LOGIN --------------------
  Future<UserModel?> signIn({
    required String mobileNo,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: mobileNo,
        password: password,
      );

      final authUser = res.user;
      if (authUser == null) throw Exception("Invalid credentials");

      final profile = await getOrCreateUserProfile(authUser);
      await _saveUserSession(profile);

      return profile;
    } catch (e) {
      throw Exception("Sign-in failed: $e");
    }
  }

  Future<UserModel> getOrCreateUserProfile(User supabaseUser) async {
    final existingUser = await _client
        .from('users')
        .select()
        .eq('user_id', supabaseUser.id)
        .maybeSingle();

    if (existingUser != null) {
      return UserModel.fromJson(existingUser);
    }

    final newUser = {
      'user_id': supabaseUser.id,
      'email': supabaseUser.email ?? '',
      'name': supabaseUser.userMetadata?['full_name'] ?? '',
      'avatar_url': supabaseUser.userMetadata?['avatar_url'] ?? '',
      'password_hash': '',
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final inserted = await _client
        .from('users')
        .insert(newUser)
        .select()
        .single();

    return UserModel.fromJson(inserted);
  }

  // -------------------- CURRENT USER --------------------
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _client.auth.currentSession;
      if (session?.user != null) {
        final response = await _client
            .from(_userTableName)
            .select()
            .eq('user_id', session!.user.id)
            .maybeSingle();

        if (response != null) {
          return UserModel.fromJson(response);
        }
      }
    } catch (_) {}
    return null;
  }

  // -------------------- SIGN OUT --------------------
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      await _clearUserSession();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // -------------------- GOOGLE SIGN-IN (NEW) --------------------
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger OAuth flow
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.example.klektion://login-callback/',
      );

      // Wait for Supabase to update session after OAuth redirect
      // The app will reopen → and now we can check the current session

      final session = _client.auth.currentSession;

      if (session == null || session.user == null) {
        throw Exception("Google login failed: No session");
      }

      final user = session.user;

      // Create or fetch user profile
      final userModel = await getOrCreateUserProfile(user);

      await _saveUserSession(userModel);

      return userModel;
    } catch (e) {
      Get.snackbar("Error", "Google Sign-in failed: $e");
      return null;
    }
  }

  // -------------------- Handle user after OAuth --------------------

  Future<UserModel?> handleUserAfterOAuth() async {
    final session = _client.auth.currentSession;
    final user = session?.user;
    if (user == null) return null;

    // Check if user already exists in DB
    final existing = await _client
        .from(_userTableName)
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing != null) {
      return UserModel.fromJson(existing);
    }

    // If not found, insert new record
    final newUser = {
      'user_id': user.id,
      'email': user.email,
      'name': user.userMetadata?['name'] ?? user.email?.split('@').first,
      'avatar_url': user.userMetadata?['avatar_url'],
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    final inserted = await _client
        .from(_userTableName)
        .insert(newUser)
        .select()
        .maybeSingle();

    if (inserted == null) return null;
    return UserModel.fromJson(inserted);
  }

  // -------------------- UTILITIES --------------------
  Future<void> _saveUserSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user.toJson().toString());
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}
