import 'dart:convert';

import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../controllers/simulation_controller.dart';
import '../../models/block_position.dart';
import '../../models/move_step.dart';

class CompactionResultPanel extends StatelessWidget {
  const CompactionResultPanel({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.errorMessage != null) {
      return _ErrorView(message: controller.errorMessage!);
    }

    final result = controller.result;
    if (result == null) {
      return const _EmptyResult();
    }

    final potentials = controller.potentialSeries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MetricGrid(
          items: [
            ('Total steps', '${result.totalSteps}'),
            ('Current', '${controller.currentStep}/${controller.totalSteps}'),
            ('Status', controller.simulationStatus),
            ('Algorithm', result.algorithm),
          ],
        ),
        const SizedBox(height: 12),
        _PotentialSummary(
          initial: result.initialPotential,
          finalValue: result.finalPotential,
          potentials: potentials,
        ),
        const SizedBox(height: 8),
        _CoordinateExpansion(
          title: 'Initial configuration',
          blocks: result.initialBlocks,
        ),
        _CoordinateExpansion(
          title: 'Final configuration',
          blocks: result.finalBlocks,
        ),
        _MovesExpansion(
          steps: result.steps,
          currentStep: controller.currentStep,
          onStepSelected: controller.jumpToStep,
        ),
        _RawJsonExpansion(raw: result.raw),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Container(
            width: 126,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.$1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PotentialSummary extends StatelessWidget {
  const _PotentialSummary({
    required this.initial,
    required this.finalValue,
    required this.potentials,
  });

  final int? initial;
  final int? finalValue;
  final List<int> potentials;

  @override
  Widget build(BuildContext context) {
    final first = initial ?? (potentials.isEmpty ? null : potentials.first);
    final last = finalValue ?? (potentials.isEmpty ? null : potentials.last);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Potential',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              '${first ?? '-'} -> ${last ?? '-'}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            if (potentials.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                potentials.join('  |  '),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CoordinateExpansion extends StatelessWidget {
  const _CoordinateExpansion({required this.title, required this.blocks});

  final String title;
  final List<BlockPosition> blocks;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text('$title (${blocks.length})'),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final block in blocks)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(block.toString()),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MovesExpansion extends StatelessWidget {
  const _MovesExpansion({
    required this.steps,
    required this.currentStep,
    required this.onStepSelected,
  });

  final List<MoveStep> steps;
  final int currentStep;
  final ValueChanged<int> onStepSelected;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: Text('Move steps (${steps.length})'),
      children: [
        if (steps.isEmpty)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('No movement steps returned.'),
          )
        else
          for (final step in steps)
            _MoveRow(
              step: step,
              selected: currentStep == step.step,
              onTap: () => onStepSelected(step.step),
            ),
      ],
    );
  }
}

class _MoveRow extends StatelessWidget {
  const _MoveRow({
    required this.step,
    required this.selected,
    required this.onTap,
  });

  final MoveStep step;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF60A5FA) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '#${step.step}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step.type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${step.from ?? '-'} -> ${step.to ?? '-'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Potential ${step.potentialBefore ?? '-'} -> ${step.potentialAfter ?? '-'}',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RawJsonExpansion extends StatelessWidget {
  const _RawJsonExpansion({required this.raw});

  final Map<String, dynamic> raw;

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: const Text('Raw JSON'),
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 220),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              encoder.convert(raw),
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'API error',
              style: TextStyle(
                color: Color(0xFFB91C1C),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              'URL: ${ApiConfig.baseUrl}${ApiConfig.compactEndpoint}\n$message',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Run compaction to see total steps, potentials, final blocks, and moves.',
    );
  }
}
