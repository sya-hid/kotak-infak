import 'package:flutter/material.dart';

class PageProvider with ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  String _currentPage = 'Home';
  String get currentPage => _currentPage;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  set currentPage(String page) {
    _currentPage = page;
    notifyListeners();
  }
}
