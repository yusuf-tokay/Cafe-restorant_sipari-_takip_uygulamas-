import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Product> _favorites = [];

  List<Product> get favorites => [..._favorites];

  // Uygulamadaki tüm ürünlerin listesi (örnek için)
  List<Product> _allProducts = [];
  set allProducts(List<Product> products) {
    _allProducts = products;
    notifyListeners();
  }

  bool isFavorite(Product product) {
    return _favorites.any((p) => p.id == product.id);
  }

  void addToFavorites(Product product) {
    if (!isFavorite(product)) {
      _favorites.add(product);
      notifyListeners();
    }
  }

  void removeFromFavorites(Product product) {
    _favorites.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }
} 