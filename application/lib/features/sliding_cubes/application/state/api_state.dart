class ApiState<T> {
  const ApiState({this.data, this.errorMessage, this.isLoading = false});

  final T? data;
  final String? errorMessage;
  final bool isLoading;

  bool get hasError => errorMessage != null;

  factory ApiState.idle() => const ApiState();

  factory ApiState.loading() => const ApiState(isLoading: true);

  factory ApiState.success(T data) => ApiState(data: data);

  factory ApiState.failure(String message) => ApiState(errorMessage: message);
}
