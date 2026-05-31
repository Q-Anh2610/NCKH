import 'package:flutter/material.dart';

enum BlockCellState { empty, block, from, to, candidate, selected }

class BlockCell extends StatelessWidget {
  const BlockCell({super.key, required this.state, required this.onTap});

  final BlockCellState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (color, borderColor) = switch (state) {
      BlockCellState.empty => (
        const Color(0xFFF8FAFC),
        const Color(0xFFE2E8F0),
      ),
      BlockCellState.block => (
        const Color(0xFF2563EB),
        const Color(0xFF1D4ED8),
      ),
      BlockCellState.from => (const Color(0xFFF97316), const Color(0xFFEA580C)),
      BlockCellState.to => (const Color(0xFF22C55E), const Color(0xFF16A34A)),
      BlockCellState.candidate => (
        const Color(0xFFD8B4FE),
        const Color(0xFFA855F7),
      ),
      BlockCellState.selected => (
        const Color(0xFF7C3AED),
        const Color(0xFF6D28D9),
      ),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
          boxShadow:
              state == BlockCellState.empty || state == BlockCellState.candidate
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
      ),
    );
  }
}
