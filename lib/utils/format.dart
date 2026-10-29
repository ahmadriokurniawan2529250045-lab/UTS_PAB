String rupiah(int angka) {
  final teks = angka.abs().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
      );
  return '${angka < 0 ? '-' : ''}Rp $teks';
}

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String tanggalIndo(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

// untuk angka desimal seperti hasil konversi kurs, contoh: 1,234.56
String desimal(num nilai) {
  final bagian = nilai.abs().toStringAsFixed(2).split('.');
  final depan = bagian[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  return '${nilai < 0 ? '-' : ''}$depan.${bagian[1]}';
}

String namaBulanSingkat(int bulan) => _bulan[bulan - 1];
