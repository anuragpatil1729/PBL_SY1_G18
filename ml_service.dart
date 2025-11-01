// lib/services/ml_service.dart

class MLService {
  /// Calculates a predicted score based on 10 factors.
  /// This is a local, weighted algorithm.
  double calculateScore({
    required double attendancePercent,
    required double assignmentAvg,
    required double quizAvg,
    required double midtermScore,
    required double studyHoursWeekly,
    required double projectScore,
    required int participationLevel, // 1-5
    required double previousGpa, // 0-4
    required int confidenceLevel, // 1-5
    required int courseDifficulty, // 1-5
  }) {
    // --- Define Weights (sum to ~100 points) ---
    // Core academics (60 points)
    final double midtermWeight = 0.25 * midtermScore;
    final double assignmentWeight = 0.20 * assignmentAvg;
    final double quizWeight = 0.15 * quizAvg;

    // Secondary academics (20 points)
    final double projectWeight = 0.10 * projectScore;
    final double gpaWeight = (previousGpa / 4.0) * 10.0; // Max 10 points

    // Effort & Engagement (20 points)
    final double attendanceWeight = 0.05 * attendancePercent; // Max 5 points
    // Assume 10 hours/week is "good" (10 points)
    final double studyWeight =
        (studyHoursWeekly / 10.0).clamp(0.0, 1.5) * 10.0; // Max 15 points
    final double participationWeight =
        (participationLevel / 5.0) * 5.0; // Max 5 points

    // --- Base Score ---
    // Start with a base score derived from weighted factors
    double baseScore =
        midtermWeight +
        assignmentWeight +
        quizWeight +
        projectWeight +
        gpaWeight +
        attendanceWeight +
        studyWeight +
        participationWeight;

    // --- Modifiers ---
    // Difficulty: 1=Easy (+4), 3=Neutral (0), 5=Hard (-4)
    final double difficultyModifier = (3 - courseDifficulty) * 2.0;

    // Confidence: 1=Low (-2), 3=Neutral (0), 5=High (+2)
    final double confidenceModifier = (confidenceLevel - 3) * 1.0;

    // Apply modifiers
    double finalScore = baseScore + difficultyModifier + confidenceModifier;

    // Ensure the final score is between 0 and 100
    return finalScore.clamp(0.0, 100.0);
  }
}
