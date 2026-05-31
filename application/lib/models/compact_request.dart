import 'block_position.dart';

class CompactRequest {
  const CompactRequest({
    required this.dimension,
    required this.blocks,
    required this.maxSteps,
  });

  final int dimension;
  final List<BlockPosition> blocks;
  final int maxSteps;

  Map<String, dynamic> toJson() {
    return {
      'dimension': dimension,
      'blocks': blocks.map((block) => block.toJson()).toList(),
      'max_steps': maxSteps,
    };
  }
}
