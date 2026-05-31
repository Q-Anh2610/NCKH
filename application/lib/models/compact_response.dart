import 'block_position.dart';
import 'move_step.dart';

class CompactResponse {
  const CompactResponse({
    required this.success,
    required this.message,
    required this.dimension,
    required this.algorithm,
    required this.initialBlocks,
    required this.steps,
    required this.finalBlocks,
    required this.totalSteps,
    required this.status,
    required this.raw,
  });

  final bool success;
  final String message;
  final int dimension;
  final String algorithm;
  final List<BlockPosition> initialBlocks;
  final List<MoveStep> steps;
  final List<BlockPosition> finalBlocks;
  final int totalSteps;
  final String status;
  final Map<String, dynamic> raw;

  bool get isCompleted => status == 'completed' || status == 'finished';
  int? get initialPotential => _readPotential(raw['initial']);
  int? get finalPotential => _readPotential(raw['final'] ?? raw['finalConfig']);

  List<int> get potentialSeries {
    final values = <int>[];
    if (steps.isNotEmpty && steps.first.potentialBefore != null) {
      values.add(steps.first.potentialBefore!);
    }
    for (final step in steps) {
      if (step.potentialAfter != null) {
        values.add(step.potentialAfter!);
      }
    }
    return values;
  }

  Map<String, dynamic> toJson() => raw;

  static CompactResponse fromJson(Map<String, dynamic> json) {
    final dimension = (json['dimension'] as num?)?.toInt() ?? 2;
    final initialBlocks = _readBlocks(
      json['initial'] ??
          json['initialConfig'] ??
          json['initial_config'] ??
          json['initial_blocks'] ??
          json['initialBlocks'],
      dimension,
    );
    final finalBlocks = _readBlocks(
      json['final'] ??
          json['finalConfig'] ??
          json['final_config'] ??
          json['final_blocks'] ??
          json['finalBlocks'],
      dimension,
    );
    final stepsJson =
        json['steps'] as List? ?? json['moves'] as List? ?? const [];
    final steps = [
      for (var index = 0; index < stepsJson.length; index++)
        MoveStep.fromJson(
          Map<String, dynamic>.from(stepsJson[index] as Map),
          index + 1,
        ),
    ];

    return CompactResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      dimension: dimension,
      algorithm: json['algorithm'] as String? ?? 'unknown',
      initialBlocks: initialBlocks,
      steps: steps,
      finalBlocks: finalBlocks,
      totalSteps:
          (json['total_steps'] as num?)?.toInt() ??
          (json['totalSteps'] as num?)?.toInt() ??
          steps.length,
      status: json['status'] as String? ?? 'unknown',
      raw: json,
    );
  }

  static List<BlockPosition> _readBlocks(Object? value, int dimension) {
    if (value is Map && value['blocks'] is List) {
      return (value['blocks'] as List).map(BlockPosition.fromJson).toList();
    }
    if (value is List) {
      return value.map(BlockPosition.fromJson).toList();
    }
    return const [];
  }

  static int? _readPotential(Object? value) {
    if (value is Map) {
      return (value['potential'] as num?)?.toInt() ??
          (value['potential_value'] as num?)?.toInt() ??
          (value['potentialValue'] as num?)?.toInt();
    }
    return null;
  }
}
