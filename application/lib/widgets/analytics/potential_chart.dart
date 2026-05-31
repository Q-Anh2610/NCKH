import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';

class PotentialChart extends StatelessWidget {
  const PotentialChart({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    final values = controller.potentialSeries;
    if (values.length < 2) {
      return const Center(
        child: Text(
          'No potential series yet.',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
      );
    }

    final minY = values.reduce((a, b) => a < b ? a : b).toDouble();
    final maxY = values.reduce((a, b) => a > b ? a : b).toDouble();
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        minY: minY - 1,
        maxY: maxY + 1,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFE2E8F0), strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var index = 0; index < values.length; index++)
                FlSpot(index.toDouble(), values[index].toDouble()),
            ],
            isCurved: true,
            color: const Color(0xFF2563EB),
            barWidth: 3,
            dotData: FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                final active = index == controller.currentStep;
                return FlDotCirclePainter(
                  radius: active ? 6 : 3,
                  color: active
                      ? const Color(0xFFF97316)
                      : const Color(0xFF2563EB),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}
