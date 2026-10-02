class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.client,
    required this.email,
    required this.phone,
    required this.plan,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.priority,
    required this.isActive,
    required this.receivedAt,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at']?.toString();
    return ServiceRequest(
      id: _asInt(json['id']),
      client: json['nombre']?.toString() ?? 'Sin nombre',
      email: json['correo']?.toString() ?? 'Sin correo',
      phone: json['telefono']?.toString() ?? 'Sin teléfono',
      plan: _asInt(json['plan'], fallback: 1),
      description: json['problema']?.toString() ?? 'Sin descripción',
      startDate: json['plazo_inicio']?.toString(),
      endDate: json['plazo_final']?.toString(),
      priority: json['prioridad']?.toString() ?? 'Normal',
      isActive: _asBool(json['estado']),
      receivedAt: createdAt == null ? 'Fecha no disponible' : _formatDate(createdAt),
    );
  }

  final int id;
  final String client;
  final String email;
  final String phone;
  final int plan;
  final String description;
  final String? startDate;
  final String? endDate;
  final String priority;
  final bool isActive;
  final String receivedAt;

  String get title => 'Consulta de $client';
  String get category => switch (plan) {
        1 => 'Básico',
        2 => 'Pro',
        3 => 'Avanzado',
        _ => 'Plan $plan',
      };
  String get status => isActive ? 'Activa' : 'Cerrada';
  String get deadline => _dateRange(startDate, endDate);

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static String _formatDate(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _dateRange(String? start, String? end) {
    if (start == null && end == null) return 'Sin plazo definido';
    if (start == null) return 'Hasta ${_formatDate(end!)}';
    if (end == null) return 'Desde ${_formatDate(start)}';
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }
}
