import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../theme/app_theme.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
        backgroundColor: AppTheme.primaryColor,
        centerTitle: true,
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final favorites = favoritesProvider.favorites;
          
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz favori ürününüz yok',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final product = favorites[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: Icon(Icons.restaurant, color: Colors.grey[600]),
                        );
                      },
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text('${product.price.toStringAsFixed(2)} TL'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          favoritesProvider.removeFromFavorites(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.name} favorilerden çıkarıldı')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          final cartProvider = Provider.of<CartProvider>(context, listen: false);
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
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/product-detail',
                      arguments: product,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 