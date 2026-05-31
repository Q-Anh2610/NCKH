import '../models/block_position.dart';

class ConnectivityUtils {
  const ConnectivityUtils._();

  static bool isConnected(List<BlockPosition> blocks, int dimension) {
    final occupied = blocks.toSet();
    if (occupied.isEmpty) {
      return false;
    }

    final visited = <BlockPosition>{};
    final queue = <BlockPosition>[occupied.first];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (!visited.add(current)) {
        continue;
      }
      for (final neighbor in neighbors(current, dimension)) {
        if (occupied.contains(neighbor) && !visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }

    return visited.length == occupied.length;
  }

  static List<BlockPosition> neighbors(BlockPosition block, int dimension) {
    final deltas = dimension == 2
        ? const [
            [1, 0],
            [-1, 0],
            [0, 1],
            [0, -1],
          ]
        : const [
            [1, 0, 0],
            [-1, 0, 0],
            [0, 1, 0],
            [0, -1, 0],
            [0, 0, 1],
            [0, 0, -1],
          ];

    return deltas
        .map(block.moveBy)
        .where((candidate) => candidate.isNonNegative)
        .toList();
  }
}
