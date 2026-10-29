import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/keuangan_controller.dart';
import '../models/kurs.dart';
import '../services/kurs_service.dart';
import '../utils/format.dart';

const _namaMataUang = {
  'USD': 'Dolar Amerika',
  'EUR': 'Euro',
  'SGD': 'Dolar Singapura',
  'JPY': 'Yen Jepang',
  'MYR': 'Ringgit Malaysia',
  'SAR': 'Riyal Saudi',
  'AUD': 'Dolar Australia',
  'GBP': 'Poundsterling',
};

class KursPage extends StatefulWidget {
  final KeuanganController controller;

  const KursPage({super.key, required this.controller});

  @override
  State<KursPage> createState() => _KursPageState();
}

class _KursPageState extends State<KursPage> {
  final _service = KursService();
  final _jumlahCtrl = TextEditingController(text: '100000');

  late Future<DataKurs> _future;
  String _kodeDipilih = 'USD';

  @override
  void initState() {
    super.initState();
    _future = _service.ambil();
  }

  @override
  void dispose() {
    _jumlahCtrl.dispose();
    super.dispose();
  }

  void _muatUlang() {
    setState(() {
      _future = _service.ambil(paksa: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataKurs>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _tampilanError(snapshot.error!);
        }
        return _isi(snapshot.data!);
      },
    );
  }

  Widget _tampilanError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Gagal mengambil kurs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _muatUlang, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }

  Widget _isi(DataKurs kurs) {
    final jumlah = int.tryParse(_jumlahCtrl.text) ?? 0;
    final hasil = jumlah * (kurs.rates[_kodeDipilih] ?? 0.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kurs hari ini (basis Rupiah)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: _muatUlang,
              icon: const Icon(Icons.refresh),
              tooltip: 'Perbarui',
            ),
          ],
        ),
        if (kurs.dariCache)
          Card(
            color: Colors.amber.shade100,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Tidak bisa terhubung ke server. Memakai kurs terakhir yang tersimpan.',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),

        // ---- konverter ----
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Konverter'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _jumlahCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Rupiah',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _kodeDipilih,
                      items: _namaMataUang.keys
                          .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                          .toList(),
                      onChanged: (k) {
                        if (k != null) setState(() => _kodeDipilih = k);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${rupiah(jumlah)} = $_kodeDipilih ${desimal(hasil)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ---- saldo dalam mata uang lain ----
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final saldo = widget.controller.saldo;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saldo kamu (${rupiah(saldo)}) setara dengan:'),
                    const SizedBox(height: 12),
                    ..._namaMataUang.entries.map((e) {
                      final nilai = saldo * (kurs.rates[e.key] ?? 0.0);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${e.key} - ${e.value}'),
                            Text(
                              desimal(nilai),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),
        Text(
          'Diperbarui: ${tanggalIndo(kurs.diperbarui)}\n'
          'Rates By Exchange Rate API (exchangerate-api.com)',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
