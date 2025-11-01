// lib/screens/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academic_predictor/screens/login_screen.dart';
import 'package:academic_predictor/screens/main_navigator.dart'; // <-- MODIFIED

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // A stream builder that listens to authentication state changes.
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Just a simple check to see if we're waiting for the first auth event.
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;

        // If the user has a session (is logged in), show the main app.
        if (session != null) {
          return const MainNavigator(); // <-- MODIFIED
        }
        // Otherwise, show the login screen.
        else {
          return const LoginScreen();
        }
      },
    );
  }
}
