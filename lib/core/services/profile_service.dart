import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  static const String _profileImageKey = 'profile_image_path';

  /// Get saved profile image path
  static Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageKey);
  }

  /// Save profile image path
  static Future<bool> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_profileImageKey, path);
  }

  /// Remove profile image
  static Future<bool> removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_profileImageKey);
  }

  /// Pick image from gallery
  static Future<String?> pickProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      await saveProfileImagePath(image.path);
      return image.path;
    }
    return null;
  }

  /// Take photo with camera
  static Future<String?> takeProfilePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      await saveProfileImagePath(image.path);
      return image.path;
    }
    return null;
  }
}