import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';

class AlgorithmSelector extends StatelessWidget {
  const AlgorithmSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AlgorithmChoice value;
  final ValueChanged<AlgorithmChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AlgorithmChoice>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Algorithm',
        helperText: 'Only Greedy is active on the backend.',
      ),
      items: AlgorithmChoice.values.map((choice) {
        return DropdownMenuItem(
          value: choice,
          enabled: choice == AlgorithmChoice.greedyPotentialReduction,
          child: Text(
            _label(choice),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (choice) {
        if (choice != null) {
          onChanged(choice);
        }
      },
    );
  }

  String _label(AlgorithmChoice choice) {
    return switch (choice) {
      AlgorithmChoice.greedyPotentialReduction => 'Greedy potential',
      AlgorithmChoice.paperInspiredCompaction => 'Paper-inspired',
      AlgorithmChoice.randomValidMoves => 'Random moves',
    };
  }
}
