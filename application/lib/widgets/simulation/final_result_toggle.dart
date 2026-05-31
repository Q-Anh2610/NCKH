import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';

class FinalResultToggle extends StatelessWidget {
  const FinalResultToggle({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Show final result'),
      subtitle: Text(
        controller.hasResult
            ? 'Preview final.blocks in visualization'
            : 'Run the algorithm to enable final preview',
      ),
      value: controller.showFinalResult,
      onChanged: controller.hasResult ? controller.setShowFinalResult : null,
    );
  }
}
