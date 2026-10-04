import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<http.Response> consultar() {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/getall');
    // Desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/');

    return _client.get(url, headers: {'Accept': 'application/json'});
  }

  Future<http.Response> obtenerConsultas() {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/consultas/getall');
    // Desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/consultas/getall');

    return _client.get(url, headers: {'Accept': 'application/json'});
  }

  Future<http.Response> crearConsulta(Map<String, dynamic> consulta) {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/consultas/crear');
    // Desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/consultas/crear');

    return _client.post(
      url,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(consulta),
    );
  }

  Future<http.Response> editarConsulta(int id, Map<String, dynamic> cambios) {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/consultas/editar/$id');
    // Desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/consultas/editar/$id');

    return _client.patch(
      url,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(cambios),
    );
  }

  Future<http.Response> desactivarConsulta(int id) {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/consultas/desactivar/$id');
    // Desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/consultas/desactivar/$id');

    return _client.patch(url, headers: {'Accept': 'application/json'});
  }

  Future<http.Response> obtenerConsulta(int id) {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/consultas/getbyid/$id');
    // Desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/consultas/getbyid/$id');

    return _client.get(url, headers: {'Accept': 'application/json'});
  }

  Future<http.Response> getProjects() {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/proyectos/getall');
    // Desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/proyectos/getall');
    return _client.get(
      url,
      headers: {'Accept': 'application/json'},
    );
  }

  Future<http.Response> createProject(Map<String, dynamic> project) {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/proyectos/crear');
    // Desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/proyectos/crear');
    return _client.post(
      url,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(project),
    );
  }

  Future<http.Response> updateProject(int id, Map<String, dynamic> changes) {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/proyectos/editar/$id');
    // Desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/proyectos/editar/$id');
    return _client.put(
      url,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(changes),
    );
  }

  Future<http.Response> manualRequest({required String method, required String url, String? body}) {
    final uri = Uri.parse(url);
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null && body.trim().isNotEmpty) headers['Content-Type'] = 'application/json';
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: body);
      case 'PUT':
        return _client.put(uri, headers: headers, body: body);
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: body);
      case 'DELETE':
        return _client.delete(uri, headers: headers, body: body);
      default:
        throw ArgumentError('Método HTTP no soportado: $method');
    }
  }

  void dispose() => _client.close();
}
