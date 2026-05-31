import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/coordinate.dart';

class RandomConfigPanel extends StatefulWidget {
  const RandomConfigPanel({
    super.key,
    required this.dimension,
    required this.onGenerated,
  });

  final int dimension;
  final ValueChanged<BlockConfiguration> onGenerated;

  @override
  State<RandomConfigPanel> createState() => _RandomConfigPanelState();
}

class _RandomConfigPanelState extends State<RandomConfigPanel> {
  double _blockCount = 10;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Random connected configuration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Row(
          children: [
            const Text('Blocks'),
            Expanded(
              child: Slider(
                min: 3,
                max: 30,
                divisions: 27,
                label: _blockCount.round().toString(),
                value: _blockCount,
                onChanged: (value) => setState(() => _blockCount = value),
              ),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: () {
            widget.onGenerated(
              _generateConnected(widget.dimension, _blockCount.round()),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Generate'),
        ),
      ],
    );
  }

  BlockConfiguration _generateConnected(int dimension, int count) {
    final random = Random();
    final blocks = <Coordinate>{Coordinate(0, 0, dimension == 3 ? 0 : null)};

    while (blocks.length < count) {
      final base = blocks.elementAt(random.nextInt(blocks.length));
      final candidates = [
        Coordinate(base.x + 1, base.y, base.z),
        Coordinate(max(0, base.x - 1), base.y, base.z),
        Coordinate(base.x, base.y + 1, base.z),
        Coordinate(base.x, max(0, base.y - 1), base.z),
      ];
      if (dimension == 3) {
        final z = base.z ?? 0;
        candidates.addAll([
          Coordinate(base.x, base.y, z + 1),
          Coordinate(base.x, base.y, max(0, z - 1)),
        ]);
      }
      blocks.add(candidates[random.nextInt(candidates.length)]);
    }

    return BlockConfiguration(dimension: dimension, blocks: blocks.toList());
  }
}
