// lib/services/ai_service.dart
//
// Single shared service for AI calls in the app — using Google Gemini's
// FREE API tier (no credit card needed).
// Used by: employer_suggestion_tab.dart (AI candidate matching)

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIService {
  // Get a free key (no credit card) at: https://aistudio.google.com
  // Click "Get API key" → "Create API key"
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AQ.Ab8RN6KgIOTRfrBIx3XCejUk6yAwP-SvcGHoze64iRCXUR7suQ',
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
          throw Exception('Gemini returned no candidates — response may have been blocked.');
        }
        final parts = candidates[0]['content']?['parts'] as List?;
        if (parts == null || parts.isEmpty) {
          throw Exception('Gemini returned an empty response.');
        }
        return parts[0]['text'] as String;
      }

      // 503 = model temporarily overloaded (common on free tier). Retry a
      // couple of times with a short delay before giving up.
      final isOverloaded = response.statusCode == 503;
      if (isOverloaded && attempt < maxRetries) {
        attempt++;
        final delaySeconds = 2 * attempt; // 2s, then 4s
        debugPrint('AIService: Gemini overloaded (503), retrying in ${delaySeconds}s '
            '(attempt $attempt/$maxRetries)...');
        await Future.delayed(Duration(seconds: delaySeconds));
        continue;
      }

      debugPrint('AIService (Gemini) error ${response.statusCode}: ${response.body}');
      if (isOverloaded) {
        throw Exception(
            'Gemini is temporarily busy. Please try again in a moment.');
      }
      throw Exception('AI request failed (${response.statusCode})');
    }
  }
}