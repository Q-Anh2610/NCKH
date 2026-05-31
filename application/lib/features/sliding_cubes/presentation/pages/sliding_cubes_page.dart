import 'package:flutter/material.dart';

import '../../../../core/enums/algorithm_type.dart';
import '../../../../core/enums/dimension_mode.dart';
import '../../../../shared/layout/responsive_breakpoints.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/panel_surface.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../application/controllers/configuration_controller.dart';
import '../../application/controllers/simulation_controller.dart';
import '../../application/state/configuration_state.dart';
import '../../data/datasources/sample_configuration_source.dart';
import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/compaction_result.dart';
import '../../domain/entities/coordinate.dart';
import '../../domain/entities/move_step.dart';
import '../../domain/services/potential_calculator.dart';
import '../../domain/services/valid_move_finder.dart';
import '../widgets/algorithm_selector.dart';
import '../widgets/coordinate_guide_3d.dart';
import '../widgets/final_result_view.dart';
import '../widgets/grid_editor_2d.dart';
import '../widgets/grid_layers_3d.dart';
import '../widgets/json_input_panel.dart';
import '../widgets/mode_selector.dart';
import '../widgets/potential_chart.dart';
import '../widgets/progress_panel.dart';
import '../widgets/random_config_panel.dart';
import '../widgets/result_export_panel.dart';
import '../widgets/sample_selector.dart';
import '../widgets/simulation_controls.dart';
import '../widgets/step_log_table.dart';
import '../widgets/valid_moves_overlay.dart';
import '../widgets/validation_panel.dart';

class SlidingCubesPage extends StatefulWidget {
  const SlidingCubesPage({super.key});

  @override
  State<SlidingCubesPage> createState() => _SlidingCubesPageState();
}

class _SlidingCubesPageState extends State<SlidingCubesPage> {
  late final ConfigurationController _configurationController;
  late final SimulationController _simulationController;
  final _validMoveFinder = const ValidMoveFinder();
  final _potentialCalculator = const PotentialCalculator();

  AlgorithmType _algorithmType = AlgorithmType.greedyPotentialReduction;
  _ConfigInputMode _inputMode = _ConfigInputMode.sample;
  List<Coordinate> _validMoves = const [];
  bool _showFinal = false;

