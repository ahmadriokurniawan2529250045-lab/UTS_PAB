import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemaController extends ChangeNotifier {
  static const _kunci = 'mode_gelap';
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  Future<void> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final gelap = prefs.getBool(_kunci) ?? false;
      _mode = gelap ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      _mode = ThemeMode.light;
    }
    notifyListeners();
  }

  Future<void> ganti(bool gelap) async {
    _mode = gelap ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kunci, gelap);
  }
}
