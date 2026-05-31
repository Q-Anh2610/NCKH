import 'package:flutter/foundation.dart';

import '../../../../core/enums/dimension_mode.dart';
import '../../data/datasources/sample_configuration_source.dart';
import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/coordinate.dart';
import '../../domain/services/configuration_validator.dart';
import '../state/configuration_state.dart';

class ConfigurationController extends ChangeNotifier {
  ConfigurationController({
    ConfigurationValidator validator = const ConfigurationValidator(),
    SampleConfigurationSource sampleSource = const SampleConfigurationSource(),
  }) : _validator = validator,
       _sampleSource = sampleSource {
    final initial = _sampleSource.twoDimensionalSamples.first.configuration;
    _state = ConfigurationState(
      dimensionMode: DimensionMode.twoD,
      configuration: initial,
      validation: _validator.validate(initial),
    );
  }

  final ConfigurationValidator _validator;
  final SampleConfigurationSource _sampleSource;

  late ConfigurationState _state;

  ConfigurationState get state => _state;

  List<SampleConfiguration> get samples {
    return _sampleSource.samplesForDimension(_state.dimensionMode.value);
  }

  void setDimension(DimensionMode mode) {
    final sample = _sampleSource.samplesForDimension(mode.value).first;
    _setConfiguration(sample.configuration, mode);
  }

  void setSample(SampleConfiguration sample) {
    _setConfiguration(
      sample.configuration,
      DimensionMode.fromDimension(sample.configuration.dimension),
    );
  }

  void toggleBlock(Coordinate coordinate) {
    final blocks = [..._state.configuration.blocks];
    if (blocks.contains(coordinate)) {
      blocks.remove(coordinate);
    } else {
      blocks.add(coordinate);
    }

    _setConfiguration(_state.configuration.copyWith(blocks: blocks));
  }

  void setConfiguration(BlockConfiguration configuration) {
    _setConfiguration(
      configuration,
      DimensionMode.fromDimension(configuration.dimension),
    );
  }

  void _setConfiguration(
    BlockConfiguration configuration, [
    DimensionMode? dimensionMode,
  ]) {
    _state = _state.copyWith(
      dimensionMode: dimensionMode,
      configuration: configuration,
      validation: _validator.validate(configuration),
    );
    notifyListeners();
  }
}
