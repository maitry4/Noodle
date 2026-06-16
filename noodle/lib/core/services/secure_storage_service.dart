import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:noodle/core/models/user_settings.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  Future<UserSettings> getUserSettings() async {
    return UserSettings(
      geminiApiKey: await _storage.read(
        key: 'gemini_api_key',
      ),
    );
  }

  Future<void> saveUserSettings(
    UserSettings settings,
  ) async {
    await _storage.write(
      key: 'gemini_api_key',
      value: settings.geminiApiKey,
    );
  }
}