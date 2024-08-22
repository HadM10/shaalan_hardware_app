import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_helper.dart'; // Assuming this is your DatabaseHelper file

Future<void> syncUsers() async {
  final url = 'http://192.168.1.4/shaalan_catalogue/api/get_users.php'; // Replace with your server URL
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> users = jsonDecode(response.body);
      for (var user in users) {
        await DatabaseHelper().insertUser(
          int.parse(user['user_id']),
          user['username'],
          user['password'],
          user['status'],
        );
      }
      print('Users synced successfully');
      await DatabaseHelper().printUsers(); // Print users after syncing
    } else {
      print('Failed to fetch users');
    }
  } catch (e) {
    print('Error: $e');
  }
}

