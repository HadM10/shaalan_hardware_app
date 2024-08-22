import 'package:flutter/material.dart';
import 'home.dart'; // Import the HomePage widget
import 'sign_in.dart'; // Import the SignInPage widget
import 'sync_service.dart'; // Import the sync service file for various synchronization tasks
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts for custom fonts
import 'package:connectivity_plus/connectivity_plus.dart'; // Import connectivity package to check internet status

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized before performing async operations

  // Check for internet connectivity
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult != ConnectivityResult.none) {
    // If there is an internet connection, sync various data
    await syncUsers(); // Sync users with the local database
    await syncProducts(); // Sync products with the local database
    await syncCategories(); // Sync categories with the local database
    // Add additional sync functions as needed
  } else {
    print('No internet connection. Running offline.');
  }

  runApp(const MyApp()); // Run the app
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      home: const SignInPage(), // Set SignInPage as the initial page
      debugShowCheckedModeBanner: false, // Remove the debug banner
      routes: {
        '/home': (context) => HomePage(), // Register the route for HomePage
      },
    );
  }
}
