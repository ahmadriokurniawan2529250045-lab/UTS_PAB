import 'package:flutter/material.dart';

class Warna {
  static const utama = Color(0xFF0B4DBB);
  static const utamaGelap = Color(0xFF083A94);
  static const utamaMuda = Color(0xFFE8EFFC);

  static const pemasukan = Color(0xFF16A34A);
  static const pengeluaran = Color(0xFFEF4444);

  static const latarTerang = Color(0xFFF3F5FA);
  static const latarGelap = Color(0xFF0E1424);
  static const kartuGelap = Color(0xFF182036);
  static const biruMuda = Color(0xFF93C5FD);

  static const gradien = LinearGradient(
    colors: [utama, utamaGelap],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  
}

