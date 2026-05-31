import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/coordinate.dart';

class SampleConfiguration {
  const SampleConfiguration({required this.name, required this.configuration});

  final String name;
  final BlockConfiguration configuration;
}

class SampleConfigurationSource {
  const SampleConfigurationSource();

  List<SampleConfiguration> samplesForDimension(int dimension) {
    return dimension == 3 ? threeDimensionalSamples : twoDimensionalSamples;
  }

  List<SampleConfiguration> get twoDimensionalSamples => const [
    SampleConfiguration(
      name: 'Line shape',
      configuration: BlockConfiguration(
        dimension: 2,
        blocks: [
          Coordinate(0, 0),
          Coordinate(1, 0),
          Coordinate(2, 0),
          Coordinate(3, 0),
        ],
      ),
    ),
    SampleConfiguration(
      name: 'L shape',
      configuration: BlockConfiguration(
        dimension: 2,
        blocks: [
          Coordinate(0, 0),
          Coordinate(1, 0),
          Coordinate(2, 0),
          Coordinate(2, 1),
        ],
      ),
    ),
    SampleConfiguration(
      name: 'Staircase shape',
      configuration: BlockConfiguration(
        dimension: 2,
        blocks: [
          Coordinate(0, 0),
          Coordinate(1, 0),
          Coordinate(1, 1),
          Coordinate(2, 1),
          Coordinate(2, 2),
        ],
      ),
    ),
    SampleConfiguration(
      name: 'Sparse connected shape',
      configuration: BlockConfiguration(
        dimension: 2,
        blocks: [
          Coordinate(0, 0),
          Coordinate(1, 0),
          Coordinate(1, 1),
          Coordinate(1, 2),
          Coordinate(2, 2),
          Coordinate(3, 2),
        ],
      ),
    ),
    SampleConfiguration(
      name: 'Hard case / zigzag',
      configuration: BlockConfiguration(
        dimension: 2,
        blocks: [
          Coordinate(0, 0),
          Coordinate(1, 0),
          Coordinate(1, 1),
          Coordinate(2, 1),
          Coordinate(2, 2),
          Coordinate(3, 2),
          Coordinate(3, 3),
        ],
      ),
    ),
  ];

  List<SampleConfiguration> get threeDimensionalSamples => const [
    SampleConfiguration(
      name: 'Vertical pillar',
      configuration: BlockConfiguration(
        dimension: 3,
        blocks: [Coordinate(0, 0, 0), Coordinate(0, 0, 1), Coordinate(0, 0, 2)],
      ),
    ),
    SampleConfiguration(
      name: 'L-shaped cubes',
      configuration: BlockConfiguration(
        dimension: 3,
        blocks: [
          Coordinate(0, 0, 0),
          Coordinate(1, 0, 0),
          Coordinate(2, 0, 0),
          Coordinate(2, 1, 0),
          Coordinate(2, 1, 1),
        ],
      ),
    ),
    SampleConfiguration(
      name: 'Stack with gap',
      configuration: BlockConfiguration(
        dimension: 3,
        blocks: [
          Coordinate(0, 0, 0),
          Coordinate(1, 0, 0),
          Coordinate(1, 0, 1),
          Coordinate(1, 0, 2),
        ],
      ),
    ),
    SampleConfiguration(
      name: 'Multi-layer connected shape',
      configuration: BlockConfiguration(
        dimension: 3,
        blocks: [
          Coordinate(0, 0, 0),
          Coordinate(1, 0, 0),
          Coordinate(1, 1, 0),
          Coordinate(1, 1, 1),
          Coordinate(2, 1, 1),
          Coordinate(2, 1, 2),
        ],
      ),
    ),
  ];
}
