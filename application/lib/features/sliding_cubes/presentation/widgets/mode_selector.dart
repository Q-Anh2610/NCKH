import 'package:flutter/material.dart';

import '../../../../core/enums/dimension_mode.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key, required this.value, required this.onChanged});

  final DimensionMode value;
  final ValueChanged<DimensionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DimensionMode>(
      segments: DimensionMode.values
          .map(
            (mode) => ButtonSegment(
              value: mode,
              icon: Icon(
                mode == DimensionMode.twoD ? Icons.grid_on : Icons.view_in_ar,
              ),
              label: Text(mode == DimensionMode.twoD ? '2D' : '3D'),
              tooltip: mode.label,
            ),
          )
          .toList(),
      selected: {value},
      onSelectionChanged: (selected) => onChanged(selected.first),
    );
  }
}
