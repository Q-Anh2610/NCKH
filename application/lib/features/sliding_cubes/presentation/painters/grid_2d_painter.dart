import 'package:flutter/material.dart';

import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/coordinate.dart';

class Grid2DPainter extends CustomPainter {
  const Grid2DPainter({
    required this.configuration,
    required this.gridSize,
    this.layer,
    this.highlightFrom,
    this.highlightTo,
  });

  final BlockConfiguration configuration;
  final int gridSize;
  final int? layer;
  final Coordinate? highlightFrom;
  final Coordinate? highlightTo;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;
    final backgroundPaint = Paint()..color = const Color(0xFFFFFFFF);
    final minorGridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    final gridPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.4;
    final blockPaint = Paint()..color = const Color(0xFF2563EB);
    final blockShadowPaint = Paint()..color = const Color(0x332563EB);
    final fromPaint = Paint()..color = const Color(0xFFF97316);
    final toPaint = Paint()..color = const Color(0xFF22C55E);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      backgroundPaint,
    );

    for (var index = 0; index <= gridSize; index++) {
      final offset = index * cellSize;
      final paint = index % 4 == 0 ? gridPaint : minorGridPaint;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), paint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
    }

    for (final block in configuration.blocks) {
      if (layer != null && block.z != layer) {
        continue;
      }
      final rect = Rect.fromLTWH(
        block.x * cellSize + 3,
        block.y * cellSize + 3,
        cellSize - 6,
        cellSize - 6,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.shift(const Offset(0, 2)),
          const Radius.circular(6),
        ),
        blockShadowPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        blockPaint,
      );
    }

    void drawHighlight(Coordinate? coordinate, Paint paint) {
      if (coordinate == null) {
        return;
      }
      if (layer != null && coordinate.z != layer) {
        return;
      }
      final rect = Rect.fromLTWH(
        coordinate.x * cellSize + 6,
        coordinate.y * cellSize + 6,
        cellSize - 12,
        cellSize - 12,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }

    drawHighlight(highlightFrom, fromPaint);
    drawHighlight(highlightTo, toPaint);
  }

  @override
  bool shouldRepaint(covariant Grid2DPainter oldDelegate) {
    return oldDelegate.configuration != configuration ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.layer != layer ||
        oldDelegate.highlightFrom != highlightFrom ||
        oldDelegate.highlightTo != highlightTo;
  }
}
