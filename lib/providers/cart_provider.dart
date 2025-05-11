import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  static const double _shippingFee = 15.0; // Sabit kargo ücreti

  List<CartItem> get items => [..._items];
  
  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  double get shippingFee => _shippingFee;

  double get grandTotal => totalAmount + shippingFee;

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.total);

  void addItem(CartItem item, {int quantity = 1, List<String>? extras}) {
    final existingIndex = _items.indexWhere((i) => i.productId == item.productId && (extras == null || i.extras == extras));
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
    } else {
      _items.add(item.copyWith(quantity: quantity, extras: extras));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity > 0) {
        _items[index] = _items[index].copyWith(quantity: quantity);
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void increaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity + 1);
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0 && _items[index].quantity > 1) {
      _items[index] = _items[index].copyWith(quantity: _items[index].quantity - 1);
      notifyListeners();
    } else if (index >= 0 && _items[index].quantity == 1) {
      _items.removeAt(index);
      notifyListeners();
    }
  }
} 