import '../models/block_position.dart';
import '../models/validation_result.dart';
import '../utils/connectivity_utils.dart';

class InputValidator {
  const InputValidator._();

  static ValidationResult validate({
    required int dimension,
    required List<BlockPosition> blocks,
    required int maxSteps,
  }) {
    final errors = <String>[];

    if (dimension != 2 && dimension != 3) {
      errors.add('Dimension must be 2 or 3.');
    }
    if (maxSteps < 1 || maxSteps > 10000) {
      errors.add('Max steps must be between 1 and 10000.');
    }
    if (blocks.isEmpty) {
      errors.add('Configuration must contain at least one block.');
    }

    final unique = blocks.toSet();
    if (unique.length != blocks.length) {
      errors.add('Configuration contains duplicate coordinates.');
    }

    for (final block in blocks) {
      if (block.dimension != dimension) {
        errors.add('Coordinate $block does not match ${dimension}D mode.');
      }
      if (!block.isNonNegative) {
        errors.add('Coordinate $block contains a negative value.');
      }
    }

    if (errors.isEmpty && !ConnectivityUtils.isConnected(blocks, dimension)) {
      errors.add('Configuration must be connected.');
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}
