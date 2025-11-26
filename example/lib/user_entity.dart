import 'package:lite_store/lite_store.dart';

class UserEntity extends Entity {
  final int? id;
  final String name;

  UserEntity({this.id, required this.name});

  @override
  String get where => 'id = ?';

  @override
  List get whereArgs => [id];

  @override
  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}
