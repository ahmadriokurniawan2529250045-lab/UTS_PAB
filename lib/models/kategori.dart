import 'package:flutter/material.dart';

enum Kategori {
  makanan,
  transportasi,
  belanja,
  tagihan,
  hiburan,
  gaji,
  bonus,
  lainnya,
}

const kategoriPemasukan = [Kategori.gaji, Kategori.bonus, Kategori.lainnya];

const kategoriPengeluaran = [
  Kategori.makanan,
  Kategori.transportasi,
  Kategori.belanja,
  Kategori.tagihan,
  Kategori.hiburan,
  Kategori.lainnya,
];

extension KategoriInfo on Kategori {
  String get nama => switch (this) {
        Kategori.makanan => 'Makanan',
        Kategori.transportasi => 'Transportasi',
        Kategori.belanja => 'Belanja',
        Kategori.tagihan => 'Tagihan',
        Kategori.hiburan => 'Hiburan',
        Kategori.gaji => 'Gaji',
        Kategori.bonus => 'Bonus',
        Kategori.lainnya => 'Lainnya',
      };

  IconData get ikon => switch (this) {
        Kategori.makanan => Icons.restaurant,
        Kategori.transportasi => Icons.directions_bus,
        Kategori.belanja => Icons.shopping_bag,
        Kategori.tagihan => Icons.receipt_long,
        Kategori.hiburan => Icons.movie,
        Kategori.gaji => Icons.work,
        Kategori.bonus => Icons.card_giftcard,
        Kategori.lainnya => Icons.more_horiz,
      };

  // warna tiap kategori, dipakai di grafik donat
  Color get warna => switch (this) {
        Kategori.makanan => const Color(0xFF0B4DBB),
        Kategori.transportasi => const Color(0xFF2563EB),
        Kategori.belanja => const Color(0xFF0EA5E9),
        Kategori.tagihan => const Color(0xFF06B6D4),
        Kategori.hiburan => const Color(0xFF6366F1),
        Kategori.gaji => const Color(0xFF14B8A6),
        Kategori.bonus => const Color(0xFF10B981),
        Kategori.lainnya => const Color(0xFF60A5FA),
      };
}
