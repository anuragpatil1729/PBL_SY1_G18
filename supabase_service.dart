// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/prediction.dart';
import '../models/study_session.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Inserts a new prediction record into the 'predictions' table.
  Future<void> addPrediction(Prediction prediction) async {
    try {
      final predictionMap = prediction.toJson();
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }
      predictionMap['user_id'] = userId;
      await _client.from('predictions').insert(predictionMap);
    } on PostgrestException catch (e) {
      print('Supabase error saving prediction: ${e.message}');
      throw Exception('Failed to save prediction: ${e.message}');
    } catch (e) {
      print('Generic error saving prediction: $e');
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// Listens for real-time changes on the 'predictions' table
  Stream<List<Prediction>> getPredictionsStream() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    final stream = _client
        .from('predictions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return stream.map((listOfMaps) {
      return listOfMaps.map((map) => Prediction.fromMap(map)).toList();
    });
  }

  // --- IMPROVEMENT 1: DELETE PREDICTION ---
  Future<void> deletePrediction(String predictionId) async {
    try {
      await _client.from('predictions').delete().eq('id', predictionId);
    } on PostgrestException catch (e) {
      print('Supabase error deleting prediction: ${e.message}');
      throw Exception('Failed to delete prediction: ${e.message}');
    } catch (e) {
      print('Generic error deleting prediction: $e');
      throw Exception('An unknown error occurred: $e');
    }
  }
  // --- END IMPROVEMENT ---

  /// Fetches a unique list of subject names from the user's predictions.
  Future<List<String>> getSubjectList() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    try {
      final response = await _client.rpc('get_user_subjects');
      final subjects = (response as List<dynamic>)
          .map((item) => item['subject_name'] as String)
          .toList();
      return subjects;
    } catch (e) {
      print('Error fetching subjects: $e');
      throw Exception(
        'Failed to load subject list. Did you run the SQL function?',
      );
    }
  }

  /// Saves a new study session and returns the XP gained.
  Future<int> addStudySession(StudySession session) async {
    try {
      await _client.from('study_sessions').insert(session.toJson());
      int xpGained = (session.durationMinutes * 10 * (session.focusRating / 5))
          .round();
      return xpGained;
    } on PostgrestException catch (e) {
      print('Supabase error saving session: ${e.message}');
      throw Exception('Failed to save session: ${e.message}');
    } catch (e) {
      print('Generic error saving session: $e');
      throw Exception('An unknown error occurred: $e');
    }
  }
}
