// ignore_for_file: depend_on_referenced_packages

import 'package:example/lite_db_page.dart';
import 'package:example/prefs_page.dart';
import 'package:example/secure_storage_page.dart';
import 'package:flutter/material.dart';
import 'package:lite_store/lite_store.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'user_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final preferenceStore = PreferenceStore(sharedPreferences: prefs);

  // Initialize SecureStorage
  final secureStore = SecureStorageImpl();

  // Initialize LiteStoreDB and UserDao
  final db = LiteStoreDB.instance;
  final userDao = UserDao(databaseCreator: db);

  await db.init(dbName: 'app.db', version: 1, tables: [userDao.schema]);

  runApp(
    MyApp(
      userDao: userDao,
      preferenceStore: preferenceStore,
      secureStore: secureStore,
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserDao userDao;
  final PreferenceStore preferenceStore;
  final SecureStorageImpl secureStore;

  const MyApp({
    super.key,
    required this.userDao,
    required this.preferenceStore,
    required this.secureStore,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LiteStore Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(
        userDao: userDao,
        preferenceStore: preferenceStore,
        secureStore: secureStore,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final UserDao userDao;
  final PreferenceStore preferenceStore;
  final SecureStorageImpl secureStore;

  const HomePage({
    super.key,
    required this.userDao,
    required this.preferenceStore,
    required this.secureStore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LiteStore Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LiteDbPage(userDao: userDao)),
              ),
              child: const Text('LiteDB Example'),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrefsPage(preferenceStore: preferenceStore),
                ),
              ),
              child: const Text('PreferenceStore Example'),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SecureStoragePage(secureStore: secureStore),
                ),
              ),
              child: const Text('SecureStorage Example'),
            ),
          ],
        ),
      ),
    );
  }
}
