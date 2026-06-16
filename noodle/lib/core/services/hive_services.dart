import 'package:hive_flutter/hive_flutter.dart';
import 'package:noodle/core/models/app_settings.dart';

class HiveService {
  static const String boxName = 'app_settings';

  late final Box _box;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  AppSettings getAppSettings() {
    return AppSettings(
      onboardingCompleted: _box.get(
        'onboardingCompleted',
        defaultValue: false,
      ),
      isSharedBrain: _box.get(
        'isSharedBrain',
        defaultValue: true,
      ),
    );
  }

  Future<void> saveAppSettings(
    AppSettings settings,
  ) async {
    await _box.put(
      'onboardingCompleted',
      settings.onboardingCompleted,
    );

    await _box.put(
      'isSharedBrain',
      settings.isSharedBrain,
    );
  }
}