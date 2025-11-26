import 'package:flutter_test/flutter_test.dart';
import 'package:lite_store/src/dao.dart';
import 'package:lite_store/src/entity.dart';
import 'package:lite_store/src/lite_db.dart';

/// ------------------------------------------------------
/// Mock Entity
/// ------------------------------------------------------
class MockEntity extends Entity {
  final int? id;
  final String value;

  MockEntity({this.id, required this.value});

  @override
  String get where => 'id = ?';

  @override
  List<Object?> get whereArgs => [id];

  @override
  Map<String, Object?> toMap() {
    return {'id': id, 'value': value};
  }
}

/// ------------------------------------------------------
/// Mock DAO
/// ------------------------------------------------------
class MockDao extends Dao<MockEntity> {
  MockDao({required LiteStoreDB db})
    : super(databaseCreator: db, tableName: 'mock');

  @override
  Future<List<MockEntity>> getAll() async {
    final db = await databaseCreator.getDatabase();
    final rows = db.select('SELECT * FROM mock');

    return rows.map((row) {
      return MockEntity(id: row['id'] as int?, value: row['value'] as String);
    }).toList();
  }

  /// Schema for tests
  TableSchema get schema => TableSchema(
    tableName: 'mock',
    createSql: '''
          CREATE TABLE IF NOT EXISTS mock (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value TEXT
          );
        ''',
  );
}

/// ------------------------------------------------------
/// Actual Unit Tests
/// ------------------------------------------------------
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dao<T>', () {
    late LiteStoreDB db;
    late MockDao dao;

    setUp(() async {
      db = LiteStoreDB.instance;
      dao = MockDao(db: db);

      // Initialize in isolated DB
      await db.init(
        dbName: 'dao_test.db',
        version: 1,
        tables: [dao.schema],
        inMemory: true,
      );
    });

    tearDown(() {
      db.close();
    });

    test('save() should insert entity', () async {
      await dao.save(MockEntity(value: 'hello'));

      final items = await dao.getAll();
      expect(items.length, 1);
      expect(items.first.value, 'hello');
    });

    test('update() should modify existing entity', () async {
      await dao.save(MockEntity(value: 'before'));
      final original = (await dao.getAll()).first;

      await dao.update(MockEntity(id: original.id, value: 'after'));

      final updated = await dao.getAll();
      expect(updated.first.value, 'after');
    });

    test('remove() should delete the entity', () async {
      await dao.save(MockEntity(value: 'delete-me'));
      final first = (await dao.getAll()).first;

      await dao.remove(first);

      final items = await dao.getAll();
      expect(items.isEmpty, true);
    });

    test('onDataChanged should emit updated list on DB change', () async {
      final emittedValues = <List<MockEntity>>[];

      final sub = dao.onDataChanged.listen((event) {
        emittedValues.add(event);
      });

      // Trigger changes
      await dao.save(MockEntity(value: 'one'));
      await dao.save(MockEntity(value: 'two'));

      // Wait for stream updates
      await Future.delayed(const Duration(milliseconds: 50));

      expect(emittedValues.length >= 2, true);
      expect(emittedValues.last.length, 2);
      expect(emittedValues.last.last.value, 'two');

      await sub.cancel();
    });

    test(
      'save(), update(), remove() should trigger change notifications',
      () async {
        final notifications = <String>[];

        dao.changeStream.listen((name) {
          notifications.add(name);
        });

        await dao.save(MockEntity(value: 'a'));
        await dao.update(MockEntity(id: 1, value: 'b'));
        await dao.remove(MockEntity(id: 1, value: 'b'));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(notifications.length, 3);
        expect(notifications.every((n) => n == 'mock'), true);
      },
    );
  });
}
