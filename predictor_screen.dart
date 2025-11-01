// lib/screens/predictor_screen.dart
import 'package:flutter/material.dart';
import '../services/ml_service.dart';
import '../services/supabase_service.dart';
import '../models/prediction.dart';
import '../services/ai_service.dart';

class PredictorScreen extends StatefulWidget {
  const PredictorScreen({super.key});

  @override
  State<PredictorScreen> createState() => _PredictorScreenState();
}

class _PredictorScreenState extends State<PredictorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mlService = MLService();
  final _subjectController = TextEditingController();
  final _supabaseService = SupabaseService();
  final _aiService = AIService();

  bool _isLoading = false;
  String _loadingMessage = 'Calculating Score...';

  // Form Default Values
  double _attendance = 80.0;
  double _assignments = 75.0;
  double _quizzes = 70.0;
  double _midterm = 65.0;
  double _studyHours = 5.0;
  double _project = 70.0;
  double _gpa = 3.0;
  int _participation = 3;
  int _confidence = 3;
  int _difficulty = 3;

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _submitPrediction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Calculating Score...';
    });

    try {
      // 1. Calculate Score
      final double score = _mlService.calculateScore(
        attendancePercent: _attendance,
        assignmentAvg: _assignments,
        quizAvg: _quizzes,
        midtermScore: _midterm,
        studyHoursWeekly: _studyHours,
        projectScore: _project,
        participationLevel: _participation,
        previousGpa: _gpa,
        confidenceLevel: _confidence,
        courseDifficulty: _difficulty,
      );

      // 2. Create temp Prediction for AI
      Prediction tempPrediction = Prediction(
        subjectName: _subjectController.text.trim(),
        predictedScore: score,
        attendancePercent: _attendance,
        assignmentAvg: _assignments,
        quizAvg: _quizzes,
        midtermScore: _midterm,
        studyHoursWeekly: _studyHours,
        projectScore: _project,
        participationLevel: _participation,
        previousGpa: _gpa,
        confidenceLevel: _confidence,
        courseDifficulty: _difficulty,
      );

      // 3. Get AI Suggestions
      setState(() {
        _loadingMessage = 'Getting AI Suggestions...';
      });
      final aiSuggestions = await _aiService.getAcademicSuggestions(
        prediction: tempPrediction,
      );

      // 4. Create final Prediction
      final finalPrediction = Prediction(
        subjectName: _subjectController.text.trim(),
        predictedScore: score,
        aiSuggestions: aiSuggestions,
        attendancePercent: _attendance,
        assignmentAvg: _assignments,
        quizAvg: _quizzes,
        midtermScore: _midterm,
        studyHoursWeekly: _studyHours,
        projectScore: _project,
        participationLevel: _participation,
        previousGpa: _gpa,
        confidenceLevel: _confidence,
        courseDifficulty: _difficulty,
      );

      // 5. Save to Supabase
      setState(() {
        _loadingMessage = 'Saving Prediction...';
      });
      await _supabaseService.addPrediction(finalPrediction);

      // 6. Show Success
      final message =
          'Saved! Predicted Score for ${_subjectController.text}: ${score.toStringAsFixed(1)}%';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      }

      // Clear form
      _formKey.currentState?.reset();
      _subjectController.clear();
      setState(() {
        _attendance = 80.0;
        _assignments = 75.0;
        _quizzes = 70.0;
        _midterm = 65.0;
        _studyHours = 5.0;
        _project = 70.0;
        _gpa = 3.0;
        _participation = 3;
        _confidence = 3;
        _difficulty = 3;
      });
    } catch (e) {
      // 7. Show Error
      final message = 'Error: ${e.toString()}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      // 8. Stop loading
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              _loadingMessage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    // --- IMPROVEMENT 4: WRAP FORM IN A CARD ---
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'New Performance Prediction',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Please enter a subject'
                      : null,
                ),
                const SizedBox(height: 20),

                // --- 10 Factor Sliders ---
                _buildSlider(
                  title: 'Attendance',
                  value: _attendance,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  labelSuffix: '%',
                  onChanged: (val) => setState(() => _attendance = val),
                ),
                _buildSlider(
                  title: 'Assignment Average',
                  value: _assignments,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  labelSuffix: '%',
                  onChanged: (val) => setState(() => _assignments = val),
                ),
                _buildSlider(
                  title: 'Quiz Average',
                  value: _quizzes,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  labelSuffix: '%',
                  onChanged: (val) => setState(() => _quizzes = val),
                ),
                _buildSlider(
                  title: 'Midterm Score',
                  value: _midterm,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  labelSuffix: '%',
                  onChanged: (val) => setState(() => _midterm = val),
                ),
                _buildSlider(
                  title: 'Project Score',
                  value: _project,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  labelSuffix: '%',
                  onChanged: (val) => setState(() => _project = val),
                ),
                _buildSlider(
                  title: 'Weekly Study Hours',
                  value: _studyHours,
                  min: 0,
                  max: 20,
                  divisions: 20,
                  labelSuffix: ' hrs',
                  onChanged: (val) => setState(() => _studyHours = val),
                ),
                _buildSlider(
                  title: 'Previous GPA',
                  value: _gpa,
                  min: 0.0,
                  max: 4.0,
                  divisions: 40,
                  labelSuffix: '',
                  onChanged: (val) => setState(() => _gpa = val),
                ),
                _buildSlider(
                  title: 'Participation Level',
                  value: _participation.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  labelSuffix: ' / 5',
                  onChanged: (val) =>
                      setState(() => _participation = val.toInt()),
                ),
                _buildSlider(
                  title: 'Your Confidence',
                  value: _confidence.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  labelSuffix: ' / 5',
                  onChanged: (val) => setState(() => _confidence = val.toInt()),
                ),
                _buildSlider(
                  title: 'Course Difficulty',
                  value: _difficulty.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  labelSuffix: ' / 5',
                  onChanged: (val) => setState(() => _difficulty = val.toInt()),
                ),

                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _submitPrediction,
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('Calculate & Save Score'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for sliders
  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String labelSuffix,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(
              '${value.toStringAsFixed(labelSuffix.isEmpty ? 1 : 0)}$labelSuffix',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(labelSuffix.isEmpty ? 1 : 0),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
