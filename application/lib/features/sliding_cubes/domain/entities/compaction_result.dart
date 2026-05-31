import 'block_configuration.dart';
import 'move_step.dart';

class CompactionResult {
  const CompactionResult({
    required this.initial,
    required this.finalConfig,
    required this.steps,
    required this.potentials,
  });

  final BlockConfiguration initial;
  final BlockConfiguration finalConfig;
  final List<MoveStep> steps;
  final List<int> potentials;

  int get totalSteps => steps.length;

  Map<String, dynamic> toJson() {
    return {
      'initial': initial.toJson(),
      'final': finalConfig.toJson(),
      'totalSteps': totalSteps,
      'potentials': potentials,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  factory CompactionResult.fromJson(Map<String, dynamic> json) {
    return CompactionResult(
      initial: BlockConfiguration.fromJson(
        json['initial'] as Map<String, dynamic>,
      ),
      finalConfig: BlockConfiguration.fromJson(
        (json['final'] ?? json['finalConfig']) as Map<String, dynamic>,
      ),
      potentials: ((json['potentials'] ?? []) as List<dynamic>)
          .map((item) => item as int)
          .toList(),
      steps: ((json['steps'] ?? []) as List<dynamic>)
          .map(
            (item) => MoveStep.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  CompactionResult copyWith({
    BlockConfiguration? initial,
    BlockConfiguration? finalConfig,
    List<MoveStep>? steps,
    List<int>? potentials,
  }) {
    return CompactionResult(
      initial: initial ?? this.initial,
      finalConfig: finalConfig ?? this.finalConfig,
      steps: steps ?? this.steps,
      potentials: potentials ?? this.potentials,
    );
  }
}