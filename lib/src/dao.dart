import 'dart:async';

import 'entity.dart';
import 'lite_db.dart';

/// Generic DAO (Data Access Object) for LiteStore.
/// Provides:
/// - CRUD operations
/// - Reactive streams via `onDataChanged`
abstract class Dao<T extends Entity> {
  Dao({
    required this.databaseCreator,
    required this.tableName,
    StreamController<String>? changeListener,
  }) {
    _changeListener = changeListener ?? StreamController<String>.broadcast();
  }

  final LiteStoreDB databaseCreator;
  final String tableName;

  late final StreamController<String> _changeListener;

  Stream<String> get changeStream => _changeListener.stream;

  /// Save entity
  Future<int> save(T entity) async {
    final db = await databaseCreator.getDatabase();
    final keys = entity.toMap().keys.join(', ');
    final placeholders = List.filled(entity.toMap().length, '?').join(', ');
    final stmt = db.prepare(
      'INSERT INTO $tableName ($keys) VALUES ($placeholders)',
    );
    stmt.execute(entity.toMap().values.toList());
    stmt.close();
    _notifyChange();
    return 1;
  }

  Future<int> saveAll(List<T> entities) async {
    final db = await databaseCreator.getDatabase();
    final batch = db.prepare(
      'INSERT INTO $tableName (${entities.first.toMap().keys.join(', ')}) '
      'VALUES (${List.filled(entities.first.toMap().length, '?').join(', ')})',
    );

    db.execute('BEGIN TRANSACTION;');
    for (var entity in entities) {
      batch.execute(entity.toMap().values.toList());
    }
    db.execute('COMMIT;');
    batch.close();
    _notifyChange();
    return entities.length;
  }

  /// Update entity
  Future<int> update(T entity) async {
    final db = await databaseCreator.getDatabase();
    final setClause = entity.toMap().keys.map((k) => '$k = ?').join(', ');
    final stmt = db.prepare(
      'UPDATE $tableName SET $setClause WHERE ${entity.where}',
    );
    stmt.execute([...entity.toMap().values, ...entity.whereArgs]);
    stmt.close();
    _notifyChange();
    return 1;
  }

  /// Delete entity
  Future<int> remove(T entity) async {
    final db = await databaseCreator.getDatabase();
    final stmt = db.prepare('DELETE FROM $tableName WHERE ${entity.where}');
    stmt.execute(entity.whereArgs);
    stmt.close();
    _notifyChange();
    return 1;
  }

  /// Get all entities
  Future<List<T>> getAll();

  /// Reactive stream for table changes
  Stream<List<T>> get onDataChanged {
    final controller = StreamController<List<T>>.broadcast();

    // Load initial data
    Future<void> refresh() async {
      final items = await getAll();
      controller.add(items);
    }

    controller.onListen = () => refresh();

    // Listen to table changes
    final subscription = _changeListener.stream.listen((_) => refresh());

    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }

  /// Notify table change
  void _notifyChange() {
    _changeListener.add(tableName);
  }
}
