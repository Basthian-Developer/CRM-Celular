import 'package:flutter/material.dart';

class ApiActionButton extends StatelessWidget {
  const ApiActionButton({required this.isLoading, required this.onPressed, super.key});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.sync_rounded, size: 22),
        label: Text(isLoading ? 'Consultando...' : 'Consumir API'),
      ),
    );
  }
}
