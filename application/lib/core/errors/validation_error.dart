class ValidationError {
  const ValidationError(this.message);

  final String message;

  @override
  String toString() => message;
}
