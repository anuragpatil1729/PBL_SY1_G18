// This is a complete, runnable Flutter application built for the LearnLytics
// project. All data persistence logic (Firestore) is handled by the
// MockFirestoreService class, which simulates real-time streams and data
// operations to ensure the application architecture is correct and functional
// without relying on external Firebase packages that caused the build error.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Used for generating unique IDs (like Firestore doc IDs)

void main() {
  runApp(const LearnLyticsApp());
}

// --- 1. DATA MODELS ---

// Model for a tracked course or subject
class Course {
  final String id;
  final String name;
  final double progress; // 0.0 to 1.0
  final DateTime lastActivity;
  final double predictedScore; // 0.0 to 100.0
  final double studyHours;
  final double difficultyRating; // 1.0 to 5.0
  final double previousAverage;
  final double anxietyLevel; // 1.0 to 5.0

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
  });

  // Helper function to convert to a simplified Map for "database" storage
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
    };
  }

  // Helper function to create a Course from a "database" Map
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
    );
  }

  // Creates a copy of the Course with updated values
  Course copyWith({
    DateTime? lastActivity,
    double? predictedScore,
  }) {
    return Course(
      id: id,
      name: name,
      progress: progress,
      lastActivity: lastActivity ?? this.lastActivity,
      predictedScore: predictedScore ?? this.predictedScore,
      studyHours: studyHours,
      difficultyRating: difficultyRating,
      previousAverage: previousAverage,
      anxietyLevel: anxietyLevel,
    );
  }
}

// Model for a logged study session
class StudySession {
  final String id;
  final String courseId;
  final double durationHours;
  final DateTime date;

  StudySession({
    required this.id,
    required this.courseId,
    required this.durationHours,
    required this.date,
  });

  // Helper function to convert to a simplified Map for "database" storage
  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'durationHours': durationHours,
      'date': date.toIso8601String(),
    };
  }

  // Helper function to create a StudySession from a "database" Map
  factory StudySession.fromMap(String id, Map<String, dynamic> data) {
    return StudySession(
      id: id,
      courseId: data['courseId'] ?? '',
      durationHours: (data['durationHours'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
    );
  }
}

// --- 2. MOCK FIREBASE/FIRESTORE SERVICE ---

class MockFirestoreService {
  // Simulates a map of collections, where each collection is a map of documents.
  final Map<String, Map<String, Map<String, dynamic>>> _database = {
    'courses': {},
    'sessions': {},
  };

  // Stream controllers to mimic Firestore's real-time listeners
  final StreamController<List<Course>> _courseController = StreamController.broadcast();
  final StreamController<List<StudySession>> _sessionController = StreamController.broadcast();

  // Constructor with initial data for demonstration
  MockFirestoreService() {
    _initializeData();
  }

  void _initializeData() {
    final uuid = const Uuid();
    final courseId1 = uuid.v4();
    final courseId2 = uuid.v4();

    // Mock Courses
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
    ).toMap();

    // Mock Sessions (last 7 days)
    for (int i = 0; i < 7; i++) {
      if (i % 2 == 0) {
        _database['sessions']![uuid.v4()] = StudySession(
          id: uuid.v4(),
          courseId: courseId1,
          durationHours: 1.5 + Random().nextDouble() * 0.5,
          date: DateTime.now().subtract(Duration(days: i)),
        ).toMap();
      }
    }

    _notifyListeners();
  }

  // Notifies all active streams of changes
  void _notifyListeners() {
    // Courses
    final courseList = _database['courses']!
        .entries
        .map((e) => Course.fromMap(e.key, e.value))
        .toList();
    courseList.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    _courseController.sink.add(courseList);

    // Sessions
    final sessionList = _database['sessions']!
        .entries
        .map((e) => StudySession.fromMap(e.key, e.value))
        .toList();
    sessionList.sort((a, b) => b.date.compareTo(a.date));
    _sessionController.sink.add(sessionList);
  }

  // Public streams to mimic Firestore's real-time collection streams
  Stream<List<Course>> get coursesStream => _courseController.stream;
  Stream<List<StudySession>> get sessionsStream => _sessionController.stream;

  // Mock implementation of Firestore's addDoc
  Future<void> addCourse(Course course) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate latency
    final newId = const Uuid().v4();
    _database['courses']![newId] = course.toMap();
    _notifyListeners();
  }

  // Mock implementation of Firestore's updateDoc
  Future<void> updateCourse(Course course) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _database['courses']![course.id] = course.toMap();
    _notifyListeners();
  }

  // Mock implementation of Firestore's addDoc
  Future<void> addSession(StudySession session) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newId = const Uuid().v4();
    _database['sessions']![newId] = session.toMap();

    // Automatically update the lastActivity of the associated course
    final courseMap = _database['courses']![session.courseId];
    if (courseMap != null) {
      final updatedCourse = Course.fromMap(session.courseId, courseMap).copyWith(lastActivity: DateTime.now());
      _database['courses']![session.courseId] = updatedCourse.toMap();
    }

    _notifyListeners();
  }

  // Clean up resources
  void dispose() {
    _courseController.close();
    _sessionController.close();
  }
}

