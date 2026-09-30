enum ApiStatus { initial, loading, success, error }

class ApiResponse {
  const ApiResponse({required this.status, required this.message, this.statusCode});

  const ApiResponse.initial()
      : status = ApiStatus.initial,
        message = 'Aún no se ha consultado la API.',
        statusCode = null;

  final ApiStatus status;
  final String message;
  final int? statusCode;

  bool get isLoading => status == ApiStatus.loading;
  bool get hasError => status == ApiStatus.error;
  bool get wasSuccessful => status == ApiStatus.success;
}
