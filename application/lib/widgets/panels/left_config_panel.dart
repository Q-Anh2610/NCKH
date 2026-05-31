import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';
import '../../data/example_configs.dart';
import '../input/algorithm_selector.dart';
import '../input/input_source_tabs.dart';
import '../input/json_input_editor.dart';
import '../input/mode_selector.dart';
import '../input/random_config_form.dart';
import '../input/sample_selector.dart';
import '../input/validation_card.dart';
import 'dashboard_card.dart';

class LeftConfigPanel extends StatefulWidget {
  const LeftConfigPanel({super.key, required this.controller});

  final SimulationController controller;

  @override
  State<LeftConfigPanel> createState() => _LeftConfigPanelState();
}

class _LeftConfigPanelState extends State<LeftConfigPanel> {
  late final TextEditingController _jsonController;
  late final TextEditingController _maxStepsController;

  @override
  void initState() {
    super.initState();
    _jsonController = TextEditingController(text: widget.controller.jsonText);
    _maxStepsController = TextEditingController(
      text: widget.controller.maxSteps.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant LeftConfigPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_jsonController.text != widget.controller.jsonText) {
      _jsonController.text = widget.controller.jsonText;
    }
    final maxStepsText = widget.controller.maxSteps.toString();
    if (_maxStepsController.text != maxStepsText) {
      _maxStepsController.text = maxStepsText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return DashboardCard(
      title: 'Controls',
      icon: Icons.tune,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ConfigSummary(controller: controller),
          const SizedBox(height: 14),
          _SidebarSection(
            title: 'Setup',
            icon: Icons.tune,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ModeSelector(
                  value: controller.dimensionMode,
                  onChanged: controller.setDimension,
                ),
                const SizedBox(height: 12),
                AlgorithmSelector(
                  value: controller.algorithm,
                  onChanged: controller.setAlgorithm,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _maxStepsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Max steps',
                    prefixIcon: Icon(Icons.timer),
                  ),
                  onSubmitted: _applyMaxSteps,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      controller.setMaxSteps(parsed);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SidebarSection(
            title: 'Input',
            icon: Icons.input,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputSourceTabs(
                  value: controller.inputSource,
                  onChanged: controller.setInputSource,
                ),
                const SizedBox(height: 12),
                _inputBody(controller),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SidebarSection(
            title: 'Validation',
            icon: Icons.verified,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ValidationCard(result: controller.validation),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: controller.canRun
                      ? () async {
                          await controller.runAlgorithm();
                          if (context.mounted &&
                              controller.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(controller.errorMessage!)),
                            );
                          }
                        }
                      : null,
                  icon: controller.apiStatus == ApiRunStatus.running
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_circle),
                  label: const Text(
                    'Run compaction',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBody(SimulationController controller) {
    return switch (controller.inputSource) {
      InputSource.sample => SampleSelector(
        samples: ExampleConfigs.forDimension(controller.dimension),
        onChanged: controller.loadSample,
      ),
      InputSource.json => JsonInputEditor(
        controller: _jsonController,
        onChanged: controller.updateJsonText,
        onApply: controller.applyJson,
        onFormat: controller.formatJson,
        onClear: controller.clearJson,
      ),
      InputSource.random => RandomConfigForm(controller: controller),
      InputSource.grid => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Use the grid in the visualization panel to add/remove blocks.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: controller.clearGrid,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear grid'),
          ),
        ],
      ),
    };
  }

  void _applyMaxSteps(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      widget.controller.setMaxSteps(parsed);
    }
  }

  @override
  void dispose() {
    _jsonController.dispose();
    _maxStepsController.dispose();
    super.dispose();
  }
}

class _ConfigSummary extends StatelessWidget {
  const _ConfigSummary({required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    final dimension = controller.dimension == 2 ? '2D' : '3D';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              controller.dimension == 2 ? Icons.grid_on : Icons.view_in_ar,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$dimension workspace',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${controller.blocks.length} blocks - ${controller.maxSteps} max steps',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarSection extends StatelessWidget {
  const _SidebarSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
