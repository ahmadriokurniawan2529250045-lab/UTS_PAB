class TargetTabungan {
  final String id;
  final String nama;
  final int nominal;
  final int terkumpul;

  const TargetTabungan({
    required this.id,
    required this.nama,
    required this.nominal,
    required this.terkumpul,
  });

  TargetTabungan copyWith({int? terkumpul}) {
    return TargetTabungan(
      id: id,
      nama: nama,
      nominal: nominal,
      terkumpul: terkumpul ?? this.terkumpul,
    );
  }

  // 0.0 sampai 1.0, dipakai untuk progres bar
  double get rasio {
    if (nominal <= 0) return 0.0;
    final hasil = terkumpul / nominal;
    return hasil > 1 ? 1.0 : hasil;
  }

  bool get tercapai => terkumpul >= nominal;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'nominal': nominal,
      'terkumpul': terkumpul,
    };
  }

  factory TargetTabungan.fromMap(Map<String, dynamic> map) {
    return TargetTabungan(
      id: map['id'] as String,
      nama: map['nama'] as String,
      nominal: map['nominal'] as int,
      terkumpul: map['terkumpul'] as int,
    );
  }
}
