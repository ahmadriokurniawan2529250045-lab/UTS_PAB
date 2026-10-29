import 'package:flutter/foundation.dart';

import '../models/pengguna.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();
  Pengguna? _pengguna;

  Pengguna? get pengguna => _pengguna;

  Future<void> muat() async {
    _pengguna = await _service.sesiAktif();
    notifyListeners();
  }

  Future<void> daftar({
    required String nama,
    required String username,
    required String password,
  }) async {
    _pengguna = await _service.daftar(
      nama: nama,
      username: username,
      password: password,
    );
    notifyListeners();
  }

  Future<void> masuk(String username, String password) async {
    _pengguna = await _service.masuk(username, password);
    notifyListeners();
  }

  Future<void> keluar() async {
    await _service.keluar();
    _pengguna = null;
    notifyListeners();
  }
}
