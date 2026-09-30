import 'package:flutter/foundation.dart';

import '../models/api_response.dart';
import '../services/api_service.dart';

class ApiController extends ChangeNotifier {
  ApiController({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;
  ApiResponse _response = const ApiResponse.initial();

  ApiResponse get response => _response;

  Future<void> consultarApi() async {
    _response = const ApiResponse(status: ApiStatus.loading, message: 'Consultando servidor...');
    notifyListeners();

    try {
      final serverResponse = await _apiService.consultar();
      _response = serverResponse.statusCode == 200
          ? ApiResponse(status: ApiStatus.success, message: serverResponse.body, statusCode: serverResponse.statusCode)
          : ApiResponse(
              status: ApiStatus.error,
              message: 'El servidor respondió con código ${serverResponse.statusCode}.',
              statusCode: serverResponse.statusCode,
            );
    } catch (error) {
      _response = ApiResponse(status: ApiStatus.error, message: 'No fue posible conectar con la API.\n\n$error');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
