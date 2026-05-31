import '../entities/block_configuration.dart';
import '../entities/coordinate.dart';

class ValidMoveFinder {
  const ValidMoveFinder();

  List<Coordinate> findMoves(
    BlockConfiguration configuration,
    Coordinate block,
  ) {
    final occupied = configuration.blocks.toSet();
    final candidates = <Coordinate>[
      Coordinate(block.x + 1, block.y, block.z),
      Coordinate(block.x - 1, block.y, block.z),
      Coordinate(block.x, block.y + 1, block.z),
      Coordinate(block.x, block.y - 1, block.z),
    ];

    if (configuration.dimension == 3) {
      final z = block.z ?? 0;
      candidates.addAll([
        Coordinate(block.x, block.y, z + 1),
        Coordinate(block.x, block.y, z - 1),
      ]);
    }

    return candidates
        .where((candidate) => !occupied.contains(candidate))
        .where((candidate) => candidate.x >= 0 && candidate.y >= 0)
        .where((candidate) => (candidate.z ?? 0) >= 0)
        .toList();
  }
}
