import 'package:flutter/material.dart';

class LagrimasWidget extends StatefulWidget {
  const LagrimasWidget({super.key});

  @override
  State<LagrimasWidget> createState() => _LagrimasWidgetState();
}

class _LagrimasWidgetState extends State<LagrimasWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Map<String, double>> _lagrimas = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 15; i++) {
      _lagrimas.add({
        'x': (i * 37.0) % 300,
        'delay': (i * 0.15) % 1.0,
        'size': 4.0 + (i % 4),
      });
    }
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
          painter: _LagrimasPainter(
            progreso: _controller.value,
            lagrimas: _lagrimas,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _LagrimasPainter extends CustomPainter {
  final double progreso;
  final List<Map<String, double>> lagrimas;

  _LagrimasPainter({required this.progreso, required this.lagrimas});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.lightBlue.withOpacity(0.8);

    for (var lagrima in lagrimas) {
      final delay = lagrima['delay']!;
      final x = lagrima['x']!;
      final s = lagrima['size']!;

      double y = ((progreso + delay) % 1.0) * size.height;

      final path = Path();
      path.moveTo(x, y);
      path.cubicTo(x - s, y + s * 1.5, x - s, y + s * 3, x, y + s * 3.5);
      path.cubicTo(x + s, y + s * 3, x + s, y + s * 1.5, x, y);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LagrimasPainter oldDelegate) => true;
}