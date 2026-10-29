import 'kategori.dart';

class Transaksi {
  final String id;
  final String judul;
  final int jumlah;
  final bool pemasukan;
  final Kategori kategori;
  final DateTime tanggal;
  final String catatan;

  const Transaksi({
    required this.id,
    required this.judul,
    required this.jumlah,
    required this.pemasukan,
    required this.kategori,
    required this.tanggal,
    this.catatan = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'jumlah': jumlah,
      'pemasukan': pemasukan,
      'kategori': kategori.name,
      'tanggal': tanggal.toIso8601String(),
      'catatan': catatan,
    };
  }

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'] as String,
      judul: map['judul'] as String,
      jumlah: map['jumlah'] as int,
      pemasukan: map['pemasukan'] as bool,
      kategori: Kategori.values.firstWhere(
        (k) => k.name == map['kategori'],
        orElse: () => Kategori.lainnya,
      ),
      tanggal: DateTime.parse(map['tanggal'] as String),
      catatan: (map['catatan'] ?? '') as String,
    );
  }
}