// --- 3. STATE MANAGEMENT (InheritedWidget for simplicity) ---

class FirestoreProvider extends InheritedWidget {
  final MockFirestoreService service;

  const FirestoreProvider({
    super.key,
    required this.service,
    required super.child,
  });

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

// --- 4. MAIN APPLICATION WIDGET ---

class LearnLyticsApp extends StatefulWidget {
  const LearnLyticsApp({super.key});

  @override
  State<LearnLyticsApp> createState() => _LearnLyticsAppState();
}

class _LearnLyticsAppState extends State<LearnLyticsApp> {
  late final MockFirestoreService _mockService;

  @override
  void initState() {
    super.initState();
    // Initialize the mock service when the app starts
    _mockService = MockFirestoreService();
  }

  @override
  void dispose() {
    // Dispose the mock service streams when the app closes
    _mockService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FirestoreProvider(
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
        home: const NavigationWrapper(),
      ),
    );
  }
}

// --- 5. NAVIGATION AND SHELL WIDGET ---

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch_outlined),
            label: 'Predictor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Tracker',
          ),
        ],
      ),
    );
  }
}

// --- 6. PREDICTOR SCREEN (Screen 2) ---

class PredictorScreen extends StatefulWidget {
  const PredictorScreen({super.key});

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  final _formKey = GlobalKey<FormState>();
  String _subjectName = '';
  double _studyHours = 5.0;
  double _progress = 0.5; // Stored as 0.0 to 1.0
  double _previousAverage = 75.0;
  double _difficulty = 3.0;
  double _anxiety = 2.0;
  double? _predictedScore;
  bool _isLoading = false;

  // ML Prediction Logic (ported from the original request)
  double _runPredictionModel() {
    const double baseScore = 50.0;
    const double weightStudyHours = 3.0;
    const double weightProgress = 25.0; // Since progress is 0-1
    const double weightPreviousAvg = 0.5;
    const double weightDifficulty = -5.0;
    const double weightAnxiety = -2.5;

    final scoreFromStudy = _studyHours * weightStudyHours;
    final scoreFromProgress = _progress * 100 * weightProgress / 100; // Progress * 25
    final scoreFromDifficulty = _difficulty * weightDifficulty;
    final scoreFromPrevious = (_previousAverage - 50.0) * weightPreviousAvg / 50; // Simple normalization around 50
    final scoreFromAnxiety = _anxiety * weightAnxiety;

    double rawScore = baseScore + scoreFromStudy + scoreFromProgress + scoreFromPrevious + scoreFromDifficulty + scoreFromAnxiety;

    // Add small random noise for realism
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

    // 1. Run Prediction
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate computation
    final score = _runPredictionModel();
    setState(() {
      _predictedScore = score;
      _isLoading = false;
    });

    // 2. Save Course
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
    );

    // Save using the mock service
    final service = FirestoreProvider.of(context);
    await service.addCourse(course);

