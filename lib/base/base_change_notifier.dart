import 'package:flutter/material.dart';

class BaseChangeNotifier extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  void setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }
}
