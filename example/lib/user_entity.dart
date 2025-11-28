import 'package:lite_store/lite_store.dart';

class UserEntity extends Entity {
  UserEntity({this.id, required this.name});

  final int? id;
  final String name;

  @override
  String get where => 'id = ?';

  @override
  List<Object?> get whereArgs => [id];

  @override
  Map<String, Object?> toMap() => {'id': id, 'name': name};

  factory UserEntity.fromRow(Row row) {
    return UserEntity(id: row['id'] as int?, name: row['name'] as String);
  }
}
