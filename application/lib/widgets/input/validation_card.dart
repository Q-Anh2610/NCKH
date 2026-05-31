import 'package:flutter/material.dart';

import '../../models/validation_result.dart';

class ValidationCard extends StatelessWidget {
  const ValidationCard({super.key, required this.result});

  final ValidationResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.isValid
        ? const Color(0xFF16A34A)
        : const Color(0xFFEA580C);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.isValid ? Icons.check_circle : Icons.warning_amber,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.isValid
                      ? 'Configuration is valid'
                      : 'Configuration has issues',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          if (!result.isValid) ...[
            const SizedBox(height: 8),
            for (final error in result.errors)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('- $error'),
              ),
          ],
        ],
      ),
    );
  }
}
