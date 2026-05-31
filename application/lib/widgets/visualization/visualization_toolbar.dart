import 'package:flutter/material.dart';

class VisualizationToolbar extends StatelessWidget {
  const VisualizationToolbar({
    super.key,
    required this.isThreeD,
    required this.isIsometric,
    required this.onIsometricChanged,
    required this.onExpandGrid,
    required this.onClearGrid,
    required this.onNormalize,
    required this.isConfigurationVisible,
    required this.isInspectorVisible,
    required this.isFullscreen,
    required this.onToggleConfiguration,
    required this.onToggleInspector,
    required this.onToggleFullscreen,
  });

  final bool isThreeD;
  final bool isIsometric;
  final ValueChanged<bool> onIsometricChanged;
  final VoidCallback onExpandGrid;
  final VoidCallback onClearGrid;
  final VoidCallback onNormalize;
  final bool isConfigurationVisible;
  final bool isInspectorVisible;
  final bool isFullscreen;
  final VoidCallback onToggleConfiguration;
  final VoidCallback onToggleInspector;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (isThreeD)
          SegmentedButton<bool>(
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            segments: const [
              ButtonSegment(
                value: true,
                icon: Icon(Icons.view_in_ar),
                label: Text('Isometric'),
              ),
              ButtonSegment(
                value: false,
                icon: Icon(Icons.layers),
                label: Text('Layer editor'),
              ),
            ],
            selected: {isIsometric},
            onSelectionChanged: (value) => onIsometricChanged(value.first),
          ),
        OutlinedButton.icon(
          onPressed: onExpandGrid,
          icon: const Icon(Icons.open_in_full),
          label: const Text('Expand'),
        ),
        OutlinedButton.icon(
          onPressed: onNormalize,
          icon: const Icon(Icons.center_focus_strong),
          label: const Text('Normalize'),
        ),
        OutlinedButton.icon(
          onPressed: onClearGrid,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear'),
        ),
        const SizedBox(width: 4),
        _ToolbarIcon(
          icon: isConfigurationVisible
              ? Icons.keyboard_double_arrow_left
              : Icons.keyboard_double_arrow_right,
          tooltip: isConfigurationVisible
              ? 'Hide configuration'
              : 'Show configuration',
          onPressed: onToggleConfiguration,
        ),
        _ToolbarIcon(
          icon: isInspectorVisible
              ? Icons.keyboard_double_arrow_right
              : Icons.keyboard_double_arrow_left,
          tooltip: isInspectorVisible ? 'Hide inspector' : 'Show inspector',
          onPressed: onToggleInspector,
        ),
        _ToolbarIcon(
          icon: isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
          tooltip: isFullscreen
              ? 'Exit fullscreen visualization'
              : 'Fullscreen visualization',
          onPressed: onToggleFullscreen,
        ),
      ],
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  const _ToolbarIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.outlined(
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
      ),
    );
  }
}
