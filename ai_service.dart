// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction.dart'; // We'll use this to get the factors

// 1. Define what prompt we are using
enum AIPromptType { academicSuggestion }

class AIService {
  // --- IMPORTANT ---
  // Paste your Gemini API Key here
  final String _apiKey =
      'AIzaSyDIV3ctH6tuMkRepwCYQMQSqOOZHUVjQvs'; // Your key is included
  // -----------------

  final String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  // 2. This function builds the master prompt
  String _getPrompt(AIPromptType type) {
    switch (type) {
      case AIPromptType.academicSuggestion:
        return """
        You are an expert, encouraging academic advisor.
        I will provide you with a student's predicted score and the 10 factors used
        to calculate it.

        Analyze these factors and provide a concise, helpful report.
        You MUST respond in a single, valid JSON object format with three keys:
        1.  "overall_feedback": A single, encouraging string summarizing the prediction.
        2.  "positive_points": A list of 2-3 strings highlighting what the student is doing well.
        3.  "areas_for_improvement": A list of 2-3 actionable, specific suggestions for improvement.

        Here is the JSON structure:
        {
          "overall_feedback": "Your predicted score is strong, and your high attendance is a great asset!",
          "positive_points": [
            "Excellent attendance (80.0%).",
            "Strong project score (70.0%)."
          ],
          "areas_for_improvement": [
            "Focus on raising the quiz average (70.0%) with short, daily reviews.",
            "Try to increase weekly study hours from 5.0 to 7-8 hours."
          ]
        }
        """;
    }
  }

  // 3. This is the main function we will call from our app
  Future<Map<String, dynamic>> getAcademicSuggestions({
    required Prediction prediction,
  }) async {
    final prompt = _getPrompt(AIPromptType.academicSuggestion);

    // Create a text-based input from the prediction data
    final String inputText =
        """
    Here is the student's data:
    - Subject: ${prediction.subjectName}
    - Predicted Score: ${prediction.predictedScore.toStringAsFixed(1)}%
    
    Factors:
    1.  Attendance: ${prediction.attendancePercent}%
    2.  Assignment Average: ${prediction.assignmentAvg}%
    3.  Quiz Average: ${prediction.quizAvg}%
    4.  Midterm Score: ${prediction.midtermScore}%
    5.  Project Score: ${prediction.projectScore}%
    6.  Weekly Study Hours: ${prediction.studyHoursWeekly}
    7.  Previous GPA: ${prediction.previousGpa}
    8.  Participation Level: ${prediction.participationLevel}/5
    9.  Confidence Level: ${prediction.confidenceLevel}/5
    10. Course Difficulty: ${prediction.courseDifficulty}/5
    """;

    // This request body is based on the "Text" case in your video_ai_service.dart
    final requestBody = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': "Here is the content to analyze:\n\n$inputText"},
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {'responseMimeType': 'application/json'},
      'safetySettings': _safetySettings,
    };

    return _sendRequest(requestBody);
  }

  // 4. This is the generic network logic, adapted from your file
  Future<Map<String, dynamic>> _sendRequest(
    Map<String, dynamic> requestBody,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final modelResponseText =
            responseBody['candidates']![0]['content']['parts']![0]['text'];

        // The model's response is a JSON string, so we parse it again
        final modelJson = jsonDecode(modelResponseText) as Map<String, dynamic>;

        return modelJson;
      } else {
        String errorMessage = 'Failed to get a valid AI response.';
        try {
          final errorJson = jsonDecode(response.body);
          errorMessage = errorJson['error']?['message'] ?? errorMessage;
        } catch (_) {}
        print('AI API Error (Status ${response.statusCode}): ${response.body}');
        throw Exception(
          'AI Error: $errorMessage (Code ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Error in _sendRequest: $e');
      throw Exception(
        'Failed to communicate with AI service. Check your API key.',
      );
    }
  }

  // --- START: NEW METHODS FOR STEP 6A ---

  // --- NEW METHOD 1: To start the chat ---
  /// Creates the initial chat history with a system prompt.
  List<dynamic> startChatSession() {
    return [
      {
        'role': 'user',
        'parts': [
          {
            'text':
                'You are an expert, encouraging academic advisor AI. Answer my questions helpfully.',
          },
        ],
      },
      {
        'role': 'model',
        'parts': [
          {'text': 'Of course! I\'m here to help. What\'s on your mind?'},
        ],
      },
    ];
  }

  // --- NEW METHOD 2: Adapted from your video_ai_service.dart ---
  /// Continues an existing chat session.
  Future<Map<String, dynamic>> continueChat({
    required List<dynamic> history,
    required String userMessage,
  }) async {
    // If userMessage is provided, add it to history.
    // If it's empty, we assume the message is already in the history.
    final userTurn = {
      'role': 'user',
      'parts': [
        {'text': userMessage},
      ],
    };

    // Add the new user message to the history
    // We modify this slightly: only add the turn if the message is not empty.
    // The chat_screen.dart logic I provided handles this, but this is safer.
    final updatedHistory = List<dynamic>.from(history);
    if (userMessage.isNotEmpty) {
      updatedHistory.add(userTurn);
    }

    final requestBody = {
      'contents': updatedHistory, // Send the whole history
      'safetySettings': _safetySettings,
    };

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final modelResponse = responseBody['candidates']![0]['content'];

        return {
          'latestMessage': modelResponse['parts']![0]['text'],
          'history': [
            ...updatedHistory,
            modelResponse,
          ], // Return the *full* new history
        };
      } else {
        print(
          'AI Chat Error (Status ${response.statusCode}): ${response.body}',
        );
        throw Exception('Failed to get a valid chat response from AI model.');
      }
    } catch (e) {
      print('Error in continueChat: $e');
      throw Exception('Failed to get chat response.');
    }
  }

  // --- END: NEW METHODS FOR STEP 6A ---

  // Copied directly from your file
  final List<Map<String, String>> _safetySettings = [
    {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
    {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_NONE'},
    {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_NONE'},
    {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_NONE'},
  ];
}
