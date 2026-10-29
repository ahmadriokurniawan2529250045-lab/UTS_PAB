import 'package:flutter/material.dart';

import '../utils/format.dart';

class KartuSaldo extends StatelessWidget {
  final int saldo;
  final int pemasukan;
  final int pengeluaran;

  const KartuSaldo({
    super.key,
    required this.saldo,
    required this.pemasukan,
    required this.pengeluaran,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo saat ini'),
            const SizedBox(height: 4),
            Text(
              rupiah(saldo),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: saldo < 0 ? Colors.red : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ringkasan('Pemasukan', pemasukan, Colors.green),
                _ringkasan('Pengeluaran', pengeluaran, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ringkasan(String label, int nilai, Color warna) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            rupiah(nilai),
            style: TextStyle(fontWeight: FontWeight.w600, color: warna),
          ),
        ],
      ),
    );
  }
}
