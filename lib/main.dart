import 'package:flutter/material.dart';
import 'home.dart'; // Import the HomePage widget
import 'sign_in.dart'; // Import the SignInPage widget
import 'sync_service.dart'; // Import the sync service file for various synchronization tasks
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts for custom fonts
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity package to check internet status
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for persisting user login status

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check for internet connectivity
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult != ConnectivityResult.none) {
    // If there is an internet connection, sync various data
    await syncUsers();
    await syncProducts();
    await syncCategories();
    await handleBlockedUsers(); // Check and handle if user is blocked
  } else {
    print('No internet connection. Running offline.');
  }

  // Check if user is signed in
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shaalan Catalogue',
      theme: ThemeData(
        primarySwatch: Colors.red, // Set the primary color of the app
        textTheme: GoogleFonts.ralewayTextTheme(
          Theme.of(context).textTheme, // Use Raleway font for text
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white, // Color of the text cursor
          selectionColor: Colors.black45, // Color of selected text
          selectionHandleColor: Colors.black45, // Color of the text selection handle
        ),
      ),
      home: isLoggedIn ? HomePage() : const SignInPage(), // Check if user is logged in
      debugShowCheckedModeBanner: false, // Remove the debug banner
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => SignInPage(),// Register the route for HomePage
      },
    );
  }
}
