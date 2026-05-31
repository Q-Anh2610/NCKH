import 'package:flutter/material.dart';

import '../../controllers/simulation_controller.dart';

class ValidMovesPanel extends StatelessWidget {
  const ValidMovesPanel({super.key, required this.controller});

  final SimulationController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedBlock;
    final moves = controller.validMoves;
    if (selected == null) {
      return const Text('Click a block to preview candidate moves.');
    }
    if (moves.isEmpty) {
      return Text('Selected $selected. No empty neighbor candidate moves.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selected block: $selected'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final move in moves)
              Chip(
                avatar: const Icon(Icons.open_with, size: 16),
                label: Text(move.toString()),
              ),
          ],
        ),
      ],
    );
  }
}
