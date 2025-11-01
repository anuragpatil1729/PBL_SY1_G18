// lib/models/study_session.dart

class StudySession {
  final String? id;
  final String userId;
  final DateTime? createdAt;
  final String subjectName;
  final int durationMinutes;
  final int focusRating; // 1-5

  StudySession({
    this.id,
    required this.userId,
    this.createdAt,
    required this.subjectName,
    required this.durationMinutes,
    required this.focusRating,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'subject_name': subjectName,
      'duration_minutes': durationMinutes,
      'focus_rating': focusRating,
    };
  }
}
