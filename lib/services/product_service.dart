import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../data/sample_products.dart';

class ProductService with ChangeNotifier {
  List<Product> _products = sampleProducts;
  List<Product> get products => [..._products];

  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  List<Product> getOnSaleProducts() {
    return _products.where((product) => product.isOnSale).toList();
  }

  Product getProductById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }
} 