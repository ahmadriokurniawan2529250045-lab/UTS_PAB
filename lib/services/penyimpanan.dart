import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/target_tabungan.dart';
import '../models/transaksi.dart';

// setiap pengguna punya data sendiri, dibedakan lewat username di kunci
class Penyimpanan {
  final String username;

  Penyimpanan(this.username);

  String get _kunciData => 'data_transaksi_$username';
  String get _kunciAnggaran => 'anggaran_$username';
  String get _kunciTarget => 'target_$username';

  Future<List<Transaksi>> muat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teks = prefs.getString(_kunciData);
      if (teks == null) return [];

      final List<dynamic> list = jsonDecode(teks);
      return list
          .map((e) => Transaksi.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // kalau datanya rusak, mulai dari kosong saja
      return [];
    }
  }

  Future<void> simpan(List<Transaksi> data) async {
    final prefs = await SharedPreferences.getInstance();
    final teks = jsonEncode(data.map((t) => t.toMap()).toList());
    await prefs.setString(_kunciData, teks);
  }

  Future<int> muatAnggaran() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kunciAnggaran) ?? 0;
  }

  Future<void> simpanAnggaran(int nilai) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kunciAnggaran, nilai);
  }

  Future<List<TargetTabungan>> muatTarget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teks = prefs.getString(_kunciTarget);
      if (teks == null) return [];

      final List<dynamic> list = jsonDecode(teks);
      return list
          .map((e) => TargetTabungan.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> simpanTarget(List<TargetTabungan> data) async {
    final prefs = await SharedPreferences.getInstance();
    final teks = jsonEncode(data.map((t) => t.toMap()).toList());
    await prefs.setString(_kunciTarget, teks);
  }
}
