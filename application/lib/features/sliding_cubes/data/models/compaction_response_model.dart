import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/compaction_result.dart';
import '../../domain/entities/coordinate.dart';
import 'move_step_model.dart';

class CompactionResponseModel {
  const CompactionResponseModel._();

  static CompactionResult fromJson(
    Map<String, dynamic> json,
    BlockConfiguration initial,
  ) {
    final finalJson = json['final'] as Map<String, dynamic>? ?? {};
    final finalBlocks = finalJson['blocks'] as List? ?? const [];
    final stepsJson = json['steps'] as List? ?? const [];
    final potentialsJson = json['potentials'] as List? ?? const [];

    return CompactionResult(
      initial: initial,
      finalConfig: BlockConfiguration(
        dimension:
            (finalJson['dimension'] as num?)?.toInt() ?? initial.dimension,
        blocks: finalBlocks
            .map((item) => Coordinate.fromList((item as List).cast<num>()))
            .toList(),
      ),
      steps: stepsJson
          .map(
            (item) =>
                MoveStepModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      potentials: potentialsJson.map((item) => (item as num).toInt()).toList(),
    );
  }
}
