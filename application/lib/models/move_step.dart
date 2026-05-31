import 'block_position.dart';

class MoveStep {
  const MoveStep({
    required this.step,
    required this.from,
    required this.to,
    required this.type,
    this.potentialBefore,
    this.potentialAfter,
    this.connected,
    this.finished,
    this.blocksAfter = const [],
  });

  final int step;
  final BlockPosition? from;
  final BlockPosition? to;
  final String type;
  final int? potentialBefore;
  final int? potentialAfter;
  final bool? connected;
  final bool? finished;
  final List<BlockPosition> blocksAfter;

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'from': from?.toJson(),
      'to': to?.toJson(),
      'type': type,
      'potential_before': potentialBefore,
      'potential_after': potentialAfter,
      'connected': connected,
      'finished': finished,
      if (blocksAfter.isNotEmpty)
        'blocks_after': blocksAfter.map((block) => block.toJson()).toList(),
    };
  }

  static MoveStep fromJson(Map<String, dynamic> json, int fallbackStep) {
    final blocksAfterSource =
        json['blocks_after'] ??
        json['blocksAfter'] ??
        json['configuration'] ??
        json['configAfter'] ??
        json['configuration_after'];
    return MoveStep(
      step:
          (json['step'] as num?)?.toInt() ??
          (json['stepIndex'] as num?)?.toInt() ??
          (json['step_index'] as num?)?.toInt() ??
          fallbackStep,
      from: json['from'] == null ? null : BlockPosition.fromJson(json['from']),
      to: json['to'] == null ? null : BlockPosition.fromJson(json['to']),
      type: json['type'] as String? ?? json['move_type'] as String? ?? 'slide',
      potentialBefore:
          (json['potential_before'] as num?)?.toInt() ??
          (json['potentialBefore'] as num?)?.toInt(),
      potentialAfter:
          (json['potential_after'] as num?)?.toInt() ??
          (json['potentialAfter'] as num?)?.toInt() ??
          (json['potential'] as num?)?.toInt(),
      connected:
          json['connected'] as bool? ??
          json['is_connected_after'] as bool? ??
          json['isConnectedAfter'] as bool?,
      finished:
          json['finished'] as bool? ??
          json['is_finished_after'] as bool? ??
          json['isFinishedAfter'] as bool?,
      blocksAfter: blocksAfterSource is List
          ? blocksAfterSource.map(BlockPosition.fromJson).toList()
          : const [],
    );
  }
}
