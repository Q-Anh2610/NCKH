import 'dart:math';

import '../models/block_position.dart';
import '../utils/connectivity_utils.dart';

class RandomConfigService {
  const RandomConfigService();

  List<BlockPosition> generate({
    required int dimension,
    required int numberOfBlocks,
    required int gridSize,
    required int maxZ,
  }) {
    final random = Random();
    final blocks = <BlockPosition>{
      BlockPosition(dimension == 2 ? [0, 0] : [0, 0, 0]),
    };

    var guard = 0;
    while (blocks.length < numberOfBlocks && guard < numberOfBlocks * 200) {
      guard++;
      final base = blocks.elementAt(random.nextInt(blocks.length));
      final candidates = ConnectivityUtils.neighbors(base, dimension).where((
        candidate,
      ) {
        final inGrid = candidate.x < gridSize && candidate.y < gridSize;
        final inLayer = dimension == 2 || candidate.z <= maxZ;
        return inGrid && inLayer && !blocks.contains(candidate);
      }).toList();
      if (candidates.isEmpty) {
        continue;
      }
      blocks.add(candidates[random.nextInt(candidates.length)]);
    }

    return blocks.toList();
  }
}
