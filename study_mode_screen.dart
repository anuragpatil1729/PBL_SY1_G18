// lib/screens/study_mode_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/study_session.dart';
import '../services/supabase_service.dart';

class StudyModeScreen extends StatefulWidget {
  const StudyModeScreen({super.key});

  @override
  State<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends State<StudyModeScreen> {
  // --- IMPROVEMENT 3: Use mutable state variables ---
  int _workMinutes = 25;
  int _breakMinutes = 5;
  // --- END IMPROVEMENT ---

  Timer? _timer;
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  bool _isRunning = false;
  bool _isWorkSession = true;

  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });

        if (_isWorkSession) {
          // Work session finished
          // --- IMPROVEMENT 3: Pass custom duration ---
          _showLogSessionDialog(_workMinutes);
          setState(() {
            _isWorkSession = false;
            _totalSeconds = _breakMinutes * 60;
            _remainingSeconds = _totalSeconds;
          });
        } else {
          // Break finished
          setState(() {
            _isWorkSession = true;
            _totalSeconds = _workMinutes * 60;
            _remainingSeconds = _totalSeconds;
          });
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isWorkSession = true;
      // --- IMPROVEMENT 3: Reset to custom duration ---
      _totalSeconds = _workMinutes * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  // --- IMPROVEMENT 3: Accept duration as a parameter ---
  Future<void> _showLogSessionDialog(int durationMinutes) async {
    String? selectedSubject;
    double focusRating = 3.0;
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Log Study Session'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Great job! Log your $durationMinutes-minute study session.',
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<String>>(
                    future: _supabaseService.getSubjectList(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return const Text(
                          'No subjects found. Add a prediction first.',
                          style: TextStyle(color: Colors.red),
                        );
                      }
                      final subjects = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: selectedSubject,
                        hint: const Text('Select Subject'),
                        items: subjects
                            .map(
                              (subject) => DropdownMenuItem(
                                value: subject,
                                child: Text(subject),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedSubject = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Focus Rating: ${focusRating.toStringAsFixed(1)}/5'),
                  Slider(
                    value: focusRating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 40,
                    label: focusRating.toStringAsFixed(1),
                    onChanged: (value) {
                      setDialogState(() {
                        focusRating = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (selectedSubject == null)
                      ? null
                      : () async {
                          final session = StudySession(
                            userId: userId,
                            subjectName: selectedSubject!,
                            durationMinutes:
                                durationMinutes, // Use custom duration
                            focusRating: focusRating.round(),
                          );
                          try {
                            final xpGained = await _supabaseService
                                .addStudySession(session);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Session logged! +$xpGained XP Earned!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: const Text('Log Session'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- IMPROVEMENT 3: Helper to change timer values ---
  void _changeTime(int delta, bool isWork) {
    if (_isRunning) return; // Don't change time while running

    setState(() {
      if (isWork) {
        _workMinutes = (_workMinutes + delta).clamp(5, 60); // 5-60 min
      } else {
        _breakMinutes = (_breakMinutes + delta).clamp(1, 30); // 1-30 min
      }
      _resetTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerColor = _isWorkSession ? theme.primaryColor : Colors.green;
    // --- IMPROVEMENT 4: Calculate progress ---
    final progress = 1.0 - (_remainingSeconds / _totalSeconds);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- IMPROVEMENT 3: Timer selection UI ---
          if (!_isRunning)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeSelector(
                  'Work',
                  _workMinutes,
                  (delta) => _changeTime(delta, true),
                ),
                _buildTimeSelector(
                  'Break',
                  _breakMinutes,
                  (delta) => _changeTime(delta, false),
                ),
              ],
            ),
          const SizedBox(height: 30),

          // --- IMPROVEMENT 4: Upgraded Timer UI ---
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isWorkSession ? 'Study Mode' : 'Break Time',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: timerColor,
                        ),
                      ),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: timerColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // --- END IMPROVEMENT 4 ---
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset Button
              IconButton(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh),
                iconSize: 30,
                color: Colors.grey,
              ),
              const SizedBox(width: 20),
              // Start/Pause Button
              ElevatedButton.icon(
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                icon: Icon(
                  _isRunning ? Icons.pause : Icons.play_arrow,
                  size: 28,
                ),
                label: Text(_isRunning ? 'Pause' : 'Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: timerColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Empty space for balance
              const SizedBox(width: 30),
            ],
          ),
        ],
      ),
    );
  }

  // --- IMPROVEMENT 3: Helper widget for time selector ---
  Widget _buildTimeSelector(
    String title,
    int minutes,
    Function(int) onChanged,
  ) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => onChanged(-5),
            ),
            Text('$minutes', style: Theme.of(context).textTheme.headlineSmall),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(5),
            ),
          ],
        ),
      ],
    );
  }
}
