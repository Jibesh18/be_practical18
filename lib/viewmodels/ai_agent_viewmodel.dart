import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/internship_model.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class AIAgentViewModel extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Call Anthropic API (or your backend endpoint)
  Future<void> sendMessage({
    required String userMessage,
    String? userName,
    List<InternshipModel>? availableInternships,
  }) async {
    _messages.add(ChatMessage(
      text: userMessage,
      isUser: true,
      time: DateTime.now(),
    ));
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Build context about available internships for smart suggestions
      String internshipContext = '';
      if (availableInternships != null && availableInternships.isNotEmpty) {
        final titles = availableInternships
            .take(10)
            .map((i) =>
        '- ${i.title} at ${i.company} (${i.type}, ${i.stipend})')
            .join('\n');
        internshipContext =
        '\n\nAvailable internships in the app:\n$titles';
      }

      final systemPrompt = '''You are an AI career assistant in the Be Practical internship app.
You help ${userName ?? 'the user'} with:
1. Resume/CV creation — ask for their skills, experience, education and generate a professional CV in text format
2. Internship recommendations — suggest which internships from the app suit them best
3. Career guidance — interview tips, skill development advice
$internshipContext

Keep responses concise and actionable. When creating CVs, format them clearly with sections.''';

      final response = await http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': 'YOUR_API_KEY', // Move to backend/env in production
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-sonnet-4-20250514',
          'max_tokens': 1000,
          'system': systemPrompt,
          'messages': _buildHistory(userMessage),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['content'][0]['text'] as String;
        _messages.add(ChatMessage(
          text: reply,
          isUser: false,
          time: DateTime.now(),
        ));
      } else {
        throw Exception('API error ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Could not reach AI. Please check your connection.';
      _messages.add(ChatMessage(
        text: 'Sorry, I\'m having trouble connecting. Please try again.',
        isUser: false,
        time: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, String>> _buildHistory(String latestUserMessage) {
    // Send last 10 messages for context (keeps tokens low)
    final history = _messages
        .take(_messages.length - 1) // exclude the one we just added
        .toList()
        .reversed
        .take(9)
        .toList()
        .reversed
        .toList();

    return [
      ...history.map((m) => {
        'role': m.isUser ? 'user' : 'assistant',
        'content': m.text,
      }),
      {'role': 'user', 'content': latestUserMessage},
    ];
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}