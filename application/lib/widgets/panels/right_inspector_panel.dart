import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';
import '../analytics/export_buttons.dart';
import '../simulation/compaction_result_panel.dart';
import '../simulation/final_result_toggle.dart';
import '../simulation/progress_inspector.dart';
import '../simulation/simulation_controls.dart';
import '../simulation/valid_moves_panel.dart';
import 'dashboard_card.dart';

class RightInspectorPanel extends StatelessWidget {
  const RightInspectorPanel({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DashboardCard(
          title: 'Current step',
          icon: Icons.insights,
          child: ProgressInspector(controller: controller),
        ),
        const SizedBox(height: 14),
        DashboardCard(
          title: 'Playback',
          icon: Icons.play_circle,
          child: SimulationControls(controller: controller),
        ),
        const SizedBox(height: 14),
        DashboardCard(
          title: 'Compaction result',
          icon: Icons.schema,
          child: CompactionResultPanel(controller: controller),
        ),
        const SizedBox(height: 14),
        DashboardCard(
          title: 'Selected coordinate',
          icon: Icons.my_location,
          child: Text(
            controller.selectedBlock?.toString() ?? 'No block selected',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 14),
        DashboardCard(
          title: 'Valid moves',
          icon: Icons.open_with,
          child: ValidMovesPanel(controller: controller),
        ),
        const SizedBox(height: 14),
        DashboardCard(
          title: 'Final result',
          icon: Icons.flag,
          child: FinalResultToggle(controller: controller),
        ),
        const SizedBox(height: 14),
        DashboardCard(
          title: 'Export',
          icon: Icons.ios_share,
          child: ExportButtons(controller: controller),
        ),
      ],
    );
  }
}
