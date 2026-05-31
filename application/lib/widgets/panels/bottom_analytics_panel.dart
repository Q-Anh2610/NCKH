import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';
import '../analytics/potential_chart.dart';
import '../analytics/step_log_table.dart';
import 'dashboard_card.dart';

class BottomAnalyticsPanel extends StatelessWidget {
  const BottomAnalyticsPanel({
    super.key,
    required this.controller,
    required this.isDesktop,
  });

  final SimulationController controller;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final height = isDesktop ? 116.0 : 240.0;

    final card = DashboardCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(icon: Icon(Icons.table_chart), text: 'Step log'),
                Tab(icon: Icon(Icons.show_chart), text: 'Potential chart'),
                Tab(icon: Icon(Icons.data_object), text: 'Raw JSON'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  SizedBox(
                    height: height,
                    child: StepLogTable(controller: controller),
                  ),
                  SizedBox(
                    height: height,
                    child: PotentialChart(controller: controller),
                  ),
                  _RawJsonView(text: controller.jsonText),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return card;
    }
    return SizedBox(height: 360, child: card);
  }
}

class _RawJsonView extends StatelessWidget {
  const _RawJsonView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          text,
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
