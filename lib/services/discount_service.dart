import 'package:flutter/foundation.dart';

class DiscountService with ChangeNotifier {
  final Map<String, double> _discountCodes = {
    'WELCOME10': 10.0,
    'SUMMER20': 20.0,
    'FALL15': 15.0,
  };

  Map<String, double> get discountCodes => {..._discountCodes};

  double? getDiscountPercentage(String code) {
    return _discountCodes[code.toUpperCase()];
  }

  bool isValidDiscountCode(String code) {
    return _discountCodes.containsKey(code.toUpperCase());
  }
} 