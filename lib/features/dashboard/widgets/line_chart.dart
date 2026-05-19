import 'package:flutter/material.dart';

class AnalyticsLineChart extends StatelessWidget {
  const AnalyticsLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _LineChartPainter(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintProfit = Paint()
      ..color = Colors.teal.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintExpense = Paint()
      ..color = Colors.orange.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pathProfit = Path();
    final pathExpense = Path();

    final List<double> profitData = [0.4, 0.6, 0.5, 0.8, 0.7, 0.9];
    final List<double> expenseData = [0.3, 0.4, 0.6, 0.5, 0.8, 0.6];

    final stepX = size.width / (profitData.length - 1);

    // Draw grid
    final gridPaint = Paint()..color = Colors.black.withOpacity(0.05);
    for (int i = 0; i < 5; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw Profit Line
    for (int i = 0; i < profitData.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - profitData[i]);
      if (i == 0)
        pathProfit.moveTo(x, y);
      else
        pathProfit.lineTo(x, y);
    }

    // Draw Expense Line
    for (int i = 0; i < expenseData.length; i++) {
      final x = i * stepX;
      final y = size.height * (1 - expenseData[i]);
      if (i == 0)
        pathExpense.moveTo(x, y);
      else
        pathExpense.lineTo(x, y);
    }

    canvas.drawPath(pathProfit, paintProfit);
    canvas.drawPath(pathExpense, paintExpense);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
