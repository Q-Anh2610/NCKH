import '../../domain/entities/coordinate.dart';
import '../../domain/entities/move_step.dart';

class MoveStepModel {
  const MoveStepModel._();

  static MoveStep fromJson(Map<String, dynamic> json) {
    return MoveStep(
      stepIndex: (json['step'] as num?)?.toInt() ?? 0,
      from: Coordinate.fromList((json['from'] as List).cast<num>()),
      to: Coordinate.fromList((json['to'] as List).cast<num>()),
      type: json['type'] as String? ?? 'slide',
      potentialBefore: (json['potentialBefore'] as num?)?.toInt() ?? 0,
      potentialAfter: (json['potentialAfter'] as num?)?.toInt() ?? 0,
    );
  }
}
