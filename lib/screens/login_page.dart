import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final AuthController auth;

  const LoginPage({super.key, required this.auth});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _modeDaftar = false;
  bool _sembunyiPassword = true;
  bool _loading = false;
  String? _pesanError;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _pesanError = null;
    });

    try {
      if (_modeDaftar) {
        await widget.auth.daftar(
          nama: _namaCtrl.text,
          username: _userCtrl.text,
          password: _passCtrl.text,
        );
      } else {
        await widget.auth.masuk(_userCtrl.text, _passCtrl.text);
      }
      // kalau sukses, main.dart otomatis pindah ke halaman utama
    } on AuthException catch (e) {
      if (mounted) setState(() => _pesanError = e.pesan);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _gantiMode() {
    setState(() {
      _modeDaftar = !_modeDaftar;
      _pesanError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.account_balance_wallet, size: 72, color: warna.primary),
                  const SizedBox(height: 12),
                  const Text(
                    'Catatan Keuangan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _modeDaftar ? 'Buat akun baru' : 'Masuk ke akunmu',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_modeDaftar) ...[
                    TextFormField(
                      controller: _namaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.alternate_email),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final teks = (v ?? '').trim();
                      if (!RegExp(r'^[a-zA-Z0-9_]{4,}$').hasMatch(teks)) {
                        return 'Minimal 4 karakter: huruf, angka, atau _';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _sembunyiPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _sembunyiPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _sembunyiPassword = !_sembunyiPassword);
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _kirim(),
                  ),
                  if (_pesanError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _pesanError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: warna.error),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: _loading ? null : _kirim,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_modeDaftar ? 'Daftar' : 'Masuk'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading ? null : _gantiMode,
                    child: Text(
                      _modeDaftar
                          ? 'Sudah punya akun? Masuk'
                          : 'Belum punya akun? Daftar',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
