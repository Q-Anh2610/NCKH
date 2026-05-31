import 'package:flutter/material.dart';

class SimulationControls extends StatelessWidget {
  const SimulationControls({
    super.key,
    required this.onStep,
    required this.onBack,
    required this.onRun,
    required this.onPause,
    required this.onReset,
    required this.speed,
    required this.onSpeedChanged,
  });

  final VoidCallback onStep;
  final VoidCallback onBack;
  final VoidCallback onRun;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final Duration speed;
  final ValueChanged<Duration> onSpeedChanged;

  @override
  Widget build(BuildContext context) {
    final speedMs = speed.inMilliseconds.toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _ControlButton(
              tooltip: 'Back',
              icon: Icons.skip_previous,
              onPressed: onBack,
            ),
            const SizedBox(width: 8),
            _ControlButton(
              tooltip: 'Step',
              icon: Icons.navigate_next,
              onPressed: onStep,
              filled: true,
            ),
            const SizedBox(width: 8),
            _ControlButton(
              tooltip: 'Run',
              icon: Icons.play_arrow,
              onPressed: onRun,
            ),
            const SizedBox(width: 8),
            _ControlButton(
              tooltip: 'Pause',
              icon: Icons.pause,
              onPressed: onPause,
            ),
            const SizedBox(width: 8),
            _ControlButton(
              tooltip: 'Reset',
              icon: Icons.restart_alt,
              onPressed: onReset,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.speed),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                min: 100,
                max: 1500,
                divisions: 14,
                value: speedMs.clamp(100, 1500),
                label: '${speed.inMilliseconds} ms',
                onChanged: (value) {
                  onSpeedChanged(Duration(milliseconds: value.round()));
                },
              ),
            ),
            SizedBox(
              width: 64,
              child: Text(
                '${speed.inMilliseconds} ms',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final child = Icon(icon);
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 44,
        child: filled
            ? FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                child: child,
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                child: child,
              ),
      ),
    );
  }
}
