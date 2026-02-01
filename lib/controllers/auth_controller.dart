import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bindings/app_binding.dart';
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
      final session = supabase.auth.currentSession;

      if (session != null) {
        currentUser.value = session.user;

        final profile = await _authService.getCurrentUser();
        if (profile != null) {
          _user.value = profile;
          _setState(AuthState.authenticated);
          return;
        } else {
          // ✅ If user logged in via Google and not found → create user
          final newUser = await _authService.handleUserAfterOAuth();
          if (newUser != null) {
            _user.value = newUser;
            _setState(AuthState.authenticated);
            return;
          }
        }
      }

      // ✅ Listen for auth changes
      supabase.auth.onAuthStateChange.listen((event) async {
        final session = event.session;

        if (session != null) {
          currentUser.value = session.user;

          // Check if user exists in DB
          final profile = await _authService.getCurrentUser();
          if (profile != null) {
            _user.value = profile;
            _setState(AuthState.authenticated);
          } else {
            // ✅ Create if not found (Google login case)
            final newUser = await _authService.handleUserAfterOAuth();
            if (newUser != null) {
              _user.value = newUser;
              _setState(AuthState.authenticated);
            }
          }
        } else {
          currentUser.value = null;
          _user.value = null;
          _setState(AuthState.unauthenticated);
        }
      });

      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError("Auth initialization failed: $e");
    }
  }

  Future<bool> signInWithGoogle() async {
    _setState(AuthState.loading);

    try {
      // 🔹 Step 1: Trigger Google OAuth
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.klektion.klektion://login-callback/',
      );

      // Note: After redirect Google → back to app,
      // Supabase automatically restores session.

      // 🔹 Step 2: Get updated session
      final session =
          Supabase.instance.client.auth.currentSession; // v2.x correct method
      final authUser = session?.user;

      if (authUser == null) {
        _setError("Google Sign-In failed: No user session restored");
        return false;
      }

      debugPrint("✅ Google Auth User: ${authUser.id}");

      // 🔹 Step 3: Fetch or Create User Profile
      final userResponse = await Supabase.instance.client
          .from('users')
          .select()
          .eq('user_id', authUser.id)
          .maybeSingle();

      UserModel userModel;

      if (userResponse == null) {
        // 🔹 Step 4: If first-time login → insert new record
        final newUser = {
          'user_id': authUser.id,
          'email': authUser.email ?? '',
          'user_name': authUser.userMetadata?['user_name'] ?? '',
          'name': authUser.userMetadata?['full_name'] ?? '',
          'avatar_url': authUser.userMetadata?['avatar_url'] ?? '',
          'password_hash': '',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        final inserted = await Supabase.instance.client
            .from('users')
            .insert(newUser)
            .select()
            .single();

        userModel = UserModel.fromJson(inserted);
        debugPrint("🆕 New Google user created in DB");
      } else {
        userModel = UserModel.fromJson(userResponse);
        debugPrint("🔁 Existing Google user found");
      }

      // 🔹 Step 5: Save user model in your controller
      _user.value = userModel;

      // 🔹 Step 6: Set auth state
      _setState(AuthState.authenticated);

      debugPrint("🎉 Google login completed for: ${userModel.name}");

      return true;
    } catch (e, stack) {
      debugPrint("❌ Google Sign-In error: $e");
      debugPrint("📌 Stack: $stack");

      _setError("Google Sign-In failed. Please try again.");
      return false;
    }
  }

  Future<bool> signUp({
    required String userNameUser,

    required String username,
    required String password,
    String? email,
  }) async {
    _setState(AuthState.loading);

    try {
      // 1️⃣ Create user in Supabase Auth
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

      // 2️⃣ Hash password using bcrypt BEFORE storing
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // 3️⃣ Store user profile in your custom 'users' table
      final userProfile = {
        'user_id': authUser.id,
        'email': email ?? '',
        'password_hash': hashedPassword, // 🔥 SAFE HASHED VALUE
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

      // 4️⃣ Fetch user model
      final userResponse = await Supabase.instance.client
          .from('users')
          .select()
          .eq('user_id', authUser.id)
          .maybeSingle();

      if (userResponse == null) {
        _setError('User record not found in database');
        return false;
      }

      final userModel = UserModel.fromJson(userResponse);
      _user.value = userModel;

      _setState(AuthState.authenticated);

      debugPrint("✅ UserModel created: ${userModel.name}");
      return true;
    } catch (e) {
      _setError('Sign up failed: $e');
      return false;
    }
  }

  bool verifyPassword(String password, String hashed) {
    return BCrypt.checkpw(password, hashed);
  }

  Future<bool> signIn({
    required String mobileNo,
    required String password,
  }) async {
    _setState(AuthState.loading);

    try {
      // 🔹 Step 1: Sign in user with Supabase Auth

      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
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
      // debugPrint('⚠️ AuthException: ${e.message}');
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
      AppBindings().dependencies();

      return true; // ✅ logout success
    } catch (e) {
      debugPrint("Logout error: $e");
      return false;
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return false;
      }

      // 1️⃣ Fetch user record from DB
      final record = await supabase
          .from('users')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (record == null) {
        Get.snackbar("Error", "User profile not found");
        return false;
      }

      final storedHashedPassword = record['password_hash'];
      print(BCrypt.hashpw(oldPassword, BCrypt.gensalt()));

      // 2️⃣ Verify old password
      final isCorrect = BCrypt.checkpw(oldPassword, storedHashedPassword);

      if (!isCorrect) {
        Get.snackbar("Error", "Old password is incorrect");
        return false;
      }

      // 3️⃣ Update Supabase Auth password
      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      // 4️⃣ Hash new password
      final newHashedPassword = BCrypt.hashpw(
        newPassword,
        BCrypt.gensalt(), // <-- auto generates a proper salt
      );

      // 5️⃣ Update users table password
      await supabase
          .from('users')
          .update({
            'password_hash': newHashedPassword,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id);

      Get.snackbar("Success", "Password updated successfully");
      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to update password: $e");
      return false;
    }
  }

  Future<void> reloadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final record = await supabase
        .from('users')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (record != null) {
      _user.value = UserModel.fromJson(record);
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String bio,
    XFile? avatarFile,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return false;
      }

      String? uploadedAvatarUrl;

      // 1️⃣ Upload avatar (with compression)
      if (avatarFile != null) {
        // 🔥 Compress image
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          avatarFile.path,
          quality: 60,
          minWidth: 1080,
          minHeight: 1080,
          format: CompressFormat.jpeg,
        );

        if (compressedBytes == null) {
          Get.snackbar("Error", "Image compression failed");
          return false;
        }

        // 🔥 Always use jpg after compression
        final fileName = "${user.id}/avatar.jpg";

        await supabase.storage
            .from("avatars")
            .uploadBinary(
              fileName,
              compressedBytes,
              fileOptions: const FileOptions(
                contentType: "image/jpeg",
                upsert: true,
              ),
            );

        uploadedAvatarUrl = supabase.storage
            .from("avatars")
            .getPublicUrl(fileName);
      }

      // 2️⃣ Update user table
      final Map<String, dynamic> updateData = {
        "name": name,
        "bio": bio,
        "updated_at": DateTime.now().toIso8601String(),
      };

      if (uploadedAvatarUrl != null) {
        updateData["avatar_url"] = uploadedAvatarUrl;
      }

      await supabase.from("users").update(updateData).eq("user_id", user.id);

      return true;
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e");
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
