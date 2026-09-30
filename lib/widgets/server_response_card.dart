import 'package:flutter/material.dart';

import '../models/api_response.dart';

class ServerResponseCard extends StatelessWidget {
  const ServerResponseCard({required this.response, super.key});

  final ApiResponse response;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.terminal_rounded, color: Color(0xFF93C5FD), size: 20),
              SizedBox(width: 9),
              Text('Respuesta del servidor', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(14)),
            child: response.isLoading
                ? const Row(
                    children: [
                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF60A5FA))),
                      SizedBox(width: 14),
                      Text('Esperando respuesta...', style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 14)),
                    ],
                  )
                : SelectableText(
                    response.message,
                    style: TextStyle(color: response.hasError ? const Color(0xFFFCA5A5) : const Color(0xFFD1D5DB), fontSize: 14, height: 1.6),
                  ),
          ),
        ],
      ),
    );
  }
}
