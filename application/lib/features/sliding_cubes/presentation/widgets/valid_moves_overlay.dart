import 'package:flutter/material.dart';

import '../../domain/entities/coordinate.dart';

class ValidMovesOverlay extends StatelessWidget {
  const ValidMovesOverlay({super.key, required this.moves});

  final List<Coordinate> moves;

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) {
      return const Text('No valid moves selected.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: moves
          .map(
            (move) => Chip(
              avatar: const Icon(Icons.open_with, size: 16),
              label: Text(move.toString()),
            ),
          )
          .toList(),
    );
  }
}
