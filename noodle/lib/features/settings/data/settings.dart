import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noodle/core/models/user_settings.dart';
import 'package:noodle/core/providers/app_providers.dart';
import 'package:noodle/core/services/hive_services.dart';
import 'package:noodle/core/services/secure_storage_service.dart';

final settingsProvider = Provider<SettingsController>((ref) {
  return SettingsController(
    ref.read(hiveServiceProvider),
    ref.read(secureStorageServiceProvider),
  );
});

class SettingsController {
  SettingsController(this._hiveService, this._secureStorageService);

  final HiveService _hiveService;

  final SecureStorageService _secureStorageService;

  bool get isSharedBrain {
    return _hiveService.getAppSettings().isSharedBrain;
  }

  Future<void> setSharedBrain(bool value) async {
    final settings = _hiveService.getAppSettings();

    await _hiveService.saveAppSettings(settings.copyWith(isSharedBrain: value));
  }

  Future<void> saveApiKey(String key) async {
    await _secureStorageService.saveUserSettings(
      UserSettings(geminiApiKey: key),
    );
  }

  Future<String?> getApiKey() async {
    final data = await _secureStorageService.getUserSettings();

    return data.geminiApiKey;
  }
}
