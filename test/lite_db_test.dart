// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:lite_store/src/lite_db.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiteStoreDB', () {
    late LiteStoreDB db;

    setUp(() async {
      PathProviderPlatform.instance = FakePathProvider();
      db = LiteStoreDB.instance;
    });

    tearDown(() {
      db.close();
    });

    test('should initialize database and create table', () async {
      final table = TableSchema(
        tableName: 'test',
        createSql:
            'CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT)',
      );

      await db.init(
        dbName: 'test.db',
        version: 1,
        tables: [table],
        inMemory: true,
      );

      final database = await db.getDatabase();
      final result = database.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='test';",
      );
      expect(result.length, 1); // table exists
    });

    test('should run migration', () async {
      int migrationCalled = 0;

      final table = TableSchema(
        tableName: 'migration_test',
        createSql:
            'CREATE TABLE IF NOT EXISTS migration_test (id INTEGER PRIMARY KEY, value TEXT)',
      );

      await db.init(
        dbName: 'migration_test.db',
        version: 2,
        tables: [table],
        inMemory: true,
        migrationCallback: (dbInstance, oldVersion, newVersion) {
          migrationCalled = 1;
          dbInstance.execute(
            'ALTER TABLE migration_test ADD COLUMN extra TEXT;',
          );
        },
      );

      expect(migrationCalled, 1);

      final dbInstance = await db.getDatabase();
      final columns = dbInstance.select("PRAGMA table_info(migration_test);");
      expect(columns.any((c) => c['name'] == 'extra'), true);
    });
  });
}

class FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return 'docs';
  }

  @override
  Future<String?> getDownloadsPath() async {
    return 'downloads';
  }

  @override
  Future<String?> getTemporaryPath() async {
    return 'temp';
  }
}
