import 'package:flutter_test/flutter_test.dart';
import 'package:sliding_cubes/features/sliding_cubes/domain/entities/block_configuration.dart';
import 'package:sliding_cubes/features/sliding_cubes/domain/entities/coordinate.dart';
import 'package:sliding_cubes/features/sliding_cubes/domain/services/configuration_validator.dart';

void main() {
  const validator = ConfigurationValidator();

  test('accepts connected 2D configuration', () {
    const configuration = BlockConfiguration(
      dimension: 2,
      blocks: [Coordinate(0, 0), Coordinate(1, 0), Coordinate(1, 1)],
    );

    expect(validator.validate(configuration).isValid, isTrue);
  });

  test('rejects duplicate coordinates', () {
    const configuration = BlockConfiguration(
      dimension: 2,
      blocks: [Coordinate(0, 0), Coordinate(0, 0)],
    );

    final result = validator.validate(configuration);

    expect(result.isValid, isFalse);
    expect(result.errors.join('\n'), contains('duplicate'));
  });

  test('rejects disconnected configuration', () {
    const configuration = BlockConfiguration(
      dimension: 2,
      blocks: [Coordinate(0, 0), Coordinate(5, 5)],
    );

    final result = validator.validate(configuration);

    expect(result.isValid, isFalse);
    expect(result.errors.join('\n'), contains('connected'));
  });
}
