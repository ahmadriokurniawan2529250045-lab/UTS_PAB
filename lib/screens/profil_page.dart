import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/auth_controller.dart';
import '../controllers/keuangan_controller.dart';
import '../controllers/tema_controller.dart';
import '../models/pengguna.dart';

class ProfilPage extends StatefulWidget {
  final AuthController auth;
  final TemaController tema;
  final KeuanganController controller;
  final Pengguna pengguna;

  const ProfilPage({
    super.key,
    required this.auth,
    required this.tema,
    required this.controller,
    required this.pengguna,
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late final TextEditingController _anggaranCtrl;

  @override
  void initState() {
    super.initState();
    final anggaran = widget.controller.anggaran;
    _anggaranCtrl = TextEditingController(
      text: anggaran > 0 ? '$anggaran' : '',
    );
  }

  @override
  void dispose() {
    _anggaranCtrl.dispose();
    super.dispose();
  }

  void _pesan(String teks) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(content: Text(teks)));
  }

  void _simpanAnggaran() {
    final nilai = int.tryParse(_anggaranCtrl.text) ?? 0;
    widget.controller.setAnggaran(nilai);
    FocusScope.of(context).unfocus();
    _pesan(nilai > 0 ? 'Anggaran bulanan disimpan' : 'Anggaran dinonaktifkan');
  }

  Future<void> _salinLaporan() async {
    final laporan = widget.controller.buatLaporan(widget.pengguna.nama);
    await Clipboard.setData(ClipboardData(text: laporan));
    if (!mounted) return;
    _pesan('Laporan disalin, tinggal ditempel di mana saja');
  }

  Future<bool> _tanya(String judul, String isi, String tombol) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(judul),
        content: Text(isi),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tombol),
          ),
        ],
      ),
    );
    return hasil ?? false;
  }

  Future<void> _hapusSemua() async {
    final yakin = await _tanya(
      'Hapus semua data?',
      'Semua transaksi akun ini akan dihapus dan tidak bisa dikembalikan.',
      'Hapus',
    );
    if (!yakin) return;
    widget.controller.hapusSemua();
    if (!mounted) return;
    _pesan('Semua transaksi dihapus');
  }

  Future<void> _keluar() async {
    final yakin = await _tanya(
      'Keluar dari akun?',
      'Kamu bisa masuk lagi kapan saja dengan username dan password.',
      'Keluar',
    );
    if (yakin) {
      await widget.auth.keluar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nama = widget.pengguna.nama;
    final inisial = nama.isEmpty ? '?' : nama[0].toUpperCase();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(radius: 24, child: Text(inisial)),
            title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('@${widget.pengguna.username}'),
          ),
        ),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Mode gelap'),
            value: widget.tema.mode == ThemeMode.dark,
            onChanged: (nilai) => widget.tema.ganti(nilai),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anggaran bulanan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Isi 0 atau kosongkan untuk menonaktifkan.'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _anggaranCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Batas pengeluaran (Rp)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _simpanAnggaran,
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Salin laporan keuangan'),
            subtitle: const Text('Ringkasan teks untuk dibagikan'),
            onTap: _salinLaporan,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Hapus semua data'),
            onTap: _hapusSemua,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Keluar'),
            onTap: _keluar,
          ),
        ),
      ],
    );
  }
}
