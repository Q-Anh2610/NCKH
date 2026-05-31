import '../../../../core/enums/simulation_status.dart';

class SimulationPlayerState {
  const SimulationPlayerState({
    this.status = SimulationStatus.idle,
    this.currentStep = 0,
    this.totalSteps = 0,
    this.speed = const Duration(milliseconds: 600),
  });

  final SimulationStatus status;
  final int currentStep;
  final int totalSteps;
  final Duration speed;

  SimulationPlayerState copyWith({
    SimulationStatus? status,
    int? currentStep,
    int? totalSteps,
    Duration? speed,
  }) {
    return SimulationPlayerState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      speed: speed ?? this.speed,
    );
  }
}
