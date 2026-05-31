import 'package:flutter/material.dart';

import '../../models/block_position.dart';
import 'coordinate_plane_2d.dart';

class Grid2dView extends StatelessWidget {
  const Grid2dView({
    super.key,
    required this.gridSize,
    required this.blocks,
    required this.candidateMoves,
    required this.onCellTap,
    this.from,
    this.to,
    this.selectedBlock,
  });

  final int gridSize;
  final List<BlockPosition> blocks;
  final List<BlockPosition> candidateMoves;
  final BlockPosition? from;
  final BlockPosition? to;
  final BlockPosition? selectedBlock;
  final ValueChanged<BlockPosition> onCellTap;

  @override
  Widget build(BuildContext context) {
    return CoordinatePlane2D(
      blocks: blocks,
      candidateMoves: candidateMoves,
      from: from,
      to: to,
      selectedBlock: selectedBlock,
      onCoordinateTap: onCellTap,
    );
  }
}
