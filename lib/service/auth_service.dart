import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  /// Sign up with email & password. Returns error message on failure or null on success.
  static Future<String?> signUp(String email, String password) async {
    try {
      print('[AuthService] signUp -> email: $email');
      final res = await _client.auth.signUp(email: email, password: password);
      print('[AuthService] signUp response: user=${res.user}, session=${res.session}');
      // if user is null, an email confirmation might be required depending on Supabase settings
      return null; // success (may require email confirmation depending on Supabase settings)
    } on AuthException catch (e) {
      print('[AuthService] signUp error: ${e.message}');
      return e.message;
    } catch (e) {
      print('[AuthService] signUp exception: $e');
      return e.toString();
    }
  }

  /// Sign in with email & password. Returns error message on failure or null on success.
  static Future<String?> signIn(String email, String password) async {
    try {
      print('[AuthService] signIn -> email: $email');
      final res = await _client.auth.signInWithPassword(email: email, password: password);
      print('[AuthService] signIn response: session=${res.session}, user=${res.user}');
      return null;
    } on AuthException catch (e) {
      print('[AuthService] signIn error: ${e.message}');
      return e.message;
    } catch (e) {
      print('[AuthService] signIn exception: $e');
      return e.toString();
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Current user
  static User? get currentUser => _client.auth.currentUser;

  /// Debug helper: prints current user info to console
  static void debugPrintCurrentUser() {
    final u = currentUser;
    if (u == null) {
      print('[AuthService] currentUser: null');
    } else {
      print('[AuthService] currentUser id=${u.id}, email=${u.email}, aud=${u.aud}');
    }
  }

  /// Listen to auth changes
  /// Subscribe to auth state changes. Returns a [StreamSubscription] you can cancel.
  static StreamSubscription onAuthStateChange(Function(Session?) callback) {
    return _client.auth.onAuthStateChange.listen((data) {
      callback(data.session);
    });
  }
}
