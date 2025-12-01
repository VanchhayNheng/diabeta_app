import 'package:shared_preferences/shared_preferences.dart';

/// Service class to handle health data persistence
class HealthDataService {
  static const String _keyPrefix = 'health_';

  // Keys for each field
  static const String _keyDiabetesType = '${_keyPrefix}diabetesType';
  static const String _keyDiagnosisYear = '${_keyPrefix}diagnosisYear';
  static const String _keyA1c = '${_keyPrefix}a1c';
  static const String _keyFastingGlucose = '${_keyPrefix}fastingGlucose';
  static const String _keyTargetGlucose = '${_keyPrefix}targetGlucose';
  static const String _keyHeight = '${_keyPrefix}height';
  static const String _keyWeight = '${_keyPrefix}weight';
  static const String _keyBmi = '${_keyPrefix}bmi';
  static const String _keyBloodPressure = '${_keyPrefix}bloodPressure';
  static const String _keyAllergies = '${_keyPrefix}allergies';
  static const String _keyConditions = '${_keyPrefix}conditions';

  /// Load health data from local storage
  Future<Map<String, dynamic>> loadHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'diabetesType': prefs.getString(_keyDiabetesType) ?? 'Type 2',
        'diagnosisYear': prefs.getString(_keyDiagnosisYear) ?? '2018',
        'a1c': prefs.getString(_keyA1c) ?? '7.2',
        'fastingGlucose': prefs.getString(_keyFastingGlucose) ?? '110',
        'targetGlucose': prefs.getString(_keyTargetGlucose) ?? '70-130',
        'height': prefs.getString(_keyHeight) ?? '175',
        'weight': prefs.getString(_keyWeight) ?? '70',
        'bmi': prefs.getString(_keyBmi) ?? '22.9',
        'bloodPressure': prefs.getString(_keyBloodPressure) ?? '120/80',
        'allergies': prefs.getString(_keyAllergies) ?? 'Penicillin',
        'conditions': prefs.getString(_keyConditions) ?? 'Hypertension',
      };
    } catch (e) {
      print('Error loading health data: $e');
      return _getDefaultData();
    }
  }

  /// Save health data to local storage
  Future<bool> saveHealthData(Map<String, dynamic> healthData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyDiabetesType, healthData['diabetesType']?.toString() ?? '');
      await prefs.setString(_keyDiagnosisYear, healthData['diagnosisYear']?.toString() ?? '');
      await prefs.setString(_keyA1c, healthData['a1c']?.toString() ?? '');
      await prefs.setString(_keyFastingGlucose, healthData['fastingGlucose']?.toString() ?? '');
      await prefs.setString(_keyTargetGlucose, healthData['targetGlucose']?.toString() ?? '');
      await prefs.setString(_keyHeight, healthData['height']?.toString() ?? '');
      await prefs.setString(_keyWeight, healthData['weight']?.toString() ?? '');
      await prefs.setString(_keyBmi, healthData['bmi']?.toString() ?? '');
      await prefs.setString(_keyBloodPressure, healthData['bloodPressure']?.toString() ?? '');
      await prefs.setString(_keyAllergies, healthData['allergies']?.toString() ?? '');
      await prefs.setString(_keyConditions, healthData['conditions']?.toString() ?? '');

      return true;
    } catch (e) {
      print('Error saving health data: $e');
      return false;
    }
  }

  /// Clear all health data from local storage
  Future<bool> clearHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyDiabetesType);
      await prefs.remove(_keyDiagnosisYear);
      await prefs.remove(_keyA1c);
      await prefs.remove(_keyFastingGlucose);
      await prefs.remove(_keyTargetGlucose);
      await prefs.remove(_keyHeight);
      await prefs.remove(_keyWeight);
      await prefs.remove(_keyBmi);
      await prefs.remove(_keyBloodPressure);
      await prefs.remove(_keyAllergies);
      await prefs.remove(_keyConditions);

      return true;
    } catch (e) {
      print('Error clearing health data: $e');
      return false;
    }
  }

  /// Get default health data
  Map<String, dynamic> _getDefaultData() {
    return {
      'diabetesType': 'Type 2',
      'diagnosisYear': '2018',
      'a1c': '7.2',
      'fastingGlucose': '110',
      'targetGlucose': '70-130',
      'height': '175',
      'weight': '70',
      'bmi': '22.9',
      'bloodPressure': '120/80',
      'allergies': 'Penicillin',
      'conditions': 'Hypertension',
    };
  }
}