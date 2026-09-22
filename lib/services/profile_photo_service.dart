import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the user's profile photo locally as a base64 string, keyed by
/// user id, so it survives app restarts without needing a backend upload
/// endpoint.
class ProfilePhotoService {
  static String _keyFor(String userId) => 'profile_photo_$userId';

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndSave(
    String userId, {
    required ImageSource source,
  }) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final base64Str = base64Encode(bytes);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(userId), base64Str);

    return base64Str;
  }

  Future<String?> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFor(userId));
  }

  Future<void> remove(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(userId));
  }
}
