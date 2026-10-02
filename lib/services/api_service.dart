import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<http.Response> consultar() {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/getall');

    // Para desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/');

    return _client.get(url, headers: {'Accept': 'application/json'});
  }

  Future<http.Response> obtenerConsultas() {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/consultas/getall');

    // Para desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/consultas/getall');

    return _client.get(url, headers: {'Accept': 'application/json'});
  }

  Future<http.Response> crearConsulta(Map<String, dynamic> consulta) {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/consultas/crear');

    // Para desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/consultas/crear');

    return _client.post(
      url,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(consulta),
    );
  }

  Future<http.Response> editarConsulta(int id, Map<String, dynamic> cambios) {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/consultas/editar/$id');

    // Para desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/consultas/editar/$id');

    return _client.patch(
      url,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(cambios),
    );
  }

  Future<http.Response> desactivarConsulta(int id) {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/consultas/desactivar/$id');

    // Para desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/consultas/desactivar/$id');

    return _client.patch(url, headers: {'Accept': 'application/json'});
  }

  Future<http.Response> obtenerConsulta(int id) {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/consultas/getbyid/$id');

    // Para desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/consultas/getbyid/$id');

    return _client.get(url, headers: {'Accept': 'application/json'});
  }

  void dispose() => _client.close();
}
