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

  // User-related operations
  Future<void> insertUser(int userId, String username, String hashedPassword, String status) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'user_id': userId,
        'username': username,
        'password': hashedPassword,
        'status': status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<void> updateUserStatus(int userId, String status) async {
    final db = await database;
    await db.update(
      'users',
      {'status': status},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteUser(int userId) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Category-related operations
  Future<void> insertCategory(int categoryId, String categoryName) async {
    final db = await database;
    await db.insert(
      'categories',
      {
        'category_id': categoryId,
        'category_name': categoryName,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<void> updateCategory(int categoryId, String categoryName) async {
    final db = await database;
    await db.update(
      'categories',
      {'category_name': categoryName},
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<void> deleteCategory(int categoryId) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  // Product-related operations
  Future<void> insertProduct(
      int productId,
      String productName,
      int categoryId,
      String imageUrl,
      int archived,
      int newCollection) async {
    final db = await database;
    await db.insert(
      'products',
      {
        'product_id': productId,
        'product_name': productName,
        'category_id': categoryId,
        'image_url': imageUrl,
        'archived': archived,
        'new_collection': newCollection,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final db = await database;
    return await db.query('products');
  }

  Future<void> updateProduct(int productId, String productName, int categoryId, String imageUrl, int archived, int newCollection) async {
    final db = await database;
    await db.update(
      'products',
      {
        'product_name': productName,
        'category_id': categoryId,
        'image_url': imageUrl,
        'archived': archived,
        'new_collection': newCollection,
      },
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<void> deleteProduct(int productId) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'product_id = ?',
      whereArgs: [productId],
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
      final hashedPassword = maps.first['password'] as String;

      print('Stored Hash: $hashedPassword');
      print('Password Entered: $password');

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

  Future<void> printCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> categories = await db.query('categories');

    if (categories.isEmpty) {
      print('No categories found in the database.');
    } else {
      for (var category in categories) {
        print('Category ID: ${category['category_id']}, Category Name: ${category['category_name']}');
      }
    }
  }

  Future<void> printProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> products = await db.query('products');

    if (products.isEmpty) {
      print('No products found in the database.');
    } else {
      for (var product in products) {
        print('Product ID: ${product['product_id']}, Product Name: ${product['product_name']}, Category ID: ${product['category_id']}, Image URL: ${product['image_url']}, Archived: ${product['archived']}, New Collection: ${product['new_collection']}');
      }
    }
  }
}
