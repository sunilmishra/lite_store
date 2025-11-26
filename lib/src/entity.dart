/// Base class for all entities.
/// Every entity should extend this class and implement:
/// - `where` & `whereArgs` for update/delete operations
/// - `toMap()` for insert/update
abstract class Entity {
  const Entity();

  /// SQL WHERE clause for update/delete
  String get where;

  /// Arguments for the WHERE clause
  List<Object?> get whereArgs;

  /// Convert entity to map for insert/update
  Map<String, Object?> toMap();
}
