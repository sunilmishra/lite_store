import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// Generic key-value store using SharedPreferences.
/// Store private, primitive data in key-value pairs.
class PreferenceStore {
  PreferenceStore({required SharedPreferences sharedPreferences})
    : _preferences = sharedPreferences;

  final SharedPreferences _preferences;
  final StreamController<String> _preferenceChangedStreamController =
      StreamController.broadcast();

  Stream<String> onPreferenceChanged() =>
      _preferenceChangedStreamController.stream;

  Future<bool> saveValue(String key, dynamic value) async {
    bool isSaved = false;

    if (key.isEmpty) {
      assert(key.isEmpty);
      throw Exception('Key can not be empty');
    }

    switch (value.runtimeType) {
      case const (int):
        isSaved = await _preferences.setInt(key, value as int);
        break;
      case const (String):
        isSaved = await _preferences.setString(key, value as String);
        break;
      case const (bool):
        isSaved = await _preferences.setBool(key, value as bool);
        break;
      case const (double):
        isSaved = await _preferences.setDouble(key, value as double);
        break;
    }

    if (value is List<String>) {
      isSaved = await _preferences.setStringList(key, value);
    }

    if (isSaved) {
      _preferenceChangedStreamController.sink.add(key);
    }

    return isSaved;
  }

  dynamic getValue(String key) => _preferences.get(key);

  Future<bool> removeValue(String key) async => await _preferences.remove(key);

  Future<bool> clearAll() async => await _preferences.clear();
}
