import 'package:flutter/material.dart';

import '../../domain/entities/move_step.dart';

class StepLogTable extends StatelessWidget {
  const StepLogTable({
    super.key,
    required this.steps,
    required this.onStepSelected,
  });

  final List<MoveStep> steps;
  final ValueChanged<int> onStepSelected;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const Text('No steps yet.');
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Step')),
          DataColumn(label: Text('From')),
          DataColumn(label: Text('To')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Potential')),
        ],
        rows: steps
            .map(
              (step) => DataRow(
                onSelectChanged: (_) => onStepSelected(step.stepIndex),
                cells: [
                  DataCell(Text('${step.stepIndex}')),
                  DataCell(Text(step.from.toString())),
                  DataCell(Text(step.to.toString())),
                  DataCell(Text(step.type)),
                  DataCell(Text('${step.potentialAfter}')),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
