// lib/widgets/prediction_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prediction.dart';

class PredictionCard extends StatelessWidget {
  final Prediction prediction;
  final VoidCallback onTap;

  // --- FIX 1: Changed property to a simple VoidCallback ---
  final VoidCallback onDeleted;

  const PredictionCard({
    super.key,
    required this.prediction,
    required this.onTap,
    required this.onDeleted, // --- Use new property in constructor ---
  });

  @override
  Widget build(BuildContext context) {
    final String formattedDate = prediction.createdAt != null
        ? DateFormat('MMM d, yyyy - h:mm a').format(prediction.createdAt!)
        : 'No date';

    final Color scoreColor;
    if (prediction.predictedScore >= 85) {
      scoreColor = Colors.green;
    } else if (prediction.predictedScore >= 70) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Dismissible(
      key: Key(prediction.id!), // Must have a unique key
      direction: DismissDirection.endToStart, // Swipe right-to-left

      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),

      // --- This shows a confirmation dialog before deleting ---
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Delete"),
              content: Text(
                "Are you sure you want to delete the prediction for '${prediction.subjectName}'?",
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(false), // Returns false
                  child: const Text("Cancel"),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () =>
                      Navigator.of(context).pop(true), // Returns true
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );
      },

      // --- FIX 1: This is called *after* confirmDismiss returns true ---
      // It now correctly calls the onDeleted callback.
      onDismissed: (direction) {
        onDeleted();
      },

      // --- This is the card itself ---
      child: Card(
        clipBehavior: Clip.antiAlias, // Ensures the ripple effect is rounded
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scoreColor, width: 4),
                  ),
                  child: Center(
                    child: Text(
                      '${prediction.predictedScore.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediction.subjectName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
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
