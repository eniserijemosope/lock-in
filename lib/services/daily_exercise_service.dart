import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseInstruction {
  final String name;
  final String instructions;
  final String category;

  const ExerciseInstruction({
    required this.name,
    required this.instructions,
    required this.category,
  });

  factory ExerciseInstruction.fromJson(Map<String, dynamic> json) {
    return ExerciseInstruction(
      name: json['name'] as String,
      instructions: json['instructions'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'instructions': instructions,
        'category': category,
      };
}

class DailyExerciseService {
  static const _dateKey = 'lock_in_exercises_date';
  static const _dataKey = 'lock_in_exercises_data';
  static final _apiBase = Uri.https('wger.de', '/api/v2/exerciseinfo/');

  static Future<List<ExerciseInstruction>> loadForToday() async {
    final preferences = await SharedPreferences.getInstance();
    final today = _dateStamp(DateTime.now());
    if (preferences.getString(_dateKey) == today) {
      final cached = preferences.getString(_dataKey);
      if (cached != null) {
        final decoded = jsonDecode(cached) as List<dynamic>;
        return decoded
            .map((item) =>
                ExerciseInstruction.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    final response = await http
        .get(_apiBase.replace(queryParameters: {
          'language': '2',
          'limit': '100',
        }))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw http.ClientException(
        'The exercise service returned HTTP ${response.statusCode}.',
        _apiBase,
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final results = payload['results'] as List<dynamic>;
    final exercises = results
        .map((result) => _parseExercise(result as Map<String, dynamic>))
        .whereType<ExerciseInstruction>()
        .toList();
    if (exercises.length < 4) {
      throw const FormatException(
        'The exercise service did not return four English instructions.',
      );
    }

    final now = DateTime.now();
    final dayNumber = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(2020))
        .inDays;
    final start = (dayNumber * 4) % exercises.length;
    final daily = List<ExerciseInstruction>.generate(
      4,
      (index) => exercises[(start + index) % exercises.length],
    );
    final saved = await preferences.setString(
      _dataKey,
      jsonEncode(daily.map((exercise) => exercise.toJson()).toList()),
    );
    if (!saved) {
      throw StateError('Today\'s exercise instructions could not be cached.');
    }
    final savedDate = await preferences.setString(_dateKey, today);
    if (!savedDate) {
      throw StateError('Today\'s exercise date could not be cached.');
    }
    return daily;
  }

  static ExerciseInstruction? _parseExercise(Map<String, dynamic> result) {
    final translations = result['translations'] as List<dynamic>? ?? [];
    for (final value in translations) {
      final translation = value as Map<String, dynamic>;
      final language = translation['language'];
      final languageId =
          language is Map<String, dynamic> ? language['id'] : language;
      if (languageId != 2) continue;

      final name = translation['name'] as String? ?? '';
      final instructions =
          _plainText(translation['description'] as String? ?? '');
      if (name.trim().isEmpty || instructions.isEmpty) continue;
      final category = result['category'] as Map<String, dynamic>?;
      return ExerciseInstruction(
        name: name.trim(),
        instructions: instructions,
        category: category?['name'] as String? ?? 'Workout',
      );
    }
    return null;
  }

  static String _plainText(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', '\'')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _dateStamp(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
