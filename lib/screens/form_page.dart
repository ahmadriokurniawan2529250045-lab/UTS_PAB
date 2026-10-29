import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/kategori.dart';
import '../models/transaksi.dart';
import '../utils/format.dart';

class FormPage extends StatefulWidget {
  // kalau awal null berarti tambah baru, kalau ada berarti mode edit
  final Transaksi? awal;

  const FormPage({super.key, this.awal});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _judulCtrl;
  late final TextEditingController _jumlahCtrl;
  late final TextEditingController _catatanCtrl;

  late bool _pemasukan;
  late Kategori _kategori;
  late DateTime _tanggal;

  bool get _modeEdit => widget.awal != null;

  @override
  void initState() {
    super.initState();
    final awal = widget.awal;
    _judulCtrl = TextEditingController(text: awal?.judul ?? '');
    _jumlahCtrl =
        TextEditingController(text: awal == null ? '' : '${awal.jumlah}');
    _catatanCtrl = TextEditingController(text: awal?.catatan ?? '');
    _pemasukan = awal?.pemasukan ?? false;
    _kategori = awal?.kategori ?? kategoriPengeluaran.first;
    _tanggal = awal?.tanggal ?? DateTime.now();
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _jumlahCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  void _gantiJenis(bool pemasukan) {
    setState(() {
      _pemasukan = pemasukan;
      final pilihan = pemasukan ? kategoriPemasukan : kategoriPengeluaran;
      if (!pilihan.contains(_kategori)) {
        _kategori = pilihan.first;
      }
    });
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (hasil != null) {
      setState(() => _tanggal = hasil);
    }
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final transaksi = Transaksi(
      id: widget.awal?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      judul: _judulCtrl.text.trim(),
      jumlah: int.parse(_jumlahCtrl.text),
      pemasukan: _pemasukan,
      kategori: _kategori,
      tanggal: _tanggal,
      catatan: _catatanCtrl.text.trim(),
    );
    Navigator.pop(context, transaksi);
  }

  @override
  Widget build(BuildContext context) {
    final pilihanKategori = _pemasukan ? kategoriPemasukan : kategoriPengeluaran;

    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Ubah Transaksi' : 'Tambah Transaksi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_pemasukan},
                onSelectionChanged: (s) => _gantiJenis(s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _judulCtrl,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  if (v.trim().length < 3) {
                    return 'Judul minimal 3 huruf';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
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
              const SizedBox(height: 16),
              DropdownButtonFormField<Kategori>(
                value: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: pilihanKategori
                    .map((k) => DropdownMenuItem(
                          value: k,
                          child: Row(
                            children: [
                              Icon(k.ikon, size: 20),
                              const SizedBox(width: 8),
                              Text(k.nama),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (k) {
                  if (k != null) setState(() => _kategori = k);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(tanggalIndo(_tanggal)),
                onTap: _pilihTanggal,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _catatanCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _simpan,
                  child: Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
