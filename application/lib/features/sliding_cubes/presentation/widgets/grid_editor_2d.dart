import 'package:flutter/material.dart';

import '../../../../core/constants/grid_constants.dart';
import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/coordinate.dart';
import '../painters/grid_2d_painter.dart';

class GridEditor2d extends StatelessWidget {
  const GridEditor2d({
    super.key,
    required this.configuration,
    this.onCellTap,
    this.gridSize = GridConstants.defaultGridSize2d,
    this.layer,
    this.highlightFrom,
    this.highlightTo,
  });

  final BlockConfiguration configuration;
  final ValueChanged<Coordinate>? onCellTap;
  final int gridSize;
  final int? layer;
  final Coordinate? highlightFrom;
  final Coordinate? highlightTo;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = constraints.maxWidth / gridSize;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: onCellTap == null
                    ? null
                    : (details) {
                        final x = (details.localPosition.dx / cellSize).floor();
                        final y = (details.localPosition.dy / cellSize).floor();
                        if (x >= 0 && y >= 0 && x < gridSize && y < gridSize) {
                          onCellTap!(
                            layer == null
                                ? Coordinate(x, y)
                                : Coordinate(x, y, layer),
                          );
                        }
                      },
                child: CustomPaint(
                  painter: Grid2DPainter(
                    configuration: configuration,
                    gridSize: gridSize,
                    layer: layer,
                    highlightFrom: highlightFrom,
                    highlightTo: highlightTo,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
