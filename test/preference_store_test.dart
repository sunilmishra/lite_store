import 'package:flutter_test/flutter_test.dart';
import 'package:lite_store/src/preference_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferenceStore Tests', () {
    late SharedPreferences prefs;
    late PreferenceStore store;

    setUp(() async {
      // Reset mock values before each test
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      store = PreferenceStore(sharedPreferences: prefs);
    });

    test('saveValue should save int value', () async {
      final result = await store.saveValue('intKey', 42);

      expect(result, true);
      expect(store.getValue('intKey'), 42);
    });

    test('saveValue should save string value', () async {
      final result = await store.saveValue('strKey', 'hello');

      expect(result, true);
      expect(store.getValue('strKey'), 'hello');
    });

    test('saveValue should save bool value', () async {
      final result = await store.saveValue('boolKey', true);

      expect(result, true);
      expect(store.getValue('boolKey'), true);
    });

    test('saveValue should save double value', () async {
      final result = await store.saveValue('doubleKey', 3.14);

      expect(result, true);
      expect(store.getValue('doubleKey'), 3.14);
    });

    test('saveValue should save string list', () async {
      final list = ['a', 'b', 'c'];
      final result = await store.saveValue('listKey', list);

      expect(result, true);
      expect(store.getValue('listKey'), list);
    });

    test('saveValue throws exception on empty key', () async {
      expect(() async => store.saveValue('', 'value'), throwsException);
    });

    test('removeValue should delete key', () async {
      await store.saveValue('removeKey', 'data');

      final removeResult = await store.removeValue('removeKey');

      expect(removeResult, true);
      expect(store.getValue('removeKey'), null);
    });

    test('clearAll should wipe all values', () async {
      await store.saveValue('a', 1);
      await store.saveValue('b', true);
      await store.saveValue('c', 'hello');

      final result = await store.clearAll();

      expect(result, true);
      expect(store.getValue('a'), null);
      expect(store.getValue('b'), null);
      expect(store.getValue('c'), null);
    });

    test('onPreferenceChanged emits correct key', () async {
      final events = <String>[];
      final sub = store.onPreferenceChanged().listen(events.add);

      await store.saveValue('changeKey', 'value');

      // Allow async event to propagate
      await Future.delayed(const Duration(milliseconds: 10));

      expect(events.length, 1);
      expect(events.first, 'changeKey');

      await sub.cancel();
    });
  });
}
