enum DimensionMode {
  twoD(2, '2D Sliding Squares'),
  threeD(3, '3D Sliding Cubes');

  const DimensionMode(this.value, this.label);

  final int value;
  final String label;

  static DimensionMode fromDimension(int dimension) {
    return dimension == 3 ? DimensionMode.threeD : DimensionMode.twoD;
  }
}
