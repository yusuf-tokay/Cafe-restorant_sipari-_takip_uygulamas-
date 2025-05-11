import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as my_order;

class OrderProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<my_order.Order> _orders = [];

  List<my_order.Order> get orders => _orders;

  Future<void> loadOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs.map((doc) => my_order.Order.fromMap(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      print('Siparişler yüklenirken hata: $e');
    }
  }

  Future<void> addOrder(my_order.Order order) async {
    try {
      final docRef = await _firestore.collection('orders').add(order.toMap());
      order = order.copyWith(id: docRef.id);
      _orders.insert(0, order);
      notifyListeners();
    } catch (e) {
      print('Sipariş eklenirken hata: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      print('Sipariş durumu güncellenirken hata: $e');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: 'cancelled');
        notifyListeners();
      }
    } catch (e) {
      print('Sipariş iptal edilirken hata: $e');
    }
  }
} 