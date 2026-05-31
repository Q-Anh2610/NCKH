import 'package:flutter/material.dart';

class PotentialChart extends StatelessWidget {
  const PotentialChart({super.key, required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(
          painter: _PotentialChartPainter(values),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _PotentialChartPainter extends CustomPainter {
  const _PotentialChartPainter(this.values);

  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const padding = 20.0;
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );
    canvas.drawLine(
      const Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );

    if (values.length < 2) {
      return;
    }

    final minValue = values.reduce((a, b) => a < b ? a : b).toDouble();
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    final valueRange = (maxValue - minValue).abs() < 1
        ? 1
        : maxValue - minValue;
    final usableWidth = size.width - padding * 2;
    final usableHeight = size.height - padding * 2;
    final path = Path();

    for (var index = 0; index < values.length; index++) {
      final x = padding + usableWidth * index / (values.length - 1);
      final normalized = (values[index] - minValue) / valueRange;
      final y = size.height - padding - usableHeight * normalized;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _PotentialChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
