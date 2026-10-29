import 'dart:math' as math;

import 'package:flutter/material.dart';

class BagianDonut {
  final String label;
  final double nilai;
  final Color warna;

  const BagianDonut({
    required this.label,
    required this.nilai,
    required this.warna,
  });
}

class DonutChart extends StatelessWidget {
  final List<BagianDonut> bagian;
  final String teksTengah;
  final double ukuran;

  const DonutChart({
    super.key,
    required this.bagian,
    required this.teksTengah,
    this.ukuran = 190,
  });

  @override
  Widget build(BuildContext context) {
    // TweenAnimationBuilder menghitung progres 0 -> 1 supaya grafik "tumbuh"
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, progres, _) {
        return SizedBox(
          width: ukuran,
          height: ukuran,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(ukuran, ukuran),
                painter: _DonutPainter(
                  bagian: bagian,
                  progres: progres,
                  warnaKosong:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              SizedBox(
                width: ukuran * 0.55,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total', style: TextStyle(fontSize: 12)),
                      Text(
                        teksTengah,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<BagianDonut> bagian;
  final double progres;
  final Color warnaKosong;

  _DonutPainter({
    required this.bagian,
    required this.progres,
    required this.warnaKosong,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double total = 0;
    for (final b in bagian) {
      total += b.nilai;
    }

    final pusat = Offset(size.width / 2, size.height / 2);
    final tebal = size.shortestSide * 0.18;
    final radius = size.shortestSide / 2 - tebal / 2;
    final area = Rect.fromCircle(center: pusat, radius: radius);

    final kuas = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = tebal;

    if (total <= 0) {
      kuas.color = warnaKosong;
      canvas.drawCircle(pusat, radius, kuas);
      return;
    }

    // mulai dari atas (jam 12), lalu searah jarum jam
    double sudutMulai = -math.pi / 2;
    for (final b in bagian) {
      final sapuan = b.nilai / total * 2 * math.pi * progres;
      kuas.color = b.warna;
      canvas.drawArc(area, sudutMulai, sapuan, false, kuas);
      sudutMulai += sapuan;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter lama) {
    return lama.progres != progres || lama.bagian != bagian;
  }
}
