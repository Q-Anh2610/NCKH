import '../models/block_position.dart';

class ExampleConfig {
  const ExampleConfig({
    required this.name,
    required this.dimension,
    required this.blocks,
  });

  final String name;
  final int dimension;
  final List<BlockPosition> blocks;
}

class ExampleConfigs {
  const ExampleConfigs._();

  static List<ExampleConfig> forDimension(int dimension) {
    return dimension == 3 ? examples3d : examples2d;
  }

  static const examples2d = [
    ExampleConfig(
      name: 'Line shape',
      dimension: 2,
      blocks: [
        BlockPosition([0, 0]),
        BlockPosition([1, 0]),
        BlockPosition([2, 0]),
        BlockPosition([3, 0]),
      ],
    ),
    ExampleConfig(
      name: 'L shape',
      dimension: 2,
      blocks: [
        BlockPosition([0, 0]),
        BlockPosition([1, 0]),
        BlockPosition([2, 0]),
        BlockPosition([2, 1]),
      ],
    ),
    ExampleConfig(
      name: 'Staircase shape',
      dimension: 2,
      blocks: [
        BlockPosition([0, 0]),
        BlockPosition([1, 0]),
        BlockPosition([1, 1]),
        BlockPosition([2, 1]),
        BlockPosition([2, 2]),
      ],
    ),
    ExampleConfig(
      name: 'Sparse connected shape',
      dimension: 2,
      blocks: [
        BlockPosition([0, 0]),
        BlockPosition([1, 0]),
        BlockPosition([1, 1]),
        BlockPosition([1, 2]),
        BlockPosition([2, 2]),
        BlockPosition([3, 2]),
      ],
    ),
    ExampleConfig(
      name: 'Zigzag hard case',
      dimension: 2,
      blocks: [
        BlockPosition([0, 0]),
        BlockPosition([1, 0]),
        BlockPosition([1, 1]),
        BlockPosition([2, 1]),
        BlockPosition([2, 2]),
        BlockPosition([3, 2]),
        BlockPosition([3, 3]),
      ],
    ),
  ];

  static const examples3d = [
    ExampleConfig(
      name: 'Vertical pillar',
      dimension: 3,
      blocks: [
        BlockPosition([0, 0, 0]),
        BlockPosition([0, 0, 1]),
        BlockPosition([0, 0, 2]),
      ],
    ),
    ExampleConfig(
      name: 'L-shaped cubes',
      dimension: 3,
      blocks: [
        BlockPosition([0, 0, 0]),
        BlockPosition([1, 0, 0]),
        BlockPosition([2, 0, 0]),
        BlockPosition([2, 1, 0]),
        BlockPosition([2, 1, 1]),
      ],
    ),
    ExampleConfig(
      name: 'Stack with gap',
      dimension: 3,
      blocks: [
        BlockPosition([0, 0, 0]),
        BlockPosition([1, 0, 0]),
        BlockPosition([1, 0, 1]),
        BlockPosition([1, 0, 2]),
      ],
    ),
    ExampleConfig(
      name: 'Multi-layer connected shape',
      dimension: 3,
      blocks: [
        BlockPosition([0, 0, 0]),
        BlockPosition([1, 0, 0]),
        BlockPosition([1, 1, 0]),
        BlockPosition([1, 1, 1]),
        BlockPosition([2, 1, 1]),
        BlockPosition([2, 1, 2]),
      ],
    ),
  ];
}