    // Show a notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${course.name} tracked! Predicted Score: ${score.toStringAsFixed(1)}%'),
        backgroundColor: Colors.indigo,
      ),
    );

    // Reset prediction for next use
    setState(() {
      _predictedScore = null;
      _subjectName = '';
    });
    _formKey.currentState!.reset();
  }

  // Helper widget for slider inputs
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
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey),
            ),
            Text(
              '${value.toStringAsFixed(divisions == 100 ? 0 : 1)}$suffix',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Predictor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Subject Name Input
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

              // Sliders
              _buildSliderInput(
                title: 'Weekly Study Hours (h)',
                value: _studyHours,
                onChanged: (v) => setState(() => _studyHours = v),
                min: 0.0, max: 20.0, divisions: 40, suffix: 'h',
              ),
              _buildSliderInput(
                title: 'Current Course Progress (%)',
                value: _progress * 100,
                onChanged: (v) => setState(() => _progress = v / 100),
                min: 0.0, max: 100.0, divisions: 100, suffix: '%',
              ),
              _buildSliderInput(
                title: 'Previous Grade Average (%)',
                value: _previousAverage,
                onChanged: (v) => setState(() => _previousAverage = v),
                min: 50.0, max: 100.0, divisions: 50, suffix: '%',
              ),
              _buildSliderInput(
                title: 'Perceived Subject Difficulty (1-5)',
                value: _difficulty,
                onChanged: (v) => setState(() => _difficulty = v),
                min: 1.0, max: 5.0, divisions: 40, suffix: '/5',
              ),
              _buildSliderInput(
                title: 'Exam Anxiety Level (1-5)',
                value: _anxiety,
                onChanged: (v) => setState(() => _anxiety = v),
                min: 1.0, max: 5.0, divisions: 40, suffix: '/5',
              ),
              const SizedBox(height: 30),

              // Prediction Button
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

              // Predicted Score Display
              if (_predictedScore != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ScoreCard(score: _predictedScore!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widget for displaying the predicted score
class ScoreCard extends StatelessWidget {
  final double score;

  const ScoreCard({required this.score, super.key});

  @override
  Widget build(BuildContext context) {
    String message;
    MaterialColor colorSwatch; // Use MaterialColor

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
        // FIX: Use colorSwatch.shade400 instead of color.shade400
        side: BorderSide(color: colorSwatch.shade400, width: 4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Predicted Score',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                // FIX: Use colorSwatch.shade700 instead of color.shade700
                color: colorSwatch.shade700,
              ),
            ),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[200],
              // FIX: Use colorSwatch here, which is of type MaterialColor
              valueColor: AlwaysStoppedAnimation<Color>(colorSwatch),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 7. STUDY TRACKER SCREEN (Screen 3) ---

class StudyTrackerScreen extends StatefulWidget {
  const StudyTrackerScreen({super.key});

  @override
  State<StudyTrackerScreen> createState() => _StudyTrackerScreenState();
}

class _StudyTrackerScreenState extends State<StudyTrackerScreen> {
  String? _selectedCourseId;
  double _durationHours = 1.0;
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
    );

    final service = FirestoreProvider.of(context);
    await service.addSession(newSession);

    setState(() => _isLogging = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully logged ${_durationHours.toStringAsFixed(1)} hours!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to changes in the courses list
    return StreamBuilder<List<Course>>(
      stream: FirestoreProvider.of(context).coursesStream,
      builder: (context, snapshot) {
        final courses = snapshot.data ?? [];
        if (courses.isNotEmpty && _selectedCourseId == null) {
          _selectedCourseId = courses.first.id;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Study Tracker')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Log New Study Session',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const Divider(height: 30),

                    // Course Selector
                    DropdownButtonFormField<String>(
                      value: _selectedCourseId,
                      decoration: const InputDecoration(
                        labelText: 'Select Subject',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                        prefixIcon: Icon(Icons.class_outlined),
                      ),
                      items: courses.map((course) {
                        return DropdownMenuItem(
                          value: course.id,
                          child: Text(course.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() => _selectedCourseId = newValue);
                      },
                      validator: (value) => value == null ? 'Please select a subject.' : null,
                      isExpanded: true,
                    ),
                    const SizedBox(height: 20),

                    // Duration Slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Duration',
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey),
                            ),
                            Text(
                              '${_durationHours.toStringAsFixed(1)} hours',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                            ),
                          ],
                        ),
                        Slider(
                          value: _durationHours,
                          min: 0.5,
                          max: 8.0,
                          divisions: 15, // Half-hour increments
                          label: _durationHours.toStringAsFixed(1),
                          onChanged: (v) => setState(() => _durationHours = v),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Log Button
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
          ),
        );
      },
    );
  }
}

// --- 8. DASHBOARD SCREEN (Screen 1) ---

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilders listen to data streams and rebuild when data changes
    return StreamBuilder<List<Course>>(
      stream: FirestoreProvider.of(context).coursesStream,
      builder: (context, courseSnapshot) {
        final courses = courseSnapshot.data ?? [];

        return StreamBuilder<List<StudySession>>(
          stream: FirestoreProvider.of(context).sessionsStream,
          builder: (context, sessionSnapshot) {
            final sessions = sessionSnapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(title: const Text('Dashboard')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Progress Header
                    _buildOverallProgress(courses),
                    const SizedBox(height: 20),

                    // Recommendations/Focus Areas
                    _buildRecommendations(courses),
                    const SizedBox(height: 20),

                    // Weekly Study Hours (Simplified)
                    _buildWeeklyStudyHours(sessions),
                    const SizedBox(height: 30),

                    // Tracked Subjects List
                    Text(
                      'Tracked Subjects (${courses.length})',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const Divider(color: Colors.indigo, thickness: 2, endIndent: 100),
                    const SizedBox(height: 10),
                    _buildSubjectList(courses),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverallProgress(List<Course> courses) {
    final totalProgress = courses.fold(0.0, (sum, c) => sum + (c.progress * 100)) / (courses.length == 0 ? 1 : courses.length);
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
                  '$progressPercent%',
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
                  Center(child: Text('$progressPercent%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(List<Course> courses) {
    final lowScoreCourses = courses
        .where((c) => c.predictedScore < 75)
        .toList()
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ Priority Focus Areas (${lowScoreCourses.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
            ),
            const Divider(color: Colors.red, thickness: 1, endIndent: 150),
            ...lowScoreCourses.take(3).map((course) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '• ${course.name} (${course.predictedScore.toStringAsFixed(0)}%): Increase study hours or manage anxiety.',
                style: TextStyle(color: Colors.red.shade600),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyStudyHours(List<StudySession> sessions) {
    // Calculate total hours logged in the last 7 days
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final weeklyHours = sessions
        .where((s) => s.date.isAfter(sevenDaysAgo))
        .fold(0.0, (sum, s) => sum + s.durationHours);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Study Hours Logged',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 8),
            Text(
              '${weeklyHours.toStringAsFixed(1)} hours',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.green),
            ),
            const SizedBox(height: 4),
            Text(
              'Logged in the last 7 days.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectList(List<Course> courses) {
    if (courses.isEmpty) {
      return const Center(
        child: Text(
          'No subjects tracked yet. Use the Predictor to add one!',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final scoreColor = course.predictedScore >= 80 ? Colors.green.shade700 : (course.predictedScore >= 60 ? Colors.amber.shade700 : Colors.red.shade700);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: Icon(Icons.book_outlined, color: Colors.indigo.shade400),
            title: Text(
              course.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Progress: ${(course.progress * 100).round()}% | Last Active: ${course.lastActivity.day}/${course.lastActivity.month}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${course.predictedScore.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: scoreColor),
                ),
                const Text('Score', style: TextStyle(fontSize: 10)),
              ],
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildDetailRow('Study Hours (Model)', '${course.studyHours.toStringAsFixed(1)} h/week'),
                    _buildDetailRow('Difficulty Rating', '${course.difficultyRating.toStringAsFixed(1)}/5'),
                    _buildDetailRow('Anxiety Level', '${course.anxietyLevel.toStringAsFixed(1)}/5'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
