import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';
import '../../services/export_service.dart';

class ExportButtons extends StatelessWidget {
  const ExportButtons({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            await ExportService.copyJson(controller.exportPayload());
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Result JSON copied')),
              );
            }
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy result JSON'),
        ),
        OutlinedButton.icon(
          onPressed: controller.hasResult
              ? () => ExportService.downloadJson(
                  'steps.json',
                  controller.exportPayload(),
                )
              : null,
          icon: const Icon(Icons.download),
          label: const Text('Download steps.json'),
        ),
        OutlinedButton.icon(
          onPressed: () => ExportService.downloadJson(
            'final_configuration.json',
            controller.finalConfigurationPayload(),
          ),
          icon: const Icon(Icons.save_alt),
          label: const Text('Download final configuration'),
        ),
      ],
    );
  }
}
