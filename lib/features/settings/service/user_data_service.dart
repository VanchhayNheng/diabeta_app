import 'package:shared_preferences/shared_preferences.dart';

/// Service class to handle user service persistence
class UserDataService {
  static const String _keyPrefix = 'user_';

  // Keys for each field
  static const String _keyName = '${_keyPrefix}name';
  static const String _keyEmail = '${_keyPrefix}email';
  static const String _keyPhone = '${_keyPrefix}phone';
  static const String _keyDateOfBirth = '${_keyPrefix}dateOfBirth';
  static const String _keyGender = '${_keyPrefix}gender';
  static const String _keyAddress = '${_keyPrefix}address';
  static const String _keyEmergencyContact = '${_keyPrefix}emergencyContact';
  static const String _keyEmergencyPhone = '${_keyPrefix}emergencyPhone';

  /// Load user service from local storage
  /// Returns default values if no service is saved
  Future<Map<String, String>> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'name': prefs.getString(_keyName) ?? 'Nick Wilde',
        'email': prefs.getString(_keyEmail) ?? 'nick.w@email.com',
        'phone': prefs.getString(_keyPhone) ?? '+1 (555) 123-4567',
        'dateOfBirth': prefs.getString(_keyDateOfBirth) ?? '1990-05-15',
        'gender': prefs.getString(_keyGender) ?? 'Male',
        'address': prefs.getString(_keyAddress) ?? '123 Main Street, Zootopia',
        'emergencyContact': prefs.getString(_keyEmergencyContact) ?? 'Judy Hopps',
        'emergencyPhone': prefs.getString(_keyEmergencyPhone) ?? '+1 (555) 987-6543',
      };
    } catch (e) {
      // If there's an error, return default values
      print('Error loading user service: $e');
      return _getDefaultData();
    }
  }

  /// Save user service to local storage
  Future<bool> saveUserData(Map<String, String> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyName, userData['name'] ?? '');
      await prefs.setString(_keyEmail, userData['email'] ?? '');
      await prefs.setString(_keyPhone, userData['phone'] ?? '');
      await prefs.setString(_keyDateOfBirth, userData['dateOfBirth'] ?? '');
      await prefs.setString(_keyGender, userData['gender'] ?? '');
      await prefs.setString(_keyAddress, userData['address'] ?? '');
      await prefs.setString(_keyEmergencyContact, userData['emergencyContact'] ?? '');
      await prefs.setString(_keyEmergencyPhone, userData['emergencyPhone'] ?? '');

      return true;
    } catch (e) {
      print('Error saving user service: $e');
      return false;
    }
  }

  /// Clear all user service from local storage
  Future<bool> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyName);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyPhone);
      await prefs.remove(_keyDateOfBirth);
      await prefs.remove(_keyGender);
      await prefs.remove(_keyAddress);
      await prefs.remove(_keyEmergencyContact);
      await prefs.remove(_keyEmergencyPhone);

      return true;
    } catch (e) {
      print('Error clearing user service: $e');
      return false;
    }
  }

  /// Get default user service
  Map<String, String> _getDefaultData() {
    return {
      'name': 'Nick Wilde',
      'email': 'nick.w@email.com',
      'phone': '+1 (555) 123-4567',
      'dateOfBirth': '1990-05-15',
      'gender': 'Male',
      'address': '123 Main Street, Zootopia',
      'emergencyContact': 'Judy Hopps',
      'emergencyPhone': '+1 (555) 987-6543',
    };
  }

  /// Get only name and email for profile display
  Future<Map<String, String>> getProfileBasicInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'name': prefs.getString(_keyName) ?? 'Nick Wilde',
        'email': prefs.getString(_keyEmail) ?? 'nick.w@email.com',
      };
    } catch (e) {
      print('Error loading profile info: $e');
      return {
        'name': 'Nick Wilde',
        'email': 'nick.w@email.com',
      };
    }
  }
}