import 'package:flutter/material.dart';

import '../models/ringkasan_bulan.dart';
import '../utils/format.dart';
import '../utils/warna.dart';

class TrenBulanan extends StatelessWidget {
  final List<RingkasanBulan> data;

  static const double _tinggi = 120;

  const TrenBulanan({super.key, required this.data});

  Widget _batang(double rasio, Color warna) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: rasio),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, nilai, _) {
        return Container(
          width: 12,
          height: nilai * _tinggi,
          decoration: BoxDecoration(
            color: warna,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // nilai terbesar dipakai sebagai patokan tinggi 100%
    int maks = 0;
    for (final d in data) {
      if (d.pemasukan > maks) maks = d.pemasukan;
      if (d.pengeluaran > maks) maks = d.pengeluaran;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((d) {
        final rasioMasuk = maks == 0 ? 0.0 : d.pemasukan / maks;
        final rasioKeluar = maks == 0 ? 0.0 : d.pengeluaran / maks;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: _tinggi,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _batang(rasioMasuk, Warna.utama),
                  const SizedBox(width: 3),
                  _batang(rasioKeluar, Warna.biruMuda),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              namaBulanSingkat(d.bulan.month),
              style: const TextStyle(fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
  }
}
