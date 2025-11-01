class Prediction {
  final String? id;
  final String? userId;
  final DateTime? createdAt;
  final String subjectName;
  final double predictedScore;
  final Map<String, dynamic>? aiSuggestions;

  // The 10 Factors
  final double attendancePercent;
  final double assignmentAvg;
  final double quizAvg;
  final double midtermScore;
  final double studyHoursWeekly;
  final double projectScore;
  final int participationLevel;
  final double previousGpa;
  final int confidenceLevel;
  final int courseDifficulty;

  Prediction({
    this.id,
    this.userId,
    this.createdAt,
    required this.subjectName,
    required this.predictedScore,
    this.aiSuggestions,
    required this.attendancePercent,
    required this.assignmentAvg,
    required this.quizAvg,
    required this.midtermScore,
    required this.studyHoursWeekly,
    required this.projectScore,
    required this.participationLevel,
    required this.previousGpa,
    required this.confidenceLevel,
    required this.courseDifficulty,
  });

  // Converts a Dart object to a JSON map for Supabase
  Map<String, dynamic> toJson() {
    return {
      // user_id is added automatically by Supabase policy/service
      'subject_name': subjectName,
      'predicted_score': predictedScore,
      'ai_suggestions': aiSuggestions,
      'attendance_percent': attendancePercent,
      'assignment_avg': assignmentAvg,
      'quiz_avg': quizAvg,
      'midterm_score': midtermScore,
      'study_hours_weekly': studyHoursWeekly,
      'project_score': projectScore,
      'participation_level': participationLevel,
      'previous_gpa': previousGpa,
      'confidence_level': confidenceLevel,
      'course_difficulty': courseDifficulty,
    };
  }

  // Creates a Prediction object from a Supabase JSON map
  factory Prediction.fromMap(Map<String, dynamic> map) {
    return Prediction(
      id: map['id'] as String?,
      userId: map['user_id'] as String?,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
      subjectName: map['subject_name'] as String,
      predictedScore: (map['predicted_score'] as num).toDouble(),
      aiSuggestions: map['ai_suggestions'] as Map<String, dynamic>?,
      attendancePercent: (map['attendance_percent'] as num).toDouble(),
      assignmentAvg: (map['assignment_avg'] as num).toDouble(),
      quizAvg: (map['quiz_avg'] as num).toDouble(),
      midtermScore: (map['midterm_score'] as num).toDouble(),
      studyHoursWeekly: (map['study_hours_weekly'] as num).toDouble(),
      projectScore: (map['project_score'] as num).toDouble(),
      participationLevel: (map['participation_level'] as num).toInt(),
      previousGpa: (map['previous_gpa'] as num).toDouble(),
      confidenceLevel: (map['confidence_level'] as num).toInt(),
      courseDifficulty: (map['course_difficulty'] as num).toInt(),
    );
  }
}
