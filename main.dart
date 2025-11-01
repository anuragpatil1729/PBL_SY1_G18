// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:academic_predictor/screens/auth_gate.dart';
import 'package:academic_predictor/app_theme.dart';

// main() function remains the same...
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pkiqcnvemragneyofiim.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBraXFjbnZlbXJhZ25leW9maWltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MDU2MjEsImV4cCI6MjA3NzQ4MTYyMX0.frqDgqrTvb43RW68fI3K5thviQ0ULjYvGAFwVZOfZjg',
  );

  runApp(
    ChangeNotifierProvider(create: (_) => AppTheme(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We only need the notifier for the DYNAMIC value (themeMode)
    final themeNotifier = Provider.of<AppTheme>(context);

    return MaterialApp(
      title: 'Academic Predictor',

      // --- FIX ---
      // Access the static themes directly from the class
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // This is an instance member, so this is correct
      themeMode: themeNotifier.themeMode,

      // --- END FIX ---
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
