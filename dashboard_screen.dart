// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../services/supabase_service.dart';
import '../widgets/prediction_card.dart';
import '../widgets/prediction_details_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Stream<List<Prediction>> _predictionStream;
  final _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    _predictionStream = _supabaseService.getPredictionsStream();
  }

  void _showPredictionDetails(Prediction prediction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      // --- FIX: Corrected class name ---
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      // --- END FIX ---
      builder: (context) {
        return PredictionDetailsSheet(prediction: prediction);
      },
    );
  }

  // --- This function is now correctly called ---
  Future<void> _deletePrediction(String id) async {
    try {
      await _supabaseService.deletePrediction(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prediction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting prediction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Prediction>>(
      stream: _predictionStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No predictions yet.\nGo to the "Predict" tab to add one!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          );
        }

        final predictions = snapshot.data!;

        // --- WRAP ListView in a Column to add the hint ---
        return Column(
          children: [
            // --- FIX 2: SWIPE HINT ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Swipe left to delete',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.swipe_left_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),

            // --- END FIX 2 ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: predictions.length,
                itemBuilder: (context, index) {
                  final prediction = predictions[index];
                  return PredictionCard(
                    prediction: prediction,
                    onTap: () => _showPredictionDetails(prediction),

                    // --- FIX 1: Use onDeleted and pass the correct function ---
                    onDeleted: () => _deletePrediction(prediction.id!),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
