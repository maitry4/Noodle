import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceUuidService {
  static const _key = 'device_uuid';

  /// Returns a persistent UUID for this device. Generates and stores it on first call.
  static Future<String> getDeviceUuid() async {
    final prefs = await SharedPreferences.getInstance();
    var uuid = prefs.getString(_key);
    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString(_key, uuid);
    }
    return uuid;
  }
}
