import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shaalan_catalogue.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        status TEXT DEFAULT 'active'
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        category_id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        product_id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        image_url TEXT,
        archived INTEGER DEFAULT 0,
        new_collection INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (category_id) ON DELETE CASCADE
      )
    ''');

  }

  Future<void> insertUser(int userId, String username, String hashedPassword, String status) async {
    final db = await database;

    await db.insert(
      'users',
      {
        'user_id': userId,
        'username': username,
        'password': hashedPassword, // Use the already hashed password
        'status': status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<bool> checkCredentials(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      final storedHash = maps.first['password'] as String;

      print('Stored Hash: $storedHash');
      print('Password Entered: $password');
      final hashedPassword = maps.first['password'] as String;

      // Check if the provided password matches the stored hash
      bool isMatch = await FlutterBcrypt.verify(password: password, hash: hashedPassword);
      print('Password check result: $isMatch');
      return isMatch;
    }

    // No user found with that username
    return false;
  }

  Future<void> printUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query('users');

    if (users.isEmpty) {
      print('No users found in the database.');
    } else {
      for (var user in users) {
        print('User ID: ${user['user_id']}, Username: ${user['username']}, Password: ${user['password']}, Status: ${user['status']}');
      }
    }
  }
// Add methods to insert, fetch, update, and delete users, categories, and products.
}
