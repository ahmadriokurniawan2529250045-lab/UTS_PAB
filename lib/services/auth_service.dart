import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pengguna.dart';

// error khusus supaya pesannya bisa langsung ditampilkan ke pengguna
class AuthException implements Exception {
  final String pesan;
  AuthException(this.pesan);

  @override
  String toString() => pesan;
}

class AuthService {
  static const _kunciDaftar = 'daftar_pengguna';
  static const _kunciAktif = 'pengguna_aktif';

  // password tidak pernah disimpan apa adanya, hanya hasil hash-nya
  String _hash(String username, String password) {
    final bytes = utf8.encode('$username:$password');
    return sha256.convert(bytes).toString();
  }

  Map<String, dynamic> _bacaSemua(SharedPreferences prefs) {
    final teks = prefs.getString(_kunciDaftar);
    if (teks == null) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(teks));
    } catch (_) {
      return {};
    }
  }

  Future<Pengguna> daftar({
    required String nama,
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final semua = _bacaSemua(prefs);
    final kunci = username.trim().toLowerCase();

    if (semua.containsKey(kunci)) {
      throw AuthException('Username sudah dipakai, coba yang lain');
    }

    semua[kunci] = {
      'nama': nama.trim(),
      'hash': _hash(kunci, password),
    };
    await prefs.setString(_kunciDaftar, jsonEncode(semua));
    await prefs.setString(_kunciAktif, kunci);

    return Pengguna(username: kunci, nama: nama.trim());
  }

  Future<Pengguna> masuk(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final semua = _bacaSemua(prefs);
    final kunci = username.trim().toLowerCase();
    final data = semua[kunci];

    if (data == null || data['hash'] != _hash(kunci, password)) {
      throw AuthException('Username atau password salah');
    }

    await prefs.setString(_kunciAktif, kunci);
    return Pengguna(username: kunci, nama: data['nama'] as String);
  }

  // dipanggil saat aplikasi dibuka: apakah ada yang masih login?
  Future<Pengguna?> sesiAktif() async {
    final prefs = await SharedPreferences.getInstance();
    final kunci = prefs.getString(_kunciAktif);
    if (kunci == null) return null;

    final data = _bacaSemua(prefs)[kunci];
    if (data == null) return null;
    return Pengguna(username: kunci, nama: data['nama'] as String);
  }

  Future<void> keluar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kunciAktif);
  }
}
