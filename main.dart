// Enhanced LearnLytics with Analytics, Gamification, Enhanced Features & Smart ML
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const LearnLyticsApp());
}

// --- 0. AUTHENTICATION SERVICE ---

class MockAuthService {
  final StreamController<bool> _controller = StreamController.broadcast();
  bool _isLoggedIn = false;

  Stream<bool> get authStateChanges => _controller.stream;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'test@test.com' && password == '123456') {
      _isLoggedIn = true;
      _controller.add(_isLoggedIn);
    } else {
      throw Exception("Invalid credentials. Try: test@test.com / 123456");
    }
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = false;
    _controller.add(_isLoggedIn);
  }

  void dispose() {
    _controller.close();
  }
}

// --- 1. DATA MODELS ---

class Course {
  final String id;
  final String name;
  final double progress;
  final DateTime lastActivity;
  final double predictedScore;
  final double studyHours;
  final double difficultyRating;
  final double previousAverage;
  final double anxietyLevel;
  final String notes; // NEW
  final DateTime createdAt; // NEW

  Course({
    required this.id,
    required this.name,
    required this.progress,
    required this.lastActivity,
    required this.predictedScore,
    required this.studyHours,
    required this.difficultyRating,
    required this.previousAverage,
    required this.anxietyLevel,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'progress': progress,
      'lastActivity': lastActivity.toIso8601String(),
      'predictedScore': predictedScore,
      'studyHours': studyHours,
      'difficultyRating': difficultyRating,
      'previousAverage': previousAverage,
      'anxietyLevel': anxietyLevel,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Course.fromMap(String id, Map<String, dynamic> data) {
    return Course(
      id: id,
      name: data['name'] ?? 'Untitled Course',
      progress: (data['progress'] as num?)?.toDouble() ?? 0.0,
      lastActivity: DateTime.tryParse(data['lastActivity'] ?? '') ?? DateTime.now(),
      predictedScore: (data['predictedScore'] as num?)?.toDouble() ?? 50.0,
      studyHours: (data['studyHours'] as num?)?.toDouble() ?? 0.0,
      difficultyRating: (data['difficultyRating'] as num?)?.toDouble() ?? 3.0,
      previousAverage: (data['previousAverage'] as num?)?.toDouble() ?? 70.0,
      anxietyLevel: (data['anxietyLevel'] as num?)?.toDouble() ?? 2.0,
      notes: data['notes'] ?? '',
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Course copyWith({
    String? name,
    double? progress,
    DateTime? lastActivity,
    double? predictedScore,
    double? studyHours,
    double? difficultyRating,
    double? previousAverage,
    double? anxietyLevel,
    String? notes,
  }) {
    return Course(
      id: id,
      name: name ?? this.name,
      progress: progress ?? this.progress,
      lastActivity: lastActivity ?? this.lastActivity,
      predictedScore: predictedScore ?? this.predictedScore,
      studyHours: studyHours ?? this.studyHours,
      difficultyRating: difficultyRating ?? this.difficultyRating,
      previousAverage: previousAverage ?? this.previousAverage,
      anxietyLevel: anxietyLevel ?? this.anxietyLevel,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

class StudySession {
  final String id;
  final String courseId;
  final double durationHours;
  final DateTime date;
  final String notes; // NEW
  final double focusRating; // NEW: 1-5 how focused were they

  StudySession({
    required this.id,
    required this.courseId,
    required this.durationHours,
    required this.date,
    this.notes = '',
    this.focusRating = 3.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'durationHours': durationHours,
      'date': date.toIso8601String(),
      'notes': notes,
      'focusRating': focusRating,
    };
  }

  factory StudySession.fromMap(String id, Map<String, dynamic> data) {
    return StudySession(
      id: id,
      courseId: data['courseId'] ?? '',
      durationHours: (data['durationHours'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      notes: data['notes'] ?? '',
      focusRating: (data['focusRating'] as num?)?.toDouble() ?? 3.0,
    );
  }
}

// NEW: Achievement Model
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'iconCode': icon.codePoint,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  factory Achievement.fromMap(String id, Map<String, dynamic> data) {
    return Achievement(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      icon: IconData(data['iconCode'] ?? Icons.star.codePoint, fontFamily: 'MaterialIcons'),
      unlockedAt: DateTime.tryParse(data['unlockedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// NEW: User Stats Model
class UserStats {
  final int totalStudyDays;
  final int currentStreak;
  final int longestStreak;
  final int totalXP;
  final int level;
  final double totalHours;
  final DateTime lastStudyDate;

  UserStats({
    this.totalStudyDays = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalXP = 0,
    this.level = 1,
    this.totalHours = 0.0,
    DateTime? lastStudyDate,
  }) : lastStudyDate = lastStudyDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'totalStudyDays': totalStudyDays,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalXP': totalXP,
      'level': level,
      'totalHours': totalHours,
      'lastStudyDate': lastStudyDate.toIso8601String(),
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> data) {
    return UserStats(
      totalStudyDays: data['totalStudyDays'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalXP: data['totalXP'] ?? 0,
      level: data['level'] ?? 1,
      totalHours: (data['totalHours'] as num?)?.toDouble() ?? 0.0,
      lastStudyDate: DateTime.tryParse(data['lastStudyDate'] ?? '') ?? DateTime.now(),
    );
  }

  UserStats copyWith({
    int? totalStudyDays,
    int? currentStreak,
    int? longestStreak,
    int? totalXP,
    int? level,
    double? totalHours,
    DateTime? lastStudyDate,
  }) {
    return UserStats(
      totalStudyDays: totalStudyDays ?? this.totalStudyDays,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalXP: totalXP ?? this.totalXP,
      level: level ?? this.level,
      totalHours: totalHours ?? this.totalHours,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }

  int get xpToNextLevel => level * 100;
  double get levelProgress => (totalXP % xpToNextLevel) / xpToNextLevel;
}

// --- 2. MOCK FIREBASE/FIRESTORE SERVICE ---

class MockFirestoreService {
  final Map<String, Map<String, Map<String, dynamic>>> _database = {
    'courses': {},
    'sessions': {},
    'achievements': {},
    'stats': {},
  };

  final StreamController<List<Course>> _courseController = StreamController.broadcast();
  final StreamController<List<StudySession>> _sessionController = StreamController.broadcast();
  final StreamController<List<Achievement>> _achievementController = StreamController.broadcast();
  final StreamController<UserStats> _statsController = StreamController.broadcast();

  MockFirestoreService() {
    _initializeData();
    // Emit initial data immediately
    Future.microtask(() => _notifyListeners());
  }

  void _initializeData() {
    final uuid = const Uuid();
    final courseId1 = uuid.v4();
    final courseId2 = uuid.v4();

    _database['courses']![courseId1] = Course(
      id: courseId1,
      name: 'Advanced Calculus',
      progress: 0.75,
      lastActivity: DateTime.now().subtract(const Duration(hours: 5)),
      predictedScore: 88.5,
      studyHours: 8.0,
      difficultyRating: 4.0,
      previousAverage: 85.0,
      anxietyLevel: 1.5,
      notes: 'Focus on integration techniques',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ).toMap();

    _database['courses']![courseId2] = Course(
      id: courseId2,
      name: 'World History',
      progress: 0.40,
      lastActivity: DateTime.now().subtract(const Duration(days: 2)),
      predictedScore: 65.2,
      studyHours: 3.0,
      difficultyRating: 2.0,
      previousAverage: 75.0,
      anxietyLevel: 3.0,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ).toMap();

    for (int i = 0; i < 7; i++) {
      if (i % 2 == 0) {
        _database['sessions']![uuid.v4()] = StudySession(
          id: uuid.v4(),
          courseId: courseId1,
          durationHours: 1.5 + Random().nextDouble() * 0.5,
          date: DateTime.now().subtract(Duration(days: i)),
          focusRating: 3.0 + Random().nextDouble() * 2.0,
        ).toMap();
      }
    }

    // Initialize user stats
    _database['stats']!['user'] = UserStats(
      totalStudyDays: 15,
      currentStreak: 3,
      longestStreak: 7,
      totalXP: 450,
      level: 4,
      totalHours: 25.5,
      lastStudyDate: DateTime.now().subtract(const Duration(days: 1)),
    ).toMap();

    _notifyListeners();
  }

  void _notifyListeners() {
    final courseList = _database['courses']!
        .entries
        .map((e) => Course.fromMap(e.key, e.value))
        .toList();
    courseList.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    _courseController.sink.add(courseList);

    final sessionList = _database['sessions']!
        .entries
        .map((e) => StudySession.fromMap(e.key, e.value))
        .toList();
    sessionList.sort((a, b) => b.date.compareTo(a.date));
    _sessionController.sink.add(sessionList);

    final achievementList = _database['achievements']!
        .entries
        .map((e) => Achievement.fromMap(e.key, e.value))
        .toList();
    achievementList.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    _achievementController.sink.add(achievementList);

    final statsData = _database['stats']!['user'];
    if (statsData != null) {
      _statsController.sink.add(UserStats.fromMap(statsData));
    }
  }

  Stream<List<Course>> get coursesStream => _courseController.stream;
  Stream<List<StudySession>> get sessionsStream => _sessionController.stream;
  Stream<List<Achievement>> get achievementsStream => _achievementController.stream;
  Stream<UserStats> get statsStream => _statsController.stream;

  Future<void> addCourse(Course course) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newId = course.id;
    _database['courses']![newId] = course.toMap();
    _notifyListeners();
    // Force an immediate emission
    await Future.delayed(const Duration(milliseconds: 100));
    _notifyListeners();
  }

  Future<void> updateCourse(Course course) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _database['courses']![course.id] = course.toMap();
    _notifyListeners();
  }

  Future<void> deleteCourse(String courseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _database['courses']!.remove(courseId);
    // Also delete related sessions
    _database['sessions']!.removeWhere((key, value) => value['courseId'] == courseId);
    _notifyListeners();
  }

  Future<void> addSession(StudySession session) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newId = const Uuid().v4();
    _database['sessions']![newId] = session.toMap();

    final courseMap = _database['courses']![session.courseId];
    if (courseMap != null) {
      final currentCourse = Course.fromMap(session.courseId, courseMap);
      final updatedCourse = currentCourse.copyWith(
        lastActivity: DateTime.now(),
        studyHours: currentCourse.studyHours + session.durationHours,
      );
      _database['courses']![session.courseId] = updatedCourse.toMap();
    }

    // Update user stats and check for achievements
    await _updateUserStats(session);
    await _checkAchievements();

    _notifyListeners();
  }

  Future<void> _updateUserStats(StudySession session) async {
    final statsData = _database['stats']!['user'];
    final currentStats = statsData != null ? UserStats.fromMap(statsData) : UserStats();

    final now = DateTime.now();
    final lastStudy = currentStats.lastStudyDate;
    final daysSinceLastStudy = now.difference(lastStudy).inDays;

    int newStreak = currentStats.currentStreak;
    if (daysSinceLastStudy == 0) {
      // Same day, maintain streak
      newStreak = currentStats.currentStreak;
    } else if (daysSinceLastStudy == 1) {
      // Next day, increment streak
      newStreak = currentStats.currentStreak + 1;
    } else {
      // Broke streak
      newStreak = 1;
    }

    final xpGained = (session.durationHours * 10 * session.focusRating).round();
    final newTotalXP = currentStats.totalXP + xpGained;
    final newLevel = (newTotalXP / 100).floor() + 1;

    final updatedStats = currentStats.copyWith(
      totalStudyDays: currentStats.totalStudyDays + (daysSinceLastStudy > 0 ? 1 : 0),
      currentStreak: newStreak,
      longestStreak: max(currentStats.longestStreak, newStreak),
      totalXP: newTotalXP,
      level: newLevel,
      totalHours: currentStats.totalHours + session.durationHours,
      lastStudyDate: now,
    );

    _database['stats']!['user'] = updatedStats.toMap();
  }

  Future<void> _checkAchievements() async {
    final statsData = _database['stats']!['user'];
    if (statsData == null) return;
    final stats = UserStats.fromMap(statsData);

    final achievements = <Achievement>[];

    // First Session
    if (stats.totalStudyDays == 1 && !_hasAchievement('first_session')) {
      achievements.add(Achievement(
        id: 'first_session',
        title: 'First Steps',
        description: 'Completed your first study session!',
        icon: Icons.celebration,
        unlockedAt: DateTime.now(),
      ));
    }

    // 7 Day Streak
    if (stats.currentStreak >= 7 && !_hasAchievement('week_warrior')) {
      achievements.add(Achievement(
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Maintained a 7-day study streak!',
        icon: Icons.local_fire_department,
        unlockedAt: DateTime.now(),
      ));
    }

    // Level 5
    if (stats.level >= 5 && !_hasAchievement('level_5')) {
      achievements.add(Achievement(
        id: 'level_5',
        title: 'Rising Star',
        description: 'Reached Level 5!',
        icon: Icons.star,
        unlockedAt: DateTime.now(),
      ));
    }

    // 20 Hours Total
    if (stats.totalHours >= 20 && !_hasAchievement('twenty_hours')) {
      achievements.add(Achievement(
        id: 'twenty_hours',
        title: 'Dedicated Learner',
        description: 'Studied for 20+ hours total!',
        icon: Icons.emoji_events,
        unlockedAt: DateTime.now(),
      ));
    }

    for (final achievement in achievements) {
      _database['achievements']![achievement.id] = achievement.toMap();
    }
  }

  bool _hasAchievement(String id) {
    return _database['achievements']!.containsKey(id);
  }

  void dispose() {
    _courseController.close();
    _sessionController.close();
    _achievementController.close();
    _statsController.close();
  }
}

// --- 3. STATE MANAGEMENT ---

class AuthProvider extends InheritedWidget {
  final MockAuthService service;
  const AuthProvider({super.key, required this.service, required super.child});
  static MockAuthService of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthProvider>()!.service;
  @override
  bool updateShouldNotify(AuthProvider oldWidget) => service != oldWidget.service;
}

class FirestoreProvider extends InheritedWidget {
  final MockFirestoreService service;
  const FirestoreProvider({super.key, required this.service, required super.child});
  static MockFirestoreService of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<FirestoreProvider>();
    if (provider == null) {
      throw FlutterError('No FirestoreProvider found in context.');
    }
    return provider.service;
  }
  @override
  bool updateShouldNotify(FirestoreProvider oldWidget) => service != oldWidget.service;
}

// --- 4. MAIN APPLICATION ---

class LearnLyticsApp extends StatefulWidget {
  const LearnLyticsApp({super.key});
  @override
  State<LearnLyticsApp> createState() => _LearnLyticsAppState();
}

class _LearnLyticsAppState extends State<LearnLyticsApp> {
  late final MockAuthService _authService;
  late final MockFirestoreService _mockService;

  @override
  void initState() {
    super.initState();
    _authService = MockAuthService();
    _mockService = MockFirestoreService();
  }

  @override
  void dispose() {
    _authService.dispose();
    _mockService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      service: _authService,
      child: FirestoreProvider(
        service: _mockService,
        child: MaterialApp(
          title: 'LearnLytics',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(secondary: Colors.amber),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey[50],
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              elevation: 4,
            ),
          ),
          home: StreamBuilder<bool>(
            stream: _authService.authStateChanges,
            initialData: _authService.isLoggedIn,
            builder: (context, snapshot) {
              final isLoggedIn = snapshot.data ?? false;
              if (isLoggedIn) {
                return const NavigationWrapper();
              } else {
                return const AuthScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}

// --- 5. AUTH SCREEN ---

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'test@test.com');
  final _passwordController = TextEditingController(text: '123456');
  bool _isLoading = false;
  bool _isSignUp = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authService = AuthProvider.of(context);

    try {
      if (_isSignUp) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Signup successful! Signing you in..."),
          backgroundColor: Colors.green,
        ));
        await Future.delayed(const Duration(milliseconds: 500));
      }
      await authService.signIn(_emailController.text, _passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Authentication Failed: ${e.toString().split(':').last}"),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.auto_graph, size: 80, color: Colors.indigo),
                const SizedBox(height: 10),
                Text(
                  'LearnLytics',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                      : Text(_isSignUp ? 'Sign Up' : 'Login',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUp = !_isSignUp;
                      _passwordController.clear();
                    });
                  },
                  child: Text(
                    _isSignUp ? 'Already have an account? Login' : "Don't have an account? Sign Up",
                    style: const TextStyle(color: Colors.indigo),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 6. NAVIGATION WRAPPER ---

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});
  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const PredictorScreen(),
    const StudyTrackerScreen(),
    const AnalyticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = AuthProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('LearnLytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.rocket_launch_outlined), label: 'Predictor'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Tracker'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// --- 7. PREDICTOR SCREEN (Enhanced) ---

class PredictorScreen extends StatefulWidget {
  const PredictorScreen({super.key});
  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _subjectName = '';
  double _studyHours = 5.0;
  double _progress = 0.5;
  double _previousAverage = 75.0;
  double _difficulty = 3.0;
  double _anxiety = 2.0;
  double? _predictedScore;
  bool _isLoading = false;
  String _notes = '';

  // Enhanced ML Prediction
  double _runPredictionModel() {
    const double baseScore = 50.0;
    const double weightStudyHours = 3.5;
    const double weightProgress = 30.0;
    const double weightPreviousAvg = 0.6;
    const double weightDifficulty = -4.0;
    const double weightAnxiety = -3.0;

    final scoreFromStudy = _studyHours * weightStudyHours;
    final scoreFromProgress = _progress * 100 * weightProgress / 100;
    final scoreFromDifficulty = _difficulty * weightDifficulty;
    final scoreFromPrevious = (_previousAverage - 50.0) * weightPreviousAvg / 50;
    final scoreFromAnxiety = _anxiety * weightAnxiety;

    double rawScore = baseScore + scoreFromStudy + scoreFromProgress +
        scoreFromPrevious + scoreFromDifficulty + scoreFromAnxiety;

    // Add efficiency bonus based on study hours and progress relationship
    if (_studyHours > 0 && _progress > 0.3) {
      final efficiencyBonus = (_progress * 100) / _studyHours;
      rawScore += efficiencyBonus * 0.5;
    }

    rawScore += (Random().nextDouble() - 0.5) * 5;
    return rawScore.clamp(0.0, 100.0);
  }

  void _predictAndSave() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _predictedScore = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    final score = _runPredictionModel();
    setState(() {
      _predictedScore = score;
      _isLoading = false;
    });

    final course = Course(
      id: const Uuid().v4(),
      name: _subjectName,
      progress: _progress,
      lastActivity: DateTime.now(),
      predictedScore: _predictedScore!,
      studyHours: _studyHours,
      difficultyRating: _difficulty,
      previousAverage: _previousAverage,
      anxietyLevel: _anxiety,
      notes: _notes,
    );

    final service = FirestoreProvider.of(context);
    await service.addCourse(course);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${course.name} tracked! Predicted: ${score.toStringAsFixed(1)}%'),
        backgroundColor: Colors.indigo,
      ),
    );

    setState(() {
      _predictedScore = null;
      _subjectName = '';
      _studyHours = 5.0;
      _progress = 0.5;
      _previousAverage = 75.0;
      _difficulty = 3.0;
      _anxiety = 2.0;
      _notes = '';
    });
    _formKey.currentState!.reset();
  }

  Widget _buildSliderInput({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    required int divisions,
    String suffix = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
            Text('${value.toStringAsFixed(divisions == 100 ? 0 : 1)}$suffix',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(divisions == 100 ? 0 : 1),
          onChanged: onChanged,
          activeColor: Colors.indigo,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text('Performance Predictor',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                prefixIcon: Icon(Icons.book),
              ),
              validator: (value) => value!.isEmpty ? 'Please enter a subject name.' : null,
              onSaved: (value) => _subjectName = value!,
              initialValue: _subjectName,
            ),
            const SizedBox(height: 20),
            _buildSliderInput(
              title: 'Weekly Study Hours (h)',
              value: _studyHours,
              onChanged: (v) => setState(() => _studyHours = v),
              min: 0.0,
              max: 20.0,
              divisions: 40,
              suffix: 'h',
            ),
            _buildSliderInput(
              title: 'Current Course Progress (%)',
              value: _progress * 100,
              onChanged: (v) => setState(() => _progress = v / 100),
              min: 0.0,
              max: 100.0,
              divisions: 100,
              suffix: '%',
            ),
            _buildSliderInput(
              title: 'Previous Grade Average (%)',
              value: _previousAverage,
              onChanged: (v) => setState(() => _previousAverage = v),
              min: 50.0,
              max: 100.0,
              divisions: 50,
              suffix: '%',
            ),
            _buildSliderInput(
              title: 'Perceived Subject Difficulty (1-5)',
              value: _difficulty,
              onChanged: (v) => setState(() => _difficulty = v),
              min: 1.0,
              max: 5.0,
              divisions: 40,
              suffix: '/5',
            ),
            _buildSliderInput(
              title: 'Exam Anxiety Level (1-5)',
              value: _anxiety,
              onChanged: (v) => setState(() => _anxiety = v),
              min: 1.0,
              max: 5.0,
              divisions: 40,
              suffix: '/5',
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
              onSaved: (value) => _notes = value ?? '',
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _predictAndSave,
              icon: _isLoading
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.rocket_launch),
              label: Text(_isLoading ? 'Calculating...' : 'Run Prediction & Track'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (_predictedScore != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ScoreCard(score: _predictedScore!),
              ),
          ],
        ),
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final double score;
  const ScoreCard({required this.score, super.key});

  @override
  Widget build(BuildContext context) {
    String message;
    MaterialColor colorSwatch;

    if (score >= 85) {
      message = 'Excellent Potential! Factors indicate strong mastery.';
      colorSwatch = Colors.green;
    } else if (score >= 70) {
      message = 'High Potential. Focus on optimization.';
      colorSwatch = Colors.lime;
    } else if (score >= 50) {
      message = 'Moderate Potential. Re-evaluate study strategies.';
      colorSwatch = Colors.amber;
    } else {
      message = 'Significant Risk. Immediate change is required.';
      colorSwatch = Colors.red;
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorSwatch.shade400, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Predicted Score',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 10),
            Text(score.toStringAsFixed(1),
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: colorSwatch.shade700)),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(colorSwatch),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 10),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.blueGrey)),
          ],
        ),
      ),
    );
  }
}

// --- 8. STUDY TRACKER SCREEN (Enhanced) ---

class StudyTrackerScreen extends StatefulWidget {
  const StudyTrackerScreen({super.key});
  @override
  State<StudyTrackerScreen> createState() => _StudyTrackerScreenState();
}

class _StudyTrackerScreenState extends State<StudyTrackerScreen> {
  String? _selectedCourseId;
  double _durationHours = 1.0;
  double _focusRating = 3.0;
  String _sessionNotes = '';
  bool _isLogging = false;

  void _logSession(List<Course> courses) async {
    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a course.')),
      );
      return;
    }

    setState(() => _isLogging = true);

    final newSession = StudySession(
      id: const Uuid().v4(),
      courseId: _selectedCourseId!,
      durationHours: _durationHours,
      date: DateTime.now(),
      notes: _sessionNotes,
      focusRating: _focusRating,
    );

    final service = FirestoreProvider.of(context);
    await service.addSession(newSession);

    setState(() {
      _isLogging = false;
      _sessionNotes = '';
      _focusRating = 3.0;
    });

    final xpGained = (_durationHours * 10 * _focusRating).round();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged ${_durationHours.toStringAsFixed(1)}h! +$xpGained XP earned! 🎉'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: FirestoreProvider.of(context).coursesStream,
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        if (courses.isNotEmpty && _selectedCourseId == null) {
          _selectedCourseId = courses.first.id;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Log New Study Session',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                      const Divider(height: 30),
                      DropdownButtonFormField<String>(
                        value: _selectedCourseId,
                        decoration: const InputDecoration(
                          labelText: 'Select Subject',
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          prefixIcon: Icon(Icons.class_outlined),
                        ),
                        items: courses.map((course) {
                          return DropdownMenuItem(value: course.id, child: Text(course.name));
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() => _selectedCourseId = newValue);
                        },
                        isExpanded: true,
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Duration',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                              Text('${_durationHours.toStringAsFixed(1)} hours',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                            ],
                          ),
                          Slider(
                            value: _durationHours,
                            min: 0.5,
                            max: 8.0,
                            divisions: 15,
                            label: _durationHours.toStringAsFixed(1),
                            onChanged: (v) => setState(() => _durationHours = v),
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Focus Level',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                              Text('${_focusRating.toStringAsFixed(1)}/5',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                            ],
                          ),
                          Slider(
                            value: _focusRating,
                            min: 1.0,
                            max: 5.0,
                            divisions: 40,
                            label: _focusRating.toStringAsFixed(1),
                            onChanged: (v) => setState(() => _focusRating = v),
                            activeColor: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Session Notes (Optional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 2,
                        onChanged: (value) => _sessionNotes = value,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _isLogging || courses.isEmpty ? null : () => _logSession(courses),
                        icon: _isLogging
                            ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(courses.isEmpty ? 'No Subjects to Log' : 'Log Study Session'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Study History
              StreamBuilder<List<StudySession>>(
                stream: FirestoreProvider.of(context).sessionsStream,
                builder: (context, sessionSnapshot) {
                  final sessions = sessionSnapshot.data ?? [];
                  if (sessions.isEmpty) return const SizedBox.shrink();

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Recent Sessions',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          const Divider(),
                          ...sessions.take(5).map((session) {
                            final course = courses.firstWhere((c) => c.id == session.courseId,
                                orElse: () => Course(
                                    id: '', name: 'Unknown', progress: 0, lastActivity: DateTime.now(),
                                    predictedScore: 0, studyHours: 0, difficultyRating: 0,
                                    previousAverage: 0, anxietyLevel: 0));
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: const Icon(Icons.check, color: Colors.green),
                              ),
                              title: Text(course.name),
                              subtitle: Text(
                                  '${session.durationHours.toStringAsFixed(1)}h • Focus: ${session.focusRating.toStringAsFixed(1)}/5'),
                              trailing: Text(
                                '${session.date.day}/${session.date.month}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- 9. ANALYTICS SCREEN (NEW) ---

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudySession>>(
      stream: FirestoreProvider.of(context).sessionsStream,
      builder: (context, sessionSnapshot) {
        final sessions = sessionSnapshot.data ?? [];

        return StreamBuilder<List<Course>>(
          stream: FirestoreProvider.of(context).coursesStream,
          builder: (context, courseSnapshot) {
            final courses = courseSnapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Analytics Dashboard',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 20),
                  _buildWeeklyChart(sessions),
                  const SizedBox(height: 20),
                  _buildStudyEfficiency(sessions),
                  const SizedBox(height: 20),
                  _buildCourseComparison(courses),
                  const SizedBox(height: 20),
                  _buildSmartRecommendations(courses, sessions),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyChart(List<StudySession> sessions) {
    final now = DateTime.now();
    final weekData = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final dayHours = sessions
          .where((s) => s.date.isAfter(dayStart) && s.date.isBefore(dayEnd))
          .fold(0.0, (sum, s) => sum + s.durationHours);
      return {'day': ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][day.weekday % 7], 'hours': dayHours};
    });

    final maxHours = weekData.fold(0.0, (max, d) => d['hours'] as double > max ? d['hours'] as double : max);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly Study Pattern',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekData.map((d) {
                final hours = d['hours'] as double;
                final height = maxHours > 0 ? (hours / maxHours) * 120 : 0.0;
                return Column(
                  children: [
                    Container(
                      width: 30,
                      height: height + 20,
                      decoration: BoxDecoration(
                        color: hours > 0 ? Colors.indigo : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          hours > 0 ? hours.toStringAsFixed(1) : '',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(d['day'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyEfficiency(List<StudySession> sessions) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    final avgFocus = sessions.fold(0.0, (sum, s) => sum + s.focusRating) / sessions.length;
    final totalHours = sessions.fold(0.0, (sum, s) => sum + s.durationHours);
    final avgSessionLength = totalHours / sessions.length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Study Efficiency Metrics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric('Avg Focus', '${avgFocus.toStringAsFixed(1)}/5', Icons.psychology, Colors.orange),
                _buildMetric('Avg Session', '${avgSessionLength.toStringAsFixed(1)}h', Icons.timer, Colors.green),
                _buildMetric('Sessions', '${sessions.length}', Icons.event_note, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCourseComparison(List<Course> courses) {
    if (courses.isEmpty) return const SizedBox.shrink();

    final sortedCourses = List<Course>.from(courses)..sort((a, b) => b.studyHours.compareTo(a.studyHours));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Study Time Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const Divider(height: 20),
            ...sortedCourses.take(5).map((course) {
              final maxHours = sortedCourses.first.studyHours;
              final percentage = (course.studyHours / maxHours * 100).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(course.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                        Text('${course.studyHours.toStringAsFixed(1)}h',
                            style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: course.studyHours / maxHours,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(Colors.indigo),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartRecommendations(List<Course> courses, List<StudySession> sessions) {
    final recommendations = <Map<String, dynamic>>[];

    // Find courses with low study time
    for (final course in courses) {
      if (course.studyHours < 5 && course.predictedScore < 75) {
        recommendations.add({
          'icon': Icons.warning_amber,
          'color': Colors.orange,
          'title': 'Increase study time for ${course.name}',
          'description': 'Only ${course.studyHours.toStringAsFixed(1)}h logged. Target: 10h+',
        });
      }
    }

    // Check for study consistency
    final last7Days = sessions.where((s) => s.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))).length;
    if (last7Days < 3) {
      recommendations.add({
        'icon': Icons.calendar_today,
        'color': Colors.blue,
        'title': 'Study more consistently',
        'description': 'Only $last7Days sessions this week. Aim for daily practice!',
      });
    }

    // Check focus levels
    final recentSessions = sessions.take(5).toList();
    if (recentSessions.isNotEmpty) {
      final avgRecentFocus = recentSessions.fold(0.0, (sum, s) => sum + s.focusRating) / recentSessions.length;
      if (avgRecentFocus < 3.0) {
        recommendations.add({
          'icon': Icons.psychology,
          'color': Colors.purple,
          'title': 'Improve focus quality',
          'description': 'Recent sessions avg ${avgRecentFocus.toStringAsFixed(1)}/5. Try the Pomodoro technique!',
        });
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add({
        'icon': Icons.thumb_up,
        'color': Colors.green,
        'title': 'Great job!',
        'description': 'Your study habits are on track. Keep up the excellent work!',
      });
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Smart Recommendations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const Divider(height: 20),
            ...recommendations.map((rec) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(rec['icon'] as IconData, color: rec['color'] as Color, size: 30),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rec['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(rec['description'] as String,
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

// --- 10. PROFILE SCREEN (NEW) ---

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserStats>(
      stream: FirestoreProvider.of(context).statsStream,
      builder: (context, statsSnapshot) {
        final stats = statsSnapshot.data ?? UserStats();

        return StreamBuilder<List<Achievement>>(
          stream: FirestoreProvider.of(context).achievementsStream,
          builder: (context, achievementSnapshot) {
            final achievements = achievementSnapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(context, stats),
                  const SizedBox(height: 20),
                  _buildStreakCard(stats),
                  const SizedBox(height: 20),
                  _buildAchievements(achievements),
                  const SizedBox(height: 20),
                  _buildStats(stats),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserStats stats) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade400, Colors.indigo.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                'L${stats.level}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Learner',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              'Level ${stats.level} Scholar',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${stats.totalXP} / ${stats.xpToNextLevel} XP',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(stats.levelProgress * 100).round()}%',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stats.levelProgress,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation(Colors.amber),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(UserStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStreakStat(
              Icons.local_fire_department,
              '${stats.currentStreak}',
              'Day Streak',
              Colors.orange,
            ),
            Container(width: 1, height: 50, color: Colors.grey.shade300),
            _buildStreakStat(
              Icons.star,
              '${stats.longestStreak}',
              'Best Streak',
              Colors.amber,
            ),
            Container(width: 1, height: 50, color: Colors.grey.shade300),
            _buildStreakStat(
              Icons.calendar_month,
              '${stats.totalStudyDays}',
              'Total Days',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStat(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 35, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAchievements(List<Achievement> achievements) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Achievements',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${achievements.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (achievements.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Start studying to unlock achievements!',
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: achievements.map((achievement) {
                  return Container(
                    width: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200, width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(achievement.icon, size: 40, color: Colors.amber.shade700),
                        const SizedBox(height: 8),
                        Text(
                          achievement.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(UserStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const Divider(height: 20),
            _buildStatRow(Icons.access_time, 'Total Study Time', '${stats.totalHours.toStringAsFixed(1)} hours'),
            _buildStatRow(Icons.trending_up, 'Total XP Earned', '${stats.totalXP} XP'),
            _buildStatRow(Icons.school, 'Current Level', 'Level ${stats.level}'),
            _buildStatRow(
              Icons.calendar_today,
              'Last Study Session',
              _formatDate(stats.lastStudyDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}

// --- 11. DASHBOARD SCREEN (Enhanced) ---

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Course>>(
      stream: FirestoreProvider.of(context).coursesStream,
      initialData: const [],
      builder: (context, courseSnapshot) {
        final courses = courseSnapshot.data ?? [];

        return StreamBuilder<List<StudySession>>(
          stream: FirestoreProvider.of(context).sessionsStream,
          initialData: const [],
          builder: (context, sessionSnapshot) {
            final sessions = sessionSnapshot.data ?? [];

            return StreamBuilder<UserStats>(
              stream: FirestoreProvider.of(context).statsStream,
              builder: (context, statsSnapshot) {
                final stats = statsSnapshot.data ?? UserStats();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickStats(stats),
                      const SizedBox(height: 20),
                      _buildOverallProgress(courses),
                      const SizedBox(height: 20),
                      _buildRecommendations(courses),
                      const SizedBox(height: 20),
                      _buildWeeklyStudyHours(sessions),
                      const SizedBox(height: 30),
                      Text(
                        'Tracked Subjects (${courses.length})',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      const Divider(color: Colors.indigo, thickness: 2, endIndent: 100),
                      const SizedBox(height: 10),
                      _buildSubjectList(context, courses),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildQuickStats(UserStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade300, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildQuickStatItem(Icons.local_fire_department, '${stats.currentStreak}', 'Streak', Colors.orange),
            _buildQuickStatItem(Icons.star, 'Lv ${stats.level}', 'Level', Colors.amber),
            _buildQuickStatItem(Icons.emoji_events, '${stats.totalXP}', 'XP', Colors.yellow),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatItem(IconData icon, String value, String label, Color iconColor) {
    return Column(
      children: [
        Icon(icon, size: 32, color: iconColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildOverallProgress(List<Course> courses) {
    final totalProgress =
        courses.fold(0.0, (sum, c) => sum + (c.progress * 100)) / (courses.isEmpty ? 1 : courses.length);
    final progressPercent = totalProgress.round();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Subject Progress', style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                Text(
                  '${progressPercent.toString()}%',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            ),
            SizedBox(
              height: 70,
              width: 70,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: totalProgress / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.indigo.shade100,
                    valueColor: const AlwaysStoppedAnimation(Colors.indigo),
                  ),
                  Center(
                      child: Text('${progressPercent.toString()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(List<Course> courses) {
    final lowScoreCourses = courses.where((c) => c.predictedScore < 75).toList()
      ..sort((a, b) => a.predictedScore.compareTo(b.predictedScore));

    if (lowScoreCourses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Great job! All subjects have a high predicted score (75%+).',
                style: TextStyle(color: Colors.green.shade800),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ Focus Areas (Predicted Score < 75%)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const Divider(color: Colors.red, height: 15),
            ...lowScoreCourses.take(3).map((c) {
              final priorityText = c.predictedScore < 60 ? 'HIGH PRIORITY' : 'Medium Priority';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Icon(c.predictedScore < 60 ? Icons.error : Icons.warning_amber, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${c.name}: $priorityText (${c.predictedScore.toStringAsFixed(1)}%)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            Text(
              'Consider logging more study hours and checking your progress for these subjects.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.red.shade800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStudyHours(List<StudySession> sessions) {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final weeklyHours = sessions.where((s) => s.date.isAfter(oneWeekAgo)).fold(0.0, (sum, s) => sum + s.durationHours);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Last 7 Days Study Time', style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${weeklyHours.toStringAsFixed(1)} h',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const Icon(Icons.timer, size: 40, color: Colors.indigo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectList(BuildContext context, List<Course> courses) {
    if (courses.isEmpty) {
      return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No subjects added yet. Go to the Predictor tab to start!'),
          ));
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: courses.length,
      itemBuilder: (context, i) {
        final c = courses[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: Icon(Icons.book, color: Colors.indigo.shade400),
            title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Predicted: ${c.predictedScore.toStringAsFixed(1)}% | Progress: ${(c.progress * 100).toStringAsFixed(0)}%'),
                Text('Last activity: ${c.lastActivity.day}/${c.lastActivity.month}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Total Hours', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  c.studyHours.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            onTap: () => _showCourseDetails(context, c),
          ),
        );
      },
    );
  }

  void _showCourseDetails(BuildContext context, Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CourseDetailsSheet(course: course),
    );
  }
}

// --- 12. COURSE DETAILS SHEET (NEW) ---

class CourseDetailsSheet extends StatefulWidget {
  final Course course;
  const CourseDetailsSheet({required this.course, super.key});

  @override
  State<CourseDetailsSheet> createState() => _CourseDetailsSheetState();
}

class _CourseDetailsSheetState extends State<CourseDetailsSheet> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late double _progress;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course.name);
    _notesController = TextEditingController(text: widget.course.notes);
    _progress = widget.course.progress;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final updatedCourse = widget.course.copyWith(
      name: _nameController.text,
      notes: _notesController.text,
      progress: _progress,
    );

    final service = FirestoreProvider.of(context);
    await service.updateCourse(updatedCourse);

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course updated!'), backgroundColor: Colors.green),
    );
  }

  void _deleteCourse() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course?'),
        content: Text('Are you sure you want to delete "${widget.course.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = FirestoreProvider.of(context);
      await service.deleteCourse(widget.course.id);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course deleted'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _isEditing
                        ? TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                    )
                        : Text(
                      widget.course.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_isEditing ? Icons.check : Icons.edit),
                    onPressed: _isEditing ? _saveChanges : () => setState(() => _isEditing = true),
                    color: Colors.indigo,
                  ),
                ],
              ),
              const Divider(height: 30),
              _buildDetailRow(Icons.rocket_launch, 'Predicted Score', '${widget.course.predictedScore.toStringAsFixed(1)}%'),
              _buildDetailRow(Icons.access_time, 'Total Study Hours', '${widget.course.studyHours.toStringAsFixed(1)} hours'),
              _buildDetailRow(Icons.calendar_today, 'Last Activity', _formatDate(widget.course.lastActivity)),
              _buildDetailRow(Icons.speed, 'Difficulty', '${widget.course.difficultyRating.toStringAsFixed(1)}/5'),
              _buildDetailRow(Icons.psychology, 'Anxiety Level', '${widget.course.anxietyLevel.toStringAsFixed(1)}/5'),
              const SizedBox(height: 20),
              const Text('Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (_isEditing)
                Slider(
                  value: _progress,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  label: '${(_progress * 100).round()}%',
                  onChanged: (v) => setState(() => _progress = v),
                  activeColor: Colors.indigo,
                )
              else
                LinearProgressIndicator(
                  value: widget.course.progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation(Colors.indigo),
                ),
              Text('${(_isEditing ? _progress * 100 : widget.course.progress * 100).round()}% complete',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              const Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (_isEditing)
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Add notes about this course...',
                  ),
                )
              else
                Text(
                  widget.course.notes.isEmpty ? 'No notes yet' : widget.course.notes,
                  style: TextStyle(color: widget.course.notes.isEmpty ? Colors.grey : Colors.black87),
                ),
              const SizedBox(height: 30),
              if (!_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _deleteCourse,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete Course'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
