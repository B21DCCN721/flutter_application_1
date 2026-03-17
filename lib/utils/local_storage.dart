import 'package:get_storage/get_storage.dart';

class LocalStorage {
  static final _box = GetStorage();

  static Future<String> getString(String key) async {
    return _box.read(key) ?? "";
  }

  static Future<void> putString(String key, String value) async {
    await _box.write(key, value);
  }

  static double getDouble(String key, {double defaultValue = 1.0}) {
    return _box.read(key) ?? defaultValue;
  }

  static Future<void> putDouble(String key, double value) async {
    await _box.write(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _box.read(key) ?? defaultValue;
  }

  static Future<void> putBool(String key, bool value) async {
    await _box.write(key, value);
  }

  static Future<void> remove(String key) async {
    await _box.remove(key);
  }

  static Future<void> clear() async {
    await _box.erase();
  }
}
