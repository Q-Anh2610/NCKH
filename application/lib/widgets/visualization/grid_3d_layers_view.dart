import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';
import '../../models/block_position.dart';
import 'layer_grid.dart';

class Grid3dLayersView extends StatelessWidget {
  const Grid3dLayersView({
    super.key,
    required this.controller,
    required this.blocks,
    required this.candidateMoves,
    this.from,
    this.to,
  });

  final SimulationController controller;
  final List<BlockPosition> blocks;
  final List<BlockPosition> candidateMoves;
  final BlockPosition? from;
  final BlockPosition? to;

  @override
  Widget build(BuildContext context) {
    final activeLayer = from?.z ?? to?.z ?? controller.selectedBlock?.z ?? 0;
    final layers = controller.showAllLayers
        ? List<int>.generate(controller.layerCount, (index) => index)
        : [activeLayer.clamp(0, controller.layerCount - 1)];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Show all layers'),
                value: controller.showAllLayers,
                onChanged: controller.setShowAllLayers,
              ),
            ),
            OutlinedButton.icon(
              onPressed: controller.addLayer,
              icon: const Icon(Icons.add),
              label: const Text('Layer'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: controller.removeLayer,
              icon: const Icon(Icons.remove),
              label: const Text('Layer'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 360,
            mainAxisExtent: 430,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: layers.length,
          itemBuilder: (context, index) {
            final layer = layers[index];
            final count = blocks.where((block) => block.z == layer).length;
            return Card(
              elevation: 0,
              color: const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Layer z = $layer',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Chip(label: Text('$count blocks')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: LayerGrid(
                        dimension: 3,
                        gridSize: controller.gridSize,
                        layer: layer,
                        blocks: blocks,
                        candidateMoves: candidateMoves,
                        from: from,
                        to: to,
                        selectedBlock: controller.selectedBlock,
                        onCellTap: _handleTap,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleTap(BlockPosition position) {
    if (blocks.contains(position) && controller.selectedBlock != position) {
      controller.selectBlock(position);
    } else {
      controller.toggleBlock(position);
    }
  }
}
