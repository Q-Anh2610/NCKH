class BlockPosition {
  const BlockPosition(this.values);

  final List<int> values;

  int get dimension => values.length;
  int get x => values[0];
  int get y => values[1];
  int get z => values.length == 3 ? values[2] : 0;

  bool get isNonNegative => values.every((value) => value >= 0);

  List<int> toJson() => List<int>.from(values);

  BlockPosition moveBy(List<int> delta) {
    return BlockPosition([
      for (var index = 0; index < values.length; index++)
        values[index] + delta[index],
    ]);
  }

  static BlockPosition fromJson(Object? value) {
    if (value is! List) {
      throw const FormatException('Coordinate must be a list.');
    }
    if (value.length != 2 && value.length != 3) {
      throw const FormatException('Coordinate must have 2 or 3 values.');
    }
    return BlockPosition(
      value.map((item) {
        if (item is! num) {
          throw const FormatException('Coordinate values must be numbers.');
        }
        return item.toInt();
      }).toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! BlockPosition || other.values.length != values.length) {
      return false;
    }
    for (var index = 0; index < values.length; index++) {
      if (values[index] != other.values[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(values);

  @override
  String toString() => '[${values.join(', ')}]';
}
