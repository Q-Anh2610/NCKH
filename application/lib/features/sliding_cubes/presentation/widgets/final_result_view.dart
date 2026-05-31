import 'package:flutter/material.dart';

import '../../domain/entities/block_configuration.dart';
import 'grid_editor_2d.dart';
import 'grid_layers_3d.dart';

class FinalResultView extends StatelessWidget {
  const FinalResultView({super.key, required this.configuration});

  final BlockConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Final configuration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (configuration.dimension == 2)
          SizedBox(
            width: 260,
            child: GridEditor2d(configuration: configuration),
          )
        else
          GridLayers3d(configuration: configuration),
      ],
    );
  }
}
