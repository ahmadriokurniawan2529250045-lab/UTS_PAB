import 'package:flutter/foundation.dart';

import '../models/kategori.dart';
import '../models/ringkasan_bulan.dart';
import '../models/transaksi.dart';
import '../services/penyimpanan.dart';
import '../utils/format.dart';

enum FilterJenis { semua, pemasukan, pengeluaran }

class KeuanganController extends ChangeNotifier {
  final Penyimpanan _penyimpanan;
  final List<Transaksi> _data = [];

  String _kataKunci = '';
  FilterJenis _filter = FilterJenis.semua;
  int _anggaran = 0;

  KeuanganController(String username) : _penyimpanan = Penyimpanan(username);

  FilterJenis get filter => _filter;
  int get anggaran => _anggaran;

  Future<void> muatData() async {
    final hasil = await _penyimpanan.muat();
    _data
      ..clear()
      ..addAll(hasil);
    _anggaran = await _penyimpanan.muatAnggaran();
    _urutkan();
    notifyListeners();
  }

  void _urutkan() {
    _data.sort((a, b) => b.tanggal.compareTo(a.tanggal));
  }

  void _perbarui() {
    notifyListeners();
    _penyimpanan.simpan(_data);
  }

  void tambah(Transaksi t) {
    _data.add(t);
    _urutkan();
    _perbarui();
  }

  void ubah(Transaksi baru) {
    final i = _data.indexWhere((t) => t.id == baru.id);
    if (i == -1) return;
    _data[i] = baru;
    _urutkan();
    _perbarui();
  }

  void hapus(Transaksi t) {
    _data.removeWhere((x) => x.id == t.id);
    _perbarui();
  }

  void hapusSemua() {
    _data.clear();
    _perbarui();
  }

  Future<void> setAnggaran(int nilai) async {
    _anggaran = nilai;
    notifyListeners();
    await _penyimpanan.simpanAnggaran(nilai);
  }

  void cari(String kata) {
    _kataKunci = kata.trim().toLowerCase();
    notifyListeners();
  }

  void setFilter(FilterJenis f) {
    _filter = f;
    notifyListeners();
  }

  // daftar yang sudah kena pencarian + filter
  List<Transaksi> get tampil {
    return _data.where((t) {
      if (_filter == FilterJenis.pemasukan && !t.pemasukan) return false;
      if (_filter == FilterJenis.pengeluaran && t.pemasukan) return false;
      if (_kataKunci.isNotEmpty &&
          !t.judul.toLowerCase().contains(_kataKunci)) {
        return false;
      }
      return true;
    }).toList();
  }

  int get totalPemasukan =>
      _data.where((t) => t.pemasukan).fold(0, (a, t) => a + t.jumlah);

  int get totalPengeluaran =>
      _data.where((t) => !t.pemasukan).fold(0, (a, t) => a + t.jumlah);

  int get saldo => totalPemasukan - totalPengeluaran;

  bool get kosong => _data.isEmpty;

  // pengeluaran khusus bulan berjalan, dipakai untuk membandingkan dengan anggaran
  int get pengeluaranBulanIni {
    final sekarang = DateTime.now();
    return _data
        .where((t) =>
            !t.pemasukan &&
            t.tanggal.year == sekarang.year &&
            t.tanggal.month == sekarang.month)
        .fold(0, (a, t) => a + t.jumlah);
  }

  Map<Kategori, int> get pengeluaranPerKategori {
    final hasil = <Kategori, int>{};
    for (final t in _data) {
      if (t.pemasukan) continue;
      hasil[t.kategori] = (hasil[t.kategori] ?? 0) + t.jumlah;
    }
    return hasil;
  }

  // ringkasan 6 bulan terakhir (termasuk bulan ini), untuk grafik batang
  List<RingkasanBulan> get tren6Bulan {
    final sekarang = DateTime.now();
    final hasil = <RingkasanBulan>[];

    for (int i = 5; i >= 0; i--) {
      // DateTime otomatis merapikan bulan negatif, mis. bulan 0 jadi Desember tahun lalu
      final bulan = DateTime(sekarang.year, sekarang.month - i, 1);
      int masuk = 0;
      int keluar = 0;

      for (final t in _data) {
        if (t.tanggal.year == bulan.year && t.tanggal.month == bulan.month) {
          if (t.pemasukan) {
            masuk += t.jumlah;
          } else {
            keluar += t.jumlah;
          }
        }
      }
      hasil.add(RingkasanBulan(
        bulan: bulan,
        pemasukan: masuk,
        pengeluaran: keluar,
      ));
    }
    return hasil;
  }

