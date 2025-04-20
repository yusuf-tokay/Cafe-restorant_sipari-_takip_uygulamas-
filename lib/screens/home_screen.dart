import 'package:flutter/material.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../data/sample_products.dart';
import '../models/product.dart';

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

  List<Product> getFilteredProducts() {
    if (selectedCategory == 'Tümü') {
      return sampleProducts;
    }
    return sampleProducts.where((product) => product.category == selectedCategory).toList();
  }

  List<Product> getFavoriteProducts() {
    return sampleProducts.where((product) => product.isFavorite).toList();
  }

  List<Product> getOnSaleProducts() {
    return sampleProducts.where((product) => product.isOnSale).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menü'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
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
                child: buildProductGrid(getFilteredProducts()),
              ),
            ],
          ),
          // Kampanyalı Ürünler Sekmesi
          buildProductGrid(getOnSaleProducts()),
          // Favori Ürünler Sekmesi
          buildProductGrid(getFavoriteProducts()),
        ],
      ),
    );
  }

  Widget buildProductGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product-detail',
              arguments: products[index],
            );
          },
          onFavoritePressed: () {
            setState(() {
              products[index].toggleFavorite();
            });
          },
        );
      },
    );
  }
} 