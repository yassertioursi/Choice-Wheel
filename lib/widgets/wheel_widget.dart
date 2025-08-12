import 'dart:math';
import 'package:flutter/material.dart';

class WheelWidget extends StatefulWidget {
  final List<String> choices;
  final Function(String) onSpinComplete;

  const WheelWidget({
    super.key,
    required this.choices,
    required this.onSpinComplete,
  });

  @override
  State<WheelWidget> createState() => _WheelWidgetState();
}

class _WheelWidgetState extends State<WheelWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _animation;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void spin() {
    if (_isSpinning || widget.choices.isEmpty) return;

    setState(() {
      _isSpinning = true;
    });

    final random = Random();
    final spins = 5 + random.nextDouble() * 5;
    final finalAngle = random.nextDouble() * 2 * pi;
    final totalRotation = spins * 2 * pi + finalAngle;

    _animation = Tween<double>(
      begin: 0,
      end: totalRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _controller.forward(from: 0).then((_) {
      // Correct calculation that matches the wheel drawing
      final normalizedAngle = totalRotation % (2 * pi);
      final sectionAngle = 2 * pi / widget.choices.length;

      // The wheel starts with index 0 at top (-π/2)
      // After rotation, we need to find which section is now at the top
      // Since we rotate clockwise, we need to reverse the calculation
      final adjustedAngle = (2 * pi - normalizedAngle) % (2 * pi);
      final selectedIndex =
          (adjustedAngle / sectionAngle).floor() % widget.choices.length;

      widget.onSpinComplete(widget.choices[selectedIndex]);

      setState(() {
        _isSpinning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: spin,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Wheel Container
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _animation ?? _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animation?.value ?? 0,
                  child: CustomPaint(
                    painter: WheelPainter(widget.choices),
                    size: const Size(280, 280),
                  ),
                );
              },
            ),
          ),
          // Pointer/Arrow at the top
          Positioned(
            top: 0,
            child: CustomPaint(
              painter: PointerPainter(),
              size: const Size(30, 40),
            ),
          ),
        ],
      ),
    );
  }
}

class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Create arrow path pointing downward
    final path = Path();
    path.moveTo(size.width / 2, size.height); // Bottom point (tip)
    path.lineTo(0, 0); // Top left
    path.lineTo(size.width, 0); // Top right
    path.close();

    // Draw arrow with border
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WheelPainter extends CustomPainter {
  final List<String> choices;

  WheelPainter(this.choices);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (choices.isEmpty) return;

    final sectionAngle = 2 * pi / choices.length;

    // Define red color variations
    final colors = [
      const Color(0xFFD32F2F),
      const Color(0xFFE53935),
      const Color(0xFFF44336),
      const Color(0xFFEF5350),
      const Color(0xFFE57373),
    ];

    for (int i = 0; i < choices.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      // Start from top (-π/2) and go clockwise
      final startAngle = -pi / 2 + (i * sectionAngle);
      final sweepAngle = sectionAngle;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      // Draw text
      final textAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + cos(textAngle) * textRadius;
      final textY = center.dy + sin(textAngle) * textRadius;

      final textPainter = TextPainter(
        text: TextSpan(
          text: choices[i],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = const Color(0xFFB71C1C)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 20, centerPaint);

    // Draw center circle border
    final centerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 20, centerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
