import 'dart:math';

import 'package:flutter/material.dart';

import 'controllers/auth_controller.dart';
import 'controllers/tema_controller.dart';
import 'screens/halaman_utama.dart';
import 'screens/login_page.dart';
import 'utils/warna.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final auth = AuthController();
  final tema = TemaController();
  await auth.muat();
  await tema.muat();

  runApp(AplikasiKeuangan(auth: auth, tema: tema));
}

class AplikasiKeuangan extends StatelessWidget {
  final AuthController auth;
  final TemaController tema;

  const AplikasiKeuangan({super.key, required this.auth, required this.tema});

  static const double _lebarMaks = 430;

  ThemeData _buatTema(Brightness kecerahan) {
    final gelap = kecerahan == Brightness.dark;
    final skema = ColorScheme.fromSeed(
      seedColor: Warna.utama,
      brightness: kecerahan,
    ).copyWith(primary: Warna.utama);

    return ThemeData(
      useMaterial3: true,
      colorScheme: skema,
      scaffoldBackgroundColor: gelap ? Warna.latarGelap : Warna.latarTerang,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: gelap ? Colors.white : const Color(0xFF111827),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: gelap ? Warna.kartuGelap : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: gelap ? Warna.kartuGelap : Colors.white,
        elevation: 12,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gelap ? Warna.kartuGelap : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Warna.utama,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([auth, tema]),
      builder: (context, _) {
        final pengguna = auth.pengguna;

        return MaterialApp(
          title: 'Catatan Keuangan',
          debugShowCheckedModeBanner: false,
          themeMode: tema.mode,
          theme: _buatTema(Brightness.light),
          darkTheme: _buatTema(Brightness.dark),
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final gelap = Theme.of(context).brightness == Brightness.dark;
            return ColoredBox(
              color: gelap ? Colors.black : const Color(0xFFDDE1EA),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _lebarMaks),
                  child: MediaQuery(
                    data: mq.copyWith(
                      size: Size(min(mq.size.width, _lebarMaks), mq.size.height),
                    ),
                    child: child!,
                  ),
                ),
              ),
            );
          },
          home: pengguna == null
              ? LoginPage(auth: auth)
              : HalamanUtama(
                  key: ValueKey(pengguna.username),
                  auth: auth,
                  tema: tema,
                ),
        );
      },
    );
  }
}