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
      imageWidth = screenWidth * 0.8; // 80% of screen width for small screens
      imageHeight = 300; // Adjust height for small screens
    } else if (isMediumScreen) {
      imageWidth = screenWidth * 0.9; // 90% of screen width for medium screens
      imageHeight = 600; // Adjust height for medium screens
    } else if (isLargeScreen) {
      imageWidth = screenWidth * 0.6; // 90% of screen width for large screens
      imageHeight = 600; // Adjust height for large screens
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
                imageUrl.isNotEmpty
                    ? Container(
                  width: imageWidth, // Adjust the width based on screen size
                  height: imageHeight, // Adjust the height based on screen size
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Center(
                      child: Text('No Image', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                )
                    : Container(
                  color: Colors.grey,
                  width: imageWidth, // Adjust the width based on screen size
                  height: imageHeight, // Adjust the height based on screen size
                  child: Center(child: Text('No Image')),
                ),
                SizedBox(height: 16.0),
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18.0 : isMediumScreen ? 22.0 : 24.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close'),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;
    final isLargeScreen = screenWidth >= 900;

    int crossAxisCount = 2;
    if (isMediumScreen) {
      crossAxisCount = 3;
    } else if (isLargeScreen) {
      crossAxisCount = 4;
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
          title: Center(
            child: Image.asset(
              'assets/shaalan1.jpg',
              height: isSmallScreen ? 100 : isMediumScreen ? 150 : 200,
            ),
          ),
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
                    fontSize: isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 22.0,
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
                                  _selectedCategoryId = category['category_id'] == _selectedCategoryId
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
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final product = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            _showProductDetails(
                              context,
                              product['product_name'],
                              product['image_url'],
                            );
                          },
                          child: _buildProductCard(
                            context,
                            product['product_name'],
                            product['image_url'],
                            product['category_id'],
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

  Widget _buildCategoryChip(BuildContext context, String category, bool isActive) {
    final screenWidth = MediaQuery.of(context).size.width;
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
