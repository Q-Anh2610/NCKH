import 'package:flutter/material.dart';

import '../../models/block_position.dart';
import 'block_cell.dart';

class LayerGrid extends StatelessWidget {
  const LayerGrid({
    super.key,
    required this.dimension,
    required this.gridSize,
    required this.layer,
    required this.blocks,
    required this.candidateMoves,
    required this.onCellTap,
    this.from,
    this.to,
    this.selectedBlock,
  });

  final int dimension;
  final int gridSize;
  final int layer;
  final List<BlockPosition> blocks;
  final List<BlockPosition> candidateMoves;
  final BlockPosition? from;
  final BlockPosition? to;
  final BlockPosition? selectedBlock;
  final ValueChanged<BlockPosition> onCellTap;

  @override
  Widget build(BuildContext context) {
    final occupied = blocks.toSet();
    final candidates = candidateMoves.toSet();
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          final x = index % gridSize;
          final y = index ~/ gridSize;
          final position = dimension == 2
              ? BlockPosition([x, y])
              : BlockPosition([x, y, layer]);
          final state = _stateFor(position, occupied, candidates);
          return BlockCell(state: state, onTap: () => onCellTap(position));
        },
      ),
    );
  }

  BlockCellState _stateFor(
    BlockPosition position,
    Set<BlockPosition> occupied,
    Set<BlockPosition> candidates,
  ) {
    if (position == from) return BlockCellState.from;
    if (position == to) return BlockCellState.to;
    if (position == selectedBlock) return BlockCellState.selected;
    if (occupied.contains(position)) return BlockCellState.block;
    if (candidates.contains(position)) return BlockCellState.candidate;
    return BlockCellState.empty;
  }
}
