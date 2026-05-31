import '../entities/block_configuration.dart';
import '../entities/coordinate.dart';

class ConnectivityChecker {
  const ConnectivityChecker();

  bool isConnected(BlockConfiguration configuration) {
    final blocks = configuration.blocks.toSet();
    if (blocks.isEmpty) {
      return false;
    }

    final visited = <Coordinate>{};
    final queue = <Coordinate>[blocks.first];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (!visited.add(current)) {
        continue;
      }

      for (final neighbor in _neighbors(current, configuration.dimension)) {
        if (blocks.contains(neighbor) && !visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }

    return visited.length == blocks.length;
  }

  List<Coordinate> _neighbors(Coordinate coordinate, int dimension) {
    final candidates = <Coordinate>[
      Coordinate(coordinate.x + 1, coordinate.y, coordinate.z),
      Coordinate(coordinate.x - 1, coordinate.y, coordinate.z),
      Coordinate(coordinate.x, coordinate.y + 1, coordinate.z),
      Coordinate(coordinate.x, coordinate.y - 1, coordinate.z),
    ];

    if (dimension == 3) {
      final z = coordinate.z ?? 0;
      candidates.addAll([
        Coordinate(coordinate.x, coordinate.y, z + 1),
        Coordinate(coordinate.x, coordinate.y, z - 1),
      ]);
    }

    return candidates;
  }
}
