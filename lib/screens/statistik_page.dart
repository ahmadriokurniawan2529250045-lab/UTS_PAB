import 'package:flutter/material.dart';

import '../controllers/keuangan_controller.dart';
import '../models/kategori.dart';
import '../utils/format.dart';
import '../utils/warna.dart';
import '../widgets/donut_chart.dart';
import '../widgets/tren_bulanan.dart';

class StatistikPage extends StatelessWidget {
  final KeuanganController controller;

  const StatistikPage({super.key, required this.controller});

  Widget _judul(String teks) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        teks,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }

  Widget _mini(String label, String nilai) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              nilai,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kartuRingkasan(KeuanganController c) {
    final masuk = c.totalPemasukan;
    final keluar = c.totalPengeluaran;
    final rasio =
        masuk <= 0 ? 0.0 : (keluar / masuk).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: Warna.gradien,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Warna.utama.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Keuangan',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              rupiah(c.saldo),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Text(
            'Saldo bersih',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rasio,
              minHeight: 10,
              color: Colors.white,
              backgroundColor: Colors.white24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pengeluaran ${(rasio * 100).round()}% dari pemasukan',
            style: const TextStyle(color: Colors.white, fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _mini('Pemasukan', rupiah(masuk))),
              const SizedBox(width: 12),
              Expanded(child: _mini('Pengeluaran', rupiah(keluar))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kartuInsight(BuildContext context, List<String> daftar) {
    final gelap = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: gelap ? Warna.kartuGelap : Warna.utamaMuda,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _judul('Insight otomatis'),
            ...daftar.map((teks) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Warna.utama.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        size: 17,
                        color: Warna.utama,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(teks)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _kartuDonut(KeuanganController c) {
    final rincian = c.pengeluaranPerKategori.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = c.totalPengeluaran;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _judul('Pengeluaran per kategori'),
            if (rincian.isEmpty)
              const Text('Belum ada pengeluaran.')
            else ...[
              Center(
                child: DonutChart(
                  bagian: rincian
                      .map((e) => BagianDonut(
                            label: e.key.nama,
                            nilai: e.value.toDouble(),
                            warna: e.key.warna,
                          ))
                      .toList(),
                  teksTengah: rupiah(total),
                ),
              ),
              const SizedBox(height: 18),
              ...rincian.map((e) {
                final persen = (e.value / total * 100).round();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: e.key.warna.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(e.key.ikon, size: 18, color: e.key.warna),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e.key.nama,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${rupiah(e.value)} ($persen%)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kartuTren(KeuanganController c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _judul('Tren 6 bulan terakhir'),
            TrenBulanan(data: c.tren6Bulan),
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 10, color: Warna.utama),
                SizedBox(width: 4),
                Text('Pemasukan', style: TextStyle(fontSize: 12)),
                SizedBox(width: 16),
                Icon(Icons.circle, size: 10, color: Warna.biruMuda),
                SizedBox(width: 4),
                Text('Pengeluaran', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.kosong) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_chart_outlined_rounded,
                  size: 64,
                  color: Warna.utama.withOpacity(0.35),
                ),
                const SizedBox(height: 12),
                const Text('Belum ada data untuk dianalisis.'),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            _kartuRingkasan(controller),
            const SizedBox(height: 12),
            _kartuInsight(context, controller.insight),
            const SizedBox(height: 12),
            _kartuDonut(controller),
            const SizedBox(height: 12),
            _kartuTren(controller),
          ],
        );
      },
    );
  }
}