import 'package:flutter/material.dart';

import '../utils/format.dart';
import '../utils/warna.dart';

class KartuAnggaran extends StatelessWidget {
  final int anggaran;
  final int terpakai;

  const KartuAnggaran({
    super.key,
    required this.anggaran,
    required this.terpakai,
  });

  @override
  Widget build(BuildContext context) {
    if (anggaran <= 0) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.account_balance_wallet_outlined),
          title: Text(
            'Anggaran bulanan belum diatur',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('Atur di tab Profil'),
        ),
      );
    }

    final rasio = (terpakai / anggaran).clamp(0.0, 1.0).toDouble();
    final lewat = terpakai > anggaran;
    final warna = lewat
        ? Warna.pengeluaran
        : (rasio > 0.8 ? Colors.orange : Warna.utama);
    final persen = (terpakai / anggaran * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Anggaran bulan ini',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '$persen%',
                  style: TextStyle(color: warna, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: rasio,
                minHeight: 10,
                color: warna,
                backgroundColor: warna.withOpacity(0.15),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lewat
                  ? 'Melebihi anggaran ${rupiah(terpakai - anggaran)}'
                  : 'Terpakai ${rupiah(terpakai)} dari ${rupiah(anggaran)}',
              style: const TextStyle(fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}