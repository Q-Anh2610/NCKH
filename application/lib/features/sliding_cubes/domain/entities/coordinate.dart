class Coordinate {
  const Coordinate(this.x, this.y, [this.z]);

  final int x;
  final int y;
  final int? z;

  int get dimension => z == null ? 2 : 3;

  List<int> toList() => z == null ? [x, y] : [x, y, z!];

  Coordinate copyWith({int? x, int? y, int? z, bool clearZ = false}) {
    return Coordinate(x ?? this.x, y ?? this.y, clearZ ? null : z ?? this.z);
  }

  static Coordinate fromList(List<num> values) {
    if (values.length != 2 && values.length != 3) {
      throw const FormatException('Coordinate must have 2 or 3 numbers.');
    }
    return Coordinate(
      values[0].toInt(),
      values[1].toInt(),
      values.length == 3 ? values[2].toInt() : null,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Coordinate && x == other.x && y == other.y && z == other.z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => toList().toString();
}
