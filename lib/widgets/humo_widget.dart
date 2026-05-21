import 'package:flutter/material.dart';

class HumoWidget extends StatefulWidget {
  const HumoWidget({super.key});

  @override
  State<HumoWidget> createState() => _HumoWidgetState();
}

class _HumoWidgetState extends State<HumoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Map<String, double>> _particulas = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 20; i++) {
      _particulas.add({
        'x': (i * 23.0) % 300,
        'delay': (i * 0.1) % 1.0,
        'size': 6.0 + (i % 8),
        'opacity': 0.3 + (i % 4) * 0.1,
      });
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _HumoPainter(
            progreso: _controller.value,
            particulas: _particulas,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _HumoPainter extends CustomPainter {
  final double progreso;
  final List<Map<String, double>> particulas;

  _HumoPainter({required this.progreso, required this.particulas});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particulas) {
      final delay = p['delay']!;
      final x = p['x']!;
      final s = p['size']!;
      final opacity = p['opacity']!;

      double progress = (progreso + delay) % 1.0;
      double y = size.height - (progress * size.height);
      double radio = s + (progress * s * 2);
      double alpha = opacity * (1 - progress);

      final paint = Paint()
        ..color = Colors.grey.withOpacity(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(Offset(x, y), radio, paint);
    }
  }

  @override
  bool shouldRepaint(_HumoPainter oldDelegate) => true;
}