import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountCode {
  final String code;
  final double discountPercentage;
  final DateTime expiryDate;
  final bool isActive;

  DiscountCode({
    required this.code,
    required this.discountPercentage,
    required this.expiryDate,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discountPercentage': discountPercentage,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'isActive': isActive,
    };
  }

  factory DiscountCode.fromMap(Map<String, dynamic> map) {
    return DiscountCode(
      code: map['code'],
      discountPercentage: map['discountPercentage'],
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      isActive: map['isActive'],
    );
  }

  bool isValid() {
    return isActive && DateTime.now().isBefore(expiryDate);
  }
} 