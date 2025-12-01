import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class to handle meal log data persistence
class MealLogService {
  static const String _keyMealLogs = 'meal_logs_list';

  /// Load meal logs from local storage
  Future<List<Map<String, dynamic>>> loadMealLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? mealsJson = prefs.getString(_keyMealLogs);

      if (mealsJson == null || mealsJson.isEmpty) {
        return _getDefaultMealLogs();
      }

      final List<dynamic> decoded = jsonDecode(mealsJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error loading meal logs: $e');
      return _getDefaultMealLogs();
    }
  }

  /// Save meal logs to local storage
  Future<bool> saveMealLogs(List<Map<String, dynamic>> mealLogs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(mealLogs);
      await prefs.setString(_keyMealLogs, encoded);
      return true;
    } catch (e) {
      print('Error saving meal logs: $e');
      return false;
    }
  }

  /// Clear all meal logs from local storage
  Future<bool> clearMealLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyMealLogs);
      return true;
    } catch (e) {
      print('Error clearing meal logs: $e');
      return false;
    }
  }

  /// Get default meal logs (initial data)
  List<Map<String, dynamic>> _getDefaultMealLogs() {
    return [
      {
        'id': '1',
        'mealType': 'Breakfast',
        'foodItems': 'Oatmeal with berries, Greek yogurt',
        'carbs': '45',
        'calories': '320',
        'time': '08:30 AM',
        'date': DateTime.now().toIso8601String(),
        'notes': 'Felt good after meal',
      },
      {
        'id': '2',
        'mealType': 'Lunch',
        'foodItems': 'Grilled chicken salad, brown rice',
        'carbs': '38',
        'calories': '450',
        'time': '12:30 PM',
        'date': DateTime.now().toIso8601String(),
        'notes': 'Light and healthy',
      },
    ];
  }
}