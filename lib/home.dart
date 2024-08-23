import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for local storage management
import 'database_helper.dart';

class HomePage extends StatelessWidget {
  Future<void> _handleLogout(BuildContext context) async {
    // Clear login status from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Or set to false, depending on your implementation

    // Navigate back to the login screen
    Navigator.pushReplacementNamed(context, '/login'); // Adjust the route as per your app's routing
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    final isLargeScreen = screenWidth >= 900;

    // Determine the number of columns based on screen size
    int crossAxisCount = 2; // Default for small screens
    if (isMediumScreen) {
      crossAxisCount = 3;
    } else if (isLargeScreen) {
      crossAxisCount = 4;
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Close keyboard on tap
      },
      child: Scaffold(
        backgroundColor: Colors.black12, // Set background color to black
        appBar: AppBar(
          backgroundColor: Colors.black54,
          toolbarHeight: isSmallScreen ? 120 : isMediumScreen ? 200 : 200,
          title: Center(
            child: Image.asset(
              'assets/shaalan1.jpg',
              height: isSmallScreen
                  ? 100
                  : isMediumScreen
                  ? 150
                  : 200,
            ),
          ),
            actions: [
        Padding(
        padding: EdgeInsets.only(right: isSmallScreen
        ? 8.0 // Padding for small screens
            : isMediumScreen
        ? 16.0 // Padding for medium screens
            : 24.0), // Padding for large screens
        child:
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white, // Set the icon color to white
                size: isSmallScreen
                    ? 30.0 // Size for small screens
                    : isMediumScreen
                    ? 40.0 // Size for medium screens
                    : 45.0, // Size for large screens
              ),
              onPressed: () => _handleLogout(context), // Logout action
            ),
        )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.red[900],
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  hintText: 'Type something',
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen
                        ? 12.0
                        : isMediumScreen
                        ? 16.0
                        : 22.0,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      // Clear search input
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().fetchCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No categories available'));
                    } else {
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: snapshot.data!.map((category) {
                          return _buildCategoryChip(
                              context, category['category_name']);
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No products available'));
                  } else {
                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1, // Adjust as needed
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final product = snapshot.data![index];
                        return _buildProductCard(
                          context,
                          product['product_name'],
                          product['image_url'],
                          product['category_id'],
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    final isLargeScreen = screenWidth >= 900;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(category),
        backgroundColor: Colors.grey[800],
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen
              ? 12.0
              : isMediumScreen
              ? 16.0
              : 18.0,
        ),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context,
      String productName,
      String imageUrl,
      int categoryId,
      ) {
    return Card(
      color: Colors.red[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Center(
                child: Text('No Image', style: TextStyle(color: Colors.white)),
              ),
            )
                : Container(
              color: Colors.grey,
              width: double.infinity,
              child: Center(child: Text('No Image')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              productName,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
