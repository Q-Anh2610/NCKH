import 'package:flutter/material.dart';

import '../../domain/entities/simulation_state.dart';

class ProgressPanel extends StatelessWidget {
  const ProgressPanel({super.key, required this.state});

  final SimulationState state;

  @override
  Widget build(BuildContext context) {
    final move = state.currentMove;
    final progress = state.totalSteps == 0
        ? 0.0
        : state.currentStep / state.totalSteps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Step ${state.currentStep} / ${state.totalSteps}',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text(state.status.name),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: progress.clamp(0, 1)),
        const SizedBox(height: 12),
        _MetricRow(label: 'Move type', value: move?.type ?? '-'),
        _MetricRow(
          label: 'Moved block',
          value: move == null ? '-' : '${move.from} -> ${move.to}',
        ),
        _MetricRow(
          label: 'Potential',
          value: move == null
              ? '-'
              : '${move.potentialBefore} -> ${move.potentialAfter}',
        ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: const Color(0xFF6B7280)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
