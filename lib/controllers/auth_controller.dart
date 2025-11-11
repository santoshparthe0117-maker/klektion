import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final supabase = Supabase.instance.client;

  final Rx<AuthState> _state = AuthState.initial.obs;
  final Rxn<UserModel> _user = Rxn<UserModel>();
  final RxnString _errorMessage = RxnString();
  final Rx<User?> currentUser = Rx<User?>(null);

  AuthState get state => _state.value;
  UserModel? get user => _user.value;
  String? get errorMessage => _errorMessage.value;
  bool get isAuthenticated =>
      _state.value == AuthState.authenticated && _user.value != null;
  bool get isLoading => _state.value == AuthState.loading;

  @override
  void onInit() {
    super.onInit();
    // initializeAuthWithSupabase();
    // _initializeAuth();
    initializeAuth();
  }

  // initializeAuthWithSupabase() async {
  //   currentUser.value = supabase.auth.currentUser;
  //   supabase.auth.onAuthStateChange.listen((data) {
  //     currentUser.value = data.session?.user;

  //   });
  // }

  // /// ✅ Initialize authentication state (auto-login if valid session)
  // Future<void> _initializeAuth() async {
  //   _setState(AuthState.loading);
  //   try {
  //     // 1️⃣ Check if current session exists (user already logged in)
  //     final currentSession = supabase.auth.currentSession;
  //     if (currentSession != null) {
  //       final userData = await _authService.getCurrentUser();
  //       if (userData != null) {
  //         _user.value = userData;
  //         _setState(AuthState.authenticated);
  //         return;
  //       }
  //     }

  //     // 2️⃣ Recover saved session (if app was closed and reopened)
  //     final prefs = await SharedPreferences.getInstance();
  //     final storedSessionJson = prefs.getString('supabase_session');

  //     if (storedSessionJson != null) {
  //       // Convert JSON string to Session object
  //       final sessionMap = jsonDecode(storedSessionJson);
  //       final recoveredSession = Session.fromJson(sessionMap);

  //       final response = await supabase.auth.recoverSession(
  //         recoveredSession as String,
  //       );

  //       if (response.session != null) {
  //         // ✅ Save refreshed session for next time
  //         await prefs.setString(
  //           'supabase_session',
  //           jsonEncode(response.session!.toJson()),
  //         );

  //         final userData = await _authService.getCurrentUser();
  //         if (userData != null) {
  //           _user.value = userData;
  //           _setState(AuthState.authenticated);
  //           return;
  //         }
  //       }
  //     }

  //     _setState(AuthState.unauthenticated);
  //   } catch (e) {
  //     _setError('Failed to initialize authentication: ${e.toString()}');
  //   }
  // }

  Future<void> initializeAuth() async {
    _setState(AuthState.loading);

    try {
      // ✅ Check if user is already logged in
      final session = supabase.auth.currentSession;

      if (session != null) {
        currentUser.value = session.user;

        // ✅ Fetch full user profile
        final profile = await _authService.getCurrentUser();
        if (profile != null) {
          _user.value = profile;
          _setState(AuthState.authenticated);
          return;
        }
      }

      // ✅ Listen for session changes (login/logout/token refresh)
      supabase.auth.onAuthStateChange.listen((event) async {
        final session = event.session;

        if (session != null) {
          // ✅ User logged in
          currentUser.value = session.user;

          final profile = await _authService.getCurrentUser();
          if (profile != null) {
            _user.value = profile;
            _setState(AuthState.authenticated);
          }
        } else {
          // ✅ User logged out
          currentUser.value = null;
          _user.value = null;
          _setState(AuthState.unauthenticated);
        }
      });

      // ✅ No active session
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError("Auth initialization failed: $e");
    }
  }

  Future<bool> signUp({
    required String username,
    required String password,
    String? email,
  }) async {
    _setState(AuthState.loading);

    try {
      // 1️⃣ Step 1: Create user in Supabase Auth
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final authUser = authResponse.user;
      final session = authResponse.session;

      if (authUser == null || session == null) {
        _setError('User creation failed in Supabase Auth');
        return false;
      }

      debugPrint("✅ Auth user created: ${authUser.id}");

      // 2️⃣ Step 2: Create matching record in your custom 'users' table
      final userProfile = {
        'user_id': authUser.id,
        'email': email ?? '',
        'password_hash': password, // ⚠️ Store hashed in production
        'name': username,
        'avatar_url': '',
        'bio': '',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client
          .from('users')
          .insert(userProfile)
          .select()
          .maybeSingle();

      // 3️⃣ Step 3: Fetch the full user record from 'users' table
      final userResponse = await Supabase.instance.client
          .from('users')
          .select()
          .eq('user_id', authUser.id)
          .maybeSingle();

      if (userResponse == null) {
        _setError('User record not found in database');
        return false;
      }

      // 4️⃣ Step 4: Convert to UserModel
      final userModel = UserModel.fromJson(userResponse);

      // 5️⃣ Step 5: Store user in observable
      _user.value = userModel;

      // ✅ Automatically handled: Supabase persists the session internally
      _setState(AuthState.authenticated);

      debugPrint("✅ UserModel created: ${userModel.name}");
      return true;
    } on PostgrestException catch (e) {
      _setError('Database error: ${e.message}');
      return false;
    } on AuthException catch (e) {
      _setError('Auth error: ${e.message}');
      return false;
    } catch (e) {
      _setError('Sign up failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> signIn({
    required String mobileNo,
    required String password,
  }) async {
    _setState(AuthState.loading);

    try {
      // 🔹 Step 1: Sign in user with Supabase Auth
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: mobileNo, // You can replace with logic to detect email/phone
        password: password,
      );

      final session = response.session;
      final authUser = response.user;

      if (authUser != null && session != null) {
        debugPrint("✅ Logged in Auth user ID: ${authUser.id}");

        // 🔹 Step 2: Fetch your full user details from your custom 'users' table
        final userResponse = await Supabase.instance.client
            .from('users') // 👈 replace with your table name
            .select()
            .eq('user_id', authUser.id)
            .maybeSingle();

        if (userResponse == null) {
          _setError('User record not found in database');
          return false;
        }

        // 🔹 Step 3: Convert response JSON to your UserModel
        final userModel = UserModel.fromJson(userResponse);

        // 🔹 Step 4: Store in observable
        _user.value = userModel;

        // 🔹 Optional: Save session persistently (Supabase does this automatically)
        // await Supabase.instance.client.auth.persistSession(session.persistSessionString);

        _setState(AuthState.authenticated);
        debugPrint("✅ UserModel loaded: ${userModel.name}");
        return true;
      } else {
        _setError('Invalid credentials');
        return false;
      }
    } on AuthException catch (e) {
      debugPrint('⚠️ AuthException: ${e.message}');
      _setError('Authentication failed: ${e.message}');
      return false;
    } catch (e, stack) {
      debugPrint('❌ Unexpected error: $e');
      debugPrint('StackTrace: $stack');
      _setError('Unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<bool> loadUserProfile(String userId) async {
    try {
      final userResponse = await Supabase.instance.client
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (userResponse == null) {
        _setError("User record not found in database");
        return false;
      }

      final userModel = UserModel.fromJson(userResponse);

      _user.value = userModel;

      debugPrint("✅ User model loaded successfully: ${userModel.name}");
      return true;
    } catch (e) {
      debugPrint("❌ Error loading user profile: $e");
      _setError("Failed to load user details");
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      // 🔹 1. Supabase logout
      await Supabase.instance.client.auth.signOut();

      // 🔹 2. Clear SharedPrefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // ✅ deletes all locally stored data

      // 🔹 3. Clear user data in controller
      _user.value = null;
      currentUser.value = null;

      // 🔹 4. Reset auth state
      _setState(AuthState.unauthenticated);

      // 🔹 5. Delete all GetX controllers
      Get.deleteAll(force: true);

      return true; // ✅ logout success
    } catch (e) {
      debugPrint("Logout error: $e");
      return false;
    }
  }

  void clearError() {
    _errorMessage.value = null;
  }

  void _setState(AuthState newState) {
    _state.value = newState;
    if (newState != AuthState.error) {
      _errorMessage.value = null;
    }
  }

  void _setError(String error) {
    _errorMessage.value = error;
    _state.value = AuthState.error;
  }
}
