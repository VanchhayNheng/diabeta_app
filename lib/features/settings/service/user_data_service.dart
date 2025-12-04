import 'package:shared_preferences/shared_preferences.dart';
//
// /// Service class to handle user data persistence
// class UserDataService {
//   static const String _keyPrefix = 'user_';
//
//   // Keys for each field
//   static const String _keyName = '${_keyPrefix}name';
//   static const String _keyEmail = '${_keyPrefix}email';
//   static const String _keyPhone = '${_keyPrefix}phone';
//   static const String _keyDateOfBirth = '${_keyPrefix}dateOfBirth';
//   static const String _keyGender = '${_keyPrefix}gender';
//   static const String _keyAddress = '${_keyPrefix}address';
//   static const String _keyEmergencyContact = '${_keyPrefix}emergencyContact';
//   static const String _keyEmergencyPhone = '${_keyPrefix}emergencyPhone';
//   static const String _keyUserId = '${_keyPrefix}userId';
//
//
//
//
//   /// Load user data from local storage
//   /// Returns default values if no data is saved
//   Future<Map<String, String>> loadUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       return {
//         'name': prefs.getString(_keyName) ?? 'Nick Wilde',
//         'email': prefs.getString(_keyEmail) ?? 'nick.w@email.com',
//         'phone': prefs.getString(_keyPhone) ?? '+1 (555) 123-4567',
//         'dateOfBirth': prefs.getString(_keyDateOfBirth) ?? '1990-05-15',
//         'gender': prefs.getString(_keyGender) ?? 'Male',
//         'address': prefs.getString(_keyAddress) ?? '123 Main Street, Zootopia',
//         'emergencyContact': prefs.getString(_keyEmergencyContact) ?? 'Judy Hopps',
//         'emergencyPhone': prefs.getString(_keyEmergencyPhone) ?? '+1 (555) 987-6543',
//       };
//     } catch (e) {
//       // If there's an error, return default values
//       print('Error loading user data: $e');
//       return _getDefaultData();
//     }
//   }
//
//   /// Save user data to local storage
//   Future<bool> saveUserData(Map<String, String> userData) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       await prefs.setString(_keyName, userData['name'] ?? '');
//       await prefs.setString(_keyEmail, userData['email'] ?? '');
//       await prefs.setString(_keyPhone, userData['phone'] ?? '');
//       await prefs.setString(_keyDateOfBirth, userData['dateOfBirth'] ?? '');
//       await prefs.setString(_keyGender, userData['gender'] ?? '');
//       await prefs.setString(_keyAddress, userData['address'] ?? '');
//       await prefs.setString(_keyEmergencyContact, userData['emergencyContact'] ?? '');
//       await prefs.setString(_keyEmergencyPhone, userData['emergencyPhone'] ?? '');
//
//       return true;
//     } catch (e) {
//       print('Error saving user data: $e');
//       return false;
//     }
//   }
//
//   /// Clear all user data from local storage
//   Future<bool> clearUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       await prefs.remove(_keyName);
//       await prefs.remove(_keyEmail);
//       await prefs.remove(_keyPhone);
//       await prefs.remove(_keyDateOfBirth);
//       await prefs.remove(_keyGender);
//       await prefs.remove(_keyAddress);
//       await prefs.remove(_keyEmergencyContact);
//       await prefs.remove(_keyEmergencyPhone);
//
//       return true;
//     } catch (e) {
//       print('Error clearing user data: $e');
//       return false;
//     }
//   }
//
//   /// Get default user data
//   Map<String, String> _getDefaultData() {
//     return {
//       'name': 'Nick Wilde',
//       'email': 'nick.w@email.com',
//       'phone': '+1 (555) 123-4567',
//       'dateOfBirth': '1990-05-15',
//       'gender': 'Male',
//       'address': '123 Main Street, Zootopia',
//       'emergencyContact': 'Judy Hopps',
//       'emergencyPhone': '+1 (555) 987-6543',
//     };
//   }
//
//   /// Get only name and email for profile display
//   Future<Map<String, String>> getProfileBasicInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       return {
//         'name': prefs.getString(_keyName) ?? 'Nick Wilde',
//         'email': prefs.getString(_keyEmail) ?? 'nick.w@email.com',
//       };
//     } catch (e) {
//       print('Error loading profile info: $e');
//       return {
//         'name': 'Nick Wilde',
//         'email': 'nick.w@email.com',
//       };
//     }
//   }
//
//   /// Get or generate user ID for API calls
//   Future<String> getUserId() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? userId = prefs.getString(_keyUserId);
//
//       if (userId == null) {
//         // Generate a unique user ID based on email or create a random one
//         final email = prefs.getString(_keyEmail) ?? 'user';
//         userId = '${email.split('@')[0]}_${DateTime.now().millisecondsSinceEpoch}';
//         await prefs.setString(_keyUserId, userId);
//       }
//
//       return 'alice_session';//userId;
//     } catch (e) {
//       print('Error getting user ID: $e');
//       return 'default_user_${DateTime.now().millisecondsSinceEpoch}';
//     }
//   }
// }


