import '../../../../core/enums/simulation_status.dart';
import 'block_configuration.dart';
import 'move_step.dart';

class SimulationState {
  const SimulationState({
    required this.configuration,
    this.currentStep = 0,
    this.totalSteps = 0,
    this.status = SimulationStatus.idle,
    this.currentMove,
  });

  final BlockConfiguration configuration;
  final int currentStep;
  final int totalSteps;
  final SimulationStatus status;
  final MoveStep? currentMove;

  SimulationState copyWith({
    BlockConfiguration? configuration,
    int? currentStep,
    int? totalSteps,
    SimulationStatus? status,
    MoveStep? currentMove,
    bool clearCurrentMove = false,
  }) {
    return SimulationState(
      configuration: configuration ?? this.configuration,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      status: status ?? this.status,
      currentMove: clearCurrentMove ? null : currentMove ?? this.currentMove,
    );
  }
}
