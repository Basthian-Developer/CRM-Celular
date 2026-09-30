import 'package:flutter/material.dart';

import '../models/api_response.dart';

class ApiStatusCard extends StatelessWidget {
  const ApiStatusCard({required this.response, super.key});

  final ApiResponse response;

  @override
  Widget build(BuildContext context) {
    final color = response.hasError
        ? const Color(0xFFDC2626)
        : response.wasSuccessful
        ? const Color(0xFF16A34A)
        : const Color(0xFF9CA3AF);
    final label = response.isLoading
        ? 'Consultando...'
        : response.hasError
        ? 'Error de conexión'
        : response.wasSuccessful
        ? 'Servidor disponible'
        : 'Sin comprobar';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(
        children: [
          Icon(response.hasError ? Icons.cloud_off_rounded : Icons.cloud_done_outlined, color: color, size: 27),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estado de la API', style: TextStyle(color: Color(0xFF6B7280))),
                const SizedBox(height: 5),
                Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }
}
