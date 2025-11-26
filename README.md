# 📦 LiteStore
### Lightweight local storage suite for Flutter (SQLite3 + Preferences + Secure Storage)

**LiteStore** is a fast, lightweight, dependency-minimal local-storage solution for Flutter apps.  
It combines three components:

- **LiteDB** – SQLite3 only database with migrations and reactive DAO pattern  
  - Version 3.1.0 of sqlite3 is a major update relying on build hooks and code assets to load SQLite.
  - Because this library uses hooks, it bundles SQLite with your application and doesn't require any external dependencies or build configuration.
  
- **PreferenceStore** – Key-value storage wrapper (SharedPreferences)  
  
- **SecureStorage** – Encrypted storage (Keychain/Keystore)  

LiteStore focuses on **minimalism**, **performance**, and **testability**.

---

# ✨ Features

### 🧱 LiteDB (SQLite3)
- sqlite3 (no sqflite)
- Auto table creation
- Version-based migrations (`PRAGMA user_version`)
- DAO + Entity pattern
- Reactive `onDataChanged` stream
- In-memory mode for testing
- Lightweight

### 🔧 PreferenceStore
- Wrapper around SharedPreferences
- Stores primitives + `List<String>`
- Emits change events via stream

### 🔐 SecureStorage
- Wrapper around flutter_secure_storage
- Encrypted storage on iOS/Android
- Supports mocks for tests

### 🧠 Database Example

    1️⃣ Define an Entity

    class UserEntity extends Entity {
    final int? id;
    final String name;

    UserEntity({this.id, required this.name});

    @override
    String get where => 'id = ?';

    @override
    List get whereArgs => [id];

    @override
    Map<String, dynamic> toMap() => {
            'id': id,
            'name': name,
        };
    }

    2️⃣ Create a DAO

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
            .map((r) => UserEntity(id: r['id'] as int, name: r['name']))
            .toList();
    }
    }

    3️⃣ Initialize Database
    
    final db = LiteStoreDB.instance;
    await db.init(
    dbName: 'app.db',
    version: 2,
    tables: [userDao.schema],
    migrationCallback: (db, oldV, newV) {
        if (oldV == 1) {
        db.execute('ALTER TABLE users ADD COLUMN age INT;');
        }
    },
    );

    4️⃣ CRUD + Reactive Updates

    await userDao.save(UserEntity(name: "Alice"));
    userDao.onDataChanged.listen((users) {
    print('Users updated: ${users.length}');
    });

### 🔧 PreferenceStore Example
    final prefs = await SharedPreferences.getInstance();
    final store = PreferenceStore(sharedPreferences: prefs);

    await store.saveValue('token', 'abc123');
    print(store.getValue('token'));

    ----Listen for changes:----
    store.onPreferenceChanged().listen((key) {
    print('Preference changed: $key');
    });

### 🔐 SecureStorage Example
    final sec = SecureStorageImpl();

    await sec.write('auth_token', 'secret');
    final token = await sec.read('auth_token');
    await sec.delete('auth_token');
    await sec.deleteAll();

## 💡 Why LiteStore?
✔ Minimal dependencies

✔ Pure SQLite3 performance

✔ Clean architecture–friendly

✔ Reactive streams for live updates

✔ Extremely simple API

### Thank you!!
LiteStore gives you a complete, lightweight local storage solution for Flutter — from reactive SQLite tables to secure encrypted storage and simple preferences.

Whether you're building a small app or a full-featured production project, LiteStore keeps your storage fast, minimal, and reliable.

Start integrating it today and simplify your Flutter data layer.

Happy Coding 😄