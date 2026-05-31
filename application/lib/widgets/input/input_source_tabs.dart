import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';

class InputSourceTabs extends StatelessWidget {
  const InputSourceTabs({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final InputSource value;
  final ValueChanged<InputSource> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (InputSource.sample, Icons.category, 'Sample'),
      (InputSource.json, Icons.data_object, 'JSON'),
      (InputSource.random, Icons.auto_awesome, 'Random'),
      (InputSource.grid, Icons.grid_on, 'Grid'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          ChoiceChip(
            selected: value == item.$1,
            avatar: Icon(item.$2, size: 16),
            label: Text(item.$3),
            labelStyle: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            visualDensity: VisualDensity.compact,
            onSelected: (_) => onChanged(item.$1),
          ),
      ],
    );
  }
}
