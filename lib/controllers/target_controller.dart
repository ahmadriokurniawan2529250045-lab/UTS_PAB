import 'package:flutter/foundation.dart';

import '../models/target_tabungan.dart';
import '../services/penyimpanan.dart';

class TargetController extends ChangeNotifier {
  final Penyimpanan _penyimpanan;
  final List<TargetTabungan> _daftar = [];

  TargetController(String username) : _penyimpanan = Penyimpanan(username);

  List<TargetTabungan> get daftar => List.unmodifiable(_daftar);

  Future<void> muatData() async {
    final hasil = await _penyimpanan.muatTarget();
    _daftar
      ..clear()
      ..addAll(hasil);
    notifyListeners();
  }

  void _perbarui() {
    notifyListeners();
    _penyimpanan.simpanTarget(_daftar);
  }

  void tambah(String nama, int nominal) {
    _daftar.add(TargetTabungan(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nama: nama.trim(),
      nominal: nominal,
      terkumpul: 0,
    ));
    _perbarui();
  }

  void setor(String id, int jumlah) {
    final i = _daftar.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _daftar[i] = _daftar[i].copyWith(terkumpul: _daftar[i].terkumpul + jumlah);
    _perbarui();
  }

  void hapus(String id) {
    _daftar.removeWhere((t) => t.id == id);
    _perbarui();
  }
}
