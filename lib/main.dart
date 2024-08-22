import 'package:flutter/material.dart';
import 'home.dart';
import 'sign_in.dart'; // Import your SignInPage file
import 'sync_service.dart'; // Import the sync service file
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  await syncUsers(); // Sync users with the local database
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shaalan Catalogue',
      theme: ThemeData(
          primarySwatch: Colors.red,
          textTheme: GoogleFonts.ralewayTextTheme(
            Theme.of(context).textTheme,
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionColor: Colors.black45,
            selectionHandleColor: Colors.black45,
          ) // You can define your color theme here
      ),
      home: const SignInPage(), // Set SignInPage as the initial page
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomePage(), // Register the HomePage route
      },// Hide the debug banner
    );
  }
}
