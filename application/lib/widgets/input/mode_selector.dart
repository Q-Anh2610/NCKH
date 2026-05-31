import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key, required this.value, required this.onChanged});

  final DimensionMode value;
  final ValueChanged<DimensionMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DimensionMode>(
      segments: const [
        ButtonSegment(
          value: DimensionMode.twoD,
          icon: Icon(Icons.grid_on),
          label: Text('2D'),
          tooltip: '2D Sliding Squares',
        ),
        ButtonSegment(
          value: DimensionMode.threeD,
          icon: Icon(Icons.view_in_ar),
          label: Text('3D'),
          tooltip: '3D Sliding Cubes',
        ),
      ],
      selected: {value},
      onSelectionChanged: (selected) => onChanged(selected.first),
    );
  }
}
