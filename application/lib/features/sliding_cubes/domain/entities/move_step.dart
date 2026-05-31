import 'coordinate.dart';

class MoveStep {
  const MoveStep({
    required this.stepIndex,
    required this.from,
    required this.to,
    required this.type,
    required this.potentialBefore,
    required this.potentialAfter,
  });

  final int stepIndex;
  final Coordinate from;
  final Coordinate to;
  final String type;
  final int potentialBefore;
  final int potentialAfter;

  Map<String, dynamic> toJson() {
    return {
      'step': stepIndex,
      'from': from.toList(),
      'to': to.toList(),
      'type': type,
      'potentialBefore': potentialBefore,
      'potentialAfter': potentialAfter,
    };
  }

  factory MoveStep.fromJson(Map<String, dynamic> json) {
    final stepValue = json['step'] ?? json['stepIndex'] ?? 0;
    final potentialBeforeValue =
        json['potentialBefore'] ?? json['potential_before'] ?? 0;
    final potentialAfterValue =
        json['potentialAfter'] ?? json['potential_after'] ?? 0;

    return MoveStep(
      stepIndex: (stepValue as num).toInt(),
      from: Coordinate.fromList(
        (json['from'] as List<dynamic>)
            .map((value) => value as num)
            .toList(),
      ),
      to: Coordinate.fromList(
        (json['to'] as List<dynamic>)
            .map((value) => value as num)
            .toList(),
      ),
      type: (json['type'] ?? '').toString(),
      potentialBefore: (potentialBeforeValue as num).toInt(),
      potentialAfter: (potentialAfterValue as num).toInt(),
    );
  }
}