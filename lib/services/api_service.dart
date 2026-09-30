import 'package:http/http.dart' as http;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<http.Response> consultar() {
    final url = Uri.parse('https://portafolio-basthianf.vercel.app/api/');

    // Para desarrollo local:
    // final url = Uri.parse('http://localhost:8000/api/');

    return _client.get(url);
  }

  void dispose() => _client.close();
}
