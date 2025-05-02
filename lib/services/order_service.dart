import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class OrderService with ChangeNotifier {
  final List<Map<String, dynamic>> _orders = [];

  List<Map<String, dynamic>> get orders => [..._orders];

  void addOrder(List<CartItem> items, double totalAmount) {
    _orders.add({
      'id': DateTime.now().toString(),
      'items': items.map((item) => {
        'productId': item.productId,
        'name': item.name,
        'quantity': item.quantity,
        'price': item.price,
      }).toList(),
      'totalAmount': totalAmount,
      'date': DateTime.now(),
    });
    notifyListeners();
  }
} 