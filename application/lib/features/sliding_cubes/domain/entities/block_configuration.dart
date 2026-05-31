import 'coordinate.dart';

class BlockConfiguration {
  const BlockConfiguration({
    required this.dimension,
    required this.blocks,
  });

  final int dimension;
  final List<Coordinate> blocks;

  bool get is2d => dimension == 2;
  bool get is3d => dimension == 3;

  Map<String, dynamic> toJson() {
    return {
      'dimension': dimension,
      'blocks': blocks.map((coordinate) => coordinate.toList()).toList(),
    };
  }

  factory BlockConfiguration.fromJson(Map<String, dynamic> json) {
    return BlockConfiguration(
      dimension: json['dimension'] as int,
      blocks: (json['blocks'] as List<dynamic>)
          .map(
            (item) => Coordinate.fromList(
              (item as List<dynamic>).map((value) => value as int).toList(),
            ),
          )
          .toList(),
    );
  }

  BlockConfiguration copyWith({
    int? dimension,
    List<Coordinate>? blocks,
  }) {
    return BlockConfiguration(
      dimension: dimension ?? this.dimension,
      blocks: blocks ?? this.blocks,
    );
  }
}