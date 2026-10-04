import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/project.dart';
import '../services/api_service.dart';

class ProjectsController extends ChangeNotifier {
  ProjectsController({required ApiService apiService, this.onLog}) : _apiService = apiService;

  final ApiService _apiService;
  final void Function(String message)? onLog;
  List<Project> _projects = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadProjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiService.getProjects();
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}: ${response.body}');
      final decoded = jsonDecode(response.body);
      final records = decoded is List<dynamic>
          ? decoded
          : decoded is Map<String, dynamic> && decoded['data'] is List<dynamic>
          ? decoded['data'] as List<dynamic>
          : <dynamic>[];
      _projects = records.whereType<Map<String, dynamic>>().map(Project.fromJson).toList();
      onLog?.call('GET /api/proyectos/getall · ${response.statusCode}');
    } catch (error) {
      _errorMessage = 'No fue posible cargar los proyectos.\n$error';
      onLog?.call('GET /api/proyectos/getall · ERROR');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createProject(Map<String, dynamic> payload) async {
    return _save(() => _apiService.createProject(payload), 'POST /api/proyectos/crear');
  }

  Future<String?> updateProject(int id, Map<String, dynamic> payload) async {
    return _save(() => _apiService.updateProject(id, payload), 'PUT /api/proyectos/editar/$id');
  }

  Future<String?> deactivateProject(int id) async {
    return updateProject(id, {'estado': false});
  }

  Future<String?> _save(Future<dynamic> Function() request, String logMessage) async {
    _isSaving = true;
    notifyListeners();
    try {
      final response = await request();
      if (response.statusCode != 200 && response.statusCode != 201) {
        return 'El servidor respondió con código ${response.statusCode}: ${response.body}';
      }
      final updatedProject = _projectFromResponse(response.body);
      onLog?.call('$logMessage · ${response.statusCode}');
      await loadProjects();
      if (updatedProject != null) {
        final index = _projects.indexWhere((project) => project.id == updatedProject.id);
        if (index >= 0) {
          final nextProjects = [..._projects];
          nextProjects[index] = updatedProject;
          _projects = nextProjects;
        } else {
          _projects = [..._projects, updatedProject];
        }
        notifyListeners();
      }
      return null;
    } catch (error) {
      onLog?.call('$logMessage · ERROR');
      return 'No fue posible completar la operación.\n$error';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Project? _projectFromResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final projectData = decoded['data'] is Map<String, dynamic> ? decoded['data'] as Map<String, dynamic> : decoded;
        if (projectData.containsKey('id')) return Project.fromJson(projectData);
      }
    } catch (_) {
      // La API puede responder sin cuerpo; en ese caso se conserva el resultado de getall.
    }
    return null;
  }
}
