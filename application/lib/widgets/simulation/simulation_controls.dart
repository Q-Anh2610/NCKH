import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';

class SimulationControls extends StatelessWidget {
  const SimulationControls({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _IconControl(
              tooltip: 'Previous step',
              icon: Icons.skip_previous,
              onPressed: controller.hasResult ? controller.stepBack : null,
            ),
            _IconControl(
              tooltip: 'Next step',
              icon: Icons.navigate_next,
              filled: true,
              onPressed: controller.hasResult ? controller.stepForward : null,
            ),
            _IconControl(
              tooltip: 'Play',
              icon: Icons.play_arrow,
              onPressed: controller.hasResult ? controller.startAutoRun : null,
            ),
            _IconControl(
              tooltip: 'Pause',
              icon: Icons.pause,
              onPressed: controller.hasResult ? controller.pause : null,
            ),
            _IconControl(
              tooltip: 'Replay',
              icon: Icons.replay,
              onPressed: controller.hasResult ? controller.replay : null,
            ),
            _IconControl(
              tooltip: 'Reset to initial',
              icon: Icons.restart_alt,
              onPressed: controller.hasResult ? controller.reset : null,
            ),
            _IconControl(
              tooltip: 'Jump to final',
              icon: Icons.last_page,
              onPressed: controller.hasResult ? controller.jumpToFinal : null,
            ),
            Text(_speedLabel(controller.speedMs)),
          ],
        ),
        Slider(
          min: 400,
          max: 700,
          divisions: 6,
          value: controller.speedMs.toDouble(),
          label: _speedLabel(controller.speedMs),
          onChanged: (value) => controller.setSpeedMs(value.round()),
        ),
      ],
    );
  }

  String _speedLabel(int speedMs) {
    final multiplier = 600 / speedMs;
    if (multiplier >= 1) {
      return '${multiplier.toStringAsFixed(multiplier >= 2 ? 0 : 1)}x';
    }
    return '${multiplier.toStringAsFixed(2)}x';
  }
}

class _IconControl extends StatelessWidget {
  const _IconControl({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 42,
        child: filled
            ? FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                child: Icon(icon),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                child: Icon(icon),
              ),
      ),
    );
  }
}
