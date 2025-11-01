// lib/screens/main_navigator.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import 'package:academic_predictor/screens/chat_screen.dart';
import 'package:academic_predictor/screens/dashboard_screen.dart';
import 'package:academic_predictor/screens/predictor_screen.dart';
import 'package:academic_predictor/services/auth_service.dart';
import 'study_mode_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  final _authService = AuthService();

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PredictorScreen(),
    const ChatScreen(),
    const StudyModeScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'New Prediction',
    'AI Assistant',
    'Study Mode',
  ];

  @override
  Widget build(BuildContext context) {
    // Access the theme notifier
    final themeNotifier = Provider.of<AppTheme>(context);
    final isDarkMode = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          // --- IMPROVEMENT 2: THEME TOGGLE BUTTON ---
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () {
              // Toggle theme
              if (isDarkMode) {
                themeNotifier.setThemeMode(ThemeMode.light);
              } else {
                themeNotifier.setThemeMode(ThemeMode.dark);
              }
            },
            tooltip: 'Toggle Theme',
          ),
          // --- END IMPROVEMENT ---
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate),
            label: 'Predict',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Study',
          ),
        ],
      ),
    );
  }
}
