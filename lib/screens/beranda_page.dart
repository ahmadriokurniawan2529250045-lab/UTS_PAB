import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/keuangan_controller.dart';
import '../models/transaksi.dart';
import '../utils/format.dart';
import '../utils/warna.dart';
import '../widgets/item_transaksi.dart';
import '../widgets/kartu_anggaran.dart';

class BerandaPage extends StatelessWidget {
  final KeuanganController controller;
  final String nama;
  final void Function(Transaksi) onUbah;
  final VoidCallback onStatistik;
  final VoidCallback onTarget;
  final VoidCallback onBuatTarget;
  final VoidCallback onKurs;
  final VoidCallback onProfil;

  const BerandaPage({
    super.key,
    required this.controller,
    required this.nama,
    required this.onUbah,
    required this.onStatistik,
    required this.onTarget,
    required this.onBuatTarget,
    required this.onKurs,
    required this.onProfil,
  });

  String _namaFilter(FilterJenis f) {
    switch (f) {
      case FilterJenis.semua:
        return 'Semua';
      case FilterJenis.pemasukan:
        return 'Pemasukan';
      case FilterJenis.pengeluaran:
        return 'Pengeluaran';
    }
  }

  void _hapusDenganUndo(BuildContext context, Transaksi t) {
    controller.hapus(t);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('"${t.judul}" dihapus'),
        action: SnackBarAction(
          label: 'BATAL',
          onPressed: () => controller.tambah(t),
        ),
      ),
    );
  }

  Future<void> _salinLaporan(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: controller.buatLaporan(nama)));
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      const SnackBar(content: Text('Laporan disalin, tinggal ditempel')),
    );
  }

  // ---------- header biru ----------
  Widget _header() {
    final inisial = nama.isEmpty ? '?' : nama[0].toUpperCase();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Warna.utama, Warna.utamaGelap],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Halo,',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white24,
                    child: Text(
                      inisial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Total Saldo',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  rupiah(controller.saldo),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _pill(
                      Icons.arrow_downward_rounded,
                      'Pemasukan',
                      rupiah(controller.totalPemasukan),
                      const Color(0xFF86EFAC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _pill(
                      Icons.arrow_upward_rounded,
                      'Pengeluaran',
                      rupiah(controller.totalPengeluaran),
                      const Color(0xFFFCA5A5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData ikon, String label, String nilai, Color warnaIkon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, color: warnaIkon, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
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
          ),
        ],
      ),
    );
  }

  // ---------- kotak fitur aplikasi ----------
  Widget _gridFitur(BuildContext context) {
    final fitur = [
      (Icons.pie_chart_rounded, 'Statistik', Colors.orange, onStatistik),
      (Icons.flag_rounded, 'Target', Colors.pink, onTarget),
      (Icons.savings_rounded, 'Buat Target', Colors.teal, onBuatTarget),
      (Icons.currency_exchange_rounded, 'Kurs', Colors.green, onKurs),
      (
        Icons.description_rounded,
        'Laporan',
        Colors.deepPurple,
        () => _salinLaporan(context)
      ),
      (Icons.person_rounded, 'Profil', Warna.utama, onProfil),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 6),
              child: Text(
                'FITUR APLIKASI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fitur.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 80,
              ),
              itemBuilder: (context, i) {
                final f = fitur[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: f.$4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: f.$3.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(f.$1, color: f.$3, size: 25),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        f.$2,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final latar = Theme.of(context).scaffoldBackgroundColor;
    const radius = BorderRadius.vertical(top: Radius.circular(28));

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final daftar = controller.tampil;

        return Column(
          children: [
            _header(),
            Expanded(
              // warna di belakang sudut lembar = ujung bawah header
              child: ColoredBox(
                color: Warna.utamaGelap,
                child: Container(
                  decoration: BoxDecoration(color: latar, borderRadius: radius),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                            child: _gridFitur(context),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: KartuAnggaran(
                              anggaran: controller.anggaran,
                              terpakai: controller.pengeluaranBulanIni,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Text(
                              'Transaksi Terakhir',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              onChanged: controller.cari,
                              decoration: const InputDecoration(
                                hintText: 'Cari transaksi...',
                                prefixIcon: Icon(Icons.search_rounded),
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                            child: Row(
                              children: FilterJenis.values.map((f) {
                                final aktif = controller.filter == f;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(_namaFilter(f)),
                                    selected: aktif,
                                    showCheckmark: false,
                                    selectedColor: Warna.utama,
                                    shape: const StadiumBorder(),
                                    labelStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: aktif ? Colors.white : null,
                                    ),
                                    onSelected: (_) => controller.setFilter(f),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        if (daftar.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                controller.kosong
                                    ? 'Belum ada catatan.\nTekan tombol + untuk menambah.'
                                    : 'Tidak ada transaksi yang cocok.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        else
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final t = daftar[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 10),
                                  child: Dismissible(
                                    key: ValueKey(t.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      decoration: BoxDecoration(
                                        color: Warna.pengeluaran,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 24),
                                      child: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (_) =>
                                        _hapusDenganUndo(context, t),
                                    child: ItemTransaksi(
                                      transaksi: t,
                                      onTap: () => onUbah(t),
                                    ),
                                  ),
                                );
                              },
                              childCount: daftar.length,
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}