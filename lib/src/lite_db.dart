import 'dart:developer';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// Callback type for migrations
typedef MigrationCallback =
    void Function(Database db, int oldVersion, int newVersion);

/// Table schema definition
class TableSchema {
  TableSchema({required this.tableName, required this.createSql});

  final String tableName;
  final String createSql;

  @override
  String toString() {
    return 'TableSchema(tableName: $tableName, createSql: $createSql)';
  }
}

/// LiteStoreDB is the main database manager for LiteStore.
/// Responsibilities:
/// - Initialize database
/// - Create tables automatically
/// - Handle migrations using `PRAGMA user_version`
/// - Provide singleton access to the database instance
class LiteStoreDB {
  LiteStoreDB._privateConstructor();
  static final LiteStoreDB instance = LiteStoreDB._privateConstructor();

  late Database _db; // SQLite database instance
  bool _isInitialized = false; // Tracks initialization
  int _dbVersion = 1; // Current DB version
  final List<TableSchema> _tables = [];
  MigrationCallback? _migrationCallback;

  /// Initialize the database
  /// [dbName]: Database file name
  /// [version]: Current DB schema version
  /// [tables]: List of table schemas to create
  /// [migrationCallback]: Callback to handle migrations
  Future<void> init({
    required List<TableSchema> tables,
    String dbName = 'app.db',
    int version = 1,
    MigrationCallback? migrationCallback,
    bool inMemory = false,
  }) async {
    if (_isInitialized) return;

    _tables
      ..clear()
      ..addAll(tables);

    _dbVersion = version;

    _migrationCallback = migrationCallback;

    if (inMemory) {
      _db = sqlite3.openInMemory();
    } else {
      final path = await _getDatabasePath(dbName);
      _db = sqlite3.open(path);
    }

    // Handle table creation and migrations
    await _handleVersionAndMigrations();

    _isInitialized = true;
  }

  /// Get database instance
  /// Throws if init() was not called
  Future<Database> getDatabase() async {
    if (!_isInitialized) throw Exception('Database not initialized.');
    return _db;
  }

  /// Close database
  void close() {
    _db.close();
    _isInitialized = false;
  }

  /// Internal: Handles table creation & migrations using PRAGMA user_version
  Future<void> _handleVersionAndMigrations() async {
    // Get current DB version
    final result = _db.select('PRAGMA user_version;');
    int currentVersion = result.first.values.first as int;

    // First-time table creation
    if (currentVersion == 0) {
      for (final table in _tables) {
        _db.execute(table.createSql);
      }
      log('LiteStoreDB: All tables created.');
    }

    // Run migration if version increased
    if (currentVersion < _dbVersion && _migrationCallback != null) {
      log(
        'LiteStoreDB: Running migration from $currentVersion to $_dbVersion...',
      );
      _migrationCallback!(_db, currentVersion, _dbVersion);
    }

    // Update user_version
    _db.execute('PRAGMA user_version = $_dbVersion;');
  }

  /// Get DB path in application documents directory
  Future<String> _getDatabasePath(String dbName) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      return p.join(appDocDir.path, dbName);
    } catch (_) {
      // Running in pure Dart tests → fallback
      return dbName;
    }
  }
}
