import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/keuangan_controller.dart';
import '../controllers/target_controller.dart';
import '../controllers/tema_controller.dart';
import '../models/pengguna.dart';
import '../models/transaksi.dart';
import '../utils/warna.dart';
import 'beranda_page.dart';
import 'form_page.dart';
import 'kurs_page.dart';
import 'profil_page.dart';
import 'statistik_page.dart';
import 'target_page.dart';

class HalamanUtama extends StatefulWidget {
  final AuthController auth;
  final TemaController tema;

  const HalamanUtama({super.key, required this.auth, required this.tema});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  static const _judul = [
    'Catatan Keuangan',
    'Statistik',
    'Target Tabungan',
    'Profil',
  ];

  late final Pengguna _pengguna;
  late final KeuanganController _controller;
  late final TargetController _target;
  bool _siap = false;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _pengguna = widget.auth.pengguna!;
    _controller = KeuanganController(_pengguna.username);
    _target = TargetController(_pengguna.username);

    Future.wait([_controller.muatData(), _target.muatData()]).then((_) {
      if (mounted) setState(() => _siap = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _bukaForm({Transaksi? awal}) async {
    final hasil = await Navigator.push<Transaksi>(
      context,
      MaterialPageRoute(builder: (_) => FormPage(awal: awal)),
    );

    if (hasil == null) return;

    if (awal == null) {
      _controller.tambah(hasil);
    } else {
      _controller.ubah(hasil);
    }
  }

  void _bukaKurs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Kurs Mata Uang',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: KursPage(controller: _controller),
        ),
      ),
    );
  }

  // tombol + di tengah: aksinya tergantung tab yang aktif
  void _aksiTengah() {
    if (_tab == 2) {
      tampilkanFormTarget(context, _target);
    } else {
      _bukaForm();
    }
  }

  Widget _itemNav(IconData ikon, IconData ikonAktif, String label, int indeks) {
    final aktif = _tab == indeks;
    final warna = aktif ? Warna.utama : Colors.grey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = indeks),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(aktif ? ikonAktif : ikon, color: warna, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                color: warna,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_siap) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // tab Beranda memakai header biru sendiri, jadi tanpa AppBar
      appBar: _tab == 0
          ? null
          : AppBar(
              title: Text(
                _judul[_tab],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Kurs mata uang',
                  icon: const Icon(Icons.currency_exchange_rounded),
                  onPressed: _bukaKurs,
                ),
              ],
            ),
      body: IndexedStack(
        index: _tab,
        children: [
          BerandaPage(
            controller: _controller,
            nama: _pengguna.nama,
            onUbah: (t) => _bukaForm(awal: t),
            onStatistik: () => setState(() => _tab = 1),
            onTarget: () => setState(() => _tab = 2),
            onBuatTarget: () => tampilkanFormTarget(context, _target),
            onKurs: _bukaKurs,
            onProfil: () => setState(() => _tab = 3),
          ),
          StatistikPage(controller: _controller),
          TargetPage(controller: _target),
          ProfilPage(
            auth: widget.auth,
            tema: widget.tema,
            controller: _controller,
            pengguna: _pengguna,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _TombolGradien(
        icon: _tab == 2 ? Icons.flag_rounded : Icons.add_rounded,
        onTap: _aksiTengah,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 66,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _itemNav(Icons.home_outlined, Icons.home_rounded, 'Beranda', 0),
            _itemNav(Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded,
                'Statistik', 1),
            const SizedBox(width: 64),
            _itemNav(Icons.flag_outlined, Icons.flag_rounded, 'Target', 2),
            _itemNav(Icons.person_outline_rounded, Icons.person_rounded,
                'Profil', 3),
          ],
        ),
      ),
    );
  }
}

class _TombolGradien extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TombolGradien({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: Warna.gradien,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Warna.utama.withOpacity(0.4),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}