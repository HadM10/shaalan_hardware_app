import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  int? _selectedCategoryId;
  TextEditingController _searchController = TextEditingController();

  Future<void> _handleLogout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('username'); // Clear username if stored

    Navigator.pushReplacementNamed(context, '/login');
  }


  void _showProductDetails(BuildContext context, String productName, String imageUrl) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    final isLargeScreen = screenWidth >= 900;

    double imageWidth;
    double imageHeight;

    if (isSmallScreen) {
      imageWidth = screenWidth * 0.9; // 90% of screen width for small screens
      imageHeight = 350; // Adjust height for small screens
    } else if (isMediumScreen) {
      imageWidth = screenWidth * 0.8; // 80% of screen width for medium screens
      imageHeight = 650; // Adjust height for medium screens
    } else if (isLargeScreen) {
      imageWidth = screenWidth * 0.6; // 60% of screen width for large screens
      imageHeight = 750; // Adjust height for large screens
    } else {
      imageWidth = screenWidth * 0.85; // Default width
      imageHeight = 500; // Default height
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16.0),
          backgroundColor: Colors.black54,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: imageWidth, // Set the width for the entire container
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                              child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Center(
                            child: Text('No Image', style: TextStyle(color: Colors.white)),
                          ),
                        )
                            : Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: Colors.grey,
                          child: Center(child: Text('No Image')),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          productName,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18.0 : isMediumScreen ? 22.0 : 24.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.red[800]!)),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    final isLargeScreen = screenWidth >= 900;
    double aspectRatio = 0.78;
    int crossAxisCount = 2;
    if (isMediumScreen) {
      crossAxisCount = 3;
    } else if (isLargeScreen) {
      crossAxisCount = 4;
    }

    if (isSmallScreen) {
      aspectRatio = 0.77; // 80% of screen width for small screens
    } else if (isMediumScreen) {
      aspectRatio = 0.78; // 90% of screen width for medium screens
    } else if (isLargeScreen) {
      aspectRatio = 0.8; // 90% of screen width for large screens
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black12,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          toolbarHeight: isSmallScreen ? 120 : isMediumScreen ? 200 : 200,
          title: Padding(
    padding: EdgeInsets.only(
    left: 30,
    ), child: Center(
            child: Image.asset(
              'assets/shaalan1.jpg',
              height: isSmallScreen ? 100 : isMediumScreen ? 150 : 200,
            ),
          ), ),
          actions: [
            Padding(
              padding: EdgeInsets.only(
                right: isSmallScreen ? 8.0 : isMediumScreen ? 16.0 : 24.0,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: isSmallScreen ? 30.0 : isMediumScreen ? 40.0 : 45.0,
                ),
                onPressed: () => _handleLogout(context),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.red[900],
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  hintText: 'Type something',
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 12.0 : isMediumScreen
                        ? 16.0
                        : 22.0,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
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
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = null;
                              });
                            },
                            child: _buildCategoryChip(
                              context,
                              'New Collection',
                              _selectedCategoryId == null,
                            ),
                          ),
                          ...snapshot.data!.map((category) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId =
                                  category['category_id'] == _selectedCategoryId
                                      ? null
                                      : category['category_id'];
                                });
                              },
                              child: _buildCategoryChip(
                                context,
                                category['category_name'],
                                _selectedCategoryId == category['category_id'],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),

            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().fetchProducts(
                  searchQuery: _searchQuery,
                  categoryId: _selectedCategoryId,
                  isNewCollection: _selectedCategoryId == null ? true : null,
                ),
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
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final product = snapshot.data![index];
                        final productName = product['product_name'];
                        final imageUrl = product['image_url'];

                        return GestureDetector(
                          onTap: () => _showProductDetails(
                            context,
                            productName,
                            imageUrl,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.red[900],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10.0),
                                    ),
                                    child: imageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          Center(child: Text('No Image')),
                                    )
                                        : Container(
                                      color: Colors.grey,
                                      child: Center(
                                        child: Text('No Image'),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    productName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen
                                          ? 12.0
                                          : isMediumScreen
                                          ? 16.0
                                          : 18.0,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  Widget _buildCategoryChip(BuildContext context, String category,
      bool isActive) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    final isLargeScreen = screenWidth >= 900;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(category),
        backgroundColor: isActive ? Colors.black54 : Colors.grey[800],
        labelStyle: TextStyle(
          color: Colors.white,
          fontSize: isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 18.0,
        ),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String productName, String imageUrl, int categoryId) {
    // Determine the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    final isLargeScreen = screenWidth >= 900;

    // Set the card height and font size based on screen size
    double imageHeight;
    double fontSizeName;
    int maxNameLength;
    if (isSmallScreen) {
      imageHeight = 165;
      fontSizeName = 11;
      maxNameLength = 22; // Maximum characters for small screens
    } else if (isMediumScreen) {
      imageHeight = 250;
      fontSizeName = 15;
      maxNameLength = 25; // Maximum characters for medium screens
    } else {
      imageHeight = 300;
      fontSizeName = 18;
      maxNameLength = 30; // Maximum characters for large screens
    }

    // Truncate the product name if it exceeds the max length and add ellipsis
    String displayProductName = productName.length > maxNameLength
        ? productName.substring(0, maxNameLength) + '...'
        : productName;

    return Card(
      color: Colors.red[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Center(
                  child: Text('No Image', style: TextStyle(color: Colors.white)),
                ),
              )
                  : Container(
                color: Colors.grey,
                child: Center(child: Text('No Image', style: TextStyle(color: Colors.white))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                displayProductName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: fontSizeName,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis, // Prevents overflow by showing ellipsis
              ),
            ),
          ],
        ),
      ),
    );
  }

}