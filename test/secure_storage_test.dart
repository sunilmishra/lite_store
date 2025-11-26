import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lite_store/src/secure_storage.dart';

void main() {
  group('SecureStorageImpl Tests', () {
    late SecureStorageImpl storage;

    setUp(() async {
      FlutterSecureStorage.setMockInitialValues({});
      storage = SecureStorageImpl(secureStorage: FlutterSecureStorage());
    });

    test('write() stores value', () async {
      await storage.write('token', '12345');
      final result = await storage.read('token');
      expect(result, '12345');
    });

    test('write() throws on empty key', () {
      expect(() => storage.write('', 'x'), throwsException);
    });

    test('read() returns null for missing key', () async {
      final result = await storage.read('missing');
      expect(result, null);
    });

    test('delete() removes a key', () async {
      await storage.write('key', 'data');
      await storage.delete('key');

      final value = await storage.read('key');
      expect(value, null);
    });

    test('deleteAll() clears everything', () async {
      await storage.write('a', '1');
      await storage.write('b', '2');
      await storage.deleteAll();

      expect(await storage.read('a'), null);
      expect(await storage.read('b'), null);
    });
  });
}
