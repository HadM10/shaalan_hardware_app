import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'database_helper.dart';

Future<void> syncUsers() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult != ConnectivityResult.none) {
    final url = 'http://192.168.1.9/shaalan_catalogue/api/get_users.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> users = jsonDecode(response.body);

        // Fetch local users
        List<Map<String, dynamic>> localUsers = await DatabaseHelper().fetchUsers();

        for (var user in users) {
          int userId = int.parse(user['user_id']);
          String username = user['username'];
          String password = user['password'];
          String status = user['status'];

          // Check if the user exists locally
          bool exists = localUsers.any((u) => u['user_id'] == userId);

          if (exists) {
            // Update existing user
            await DatabaseHelper().updateUserStatus(userId, status);
          } else {
            // Insert new user
            await DatabaseHelper().insertUser(userId, username, password, status);
          }
        }

        // Optionally print users after syncing
        await DatabaseHelper().printUsers();
        print('Users synced successfully');
      } else {
        print('Failed to fetch users');
      }
    } catch (e) {
      print('Error: $e');
    }
  } else {
    print('No internet connection. Running offline.');
  }
}

Future<void> syncCategories() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult != ConnectivityResult.none) {
    final url = 'http://192.168.1.9/shaalan_catalogue/api/view_categories.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> categories = jsonDecode(response.body);

        // Fetch local categories
        List<Map<String, dynamic>> localCategories = await DatabaseHelper().fetchCategories();

        for (var category in categories) {
          int categoryId = int.parse(category['category_id']);
          String categoryName = category['category_name'];

          // Check if the category exists locally
          bool exists = localCategories.any((c) => c['category_id'] == categoryId);

          if (exists) {
            // Update existing category
            await DatabaseHelper().updateCategory(categoryId, categoryName);
          } else {
            // Insert new category
            await DatabaseHelper().insertCategory(categoryId, categoryName);
          }
        }

        // Handle deletions - Remove categories not in the fetched data
        for (var localCategory in localCategories) {
          if (!categories.any((c) => c['category_id'] == localCategory['category_id'])) {
            await DatabaseHelper().deleteCategory(localCategory['category_id']);
          }
        }

        // Optionally print categories after syncing
        await DatabaseHelper().printCategories();
        print('Categories synced successfully');
      } else {
        print('Failed to fetch categories');
      }
    } catch (e) {
      print('Error: $e');
    }
  } else {
    print('No internet connection. Running offline.');
  }
}

Future<void> syncProducts() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult != ConnectivityResult.none) {
    final url = 'http://192.168.1.9/shaalan_catalogue/api/view_products.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> products = jsonDecode(response.body);

        // Fetch local products
        List<Map<String, dynamic>> localProducts = await DatabaseHelper().fetchProducts();

        for (var product in products) {
          try {
            // Safely parse each field, ensuring correct data types
            int productId = product['product_id'] is int ? product['product_id'] : int.parse(product['product_id'].toString());
            String productName = product['product_name'] is String ? product['product_name'] : product['product_name'].toString();
            int categoryId = product['category_id'] is int ? product['category_id'] : int.parse(product['category_id'].toString());
            String imageUrl = product['image_url'] is String ? product['image_url'] : product['image_url'].toString();
            int archived = product['archived'] is int ? product['archived'] : int.parse(product['archived'].toString());
            int newCollection = product['new_collection'] is int ? product['new_collection'] : int.parse(product['new_collection'].toString());

            // Check if the product exists locally
            bool exists = localProducts.any((p) => p['product_id'] == productId);

            if (exists) {
              // Update existing product
              await DatabaseHelper().updateProduct(
                  productId,
                  productName,
                  categoryId,
                  imageUrl,
                  archived,
                  newCollection
              );
            } else {
              // Insert new product
              await DatabaseHelper().insertProduct(
                  productId,
                  productName,
                  categoryId,
                  imageUrl,
                  archived,
                  newCollection
              );
            }
          } catch (e) {
            print('Error processing product: $e');
          }
        }

        // Handle deletions - Remove products not in the fetched data
        for (var localProduct in localProducts) {
          if (!products.any((p) => p['product_id'] == localProduct['product_id'])) {
            await DatabaseHelper().deleteProduct(localProduct['product_id']);
          }
        }

        // Optionally print products after syncing
        await DatabaseHelper().printProducts();
        print('Products synced successfully');
      } else {
        print('Failed to fetch products');
      }
    } catch (e) {
      print('Error: $e');
    }
  } else {
    print('No internet connection. Running offline.');
  }
}

