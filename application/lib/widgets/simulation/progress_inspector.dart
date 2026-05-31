import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';

class ProgressInspector extends StatelessWidget {
  const ProgressInspector({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    final move = controller.currentMove;
    final progress = controller.totalSteps == 0
        ? 0.0
        : controller.currentStep / controller.totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Step ${controller.currentStep} / ${controller.totalSteps}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            _StatusChip(status: controller.simulationStatus),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(value: progress.clamp(0, 1)),
        const SizedBox(height: 14),
        _InfoRow(label: 'Move type', value: move?.type ?? '-'),
        if (controller.activeSubStepCount > 1)
          _InfoRow(
            label: 'Sub-step',
            value:
                '${controller.activeSubStepIndex + 1} / ${controller.activeSubStepCount}',
          ),
        _InfoRow(
          label: 'Moved block',
          value: move == null ? '-' : '${move.from} -> ${move.to}',
        ),
        _InfoRow(
          label: 'Potential',
          value: move == null
              ? '-'
              : '${move.potentialBefore ?? '-'} -> ${move.potentialAfter ?? '-'}',
        ),
        _InfoRow(label: 'Connected after', value: '${move?.connected ?? '-'}'),
        _InfoRow(label: 'Finished after', value: '${move?.finished ?? '-'}'),
        _InfoRow(label: 'Algorithm status', value: controller.backendStatus),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'running' => const Color(0xFF2563EB),
      'finished' => const Color(0xFF16A34A),
      'error' => const Color(0xFFDC2626),
      _ => const Color(0xFF64748B),
    };
    return Chip(
      label: Text(status),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.25)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w800),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B)),
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
