import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_theme.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  List<String> selectedExtras = [];

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final product = widget.product;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant, size: 64),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  favoritesProvider.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                  color: favoritesProvider.isFavorite(product) ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  if (favoritesProvider.isFavorite(product)) {
                    favoritesProvider.removeFromFavorites(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} favorilerden çıkarıldı')),
                    );
                  } else {
                    favoritesProvider.addToFavorites(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} favorilere eklendi')),
                    );
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTheme.titleStyle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} TL',
                        style: AppTheme.titleStyle.copyWith(
                          color: AppTheme.primaryColor,
                          fontSize: 20,
                        ),
                      ),
                      if (product.isOnSale && product.salePrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${product.salePrice!.toStringAsFixed(2)} TL',
                          style: AppTheme.bodyStyle.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.description,
                    style: AppTheme.bodyStyle,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        cartProvider.addItem(
                          CartItem(
                            id: DateTime.now().toString(),
                            productId: product.id,
                            name: product.name,
                            quantity: 1,
                            price: product.isOnSale ? (product.salePrice ?? product.price) : product.price,
                            imageUrl: product.imageUrl,
                            extras: [],
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} sepete eklendi'),
                            action: SnackBarAction(
                              label: 'Sepete Git',
                              onPressed: () {
                                Navigator.pushNamed(context, '/cart');
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Sepete Ekle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 