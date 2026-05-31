import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';
import '../../models/block_position.dart';
import '../../models/move_step.dart';
import '../simulation/simulation_controls.dart';
import '../visualization/coordinate_plane_2d.dart';
import '../visualization/grid_3d_layers_view.dart';
import '../visualization/isometric_cubes_3d.dart';
import '../visualization/visualization_legend.dart';
import '../visualization/visualization_toolbar.dart';
import 'dashboard_card.dart';

class CenterVisualizationPanel extends StatefulWidget {
  const CenterVisualizationPanel({
    super.key,
    required this.controller,
    this.isConfigurationVisible = true,
    this.isInspectorVisible = true,
    this.isFullscreen = false,
    this.onToggleConfiguration,
    this.onToggleInspector,
    this.onToggleFullscreen,
  });

  final SimulationController controller;
  final bool isConfigurationVisible;
  final bool isInspectorVisible;
  final bool isFullscreen;
  final VoidCallback? onToggleConfiguration;
  final VoidCallback? onToggleInspector;
  final VoidCallback? onToggleFullscreen;

  @override
  State<CenterVisualizationPanel> createState() =>
      _CenterVisualizationPanelState();
}

class _CenterVisualizationPanelState extends State<CenterVisualizationPanel> {
  bool _showIsometric = true;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final blocks = controller.currentBlocks;
    final move = controller.currentMove;

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
        final isThreeD = controller.dimension == 3;
        final unboundedVizHeight = isThreeD ? 620.0 : 540.0;

        final visualization = _VisualizationBody(
          controller: controller,
          blocks: blocks,
          candidateMoves: controller.validMoves,
          from: move?.from,
          to: move?.to,
          selectedBlock: controller.selectedBlock,
          activeStep: controller.activeSubStep,
          animationProgress: controller.animationProgress,
          showIsometric: _showIsometric,
          onCoordinateTap: (position) =>
              _handleCoordinateTap(controller, blocks, position),
          onCubeTap: controller.selectBlock,
        );

        return DashboardCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(controller: controller, blockCount: blocks.length),
              const SizedBox(height: 10),
              VisualizationToolbar(
                isThreeD: controller.dimension == 3,
                isIsometric: _showIsometric,
                onIsometricChanged: (value) =>
                    setState(() => _showIsometric = value),
                onExpandGrid: controller.expandGrid,
                onClearGrid: controller.clearGrid,
                onNormalize: controller.normalizeToOrigin,
                isConfigurationVisible: widget.isConfigurationVisible,
                isInspectorVisible: widget.isInspectorVisible,
                isFullscreen: widget.isFullscreen,
                onToggleConfiguration: widget.onToggleConfiguration ?? () {},
                onToggleInspector: widget.onToggleInspector ?? () {},
                onToggleFullscreen: widget.onToggleFullscreen ?? () {},
              ),
              const SizedBox(height: 10),
              if (hasBoundedHeight)
                Expanded(child: visualization)
              else
                SizedBox(height: unboundedVizHeight, child: visualization),
              if (!widget.isFullscreen) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),
                SimulationControls(controller: controller),
              ],
            ],
          ),
        );
      },
    );
  }

  void _handleCoordinateTap(
    SimulationController controller,
    List<BlockPosition> visibleBlocks,
    BlockPosition position,
  ) {
    if (visibleBlocks.contains(position) &&
        controller.selectedBlock != position) {
      controller.selectBlock(position);
      return;
    }
    controller.toggleBlock(position);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.blockCount});

  final SimulationController controller;
  final int blockCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.dimension == 2
                  ? 'Oxy Coordinate Plane'
                  : '3D Oxyz View',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              '$blockCount blocks - step ${controller.currentStep}/${controller.totalSteps} - ${controller.simulationStatus} - positive axes only',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
        );

        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 10),
              const VisualizationLegend(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            const VisualizationLegend(),
          ],
        );
      },
    );
  }
}

class _VisualizationBody extends StatelessWidget {
  const _VisualizationBody({
    required this.controller,
    required this.blocks,
    required this.candidateMoves,
    required this.showIsometric,
    required this.onCoordinateTap,
    required this.onCubeTap,
    this.from,
    this.to,
    this.selectedBlock,
    this.activeStep,
    this.animationProgress = 0,
  });

  final SimulationController controller;
  final List<BlockPosition> blocks;
  final List<BlockPosition> candidateMoves;
  final BlockPosition? from;
  final BlockPosition? to;
  final BlockPosition? selectedBlock;
  final MoveStep? activeStep;
  final double animationProgress;
  final bool showIsometric;
  final ValueChanged<BlockPosition> onCoordinateTap;
  final ValueChanged<BlockPosition> onCubeTap;

  @override
  Widget build(BuildContext context) {
    if (controller.dimension == 2) {
      return CoordinatePlane2D(
        blocks: blocks,
        candidateMoves: candidateMoves,
        from: from,
        to: to,
        selectedBlock: selectedBlock,
        activeStep: activeStep,
        animationProgress: animationProgress,
        onCoordinateTap: onCoordinateTap,
      );
    }

    if (showIsometric) {
      return IsometricCubes3D(
        blocks: blocks,
        candidateMoves: candidateMoves,
        from: from,
        to: to,
        selectedBlock: selectedBlock,
        activeStep: activeStep,
        animationProgress: animationProgress,
        onCubeTap: onCubeTap,
      );
    }

    return SingleChildScrollView(
      child: Grid3dLayersView(
        controller: controller,
        blocks: blocks,
        candidateMoves: candidateMoves,
        from: from,
        to: to,
      ),
    );
  }
}
