import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
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
          toolbarHeight: isSmallScreen
              ? 120
              : isMediumScreen
              ? 200
              : 200,
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
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  hintText: 'Type something',
                  hintStyle: const TextStyle(color: Colors.white),
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
            Container(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('Sprayer'),
                  _buildCategoryChip('Cutting'),
                  _buildCategoryChip('Motors'),
                  _buildCategoryChip('Products'),
                  // Add more categories as needed
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1, // Adjust as needed
                ),
                itemCount: 6, // Update with actual number of products
                itemBuilder: (context, index) {
                  return _buildProductCard(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(category),
        backgroundColor: Colors.grey[800],
        labelStyle: const TextStyle(color: Colors.white),
        onDeleted: () {
          // Handle category removal
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    return Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              'assets/product_$index.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Product Name $index',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Product Description $index',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
