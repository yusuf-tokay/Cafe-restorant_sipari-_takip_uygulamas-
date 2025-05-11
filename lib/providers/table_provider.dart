import 'package:flutter/material.dart';

class TableProvider with ChangeNotifier {
  String? _tableCode;

  String? get tableCode => _tableCode;

  void setTable(String code) {
    _tableCode = code;
    notifyListeners();
  }

  void clearTable() {
    _tableCode = null;
    notifyListeners();
  }
} 