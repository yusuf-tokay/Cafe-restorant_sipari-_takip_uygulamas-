import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FavoriteProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  Future<void> loadFavorites(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      _favorites = snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Favoriler yüklenirken hata: $e');
    }
  }

  Future<void> addToFavorites(String userId, Product product) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(product.id)
          .set(product.toMap());

      _favorites.add(product);
      notifyListeners();
    } catch (e) {
      print('Favorilere eklenirken hata: $e');
    }
  }

  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .delete();

      _favorites.removeWhere((product) => product.id == productId);
      notifyListeners();
    } catch (e) {
      print('Favorilerden kaldırılırken hata: $e');
    }
  }

  bool isFavorite(String productId) {
    return _favorites.any((product) => product.id == productId);
  }
} 