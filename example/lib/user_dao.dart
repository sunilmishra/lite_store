import 'package:lite_store/lite_store.dart';
import 'user_entity.dart';

class UserDao extends Dao<UserEntity> {
  UserDao({required super.databaseCreator}) : super(tableName: 'users');

  TableSchema get schema => TableSchema(
    tableName: 'users',
    createSql:
        'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT);',
  );

  @override
  Future<List<UserEntity>> getAll() async {
    final db = await databaseCreator.getDatabase();
    final rows = db.select('SELECT * FROM users');
    return rows
        .map((r) => UserEntity(id: r['id'] as int, name: r['name'] as String))
        .toList();
  }
}
