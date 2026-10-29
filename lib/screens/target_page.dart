import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/target_controller.dart';
import '../models/target_tabungan.dart';
import '../utils/format.dart';

// dipanggil dari tombol + di halaman utama
Future<void> tampilkanFormTarget(
  BuildContext context,
  TargetController controller,
) async {
  final hasil = await showDialog<(String, int)>(
    context: context,
    builder: (_) => const _DialogTarget(),
  );
  if (hasil != null) {
    controller.tambah(hasil.$1, hasil.$2);
  }
}

class TargetPage extends StatelessWidget {
  final TargetController controller;

  const TargetPage({super.key, required this.controller});

  Future<void> _setor(BuildContext context, TargetTabungan t) async {
    final jumlah = await showDialog<int>(
      context: context,
      builder: (_) => _DialogSetor(nama: t.nama),
    );
    if (jumlah != null) {
      controller.setor(t.id, jumlah);
    }
  }

  Future<void> _hapus(BuildContext context, TargetTabungan t) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus target?'),
        content: Text('Target "${t.nama}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin == true) {
      controller.hapus(t.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final daftar = controller.daftar;

        if (daftar.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada target.\nTekan tombol bendera untuk membuat target tabungan.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          itemCount: daftar.length,
          itemBuilder: (context, index) {
            final t = daftar[index];
            final sisa = t.nominal - t.terkumpul;
            final persen = (t.rasio * 100).round();

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.nama,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _hapus(context, t),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: t.rasio,
                        minHeight: 12,
                        color: t.tercapai ? Colors.green : null,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${rupiah(t.terkumpul)} dari ${rupiah(t.nominal)} ($persen%)',
                    ),
                    const SizedBox(height: 8),
                    if (t.tercapai)
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 6),
                          Text(
                            'Target tercapai!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kurang ${rupiah(sisa)}'),
                          FilledButton.tonal(
                            onPressed: () => _setor(context, t),
                            child: const Text('Setor'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DialogTarget extends StatefulWidget {
  const _DialogTarget();

  @override
  State<_DialogTarget> createState() => _DialogTargetState();
}

class _DialogTargetState extends State<_DialogTarget> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nominalCtrl = TextEditingController();

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nominalCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, (_namaCtrl.text.trim(), int.parse(_nominalCtrl.text)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Target baru'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _namaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama target (misal: Laptop baru)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nominalCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Nominal target (Rp)',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final angka = int.tryParse(v ?? '');
                if (angka == null || angka <= 0) {
                  return 'Isi nominal lebih dari 0';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _simpan, child: const Text('Simpan')),
      ],
    );
  }
}

class _DialogSetor extends StatefulWidget {
  final String nama;

  const _DialogSetor({required this.nama});

  @override
  State<_DialogSetor> createState() => _DialogSetorState();
}

class _DialogSetorState extends State<_DialogSetor> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahCtrl = TextEditingController();

  @override
  void dispose() {
    _jumlahCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, int.parse(_jumlahCtrl.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Setor ke "${widget.nama}"'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _jumlahCtrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Jumlah setoran (Rp)',
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            final angka = int.tryParse(v ?? '');
            if (angka == null || angka <= 0) {
              return 'Isi jumlah lebih dari 0';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _simpan, child: const Text('Setor')),
      ],
    );
  }
}
