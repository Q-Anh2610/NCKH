import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';

class RandomConfigForm extends StatelessWidget {
  const RandomConfigForm({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NumberSlider(
          label: 'Blocks',
          value: controller.randomBlockCount,
          min: 3,
          max: 60,
          onChanged: controller.setRandomBlockCount,
        ),
        _NumberSlider(
          label: 'Grid size',
          value: controller.randomGridSize,
          min: 4,
          max: 20,
          onChanged: controller.setRandomGridSize,
        ),
        if (controller.dimension == 3)
          _NumberSlider(
            label: 'Max z',
            value: controller.randomMaxZ,
            min: 1,
            max: 10,
            onChanged: controller.setRandomMaxZ,
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: controller.generateRandom,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Generate config', overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _NumberSlider extends StatelessWidget {
  const _NumberSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: Slider(
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: value.toString(),
            value: value.clamp(min, max).toDouble(),
            onChanged: (next) => onChanged(next.round()),
          ),
        ),
        SizedBox(
          width: 34,
          child: Text(value.toString(), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