  // insight berbasis aturan (rule-based), bukan AI
  List<String> get insight {
    if (_data.isEmpty) {
      return ['Mulai catat transaksi untuk melihat insight di sini.'];
    }

    final hasil = <String>[];
    final sekarang = DateTime.now();

    // 1. kategori pengeluaran terbesar
    final rincian = pengeluaranPerKategori.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (rincian.isNotEmpty && totalPengeluaran > 0) {
      final teratas = rincian.first;
      final persen = (teratas.value / totalPengeluaran * 100).round();
      hasil.add(
        'Pengeluaran terbesar ada di ${teratas.key.nama} ($persen% dari seluruh pengeluaran).',
      );
    }

    // 2. bulan ini dibanding bulan lalu
    final tren = tren6Bulan;
    final bulanIni = tren.last.pengeluaran;
    final bulanLalu = tren[tren.length - 2].pengeluaran;
    if (bulanLalu > 0) {
      final selisih = ((bulanIni - bulanLalu) / bulanLalu * 100).round();
      if (selisih > 0) {
        hasil.add('Pengeluaran bulan ini naik $selisih% dibanding bulan lalu.');
      } else if (selisih < 0) {
        hasil.add(
          'Bagus! Pengeluaran bulan ini turun ${-selisih}% dibanding bulan lalu.',
        );
      } else {
        hasil.add('Pengeluaran bulan ini sama dengan bulan lalu.');
      }
    }

    // 3. berapa persen pemasukan yang tersisa
    if (totalPemasukan > 0) {
      final persen =
          ((totalPemasukan - totalPengeluaran) / totalPemasukan * 100).round();
      if (persen >= 20) {
        hasil.add(
          'Kamu menyisihkan $persen% dari pemasukan, sudah di atas patokan umum 20%.',
        );
      } else if (persen >= 0) {
        hasil.add(
          'Kamu menyisihkan $persen% dari pemasukan. Patokan umumnya minimal 20%.',
        );
      } else {
        hasil.add(
          'Pengeluaran lebih besar dari pemasukan. Coba kurangi pengeluaran yang tidak penting.',
        );
      }
    }

    // 4. rata-rata harian dan prediksi akhir bulan
    if (bulanIni > 0) {
      final rataHarian = bulanIni ~/ sekarang.day;
      hasil.add('Rata-rata pengeluaran harian bulan ini ${rupiah(rataHarian)}.');

      if (_anggaran > 0) {
        // hari ke-0 bulan depan = hari terakhir bulan ini
        final hariDalamBulan =
            DateTime(sekarang.year, sekarang.month + 1, 0).day;
        final proyeksi = rataHarian * hariDalamBulan;
        if (proyeksi > _anggaran) {
          hasil.add(
            'Dengan laju ini, pengeluaran akhir bulan diperkirakan ${rupiah(proyeksi)}, melebihi anggaran ${rupiah(_anggaran)}.',
          );
        } else {
          hasil.add(
            'Dengan laju ini, pengeluaran akhir bulan diperkirakan ${rupiah(proyeksi)}, masih dalam anggaran.',
          );
        }
      }
    }

    return hasil;
  }

  // teks laporan yang bisa disalin lalu ditempel ke WhatsApp dll
  String buatLaporan(String nama) {
    final teks = StringBuffer();
    teks.writeln('LAPORAN KEUANGAN - $nama');
    teks.writeln('Tanggal: ${tanggalIndo(DateTime.now())}');
    teks.writeln('');
    teks.writeln('Pemasukan   : ${rupiah(totalPemasukan)}');
    teks.writeln('Pengeluaran : ${rupiah(totalPengeluaran)}');
    teks.writeln('Saldo       : ${rupiah(saldo)}');

    final rincian = pengeluaranPerKategori.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (rincian.isNotEmpty) {
      teks.writeln('');
      teks.writeln('Pengeluaran per kategori:');
      for (final e in rincian) {
        teks.writeln('- ${e.key.nama}: ${rupiah(e.value)}');
      }
    }

    if (_anggaran > 0) {
      teks.writeln('');
      teks.writeln('Anggaran bulan ini: ${rupiah(_anggaran)}');
      teks.writeln('Terpakai: ${rupiah(pengeluaranBulanIni)}');
    }
    return teks.toString();
  }
}
