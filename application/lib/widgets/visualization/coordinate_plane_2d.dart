import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/block_position.dart';
import '../../models/move_step.dart';

class CoordinatePlane2D extends StatefulWidget {
  const CoordinatePlane2D({
    super.key,
    required this.blocks,
    required this.candidateMoves,
    required this.onCoordinateTap,
    this.from,
    this.to,
    this.selectedBlock,
    this.activeStep,
    this.animationProgress = 0,
    this.minHeight = 520,
  });

  final List<BlockPosition> blocks;
  final List<BlockPosition> candidateMoves;
  final BlockPosition? from;
  final BlockPosition? to;
  final BlockPosition? selectedBlock;
  final MoveStep? activeStep;
  final double animationProgress;
  final ValueChanged<BlockPosition> onCoordinateTap;
  final double minHeight;

  @override
  State<CoordinatePlane2D> createState() => _CoordinatePlane2DState();
}

class _CoordinatePlane2DState extends State<CoordinatePlane2D> {
  static const double _axisPadding = 58;
  double _unit = 48;
  Offset _pan = Offset.zero;
  Offset? _hoverLocal;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : widget.minHeight;
        final size = Size(constraints.maxWidth, height);

        return SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFBFF),
                border: Border.all(color: const Color(0xFFDDE3EE)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  MouseRegion(
                    onHover: (event) => setState(() {
                      _hoverLocal = event.localPosition;
                    }),
                    onExit: (_) => setState(() => _hoverLocal = null),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (details) => setState(() {
                        _pan += details.delta;
                      }),
                      onTapUp: (details) {
                        final coordinate = _coordinateAt(
                          details.localPosition,
                          size,
                        );
                        if (coordinate != null) {
                          widget.onCoordinateTap(coordinate);
                        }
                      },
                      child: CustomPaint(
                        painter: _CoordinatePlanePainter(
                          blocks: widget.blocks,
                          candidateMoves: widget.candidateMoves,
                          from: widget.from,
                          to: widget.to,
                          selectedBlock: widget.selectedBlock,
                          activeStep: widget.activeStep,
                          animationProgress: widget.animationProgress,
                          unit: _unit,
                          pan: _pan,
                          hoverCoordinate: _hoverLocal == null
                              ? null
                              : _coordinateAt(_hoverLocal!, size),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _PlaneControls(
                      onZoomIn: () => _setUnit(_unit * 1.18),
                      onZoomOut: () => _setUnit(_unit / 1.18),
                      onFit: () => _fitToBlocks(size),
                      onReset: () => setState(() {
                        _unit = 48;
                        _pan = Offset.zero;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _setUnit(double value) {
    setState(() => _unit = value.clamp(24, 96));
  }

  void _fitToBlocks(Size size) {
    final points = _allPoints();
    final maxX = points.isEmpty ? 4 : points.map((p) => p.x).reduce(math.max);
    final maxY = points.isEmpty ? 4 : points.map((p) => p.y).reduce(math.max);
    final availableWidth = math.max(120.0, size.width - _axisPadding - 40);
    final availableHeight = math.max(120.0, size.height - _axisPadding - 36);
    final nextUnit = math.min(
      availableWidth / (maxX + 1.7),
      availableHeight / (maxY + 1.7),
    );
    setState(() {
      _unit = nextUnit.clamp(28, 72);
      _pan = Offset.zero;
    });
  }

  BlockPosition? _coordinateAt(Offset local, Size size) {
    final origin = _originFor(size, _pan);
    final x = ((local.dx - origin.dx) / _unit).floor();
    final y = ((origin.dy - local.dy) / _unit).floor();
    if (x < 0 || y < 0) {
      return null;
    }
    return BlockPosition([x, y]);
  }

  List<BlockPosition> _allPoints() => [
    ...widget.blocks,
    ...widget.candidateMoves,
    if (widget.from != null) widget.from!,
    if (widget.to != null) widget.to!,
    if (widget.activeStep?.from != null) widget.activeStep!.from!,
    if (widget.activeStep?.to != null) widget.activeStep!.to!,
  ];

  static Offset _originFor(Size size, Offset pan) {
    return Offset(_axisPadding + pan.dx, size.height - _axisPadding + pan.dy);
  }
}

class _PlaneControls extends StatelessWidget {
  const _PlaneControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
    required this.onReset,
  });

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        border: Border.all(color: const Color(0xFFDDE3EE)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconControl(
            icon: Icons.add,
            tooltip: 'Zoom in',
            onPressed: onZoomIn,
          ),
          _IconControl(
            icon: Icons.remove,
            tooltip: 'Zoom out',
            onPressed: onZoomOut,
          ),
          _IconControl(
            icon: Icons.fit_screen,
            tooltip: 'Fit to blocks',
            onPressed: onFit,
          ),
          _IconControl(
            icon: Icons.restart_alt,
            tooltip: 'Reset view',
            onPressed: onReset,
          ),
        ],
      ),
    );
  }
}

class _IconControl extends StatelessWidget {
  const _IconControl({
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
      child: IconButton(
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _CoordinatePlanePainter extends CustomPainter {
  const _CoordinatePlanePainter({
    required this.blocks,
    required this.candidateMoves,
    required this.unit,
    required this.pan,
    this.from,
    this.to,
    this.selectedBlock,
    this.activeStep,
    this.animationProgress = 0,
    this.hoverCoordinate,
  });

  final List<BlockPosition> blocks;
  final List<BlockPosition> candidateMoves;
  final BlockPosition? from;
  final BlockPosition? to;
  final BlockPosition? selectedBlock;
  final MoveStep? activeStep;
  final double animationProgress;
  final BlockPosition? hoverCoordinate;
  final double unit;
  final Offset pan;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = _CoordinatePlane2DState._originFor(size, pan);
    _drawGrid(canvas, size, origin);
    _drawAxes(canvas, size, origin);
    _drawCandidates(canvas, origin);
    _drawBlocks(canvas, origin);
    _drawHoverLabel(canvas, origin);
  }

  void _drawGrid(Canvas canvas, Size size, Offset origin) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE0E7F2)
      ..strokeWidth = 1;
    final tickPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 1.2;
    final maxX = ((size.width - origin.dx) / unit).ceil().clamp(0, 80);
    final maxY = (origin.dy / unit).ceil().clamp(0, 80);

    for (var x = 0; x <= maxX; x++) {
      final dx = origin.dx + x * unit;
      canvas.drawLine(Offset(dx, origin.dy), Offset(dx, 0), gridPaint);
      canvas.drawLine(
        Offset(dx, origin.dy - 5),
        Offset(dx, origin.dy + 5),
        tickPaint,
      );
      _drawText(
        canvas,
        '$x',
        Offset(dx, origin.dy + 16),
        const Color(0xFF475569),
        center: true,
      );
    }

    for (var y = 0; y <= maxY; y++) {
      final dy = origin.dy - y * unit;
      canvas.drawLine(Offset(origin.dx, dy), Offset(size.width, dy), gridPaint);
      canvas.drawLine(
        Offset(origin.dx - 5, dy),
        Offset(origin.dx + 5, dy),
        tickPaint,
      );
      _drawText(
        canvas,
        '$y',
        Offset(origin.dx - 16, dy - 7),
        const Color(0xFF475569),
        center: true,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size, Offset origin) {
    final axisPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final originPaint = Paint()..color = const Color(0xFF111827);

    canvas.drawLine(origin, Offset(size.width - 22, origin.dy), axisPaint);
    canvas.drawLine(origin, Offset(origin.dx, 18), axisPaint);
    _drawArrow(canvas, Offset(size.width - 22, origin.dy), 0, axisPaint);
    _drawArrow(canvas, Offset(origin.dx, 18), -math.pi / 2, axisPaint);
    canvas.drawCircle(origin, 5.5, originPaint);
    _drawText(
      canvas,
      'O',
      origin + const Offset(-24, 8),
      const Color(0xFF111827),
    );
    _drawText(
      canvas,
      'X+',
      Offset(size.width - 44, origin.dy - 28),
      const Color(0xFF111827),
    );
    _drawText(
      canvas,
      'Y+',
      Offset(origin.dx + 12, 20),
      const Color(0xFF111827),
    );
  }

  void _drawCandidates(Canvas canvas, Offset origin) {
    final candidates = candidateMoves.where((p) => p.dimension == 2).toSet();
    for (final position in candidates) {
      final rect = _rectFor(position, origin).deflate(unit * 0.11);
      _drawDashedRect(
        canvas,
        rect,
        Paint()
          ..color = const Color(0xFF9333EA)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = const Color(0xFFD8B4FE).withValues(alpha: 0.22)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawBlocks(Canvas canvas, Offset origin) {
    for (final position in blocks.where((p) => p.dimension == 2)) {
      if (_isMovingFrom(position)) {
        continue;
      }
      _drawBlockAt(
        canvas,
        origin,
        position.x.toDouble(),
        position.y.toDouble(),
        position,
        _colorFor(position),
      );
    }

    final step = activeStep;
    if (step?.from?.dimension == 2 && step?.to?.dimension == 2) {
      final from = step!.from!;
      final to = step.to!;
      final t = animationProgress.clamp(0.0, 1.0);
      _drawBlockAt(
        canvas,
        origin,
        _lerp(from.x, to.x, t),
        _lerp(from.y, to.y, t),
        from,
        const Color(0xFFF97316),
      );
    }
  }

  void _drawBlockAt(
    Canvas canvas,
    Offset origin,
    double x,
    double y,
    BlockPosition labelPosition,
    Color stateColor,
  ) {
    final rect = _rectForValues(x, y, origin).deflate(unit * 0.09);
    final radius = Radius.circular((unit * 0.13).clamp(5, 10));
    final rrect = RRect.fromRectAndRadius(rect, radius);
    canvas.drawRRect(
      rrect.shift(const Offset(0, 4)),
      Paint()
        ..color = stateColor.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawRRect(rrect, Paint()..color = stateColor);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _isSelected(labelPosition)
            ? const Color(0xFF111827)
            : const Color(0xFF0F172A).withValues(alpha: 0.25)
        ..strokeWidth = _isSelected(labelPosition) ? 3 : 1.2
        ..style = PaintingStyle.stroke,
    );
    _drawText(
      canvas,
      '[${labelPosition.x},${labelPosition.y}]',
      rect.center - const Offset(0, 7),
      Colors.white,
      center: true,
      fontSize: unit < 38 ? 9 : 11,
      fontWeight: FontWeight.w800,
    );
  }

  void _drawHoverLabel(Canvas canvas, Offset origin) {
    final coordinate = hoverCoordinate;
    if (coordinate == null) {
      return;
    }
    final rect = _rectFor(coordinate, origin);
    canvas.drawRect(
      rect,
      Paint()
        ..color = const Color(0xFF0F172A).withValues(alpha: 0.04)
        ..style = PaintingStyle.fill,
    );
    _drawText(
      canvas,
      '[${coordinate.x},${coordinate.y}]',
      rect.topLeft + const Offset(6, 6),
      const Color(0xFF111827),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      background: Colors.white.withValues(alpha: 0.88),
    );
  }

  Rect _rectFor(BlockPosition position, Offset origin) {
    return _rectForValues(position.x.toDouble(), position.y.toDouble(), origin);
  }

  Rect _rectForValues(double x, double y, Offset origin) {
    return Rect.fromLTWH(
      origin.dx + x * unit,
      origin.dy - (y + 1) * unit,
      unit,
      unit,
    );
  }

  bool _isMovingFrom(BlockPosition position) {
    final step = activeStep;
    return step?.from == position && step?.to?.dimension == 2;
  }

  double _lerp(num a, num b, double t) => a + (b - a) * t;

  Color _colorFor(BlockPosition position) {
    if (position == from) return const Color(0xFFF97316);
    if (position == to) return const Color(0xFF22C55E);
    return const Color(0xFF2563EB);
  }

  bool _isSelected(BlockPosition position) => position == selectedBlock;

  void _drawArrow(Canvas canvas, Offset tip, double angle, Paint paint) {
    const size = 10.0;
    final left = tip + Offset.fromDirection(angle + math.pi * 0.78, size);
    final right = tip + Offset.fromDirection(angle - math.pi * 0.78, size);
    canvas.drawLine(tip, left, paint);
    canvas.drawLine(tip, right, paint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    final path = Path()..addRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + 8, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += 13;
      }
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    bool center = false,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w700,
    Color? background,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final drawOffset = center
        ? offset - Offset(painter.width / 2, painter.height / 2)
        : offset;
    if (background != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          (drawOffset & painter.size).inflate(4),
          const Radius.circular(5),
        ),
        Paint()..color = background,
      );
    }
    painter.paint(canvas, drawOffset);
  }

  @override
  bool shouldRepaint(covariant _CoordinatePlanePainter oldDelegate) {
    return oldDelegate.blocks != blocks ||
        oldDelegate.candidateMoves != candidateMoves ||
        oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.selectedBlock != selectedBlock ||
        oldDelegate.activeStep != activeStep ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.hoverCoordinate != hoverCoordinate ||
        oldDelegate.unit != unit ||
        oldDelegate.pan != pan;
  }
}
