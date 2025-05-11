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

  Future<void> addSampleDiscountCodes() async {
    // Örnek indirim kodları zaten _discountCodes map'inde tanımlı
    // Bu metot şu an için boş bırakılabilir veya ileride Firebase gibi
    // bir veritabanına indirim kodlarını yüklemek için kullanılabilir
    notifyListeners();
  }
} 