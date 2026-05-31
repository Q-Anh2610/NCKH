import 'package:flutter/material.dart';

import '../../../../core/enums/algorithm_type.dart';

class AlgorithmSelector extends StatelessWidget {
  const AlgorithmSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final AlgorithmType value;
  final ValueChanged<AlgorithmType> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<AlgorithmType>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Algorithm'),
      items: AlgorithmType.values
          .map(
            (algorithm) => DropdownMenuItem(
              value: algorithm,
              child: Text(algorithm.label, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: (algorithm) {
        if (algorithm != null) {
          onChanged(algorithm);
        }
      },
    );
  }
}
