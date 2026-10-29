class DataKurs {
  // 1 Rupiah = berapa mata uang lain, contoh: {'USD': 0.000061, ...}
  final Map<String, double> rates;
  final DateTime diperbarui;
  final bool dariCache;

  const DataKurs({
    required this.rates,
    required this.diperbarui,
    this.dariCache = false,
  });

  factory DataKurs.fromJson(Map<String, dynamic> json, {bool dariCache = false}) {
    if (json['result'] != 'success') {
      throw Exception('API mengembalikan status gagal');
    }

    final mentah = json['rates'] as Map<String, dynamic>;
    final rates = mentah.map((kode, nilai) {
      return MapEntry(kode, (nilai as num).toDouble());
    });

    final detik = (json['time_last_update_unix'] as num).toInt();

    return DataKurs(
      rates: rates,
      diperbarui: DateTime.fromMillisecondsSinceEpoch(detik * 1000),
      dariCache: dariCache,
    );
  }
}
