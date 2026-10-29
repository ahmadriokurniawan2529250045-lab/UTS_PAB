import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kurs.dart';

class KursService {
  static const _url = 'https://open.er-api.com/v6/latest/IDR';
  static const _kunciCache = 'cache_kurs';
  static const _kunciWaktu = 'cache_kurs_waktu';
  static const _umurCache = Duration(hours: 1);

  Future<DataKurs> ambil({bool paksa = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString(_kunciCache);
    final waktu = prefs.getInt(_kunciWaktu);

    // API gratis ini dibatasi jumlah request-nya, jadi pakai cache 1 jam
    if (!paksa && cache != null && waktu != null) {
      final umur = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(waktu),
      );
      if (umur < _umurCache) {
        return DataKurs.fromJson(jsonDecode(cache));
      }
    }

    try {
      final respons = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 10));

      if (respons.statusCode != 200) {
        throw Exception('Server membalas kode ${respons.statusCode}');
      }

      final data = DataKurs.fromJson(jsonDecode(respons.body));
      await prefs.setString(_kunciCache, respons.body);
      await prefs.setInt(_kunciWaktu, DateTime.now().millisecondsSinceEpoch);
      return data;
    } catch (e) {
      // gagal (misal offline): pakai data lama kalau ada
      if (cache != null) {
        return DataKurs.fromJson(jsonDecode(cache), dariCache: true);
      }
      rethrow;
    }
  }
}
