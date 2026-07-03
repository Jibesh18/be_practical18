// lib/services/ai_services.dart
// Single shared service for AI calls — using Google Gemini FREE API tier.
// Used by: employer_suggestion_tab.dart (AI candidate matching)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../env.dart';

class AIService {
  // Key is injected at build time via --dart-define=GEMINI_API_KEY=...
  // Run with: flutter run --dart-define=GEMINI_API_KEY=your_key_here
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: geminiApiKey,
  );
  static const String _model = 'gemini-2.5-flash';

  static String get _endpoint =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static Future<String> ask({
    required String prompt,
    String? systemPrompt,
    int maxOutputTokens = 1000,
    int maxRetries = 2,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'Gemini API key not set. Run with --dart-define=GEMINI_API_KEY=your_key');
    }

    final body = {
      if (systemPrompt != null)
        'system_instruction': {
          'parts': [
            {'text': systemPrompt}
          ]
        },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'maxOutputTokens': maxOutputTokens,
      },
    };

    int attempt = 0;
    while (true) {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          throw Exception('Gemini returned no candidates.');
        }
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          throw Exception('Gemini returned an empty response.');
        }
        return parts[0]['text'] as String;
      }

      final isOverloaded = response.statusCode == 503;
      if (isOverloaded && attempt < maxRetries) {
        attempt++;
        final delaySeconds = 2 * attempt;
        debugPrint('AIService: Gemini overloaded, retrying in ${delaySeconds}s...');
        await Future.delayed(Duration(seconds: delaySeconds));
        continue;
      }

      debugPrint('AIService error ${response.statusCode}: ${response.body}');
      if (isOverloaded) {
        throw Exception('Gemini is temporarily busy. Please try again.');
      }
      throw Exception('AI request failed (${response.statusCode})');
    }
  }
}