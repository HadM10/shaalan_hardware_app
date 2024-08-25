import 'package:flutter_bcrypt/flutter_bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    try {
      return await db.query('categories');
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
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

  Future<List<Map<String, dynamic>>> fetchProducts({
    String? searchQuery,
    int? categoryId,
    bool? isNewCollection, // Parameter for filtering by new collection
  }) async {
    final db = await database;

    // Building the WHERE clause and arguments dynamically
    String whereClause = 'archived = 0'; // Filter out archived products
    List<dynamic> whereArgs = [];

    // Add filter for search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += " AND product_name LIKE ?";
      whereArgs.add('%$searchQuery%');
    }

    // Add filter for category ID
    if (categoryId != null) {
      whereClause += " AND category_id = ?";
      whereArgs.add(categoryId);
    }

    // Add filter for new collection
    if (isNewCollection != null) {
      whereClause += " AND new_collection = ?";
      whereArgs.add(isNewCollection ? 1 : 0);
    }

    // Query the database with the dynamic WHERE clause and arguments
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    return maps;
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

  Future<Map<String, dynamic>> checkCredentials(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      final user = maps.first;
      final hashedPassword = user['password'] as String;
      final status = user['status'] as String;

      bool isMatch = await FlutterBcrypt.verify(password: password, hash: hashedPassword);

      if (isMatch) {
        return {'valid': true, 'status': status}; // Credentials are correct
      } else {
        return {'valid': false, 'status': 'invalid_password'}; // Wrong password
      }
    }

    return {'valid': false, 'status': 'user_not_found'}; // User not found
  }

  Future<String> getUserStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username'); // Assuming you store the username in SharedPreferences

    if (username == null) {
      return 'unknown';
    }

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      final user = maps.first;
      return user['status'] as String;
    }

    return 'user_not_found';
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
    List<Map<String, dynamic>> categories = await db.query('categories');
    print('Categories in database: $categories');
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
