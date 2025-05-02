import 'package:flutter/foundation.dart';
import '../models/product.dart';

class FavoritesProvider with ChangeNotifier {
  final List<String> _favoriteIds = [];

  List<String> get favoriteIds => [..._favoriteIds];

  bool isFavorite(String productId) {
    return _favoriteIds.contains(productId);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product.id)) {
      _favoriteIds.remove(product.id);
    } else {
      _favoriteIds.add(product.id);
    }
    notifyListeners();
  }

  void removeFromFavorites(String productId) {
    _favoriteIds.removeWhere((id) => id == productId);
    notifyListeners();
  }
} 