import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_services.dart';

class UserDataService {
  static const String _userIdKey = 'user_id';
  final UserService _userService = UserService();

  /// Get stored user ID from local storage
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey) ?? 'alice_session'; // Default user for testing
  }

  /// Set user ID in local storage
  Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  /// Get basic profile info (name and email) - used for HomeScreen and SettingsScreen
  Future<Map<String, String>> getProfileBasicInfo() async {
    try {
      final userId = await getUserId();
      final userData = await _userService.getUserInfo(userId);

      return {
        'name': userData['full_name'] ?? 'Nick Wilde',
        'email': userData['email'] ?? 'nick.w@email.com',
      };
    } catch (e) {
      print('Error loading profile basic info: $e');
      // Return default values on error
      return {
        'name': 'Nick Wilde',
        'email': 'nick.w@email.com',
      };
    }
  }

  /// Load full user data from API
  Future<Map<String, String>> loadUserData() async {
    try {
      final userId = await getUserId();
      final userData = await _userService.getUserInfo(userId);

      return {
        'name': userData['full_name'] ?? '',
        'email': userData['email'] ?? '',
        'phone': userData['phone'] ?? '',
        'dateOfBirth': userData['date_of_birth'] ?? '',
        'gender': userData['gender'] ?? '',
        'address': userData['address'] ?? '',
        'emergencyContact': userData['emergency_contact_name'] ?? '',
        'emergencyPhone': userData['emergency_contact_phone'] ?? '',
        'a1c': userData['a1c']?.toString() ?? '',
        'weight': userData['weight']?.toString() ?? '',
        'age': userData['age']?.toString() ?? '',
      };
    } catch (e) {
      print('Error loading user data: $e');
      rethrow;
    }
  }

  /// Save user data to API
  Future<bool> saveUserData(Map<String, String> userData) async {
    try {
      final userId = await getUserId();

      await _userService.updateUser(
        userId: userId,
        email: userData['email'] ?? '',
        fullName: userData['name'] ?? '',
        phone: userData['phone'] ?? '',
        dateOfBirth: userData['dateOfBirth'] ?? '',
        gender: userData['gender'] ?? '',
        address: userData['address'],
        emergencyContactName: userData['emergencyContact'],
        emergencyContactPhone: userData['emergencyPhone'],
        a1c: userData['a1c'] != null && userData['a1c']!.isNotEmpty
            ? double.tryParse(userData['a1c']!)
            : null,
        weight: userData['weight'] != null && userData['weight']!.isNotEmpty
            ? double.tryParse(userData['weight']!)
            : null,
      );

      return true;
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  /// Create new user via API
  Future<bool> createUser({
    required String userId,
    required String email,
    required String fullName,
    required String phone,
    required String dateOfBirth,
    required String gender,
    double? a1c,
    double? weight,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      await _userService.createUser(
        userId: userId,
        email: email,
        fullName: fullName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        a1c: a1c,
        weight: weight,
        address: address,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
      );

      // Save the userId to local storage
      await setUserId(userId);

      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }
}