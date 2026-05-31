import '../models/block_position.dart';

class CoordinateUtils {
  const CoordinateUtils._();

  static int potential(List<BlockPosition> blocks) {
    return blocks.fold(0, (sum, block) {
      return sum + block.values.fold(0, (axisSum, value) => axisSum + value);
    });
  }

  static List<BlockPosition> normalizeToOrigin(List<BlockPosition> blocks) {
    if (blocks.isEmpty) {
      return blocks;
    }
    final dimension = blocks.first.dimension;
    final mins = List<int>.filled(dimension, 1 << 30);
    for (final block in blocks) {
      for (var axis = 0; axis < dimension; axis++) {
        if (block.values[axis] < mins[axis]) {
          mins[axis] = block.values[axis];
        }
      }
    }
    return blocks
        .map(
          (block) => BlockPosition([
            for (var axis = 0; axis < dimension; axis++)
              block.values[axis] - mins[axis],
          ]),
        )
        .toList();
  }

  static List<BlockPosition> applyMove(
    List<BlockPosition> blocks,
    BlockPosition? from,
    BlockPosition? to,
  ) {
    if (from == null || to == null) {
      return blocks;
    }
    return blocks.map((block) => block == from ? to : block).toList();
  }
}
