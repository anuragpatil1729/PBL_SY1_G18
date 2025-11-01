// lib/widgets/prediction_details_sheet.dart
import 'package:flutter/material.dart';
import '../models/prediction.dart';

class PredictionDetailsSheet extends StatelessWidget {
  final Prediction prediction;
  const PredictionDetailsSheet({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    // Safely extract AI suggestions
    final suggestions = prediction.aiSuggestions ?? {};
    final feedback =
        suggestions['overall_feedback'] as String? ??
        "No AI feedback available.";
    final positives = List<String>.from(suggestions['positive_points'] ?? []);
    final improvements = List<String>.from(
      suggestions['areas_for_improvement'] ?? [],
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Text(
                prediction.subjectName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                'Predicted Score: ${prediction.predictedScore.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(height: 30),

              // --- AI Feedback Section ---
              if (prediction.aiSuggestions != null) ...[
                _buildSectionTitle(
                  context,
                  'AI Academic Advisor',
                  Icons.smart_toy_outlined,
                ),
                Text(
                  feedback,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),

                // Positive Points
                if (positives.isNotEmpty)
                  _buildAIPoint(
                    context,
                    'What\'s working well:',
                    Icons.check_circle_outline,
                    Colors.green,
                    positives,
                  ),

                // Improvement Points
                if (improvements.isNotEmpty)
                  _buildAIPoint(
                    context,
                    'Actionable suggestions:',
                    Icons.lightbulb_outline,
                    Colors.orange,
                    improvements,
                  ),

                const Divider(height: 30),
              ],

              // --- Raw Data Section ---
              _buildSectionTitle(
                context,
                'Data Snapshot',
                Icons.analytics_outlined,
              ),
              _buildDetailRow(
                'Attendance:',
                '${prediction.attendancePercent}%',
              ),
              _buildDetailRow(
                'Assignment Avg:',
                '${prediction.assignmentAvg}%',
              ),
              _buildDetailRow('Quiz Avg:', '${prediction.quizAvg}%'),
              _buildDetailRow('Midterm Score:', '${prediction.midtermScore}%'),
              _buildDetailRow('Project Score:', '${prediction.projectScore}%'),
              _buildDetailRow(
                'Weekly Study Hours:',
                '${prediction.studyHoursWeekly} hrs',
              ),
              _buildDetailRow('Previous GPA:', '${prediction.previousGpa}'),
              _buildDetailRow(
                'Participation:',
                '${prediction.participationLevel}/5',
              ),
              _buildDetailRow('Confidence:', '${prediction.confidenceLevel}/5'),
              _buildDetailRow(
                'Difficulty:',
                '${prediction.courseDifficulty}/5',
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper to build section titles
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper to build a list of AI points
  Widget _buildAIPoint(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    List<String> points,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 8),
                  Expanded(child: Text(point)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build data rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
