import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/enums/simulation_status.dart';
import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/compaction_result.dart';
import '../../domain/entities/move_step.dart';
import '../../domain/entities/simulation_state.dart';

class SimulationController extends ChangeNotifier {
  SimulationController(BlockConfiguration initial)
    : _state = SimulationState(configuration: initial);

  SimulationState _state;
  CompactionResult? _result;
  Timer? _timer;
  Duration _speed = const Duration(milliseconds: 600);

  SimulationState get state => _state;
  Duration get speed => _speed;
  CompactionResult? get result => _result;

  void loadResult(CompactionResult result) {
    _timer?.cancel();
    _result = result;
    _state = SimulationState(
      configuration: result.initial,
      totalSteps: result.totalSteps,
      status: SimulationStatus.ready,
    );
    notifyListeners();
  }

  void setInitialConfiguration(BlockConfiguration configuration) {
    if (_result != null) {
      return;
    }
    _state = _state.copyWith(configuration: configuration);
    notifyListeners();
  }

  void replaceInitialConfiguration(BlockConfiguration configuration) {
    _timer?.cancel();
    _result = null;
    _state = SimulationState(configuration: configuration);
    notifyListeners();
  }

  void stepForward() {
    final result = _result;
    if (result == null || _state.currentStep >= result.steps.length) {
      _state = _state.copyWith(status: SimulationStatus.finished);
      notifyListeners();
      return;
    }

    final move = result.steps[_state.currentStep];
    final nextConfiguration = _applyMove(_state.configuration, move);
    final nextStep = _state.currentStep + 1;

    _state = _state.copyWith(
      configuration: nextConfiguration,
      currentStep: nextStep,
      status: nextStep == result.steps.length
          ? SimulationStatus.finished
          : SimulationStatus.paused,
      currentMove: move,
    );
    notifyListeners();
  }

  void stepBack() {
    final result = _result;
    if (result == null || _state.currentStep == 0) {
      reset();
      return;
    }

    final nextStep = _state.currentStep - 1;
    _state = _state.copyWith(
      configuration: _configurationAt(result, nextStep),
      currentStep: nextStep,
      status: SimulationStatus.paused,
      currentMove: nextStep == 0 ? null : result.steps[nextStep - 1],
      clearCurrentMove: nextStep == 0,
    );
    notifyListeners();
  }

  void run() {
    final result = _result;
    if (result == null || _state.status == SimulationStatus.finished) {
      return;
    }

    _state = _state.copyWith(status: SimulationStatus.running);
    notifyListeners();
    _timer?.cancel();
    _timer = Timer.periodic(_speed, (_) {
      if (_state.currentStep >= result.steps.length) {
        pause(status: SimulationStatus.finished);
      } else {
        stepForward();
        if (_state.status != SimulationStatus.finished) {
          _state = _state.copyWith(status: SimulationStatus.running);
          notifyListeners();
        }
      }
    });
  }

  void pause({SimulationStatus status = SimulationStatus.paused}) {
    _timer?.cancel();
    _state = _state.copyWith(status: status);
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    final result = _result;
    _state = SimulationState(
      configuration: result?.initial ?? _state.configuration,
      totalSteps: result?.totalSteps ?? 0,
      status: result == null ? SimulationStatus.idle : SimulationStatus.ready,
    );
    notifyListeners();
  }

  void setSpeed(Duration speed) {
    _speed = speed;
    if (_state.status == SimulationStatus.running) {
      run();
    } else {
      notifyListeners();
    }
  }

  BlockConfiguration _configurationAt(CompactionResult result, int step) {
    var configuration = result.initial;
    for (var index = 0; index < step; index++) {
      configuration = _applyMove(configuration, result.steps[index]);
    }
    return configuration;
  }

  BlockConfiguration _applyMove(
    BlockConfiguration configuration,
    MoveStep move,
  ) {
    final blocks = configuration.blocks.map((block) {
      return block == move.from ? move.to : block;
    }).toList();

    return configuration.copyWith(blocks: blocks);
  }

  void jumpToStep(int step) {
    final result = _result;
    if (result == null) {
      return;
    }
    final boundedStep = step.clamp(0, result.totalSteps);
    _state = _state.copyWith(
      configuration: _configurationAt(result, boundedStep),
      currentStep: boundedStep,
      status: boundedStep == result.totalSteps
          ? SimulationStatus.finished
          : SimulationStatus.paused,
      currentMove: boundedStep == 0 ? null : result.steps[boundedStep - 1],
      clearCurrentMove: boundedStep == 0,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
