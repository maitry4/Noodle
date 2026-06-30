import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noodle/core/models/user_settings.dart';
import 'package:noodle/core/providers/app_providers.dart';
import 'package:noodle/core/services/hive_services.dart';
import 'package:noodle/core/services/secure_storage_service.dart';

final onboardingDataProvider = Provider<OnboardingData>((ref) {
  return OnboardingData(
    ref.read(hiveServiceProvider),
    ref.read(secureStorageServiceProvider),
  );
});

class OnboardingData {
  OnboardingData(this._hiveService, this._secureStorageService);

  final HiveService _hiveService;
  final SecureStorageService _secureStorageService;

  Future<void> selectSharedBrain() async {
    final settings = _hiveService.getAppSettings();

    await _hiveService.saveAppSettings(settings.copyWith(isSharedBrain: true));
  }

  Future<void> selectOwnApiKey(String apiKey) async {
    await _secureStorageService.saveUserSettings(
      UserSettings(geminiApiKey: apiKey),
    );

    final settings = _hiveService.getAppSettings();

    await _hiveService.saveAppSettings(settings.copyWith(isSharedBrain: false));
  }

  Future<void> completeOnboarding() async {
    final settings = _hiveService.getAppSettings();

    await _hiveService.saveAppSettings(
      settings.copyWith(onboardingCompleted: true),
    );
  }
}
