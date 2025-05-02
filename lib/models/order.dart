import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafe_restaurant_app/models/product.dart';

enum OrderStatus {
  pending,
  preparing,
  ready,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String userId;
  final List<Product> products;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? deliveryAddress;
  final String? paymentMethod;
  final String? discountCode;
  final double? discountAmount;

  Order({
    required this.id,
    required this.userId,
    required this.products,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.deliveryAddress,
    this.paymentMethod,
    this.discountCode,
    this.discountAmount,
  });

  double get finalAmount => totalAmount - (discountAmount ?? 0);

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Beklemede';
      case 'preparing':
        return 'Hazırlanıyor';
      case 'ready':
        return 'Hazır';
      case 'delivered':
        return 'Teslim Edildi';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return 'Bilinmeyen';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'delivered':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'products': products.map((product) => product.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'discountCode': discountCode,
      'discountAmount': discountAmount,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      products: (map['products'] as List)
          .map((product) => Product.fromMap(product))
          .toList(),
      totalAmount: map['totalAmount'],
      status: map['status'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      deliveryAddress: map['deliveryAddress'],
      paymentMethod: map['paymentMethod'],
      discountCode: map['discountCode'],
      discountAmount: map['discountAmount'],
    );
  }
} 