  @override
  void initState() {
    super.initState();
    _configurationController = ConfigurationController();
    _simulationController = SimulationController(
      _configurationController.state.configuration,
    );
    _configurationController.addListener(_syncConfiguration);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Sliding Cubes',
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _configurationController,
          _simulationController,
        ]),
        builder: (context, _) {
          final configState = _configurationController.state;
          final simulationState = _simulationController.state;
          final currentConfig = simulationState.configuration;
          final result = _simulationController.result;
          final potentialValues =
              result?.potentials ??
              [_potentialCalculator.calculate(configState.configuration)];

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= ResponsiveBreakpoints.wide;
              final workspace = _WorkspacePane(
                configuration: currentConfig,
                dimensionMode: configState.dimensionMode,
                blockCount: currentConfig.blocks.length,
                selectedMoveCount: _validMoves.length,
                onCellTap: _handleCellTap,
                highlightFrom: simulationState.currentMove?.from,
                highlightTo: simulationState.currentMove?.to,
              );
              final configure = _ConfigurePane(
                configState: configState,
                algorithmType: _algorithmType,
                inputMode: _inputMode,
                samples: _configurationController.samples,
                onAlgorithmChanged: (value) =>
                    setState(() => _algorithmType = value),
                onInputModeChanged: (value) =>
                    setState(() => _inputMode = value),
                onDimensionChanged: _configurationController.setDimension,
                onSampleChanged: _configurationController.setSample,
                onJsonParsed: _configurationController.setConfiguration,
                onRunAlgorithm: configState.validation.isValid
                    ? _runAlgorithm
                    : null,
                onRandomGenerated: _configurationController.setConfiguration,
              );
              final inspector = _InspectorPane(
                simulationController: _simulationController,
                potentialValues: potentialValues,
                validMoves: _validMoves,
                result: result,
                showFinal: _showFinal,
                onShowFinalChanged: (value) =>
                    setState(() => _showFinal = value),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 300, child: configure),
                    Expanded(child: workspace),
                    SizedBox(width: 340, child: inspector),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  configure,
                  const SizedBox(height: 16),
                  workspace,
                  const SizedBox(height: 16),
                  inspector,
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _syncConfiguration() {
    _validMoves = const [];
    _showFinal = false;
    _simulationController.replaceInitialConfiguration(
      _configurationController.state.configuration,
    );
  }

  void _handleCellTap(Coordinate coordinate) {
    final configuration = _configurationController.state.configuration;
    if (configuration.blocks.contains(coordinate)) {
      setState(() {
        _validMoves = _validMoveFinder.findMoves(configuration, coordinate);
      });
      return;
    }

    _configurationController.toggleBlock(coordinate);
  }

  void _runAlgorithm() {
    final result = _buildPreviewCompaction(
      _configurationController.state.configuration,
    );
    _simulationController.loadResult(result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Preview result generated locally. API endpoint can replace this later.',
        ),
      ),
    );
  }

  CompactionResult _buildPreviewCompaction(BlockConfiguration initial) {
    var configuration = initial;
    final steps = <MoveStep>[];
    final potentials = <int>[_potentialCalculator.calculate(configuration)];
    const maxIterations = 30;

    for (var index = 0; index < maxIterations; index++) {
      final move = _findGreedyMove(configuration, steps.length + 1);
      if (move == null) {
        break;
      }
      configuration = _applyMove(configuration, move);
      steps.add(move);
      potentials.add(move.potentialAfter);
    }

    return CompactionResult(
      initial: initial,
      finalConfig: configuration,
      steps: steps,
      potentials: potentials,
    );
  }

  MoveStep? _findGreedyMove(BlockConfiguration configuration, int stepIndex) {
    final occupied = configuration.blocks.toSet();
    final before = _potentialCalculator.calculate(configuration);
    for (final block in configuration.blocks.reversed) {
      final candidates = <Coordinate>[
        if (block.x > 0) Coordinate(block.x - 1, block.y, block.z),
        if (block.y > 0) Coordinate(block.x, block.y - 1, block.z),
        if (configuration.dimension == 3 && (block.z ?? 0) > 0)
          Coordinate(block.x, block.y, (block.z ?? 0) - 1),
      ];
      for (final target in candidates) {
        if (occupied.contains(target)) {
          continue;
        }
        final next = _applyMove(
          configuration,
          MoveStep(
            stepIndex: stepIndex,
            from: block,
            to: target,
            type: 'slide',
            potentialBefore: before,
            potentialAfter: before,
          ),
        );
        final after = _potentialCalculator.calculate(next);
        if (after < before) {
          return MoveStep(
            stepIndex: stepIndex,
            from: block,
            to: target,
            type: 'slide',
            potentialBefore: before,
            potentialAfter: after,
          );
        }
      }
    }
    return null;
  }

  BlockConfiguration _applyMove(
    BlockConfiguration configuration,
    MoveStep move,
  ) {
    return configuration.copyWith(
      blocks: configuration.blocks
          .map((block) => block == move.from ? move.to : block)
          .toList(),
    );
  }

  @override
  void dispose() {
    _configurationController.removeListener(_syncConfiguration);
    _configurationController.dispose();
    _simulationController.dispose();
    super.dispose();
  }
}

enum _ConfigInputMode {
  sample('Sample', Icons.category),
  json('JSON', Icons.data_object),
  random('Random', Icons.auto_awesome);

  const _ConfigInputMode(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _ConfigurePane extends StatelessWidget {
  const _ConfigurePane({
    required this.configState,
    required this.algorithmType,
    required this.inputMode,
    required this.samples,
    required this.onAlgorithmChanged,
    required this.onInputModeChanged,
    required this.onDimensionChanged,
    required this.onSampleChanged,
    required this.onJsonParsed,
    required this.onRunAlgorithm,
    required this.onRandomGenerated,
  });

  final ConfigurationState configState;
  final AlgorithmType algorithmType;
  final _ConfigInputMode inputMode;
  final List<SampleConfiguration> samples;
  final ValueChanged<AlgorithmType> onAlgorithmChanged;
  final ValueChanged<_ConfigInputMode> onInputModeChanged;
  final ValueChanged<DimensionMode> onDimensionChanged;
  final ValueChanged<SampleConfiguration> onSampleChanged;
  final ValueChanged<BlockConfiguration> onJsonParsed;
  final VoidCallback? onRunAlgorithm;
  final ValueChanged<BlockConfiguration> onRandomGenerated;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionHeader(
            title: 'Configure',
            trailing: Chip(
              visualDensity: VisualDensity.compact,
              label: Text(
                configState.dimensionMode == DimensionMode.twoD
                    ? 'x,y >= 0'
                    : 'x,y,z >= 0',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ModeSelector(
            value: configState.dimensionMode,
            onChanged: onDimensionChanged,
          ),
          const SizedBox(height: 16),
          AlgorithmSelector(
            value: algorithmType,
            onChanged: onAlgorithmChanged,
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Input source'),
          const SizedBox(height: 10),
          SegmentedButton<_ConfigInputMode>(
            segments: _ConfigInputMode.values
                .map(
                  (mode) => ButtonSegment(
                    value: mode,
                    icon: Icon(mode.icon),
                    label: Text(mode.label),
                  ),
                )
                .toList(),
            selected: {inputMode},
            onSelectionChanged: (selected) =>
                onInputModeChanged(selected.first),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: switch (inputMode) {
              _ConfigInputMode.sample => SampleSelector(
                key: const ValueKey('sample'),
                samples: samples,
                onChanged: onSampleChanged,
              ),
              _ConfigInputMode.json => PanelSurface(
                key: const ValueKey('json'),
                padding: const EdgeInsets.all(12),
                child: JsonInputPanel(
                  configuration: configState.configuration,
                  onParsed: onJsonParsed,
                ),
              ),
              _ConfigInputMode.random => PanelSurface(
                key: const ValueKey('random'),
                padding: const EdgeInsets.all(12),
                child: RandomConfigPanel(
                  dimension: configState.dimensionMode.value,
                  onGenerated: onRandomGenerated,
                ),
              ),
            },
          ),
          const SizedBox(height: 16),
          ValidationPanel(result: configState.validation),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRunAlgorithm,
            icon: const Icon(Icons.play_circle),
            label: const Text('Compact / Run Algorithm'),
          ),
        ],
      ),
    );
  }
}

class _WorkspacePane extends StatelessWidget {
  const _WorkspacePane({
    required this.configuration,
    required this.dimensionMode,
    required this.blockCount,
    required this.selectedMoveCount,
    required this.onCellTap,
    this.highlightFrom,
    this.highlightTo,
  });

