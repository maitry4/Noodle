import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noodle/core/services/hive_services.dart';
import 'package:noodle/core/services/secure_storage_service.dart';

final hiveService = HiveService();
final secureStorageService = SecureStorageService();

final hiveServiceProvider = Provider<HiveService>((ref) {
  return hiveService;
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return secureStorageService;
});

final onboardingStatusProvider = Provider<bool>((ref) {
  final hive = ref.read(hiveServiceProvider);

  return hive.getAppSettings().onboardingCompleted;
});
