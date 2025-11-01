// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // --- MODIFIED: Import markdown ---
import '../services/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _aiService = AIService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<dynamic> _chatHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chatHistory = _aiService.startChatSession();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final userMessage = message;
    _messageController.clear();

    setState(() {
      _isLoading = true;
      _chatHistory.add({
        'role': 'user',
        'parts': [
          {'text': userMessage},
        ],
      });
    });
    _scrollToBottom();

    try {
      final response = await _aiService.continueChat(
        history: _chatHistory,
        userMessage: '', // Message is already in history
      );

      setState(() {
        _chatHistory = List<dynamic>.from(response['history']);
      });
    } catch (e) {
      setState(() {
        _chatHistory.add({
          'role': 'model',
          'parts': [
            {'text': 'Sorry, I ran into an error: $e'},
          ],
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount: _chatHistory.length - 1,
            itemBuilder: (context, index) {
              final message = _chatHistory[index + 1];
              final isUser = message['role'] == 'user';
              return _buildChatBubble(
                message: message['parts']![0]['text'],
                isUser: isUser,
              );
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(),
          ),
        _buildTextInput(),
      ],
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask your AI advisor...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : _sendMessage,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --- MODIFIED: This widget is now updated ---
  Widget _buildChatBubble({required String message, required bool isUser}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser
        ? theme.primaryColor
        : (isDarkMode ? theme.cardColor : Colors.grey[200]);
    final textColor = isUser ? Colors.white : theme.textTheme.bodyLarge?.color;

    // --- Create a theme-aware stylesheet for Markdown ---
    final markdownStyle = MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: theme.textTheme.bodyLarge?.copyWith(color: textColor),
      listBullet: theme.textTheme.bodyLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      blockquoteDecoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      code: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: Colors.black.withOpacity(0.1),
      ),
    );

    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        // --- Replace Text with MarkdownBody ---
        child: MarkdownBody(
          data: message,
          selectable: true,
          styleSheet: markdownStyle,
        ),
      ),
    );
  }
}