  final BlockConfiguration configuration;
  final DimensionMode dimensionMode;
  final int blockCount;
  final int selectedMoveCount;
  final ValueChanged<Coordinate> onCellTap;
  final Coordinate? highlightFrom;
  final Coordinate? highlightTo;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dimensionMode.label,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$blockCount selected blocks - $selectedMoveCount valid moves shown - positive axes only',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            _Legend(),
          ],
        ),
        const SizedBox(height: 18),
        PanelSurface(
          padding: const EdgeInsets.all(18),
          child: dimensionMode == DimensionMode.twoD
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: GridEditor2d(
                      configuration: configuration,
                      onCellTap: onCellTap,
                      highlightFrom: highlightFrom,
                      highlightTo: highlightTo,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CoordinateGuide3d(
                      configuration: configuration,
                      highlightFrom: highlightFrom,
                      highlightTo: highlightTo,
                      height: 520,
                    ),
                    const SizedBox(height: 16),
                    GridLayers3d(
                      configuration: configuration,
                      onCellTap: onCellTap,
                      highlightFrom: highlightFrom,
                      highlightTo: highlightTo,
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _InspectorPane extends StatelessWidget {
  const _InspectorPane({
    required this.simulationController,
    required this.potentialValues,
    required this.validMoves,
    required this.result,
    required this.showFinal,
    required this.onShowFinalChanged,
  });

  final SimulationController simulationController;
  final List<int> potentialValues;
  final List<Coordinate> validMoves;
  final CompactionResult? result;
  final bool showFinal;
  final ValueChanged<bool> onShowFinalChanged;

  @override
  Widget build(BuildContext context) {
    final state = simulationController.state;
    return ColoredBox(
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader(title: 'Simulation'),
          const SizedBox(height: 12),
          PanelSurface(
            child: SimulationControls(
              onStep: simulationController.stepForward,
              onBack: simulationController.stepBack,
              onRun: simulationController.run,
              onPause: simulationController.pause,
              onReset: simulationController.reset,
              speed: simulationController.speed,
              onSpeedChanged: simulationController.setSpeed,
            ),
          ),
          const SizedBox(height: 16),
          PanelSurface(child: ProgressPanel(state: state)),
          const SizedBox(height: 16),
          PanelSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Potential'),
                const SizedBox(height: 12),
                PotentialChart(values: potentialValues),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PanelSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Valid moves'),
                const SizedBox(height: 10),
                ValidMovesOverlay(moves: validMoves),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ResultExportPanel(result: result),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Show final result'),
            value: showFinal,
            onChanged: onShowFinalChanged,
          ),
          if (showFinal && result != null) ...[
            const SizedBox(height: 8),
            PanelSurface(
              child: FinalResultView(configuration: result!.finalConfig),
            ),
          ],
          const SizedBox(height: 16),
          const SectionHeader(title: 'Step log'),
          const SizedBox(height: 8),
          StepLogTable(
            steps: result?.steps ?? const [],
            onStepSelected: simulationController.jumpToStep,
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: const [
        _LegendItem(color: Color(0xFF2563EB), label: 'Block'),
        _LegendItem(color: Color(0xFFF97316), label: 'From'),
        _LegendItem(color: Color(0xFF22C55E), label: 'To'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const SizedBox.square(dimension: 12),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
