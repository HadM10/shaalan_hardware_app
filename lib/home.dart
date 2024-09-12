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
  List<Map<String, dynamic>>? _categories;
  ScrollController _scrollController = ScrollController();
  Future<List<Map<String, dynamic>>>? _productsFuture;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await DatabaseHelper().fetchCategories();
      setState(() {
        _categories = categories;
        _updateProductsFuture();
      });
    } catch (error) {
      // Handle or log the error appropriately
    }
  }

  void _updateProductsFuture() {
    setState(() {
      _productsFuture = _searchQuery.isNotEmpty
          ? DatabaseHelper().searchProducts(_searchQuery)
          : DatabaseHelper().fetchProducts(
        searchQuery: _searchQuery,
        categoryId: _selectedCategoryId,
        isNewCollection: _selectedCategoryId == null ? true : null,
      );
    });
  }

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
      imageWidth = screenWidth * 0.9;
      imageHeight = 350;
    } else if (isMediumScreen) {
      imageWidth = screenWidth * 0.8;
      imageHeight = 650;
    } else {
      imageWidth = screenWidth * 0.6;
      imageHeight = 750;
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
                  width: imageWidth,
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
                          placeholder: (context, url) => Center(child: CircularProgressIndicator()),
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
    final screenWidth = MediaQuery.of(context).size.width;
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
      aspectRatio = 0.77;
    } else if (isMediumScreen) {
      aspectRatio = 0.78;
    } else {
      aspectRatio = 0.8;
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
            padding: EdgeInsets.only(left: 30),
            child: Center(
              child: Image.asset(
                'assets/shaalan1.jpg',
                height: isSmallScreen ? 100 : isMediumScreen ? 150 : 200,
              ),
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
                        _updateProductsFuture();
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
                    _updateProductsFuture();
                  });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                child: _categories == null
                    ? Center(child: CircularProgressIndicator())
                    : _categories!.isEmpty
                    ? Center(child: Text('No categories available'))
                    : ListView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = null;
                          _updateProductsFuture();
                        });
                      },
                      child: _buildCategoryChip(
                        context,
                        'New Collection',
                        _selectedCategoryId == null,
                      ),
                    ),
                    ..._categories!.map((category) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryId =
                            category['category_id'] == _selectedCategoryId
                                ? null
                                : category['category_id'];
                            _updateProductsFuture();
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
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _productsFuture,
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
                                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => Center(child: Text('No Image')),
                                    )
                                        : Container(
                                      color: Colors.grey,
                                      child: Center(child: Text('No Image')),
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
}
