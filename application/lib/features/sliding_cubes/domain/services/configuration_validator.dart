import '../entities/block_configuration.dart';
import '../entities/validation_result.dart';
import 'connectivity_checker.dart';

class ConfigurationValidator {
  const ConfigurationValidator({
    this.connectivityChecker = const ConnectivityChecker(),
  });

  final ConnectivityChecker connectivityChecker;

  ValidationResult validate(BlockConfiguration configuration) {
    final errors = <String>[];

    if (configuration.dimension != 2 && configuration.dimension != 3) {
      errors.add('Dimension must be 2 or 3.');
    }

    if (configuration.blocks.isEmpty) {
      errors.add('Configuration must contain at least one block.');
    }

    final uniqueBlocks = configuration.blocks.toSet();
    if (uniqueBlocks.length != configuration.blocks.length) {
      errors.add('Configuration contains duplicate coordinates.');
    }

    for (final block in configuration.blocks) {
      if (block.dimension != configuration.dimension) {
        errors.add('Coordinate $block does not match selected dimension.');
      }
      if (block.x < 0 || block.y < 0 || (block.z ?? 0) < 0) {
        errors.add('Coordinate $block contains a negative value.');
      }
    }

    if (errors.isEmpty && !connectivityChecker.isConnected(configuration)) {
      errors.add('Configuration must be connected.');
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}
