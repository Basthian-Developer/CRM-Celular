import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/service_request.dart';
import '../services/api_service.dart';

class ConsultationsController extends ChangeNotifier {
  ConsultationsController({required ApiService apiService, this.onLog}) : _apiService = apiService;

  final ApiService _apiService;
  final void Function(String message)? onLog;
  List<ServiceRequest> _consultations = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<ServiceRequest> get consultations => _consultations;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> cargarConsultas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.obtenerConsultas();
      if (response.statusCode != 200) {
        throw Exception(
          'El servidor respondió con código ${response.statusCode}: ${_shortBody(response.body)}',
        );
      }

      final decoded = jsonDecode(response.body);
      final records = _extractRecords(decoded);
      _consultations = records
          .whereType<Map<String, dynamic>>()
          .map(ServiceRequest.fromJson)
          .where((consultation) => consultation.isActive)
          .toList();
      onLog?.call('GET /api/consultas/getall · ${response.statusCode}');
    } catch (error) {
      _errorMessage = 'No fue posible cargar las solicitudes.\n$error';
      onLog?.call('GET /api/consultas/getall · ERROR');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> crearConsulta(Map<String, dynamic> consulta) async {
    _isSaving = true;
    notifyListeners();

    try {
      final response = await _apiService.crearConsulta(consulta);
      if (response.statusCode != 200 && response.statusCode != 201) {
        return 'El servidor respondió con código ${response.statusCode}.';
      }

      await cargarConsultas();
      onLog?.call('POST /api/consultas/crear · ${response.statusCode}');
      return null;
    } catch (error) {
      return 'No fue posible crear la solicitud.\n$error';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> editarConsulta(int id, Map<String, dynamic> cambios) async {
    _isSaving = true;
    notifyListeners();

    try {
      final response = await _apiService.editarConsulta(id, cambios);
      if (response.statusCode != 200 && response.statusCode != 204) {
        return 'No fue posible editar la solicitud. Código ${response.statusCode}.';
      }

      await cargarConsultas();
      onLog?.call('PATCH /api/consultas/editar/$id · ${response.statusCode}');
      return null;
    } catch (error) {
      return 'No fue posible editar la solicitud.\n$error';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> desactivarConsulta(int id) async {
    _isSaving = true;
    notifyListeners();

    try {
      final response = await _apiService.desactivarConsulta(id);
      if (response.statusCode != 200 && response.statusCode != 204) {
        return 'No fue posible desactivar la solicitud. Código ${response.statusCode}.';
      }

      await cargarConsultas();
      onLog?.call('PATCH /api/consultas/desactivar/$id · ${response.statusCode}');
      return null;
    } catch (error) {
      return 'No fue posible desactivar la solicitud.\n$error';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<ServiceRequest?> obtenerConsulta(int id) async {
    try {
      final response = await _apiService.obtenerConsulta(id);
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      final record = decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>
          ? decoded['data'] as Map<String, dynamic>
          : decoded as Map<String, dynamic>;
      return ServiceRequest.fromJson(record);
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _extractRecords(dynamic decoded) {
    final records = _findRecords(decoded);
    if (records != null) return records;
    throw const FormatException('La respuesta de consultas no tiene un formato válido.');
  }

  List<dynamic>? _findRecords(dynamic value) {
    if (value is List<dynamic>) return value;
    if (value is Map<String, dynamic>) {
      for (final key in ['consultas', 'data', 'results', 'result', 'items']) {
        final records = _findRecords(value[key]);
        if (records != null) return records;
      }
    }
    return null;
  }

  String _shortBody(String body) {
    final normalized = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 160) return normalized;
    return '${normalized.substring(0, 160)}...';
  }
}
