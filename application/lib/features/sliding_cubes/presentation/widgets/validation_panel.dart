import 'package:flutter/material.dart';

import '../../domain/entities/validation_result.dart';

class ValidationPanel extends StatelessWidget {
  const ValidationPanel({super.key, required this.result});

  final ValidationResult result;

  @override
  Widget build(BuildContext context) {
    if (result.isValid) {
      return const ListTile(
        dense: true,
        leading: Icon(Icons.check_circle, color: Color(0xFF16A34A)),
        title: Text('Configuration is valid'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTile(
          dense: true,
          leading: Icon(Icons.error, color: Color(0xFFDC2626)),
          title: Text('Configuration has errors'),
        ),
        for (final error in result.errors)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text('- $error'),
          ),
      ],
    );
  }
}
