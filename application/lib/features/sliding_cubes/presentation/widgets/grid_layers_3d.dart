import 'package:flutter/material.dart';

import '../../../../core/constants/grid_constants.dart';
import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/coordinate.dart';
import 'grid_editor_2d.dart';

class GridLayers3d extends StatelessWidget {
  const GridLayers3d({
    super.key,
    required this.configuration,
    this.onCellTap,
    this.layerCount = GridConstants.defaultLayerCount,
    this.highlightFrom,
    this.highlightTo,
  });

  final BlockConfiguration configuration;
  final ValueChanged<Coordinate>? onCellTap;
  final int layerCount;
  final Coordinate? highlightFrom;
  final Coordinate? highlightTo;

  @override
  Widget build(BuildContext context) {
    final maxZ = configuration.blocks.fold<int>(
      0,
      (maxLayer, block) => (block.z ?? 0) > maxLayer ? block.z ?? 0 : maxLayer,
    );
    final visibleLayerCount = layerCount > maxZ + 1 ? layerCount : maxZ + 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 340,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: 390,
      ),
      itemCount: visibleLayerCount,
      itemBuilder: (context, index) {
        final blockCount = configuration.blocks
            .where((block) => (block.z ?? 0) == index)
            .length;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Layer z = $index',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text('$blockCount blocks'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridEditor2d(
                    configuration: configuration,
                    gridSize: GridConstants.defaultGridSize3d,
                    layer: index,
                    onCellTap: onCellTap,
                    highlightFrom: highlightFrom,
                    highlightTo: highlightTo,
                  ),
                ),
                if (blockCount == 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Empty layer',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
