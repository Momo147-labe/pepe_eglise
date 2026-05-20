import 'package:flutter/material.dart';

class AnalyticsLineChart extends StatelessWidget {
  final List<Map<String, dynamic>>? monthlyTrend;

  const AnalyticsLineChart({super.key, this.monthlyTrend});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: _LineChartPainter(monthlyTrend: monthlyTrend ?? []),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> monthlyTrend;

  _LineChartPainter({required this.monthlyTrend});

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

    List<double> profitData = [0.0];
    List<double> expenseData = [0.0];

    if (monthlyTrend.isNotEmpty) {
      // Find max to scale
      double maxVal = 1.0;
      for (var m in monthlyTrend) {
        if (m['income'] > maxVal) maxVal = m['income'] as double;
        if (m['expense'] > maxVal) maxVal = m['expense'] as double;
      }
      
      profitData = monthlyTrend.map((e) => (e['income'] as double) / maxVal).toList();
      expenseData = monthlyTrend.map((e) => (e['expense'] as double) / maxVal).toList();
    }

    final stepX = profitData.length > 1 ? size.width / (profitData.length - 1) : size.width;

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
