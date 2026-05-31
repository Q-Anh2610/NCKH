import 'dart:convert';

import '../../features/sliding_cubes/domain/entities/block_configuration.dart';
import '../../features/sliding_cubes/domain/entities/coordinate.dart';

class CoordinateParser {
  const CoordinateParser._();

  static BlockConfiguration parseConfiguration(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('JSON root must be an object.');
    }

    final dimension = decoded['dimension'];
    final blocks = decoded['blocks'];

    if (dimension is! int) {
      throw const FormatException('dimension must be an integer.');
    }
    if (blocks is! List) {
      throw const FormatException('blocks must be a list.');
    }

    return BlockConfiguration(
      dimension: dimension,
      blocks: blocks.map((item) {
        if (item is! List) {
          throw const FormatException('Each block must be a coordinate list.');
        }
        return Coordinate.fromList(item.cast<num>());
      }).toList(),
    );
  }
}
