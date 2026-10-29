import 'package:flutter/material.dart';

import '../models/kategori.dart';
import '../models/transaksi.dart';
import '../utils/format.dart';
import '../utils/warna.dart';

class ItemTransaksi extends StatelessWidget {
  final Transaksi transaksi;
  final VoidCallback onTap;

  const ItemTransaksi({super.key, required this.transaksi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = transaksi;
    final tema = Theme.of(context);
    final gelap = tema.brightness == Brightness.dark;
    final warnaJumlah = t.pemasukan ? Warna.pemasukan : Warna.pengeluaran;
    final warnaKat = t.kategori.warna;
    final radius = BorderRadius.circular(18);

    return Container(
      decoration: BoxDecoration(
        color: gelap ? Warna.kartuGelap : Colors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(gelap ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: warnaKat.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(t.kategori.ikon, color: warnaKat, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.judul,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${t.kategori.nama} • ${tanggalIndo(t.tanggal)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: tema.colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${t.pemasukan ? '+' : '-'}${rupiah(t.jumlah)}',
                  style: TextStyle(
                    color: warnaJumlah,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}