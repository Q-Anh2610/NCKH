import '../../../../core/enums/dimension_mode.dart';
import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/validation_result.dart';

class ConfigurationState {
  const ConfigurationState({
    required this.dimensionMode,
    required this.configuration,
    required this.validation,
  });

  final DimensionMode dimensionMode;
  final BlockConfiguration configuration;
  final ValidationResult validation;

  ConfigurationState copyWith({
    DimensionMode? dimensionMode,
    BlockConfiguration? configuration,
    ValidationResult? validation,
  }) {
    return ConfigurationState(
      dimensionMode: dimensionMode ?? this.dimensionMode,
      configuration: configuration ?? this.configuration,
      validation: validation ?? this.validation,
    );
  }
}
