import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/block_configuration.dart';
import '../../domain/entities/coordinate.dart';

class CoordinateGuide3d extends StatefulWidget {
  const CoordinateGuide3d({
    super.key,
    required this.configuration,
    this.highlightFrom,
    this.highlightTo,
    this.height = 460,
  });

  final BlockConfiguration configuration;
  final Coordinate? highlightFrom;
  final Coordinate? highlightTo;
  final double height;

  @override
  State<CoordinateGuide3d> createState() => _CoordinateGuide3dState();
}

class _CoordinateGuide3dState extends State<CoordinateGuide3d> {
  double _yaw = -0.72;
  double _pitch = 0.82;
  double _zoom = 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  setState(() {
                    _zoom = (_zoom - event.scrollDelta.dy * 0.0015).clamp(
                      0.55,
                      2.4,
                    );
                  });
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  setState(() {
                    _yaw += details.delta.dx * 0.012;
                    _pitch = (_pitch + details.delta.dy * 0.012).clamp(
                      -1.25,
                      1.25,
                    );
                  });
                },
                onDoubleTap: _resetCamera,
                child: CustomPaint(
                  painter: _CoordinateGuide3dPainter(
                    configuration: widget.configuration,
                    highlightFrom: widget.highlightFrom,
                    highlightTo: widget.highlightTo,
                    yaw: _yaw,
                    pitch: _pitch,
                    zoom: _zoom,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Positioned(
              left: 14,
              top: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xEEFFFFFF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.threed_rotation, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Drag to rotate - scroll to zoom',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 10,
              child: Row(
                children: [
                  _CameraButton(
                    tooltip: 'Zoom out',
                    icon: Icons.remove,
                    onPressed: () {
                      setState(() => _zoom = (_zoom - 0.12).clamp(0.55, 2.4));
                    },
                  ),
                  const SizedBox(width: 8),
                  _CameraButton(
                    tooltip: 'Reset view',
                    icon: Icons.center_focus_strong,
                    onPressed: _resetCamera,
                  ),
                  const SizedBox(width: 8),
                  _CameraButton(
                    tooltip: 'Zoom in',
                    icon: Icons.add,
                    onPressed: () {
                      setState(() => _zoom = (_zoom + 0.12).clamp(0.55, 2.4));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetCamera() {
    setState(() {
      _yaw = -0.72;
      _pitch = 0.82;
      _zoom = 1;
    });
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: 36,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: Colors.white,
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _CoordinateGuide3dPainter extends CustomPainter {
  const _CoordinateGuide3dPainter({
    required this.configuration,
    required this.yaw,
    required this.pitch,
    required this.zoom,
    this.highlightFrom,
    this.highlightTo,
  });

  final BlockConfiguration configuration;
  final double yaw;
  final double pitch;
  final double zoom;
  final Coordinate? highlightFrom;
  final Coordinate? highlightTo;

  @override
  void paint(Canvas canvas, Size size) {
    final maxCoordinate = _maxCoordinate(configuration).clamp(3, 10);
    final origin = Offset(size.width * 0.5, size.height * 0.62);
    final unit =
        math.min(size.width, size.height) / (maxCoordinate + 3.2) * zoom;

    Offset project(_Vector3 vector) {
      final rotated = _rotate(vector);
      return origin + Offset(rotated.x * unit, -rotated.z * unit);
    }

    final xEnd = project(_Vector3((maxCoordinate + 1).toDouble(), 0, 0));
    final yEnd = project(_Vector3(0, (maxCoordinate + 1).toDouble(), 0));
    final zEnd = project(_Vector3(0, 0, (maxCoordinate + 1).toDouble()));
    final projectedOrigin = project(_Vector3.zero);

    _drawPlane(canvas, [
      project(_Vector3.zero),
      project(_Vector3(maxCoordinate.toDouble(), 0, 0)),
      project(_Vector3(maxCoordinate.toDouble(), maxCoordinate.toDouble(), 0)),
      project(_Vector3(0, maxCoordinate.toDouble(), 0)),
    ], const Color(0x18F97316));
    _drawPlane(canvas, [
      project(_Vector3.zero),
      project(_Vector3(0, maxCoordinate.toDouble(), 0)),
      project(_Vector3(0, maxCoordinate.toDouble(), maxCoordinate.toDouble())),
      project(_Vector3(0, 0, maxCoordinate.toDouble())),
    ], const Color(0x1822C55E));
    _drawPlane(canvas, [
      project(_Vector3.zero),
      project(_Vector3(maxCoordinate.toDouble(), 0, 0)),
      project(_Vector3(maxCoordinate.toDouble(), 0, maxCoordinate.toDouble())),
      project(_Vector3(0, 0, maxCoordinate.toDouble())),
    ], const Color(0x182563EB));

    _drawGrid(canvas, project, _Axis.xy, maxCoordinate);
    _drawGrid(canvas, project, _Axis.xz, maxCoordinate);
    _drawGrid(canvas, project, _Axis.yz, maxCoordinate);

    _drawArrow(canvas, projectedOrigin, xEnd, const Color(0xFFEF4444), 'X+');
    _drawArrow(canvas, projectedOrigin, yEnd, const Color(0xFF22C55E), 'Y+');
    _drawArrow(canvas, projectedOrigin, zEnd, const Color(0xFF2563EB), 'Z+');
    _drawText(
      canvas,
      'O',
      projectedOrigin + const Offset(-18, 8),
      const Color(0xFF374151),
    );

    final projectedBlocks = configuration.blocks.map((block) {
      final vector = _Vector3(
        block.x.toDouble(),
        block.y.toDouble(),
        (block.z ?? 0).toDouble(),
      );
      return _ProjectedBlock(
        coordinate: block,
        center: project(vector),
        depth: _rotate(vector).y,
      );
    }).toList()..sort((a, b) => b.depth.compareTo(a.depth));

    for (final block in projectedBlocks) {
      final color = block.coordinate == highlightFrom
          ? const Color(0xFFF97316)
          : block.coordinate == highlightTo
          ? const Color(0xFF22C55E)
          : const Color(0xFF2563EB);
      _drawIsoCube(canvas, block.center, unit * 0.26, color);
    }
  }

  _Vector3 _rotate(_Vector3 vector) {
    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);
    final yawX = vector.x * cosYaw - vector.y * sinYaw;
    final yawY = vector.x * sinYaw + vector.y * cosYaw;

    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    final pitchY = yawY * cosPitch - vector.z * sinPitch;
    final pitchZ = yawY * sinPitch + vector.z * cosPitch;

    return _Vector3(yawX, pitchY, pitchZ);
  }

  int _maxCoordinate(BlockConfiguration configuration) {
    var maxValue = 0;
    for (final block in configuration.blocks) {
      maxValue = math.max(maxValue, block.x);
      maxValue = math.max(maxValue, block.y);
      maxValue = math.max(maxValue, block.z ?? 0);
    }
    return maxValue;
  }

  void _drawPlane(Canvas canvas, List<Offset> points, Color color) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawGrid(
    Canvas canvas,
    Offset Function(_Vector3 vector) project,
    _Axis axis,
    int maxCoordinate,
  ) {
    final paint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    for (var index = 0; index <= maxCoordinate; index++) {
      final value = index.toDouble();
      final (aStart, aEnd, bStart, bEnd) = switch (axis) {
        _Axis.xy => (
          _Vector3(value, 0, 0),
          _Vector3(value, maxCoordinate.toDouble(), 0),
          _Vector3(0, value, 0),
          _Vector3(maxCoordinate.toDouble(), value, 0),
        ),
        _Axis.xz => (
          _Vector3(value, 0, 0),
          _Vector3(value, 0, maxCoordinate.toDouble()),
          _Vector3(0, 0, value),
          _Vector3(maxCoordinate.toDouble(), 0, value),
        ),
        _Axis.yz => (
          _Vector3(0, value, 0),
          _Vector3(0, value, maxCoordinate.toDouble()),
          _Vector3(0, 0, value),
          _Vector3(0, maxCoordinate.toDouble(), value),
        ),
      };
      canvas.drawLine(project(aStart), project(aEnd), paint);
      canvas.drawLine(project(bStart), project(bEnd), paint);
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    String label,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);

    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - math.cos(angle - 0.45) * 12,
        end.dy - math.sin(angle - 0.45) * 12,
      )
      ..lineTo(
        end.dx - math.cos(angle + 0.45) * 12,
        end.dy - math.sin(angle + 0.45) * 12,
      )
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = color);
    _drawText(canvas, label, end + const Offset(8, -8), color);
  }

  void _drawIsoCube(Canvas canvas, Offset center, double size, Color color) {
    final top = Paint()..color = Color.alphaBlend(Colors.white54, color);
    final left = Paint()..color = Color.alphaBlend(Colors.black12, color);
    final right = Paint()..color = color;
    final stroke = Paint()
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final p1 = center + Offset(0, -size);
    final p2 = center + Offset(size, -size * 0.48);
    final p3 = center + Offset(size, size * 0.48);
    final p4 = center + Offset(0, size);
    final p5 = center + Offset(-size, size * 0.48);
    final p6 = center + Offset(-size, -size * 0.48);
    final mid = center;

    final topPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(mid.dx, mid.dy)
      ..lineTo(p6.dx, p6.dy)
      ..close();
    final rightPath = Path()
      ..moveTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..lineTo(mid.dx, mid.dy)
      ..close();
    final leftPath = Path()
      ..moveTo(p6.dx, p6.dy)
      ..lineTo(mid.dx, mid.dy)
      ..lineTo(p4.dx, p4.dy)
      ..lineTo(p5.dx, p5.dy)
      ..close();

    canvas.drawPath(leftPath, left);
    canvas.drawPath(rightPath, right);
    canvas.drawPath(topPath, top);
    canvas.drawPath(leftPath, stroke);
    canvas.drawPath(rightPath, stroke);
    canvas.drawPath(topPath, stroke);
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _CoordinateGuide3dPainter oldDelegate) {
    return oldDelegate.configuration != configuration ||
        oldDelegate.highlightFrom != highlightFrom ||
        oldDelegate.highlightTo != highlightTo ||
        oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.zoom != zoom;
  }
}

enum _Axis { xy, xz, yz }

class _ProjectedBlock {
  const _ProjectedBlock({
    required this.coordinate,
    required this.center,
    required this.depth,
  });

  final Coordinate coordinate;
  final Offset center;
  final double depth;
}

class _Vector3 {
  const _Vector3(this.x, this.y, this.z);

  static const zero = _Vector3(0, 0, 0);

  final double x;
  final double y;
  final double z;
}
