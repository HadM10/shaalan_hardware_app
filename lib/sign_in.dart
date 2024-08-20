import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
        body: GestureDetector(
        onTap: () {
      // Dismiss the keyboard when tapping outside the text fields
      FocusScope.of(context).unfocus();
    },
    child: LayoutBuilder(
        builder: (context, constraints) {
          double screenHeight = MediaQuery.of(context).size.height;
          double screenWidth = constraints.maxWidth;

          // Define the screen categories
          bool isSmallScreen = screenWidth < 600;
          bool isMediumScreen = screenWidth >= 600 && screenWidth < 900;
          bool isLargeScreen = screenWidth >= 900;

          // Define the image and form heights based on the screen size category
          double imageHeight = isLargeScreen
              ? 200
              : isMediumScreen
              ? 300
              : 220;
          double formHeight = screenHeight - imageHeight;

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: imageHeight, // Height of the image container
                  color: Colors.black,
                  child: Center(
                    child: Image.asset(
                      'assets/shaalan1.jpg',
                      height: imageHeight * 0.6,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: formHeight, // Form height based on screen height minus image height
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 80 : isMediumScreen ? 60 : 30,
                        vertical: isLargeScreen ? 60 : isMediumScreen ? 50 : 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Login',
                            style: GoogleFonts.raleway(
                              fontSize: isLargeScreen
                                  ? 38
                                  : isMediumScreen
                                  ? 38
                                  : 30,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Sign in to continue.',
                            style: GoogleFonts.raleway(
                              fontSize: isLargeScreen
                                  ? 20
                                  : isMediumScreen
                                  ? 20
                                  : 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Container(
                            width: isLargeScreen
                                ? 400
                                : isMediumScreen
                                ? 400
                                : double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NAME',
                                  style:  TextStyle(
                                    color: Colors.black87,
                                    fontSize: isLargeScreen
                                        ? 20
                                        : isMediumScreen
                                        ? 20
                                        : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFE81A1E),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16.0, horizontal: 16.0),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'PASSWORD',
                                  style:  TextStyle(
                                    color: Colors.black87,
                                    fontSize: isLargeScreen
                                        ? 20
                                        : isMediumScreen
                                        ? 20
                                        : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  style: const TextStyle(color: Colors.white),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFE81A1E),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16.0, horizontal: 16.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: isLargeScreen
                                ? 400
                                : isMediumScreen
                                ? 350
                                : double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF010101),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                // Add your login logic here
                              },
                              child:  Text(
                                'Log in',
                                style: TextStyle(
                                    fontSize: isLargeScreen
                                        ? 20
                                        : isMediumScreen
                                        ? 20
                                        : 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
        ),
    );
  }
}
