import 'package:flutter/material.dart';
import 'dart:math';

class DashboardPieChart extends StatelessWidget {
  final Map<String, double> data;
  final List<Color> colors;

  const DashboardPieChart({
    super.key,
    required this.data,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: CustomPaint(
            painter: _PieChartPainter(data, colors),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "${data.values.first.toInt()}%",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: data.entries.indexed.map((entry) {
            final index = entry.$1;
            final key = entry.$2.key;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  key,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors;

  _PieChartPainter(this.data, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;
    final total = data.values.fold(0.0, (sum, val) => sum + val);

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data.values.elementAt(i) / total) * 2 * pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 25
        ..color = colors[i % colors.length]
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle + 0.1, sweepAngle - 0.2, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
