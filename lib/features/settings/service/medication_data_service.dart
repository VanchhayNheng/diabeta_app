import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service class to handle medication data persistence
class MedicationDataService {
  static const String _keyMedications = 'medications_list';

  /// Load medications from local storage
  Future<List<Map<String, dynamic>>> loadMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? medicationsJson = prefs.getString(_keyMedications);

      if (medicationsJson == null || medicationsJson.isEmpty) {
        return _getDefaultMedications();
      }

      final List<dynamic> decoded = jsonDecode(medicationsJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      print('Error loading medications: $e');
      return _getDefaultMedications();
    }
  }

  /// Save medications to local storage
  Future<bool> saveMedications(List<Map<String, dynamic>> medications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(medications);
      await prefs.setString(_keyMedications, encoded);
      return true;
    } catch (e) {
      print('Error saving medications: $e');
      return false;
    }
  }

  /// Clear all medications from local storage
  Future<bool> clearMedications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyMedications);
      return true;
    } catch (e) {
      print('Error clearing medications: $e');
      return false;
    }
  }

  /// Get default medications (initial data)
  List<Map<String, dynamic>> _getDefaultMedications() {
    return [
      {
        'name': 'Metformin',
        'dosage': '500mg',
        'frequency': 'Twice daily',
        'time': ['08:00 AM', '08:00 PM'],
        'instructions': 'Take with food',
        'active': true,
      },
      {
        'name': 'Insulin Glargine',
        'dosage': '20 units',
        'frequency': 'Once daily',
        'time': ['10:00 PM'],
        'instructions': 'Inject subcutaneously',
        'active': true,
      },
    ];
  }
}