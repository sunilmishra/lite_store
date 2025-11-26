import 'package:flutter/material.dart';

import 'user_dao.dart';
import 'user_entity.dart';

class LiteDbPage extends StatefulWidget {
  final UserDao userDao;
  const LiteDbPage({super.key, required this.userDao});

  @override
  State<LiteDbPage> createState() => _LiteDbPageState();
}

class _LiteDbPageState extends State<LiteDbPage> {
  final TextEditingController _nameController = TextEditingController();
  List<UserEntity> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();

    widget.userDao.onDataChanged.listen((updatedUsers) {
      setState(() {
        users = updatedUsers;
      });
    });
  }

  Future<void> _loadUsers() async {
    final allUsers = await widget.userDao.getAll();
    setState(() => users = allUsers);
  }

  Future<void> _addUser() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    await widget.userDao.save(UserEntity(name: name));
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LiteDB Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'User Name'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _addUser, child: const Text('Add User')),
            const SizedBox(height: 16),
            Text(
              'Users in DB:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, index) => ListTile(
                  title: Text(users[index].name),
                  subtitle: Text('ID: ${users[index].id}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
