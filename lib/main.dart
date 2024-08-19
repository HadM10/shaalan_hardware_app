import 'package:flutter/material.dart';
import 'sign_in.dart'; // Import your SignInPage file
import 'package:google_fonts/google_fonts.dart';

void main() {
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
          )// You can define your color theme here
      ),
      home: const SignInPage(), // Set SignInPage as the initial page
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}
