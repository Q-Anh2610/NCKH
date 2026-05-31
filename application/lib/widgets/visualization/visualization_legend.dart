import 'package:flutter/material.dart';

import 'block_cell.dart';

class VisualizationLegend extends StatelessWidget {
  const VisualizationLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: const [
        _LegendItem(state: BlockCellState.block, label: 'Block'),
        _LegendItem(state: BlockCellState.from, label: 'From'),
        _LegendItem(state: BlockCellState.to, label: 'To'),
        _LegendItem(state: BlockCellState.selected, label: 'Selected'),
        _LegendItem(state: BlockCellState.candidate, label: 'Candidate'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.state, required this.label});

  final BlockCellState state;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 14,
          child: BlockCell(state: state, onTap: () {}),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
