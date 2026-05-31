import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';

class StepLogTable extends StatelessWidget {
  const StepLogTable({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    final steps = controller.result?.steps ?? const [];
    if (steps.isEmpty) {
      return const _EmptyState(
        icon: Icons.table_rows,
        text: 'No steps yet. Run the algorithm to populate the log.',
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        headingRowHeight: 40,
        dataRowMinHeight: 42,
        dataRowMaxHeight: 46,
        columns: const [
          DataColumn(label: Text('Step')),
          DataColumn(label: Text('From')),
          DataColumn(label: Text('To')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Potential')),
          DataColumn(label: Text('Connected')),
          DataColumn(label: Text('Finished')),
        ],
        rows: [
          for (final step in steps)
            DataRow(
              selected: controller.currentStep == step.step,
              onSelectChanged: (_) => controller.jumpToStep(step.step),
              cells: [
                DataCell(Text('${step.step}')),
                DataCell(Text('${step.from ?? '-'}')),
                DataCell(Text('${step.to ?? '-'}')),
                DataCell(Text(step.type)),
                DataCell(Text('${step.potentialAfter ?? '-'}')),
                DataCell(Text('${step.connected ?? '-'}')),
                DataCell(Text('${step.finished ?? '-'}')),
              ],
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 34, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
