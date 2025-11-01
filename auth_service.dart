// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // A helper to get the Supabase client instance.
  final SupabaseClient _supabase = Supabase.instance.client;

  // Stream to listen for auth changes (user logged in or out).
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign In with Email & Password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // Sign Up with Email & Password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // You can add email confirmation in your Supabase project settings
    await _supabase.auth.signUp(email: email, password: password);
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
