class ValidationResult {
  const ValidationResult({required this.isValid, this.errors = const []});

  final bool isValid;
  final List<String> errors;

  factory ValidationResult.valid() => const ValidationResult(isValid: true);

  factory ValidationResult.invalid(List<String> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }
}
