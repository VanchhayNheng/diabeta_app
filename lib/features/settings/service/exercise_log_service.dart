import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class to handle exercise log data persistence
class ExerciseLogService {
  static const String _keyExerciseLogs = 'exercise_logs_list';

  /// Load exercise logs from local storage
  Future<List<Map<String, dynamic>>> loadExerciseLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? exercisesJson = prefs.getString(_keyExerciseLogs);

      if (exercisesJson == null || exercisesJson.isEmpty) {
        return _getDefaultExerciseLogs();
      }

      final List<dynamic> decoded = jsonDecode(exercisesJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error loading exercise logs: $e');
      return _getDefaultExerciseLogs();
    }
  }

  /// Save exercise logs to local storage
  Future<bool> saveExerciseLogs(List<Map<String, dynamic>> exerciseLogs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(exerciseLogs);
      await prefs.setString(_keyExerciseLogs, encoded);
      return true;
    } catch (e) {
      print('Error saving exercise logs: $e');
      return false;
    }
  }

  /// Clear all exercise logs from local storage
  Future<bool> clearExerciseLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyExerciseLogs);
      return true;
    } catch (e) {
      print('Error clearing exercise logs: $e');
      return false;
    }
  }

  /// Get default exercise logs (initial data)
  List<Map<String, dynamic>> _getDefaultExerciseLogs() {
    return [
      {
        'id': '1',
        'activityType': 'Walking',
        'duration': '30',
        'intensity': 'Moderate',
        'calories': '150',
        'time': '07:00 AM',
        'date': DateTime.now().toIso8601String(),
        'notes': 'Morning walk in the park',
      },
      {
        'id': '2',
        'activityType': 'Cycling',
        'duration': '45',
        'intensity': 'High',
        'calories': '320',
        'time': '06:00 PM',
        'date': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'notes': 'Evening bike ride',
      },
    ];
  }
}