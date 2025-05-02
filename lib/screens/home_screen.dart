import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';
import 'settings_screen.dart';
import 'reservation_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String selectedCategory = 'Tümü';
  late TabController _tabController;
  final List<String> categories = [
    'Tümü',
    'Burgerler',
    'Pizzalar',
    'Salatalar',
    'Tatlılar',
    'İçecekler',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Cafe Restaurant',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today, color: Colors.blue[900]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite, color: Colors.blue[900]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blue[900]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.blue[900]),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              if (cartProvider.items.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartProvider.items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue[900],
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue[900],
          tabs: const [
            Tab(text: 'Tüm Ürünler'),
            Tab(text: 'Kampanyalılar'),
            Tab(text: 'Favoriler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tüm Ürünler Sekmesi
          Column(
            children: [
              // Kategori listesi
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        category: categories[index],
                        isSelected: selectedCategory == categories[index],
                        onTap: () {
                          setState(() {
                            selectedCategory = categories[index];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              // Ürün listesi
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: selectedCategory == 'Tümü'
                      ? productService.products.length
                      : productService.getProductsByCategory(selectedCategory).length,
                  itemBuilder: (context, index) {
                    final products = selectedCategory == 'Tümü'
                        ? productService.products
                        : productService.getProductsByCategory(selectedCategory);
                    return ProductCard(
                      product: products[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product-detail',
                          arguments: products[index],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          // Kampanyalı Ürünler Sekmesi
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: productService.getOnSaleProducts().length,
            itemBuilder: (context, index) {
              final products = productService.getOnSaleProducts();
              return ProductCard(
                product: products[index],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/product-detail',
                    arguments: products[index],
                  );
                },
              );
            },
          ),
          // Favori Ürünler Sekmesi
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: productService.products.where((p) => p.isFavorite).length,
            itemBuilder: (context, index) {
              final products = productService.products.where((p) => p.isFavorite).toList();
              return ProductCard(
                product: products[index],
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/product-detail',
                    arguments: products[index],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
} 