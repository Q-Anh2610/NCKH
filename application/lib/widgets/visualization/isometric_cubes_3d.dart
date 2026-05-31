import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../models/block_position.dart';
import '../../models/move_step.dart';
import '../../utils/projection_3d_utils.dart';
import 'camera_3d.dart';

class IsometricCubes3D extends StatefulWidget {
  const IsometricCubes3D({
    super.key,
    required this.blocks,
    required this.candidateMoves,
    required this.onCubeTap,
    this.from,
    this.to,
    this.selectedBlock,
    this.activeStep,
    this.animationProgress = 0,
    this.minHeight = 560,
  });

  final List<BlockPosition> blocks;
  final List<BlockPosition> candidateMoves;
  final BlockPosition? from;
  final BlockPosition? to;
  final BlockPosition? selectedBlock;
  final MoveStep? activeStep;
  final double animationProgress;
  final ValueChanged<BlockPosition> onCubeTap;
  final double minHeight;

  @override
  State<IsometricCubes3D> createState() => _IsometricCubes3DState();
}

class _IsometricCubes3DState extends State<IsometricCubes3D> {
  Camera3D _camera = Camera3D.initial();
  bool _isDragging = false;
  Size? _lastSize;
  bool _needsInitialFit = true;
  double _lastGestureScale = 1;

  @override
  void didUpdateWidget(covariant IsometricCubes3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_blockSignature(oldWidget.blocks) != _blockSignature(widget.blocks)) {
      _needsInitialFit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : widget.minHeight;
        final size = Size(constraints.maxWidth, height);
        _lastSize = size;

        if (_needsInitialFit) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _fitToBlocks();
            }
          });
          _needsInitialFit = false;
        }

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
                    cursor: _cursorForMode(),
                    child: Listener(
                      onPointerSignal: (event) {
                        if (event is PointerScrollEvent) {
                          _zoomAt(
                            event.localPosition,
                            math.exp(-event.scrollDelta.dy * 0.0015),
                          );
                        }
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onDoubleTap: _fitToBlocks,
                        onTapUp: (details) {
                          final hit = _pickCube(details.localPosition);
                          if (hit != null) {
                            widget.onCubeTap(hit);
                          }
                        },
                        onScaleStart: (_) => setState(() {
                          _isDragging = true;
                          _lastGestureScale = 1;
                        }),
                        onScaleEnd: (_) => setState(() => _isDragging = false),
                        onScaleUpdate: (details) {
                          if (details.pointerCount > 1 &&
                              details.scale != 1.0) {
                            _zoomAt(
                              details.localFocalPoint,
                              details.scale / _lastGestureScale,
                            );
                            _lastGestureScale = details.scale;
                          }
                          if (_camera.mode == CameraMode3D.pan ||
                              details.pointerCount > 1) {
                            _pan(details.focalPointDelta);
                          } else {
                            _rotate(details.focalPointDelta);
                          }
                        },
                        child: CustomPaint(
                          painter: _InteractiveCubesPainter(
                            blocks: widget.blocks,
                            candidateMoves: widget.candidateMoves,
                            from: widget.from,
                            to: widget.to,
                            selectedBlock: widget.selectedBlock,
                            activeStep: widget.activeStep,
                            animationProgress: widget.animationProgress,
                            camera: _camera,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 12,
                    child: _CameraToolbar(
                      camera: _camera,
                      onZoomIn: () => _zoomAt(size.center(Offset.zero), 1.16),
                      onZoomOut: () => _zoomAt(size.center(Offset.zero), 0.86),
                      onFit: _fitToBlocks,
                      onReset: _resetCamera,
                      onPresetChanged: _setPreset,
                      onModeChanged: (mode) {
                        setState(() => _camera = _camera.copyWith(mode: mode));
                      },
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 12,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          border: Border.all(color: const Color(0xFFDDE3EE)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          child: Text(
                            'Drag to rotate • Scroll to zoom • Toggle Pan to move',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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

  MouseCursor _cursorForMode() {
    if (_camera.mode == CameraMode3D.pan) {
      return SystemMouseCursors.move;
    }
    return _isDragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab;
  }

  void _rotate(Offset delta) {
    setState(() {
      _camera = _camera.copyWith(
        yaw: _camera.yaw + delta.dx * 0.009,
        pitch: (_camera.pitch - delta.dy * 0.008).clamp(
          _degToRad(-75),
          _degToRad(75),
        ),
        preset: ViewPreset3D.isometric,
      );
    });
  }

  void _pan(Offset delta) {
    setState(
      () => _camera = _camera.copyWith(panOffset: _camera.panOffset + delta),
    );
  }

  void _zoomAt(Offset localPoint, double factor) {
    final size = _lastSize;
    if (size == null) {
      return;
    }
    final oldZoom = _camera.zoom;
    final nextZoom = (oldZoom * factor).clamp(20.0, 180.0);
    final centerRelative = localPoint - size.center(Offset.zero);
    final zoomRatio = nextZoom / oldZoom;
    final nextPan =
        centerRelative - (centerRelative - _camera.panOffset) * zoomRatio;

    setState(() {
      _camera = _camera.copyWith(zoom: nextZoom, panOffset: nextPan);
    });
  }

  void _setPreset(ViewPreset3D preset) {
    setState(() => _camera = _camera.withPreset(preset));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fitToBlocks(keepAngles: true);
      }
    });
  }

  void _resetCamera() {
    setState(() => _camera = Camera3D.initial());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fitToBlocks(keepAngles: true);
      }
    });
  }

  void _fitToBlocks({bool keepAngles = true}) {
    final size = _lastSize;
    if (size == null) {
      return;
    }

    final points = _fitPoints();
    if (points.isEmpty) {
      setState(() => _camera = Camera3D.initial());
      return;
    }

    final raw = points
        .map(
          (p) => Projection3DUtils.rotatePoint(
            x: p.$1,
            y: p.$2,
            z: p.$3,
            yaw: _camera.yaw,
            pitch: _camera.pitch,
          ),
        )
        .toList();
    final minX = raw.map((p) => p.x).reduce(math.min);
    final maxX = raw.map((p) => p.x).reduce(math.max);
    final minY = raw.map((p) => p.y).reduce(math.min);
    final maxY = raw.map((p) => p.y).reduce(math.max);
    final rawWidth = math.max(1.0, maxX - minX);
    final rawHeight = math.max(1.0, maxY - minY);
    final padding = size.shortestSide < 460 ? 38.0 : 64.0;
    final availableWidth = math.max(120.0, size.width - padding * 2);
    final availableHeight = math.max(120.0, size.height - padding * 2);
    final all = [
      ...widget.blocks,
      ...widget.candidateMoves,
      ?widget.from,
      ?widget.to,
      ?widget.activeStep?.from,
      ?widget.activeStep?.to,
    ];
    final maxZoom = all.length <= 20 ? 118.0 : 92.0;
    final nextZoom = math
        .min(availableWidth / rawWidth, availableHeight / rawHeight)
        .clamp(24.0, maxZoom);
    final rawCenter = Offset((minX + maxX) / 2, (minY + maxY) / 2);

    setState(() {
      _camera = (keepAngles ? _camera : Camera3D.initial()).copyWith(
        zoom: nextZoom,
        panOffset: Offset(-rawCenter.dx * nextZoom, rawCenter.dy * nextZoom),
      );
    });
  }

  String _blockSignature(List<BlockPosition> blocks) {
    if (blocks.isEmpty) {
      return 'empty';
    }
    final maxX = blocks.map((p) => p.x).reduce(math.max);
    final maxY = blocks.map((p) => p.y).reduce(math.max);
    final maxZ = blocks.map((p) => p.z).reduce(math.max);
    return '${blocks.length}:$maxX:$maxY:$maxZ';
  }

  List<(double, double, double)> _fitPoints() {
    final all = [
      ...widget.blocks,
      ...widget.candidateMoves,
      ?widget.from,
      ?widget.to,
    ];
    if (all.isEmpty) {
      return const [];
    }
    final maxX = all.map((p) => p.x).reduce(math.max) + 2;
    final maxY = all.map((p) => p.y).reduce(math.max) + 2;
    final maxZ = all.map((p) => p.z).reduce(math.max) + 2;
    final points = <(double, double, double)>[
      (0, 0, 0),
      (maxX.toDouble(), 0, 0),
      (0, maxY.toDouble(), 0),
      (0, 0, maxZ.toDouble()),
    ];
    for (final block in all) {
      for (final dx in const [0.0, 1.0]) {
        for (final dy in const [0.0, 1.0]) {
          for (final dz in const [0.0, 1.0]) {
            points.add((block.x + dx, block.y + dy, block.z + dz));
          }
        }
      }
    }
    return points;
  }

  BlockPosition? _pickCube(Offset local) {
    final size = _lastSize;
    if (size == null || widget.blocks.isEmpty) {
      return null;
    }

    final threshold = (_camera.zoom * 0.72).clamp(24.0, 46.0);
    BlockPosition? best;
    var bestDistance = double.infinity;
    var bestDepth = -double.infinity;

    for (final cube in widget.blocks.where((p) => p.dimension == 3)) {
      final projected = Projection3DUtils.projectPoint3D(
        size: size,
        camera: _camera,
        x: cube.x + 0.5,
        y: cube.y + 0.5,
        z: cube.z + 0.5,
      );
      final distance = (projected.screen - local).distance;
      if (distance <= threshold &&
          (distance < bestDistance - 2 || projected.depth > bestDepth)) {
        best = cube;
        bestDistance = distance;
        bestDepth = projected.depth;
      }
    }
    return best;
  }

  double _degToRad(double degrees) => degrees * math.pi / 180;
}

class _CameraToolbar extends StatelessWidget {
  const _CameraToolbar({
    required this.camera,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
    required this.onReset,
    required this.onPresetChanged,
    required this.onModeChanged,
  });

  final Camera3D camera;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;
  final VoidCallback onReset;
  final ValueChanged<ViewPreset3D> onPresetChanged;
  final ValueChanged<CameraMode3D> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Align(
          alignment: Alignment.topRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                border: Border.all(color: const Color(0xFFDDE3EE)),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140F172A),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                    const SizedBox(width: 4),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<ViewPreset3D>(
                        value: camera.preset,
                        isDense: true,
                        borderRadius: BorderRadius.circular(10),
                        items: ViewPreset3D.values
                            .map(
                              (preset) => DropdownMenuItem(
                                value: preset,
                                child: Text(preset.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onPresetChanged(value);
                          }
                        },
                      ),
                    ),
                    SegmentedButton<CameraMode3D>(
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      segments: const [
                        ButtonSegment(
                          value: CameraMode3D.rotate,
                          icon: Icon(Icons.threesixty, size: 16),
                          label: Text('Rotate'),
                        ),
                        ButtonSegment(
                          value: CameraMode3D.pan,
                          icon: Icon(Icons.open_with, size: 16),
                          label: Text('Pan'),
                        ),
                      ],
                      selected: {camera.mode},
                      onSelectionChanged: (value) => onModeChanged(value.first),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

class _InteractiveCubesPainter extends CustomPainter {
  const _InteractiveCubesPainter({
    required this.blocks,
    required this.candidateMoves,
    required this.camera,
    this.from,
    this.to,
    this.selectedBlock,
    this.activeStep,
    this.animationProgress = 0,
  });

  final List<BlockPosition> blocks;
  final List<BlockPosition> candidateMoves;
  final BlockPosition? from;
  final BlockPosition? to;
  final BlockPosition? selectedBlock;
  final MoveStep? activeStep;
  final double animationProgress;
  final Camera3D camera;

  @override
  void paint(Canvas canvas, Size size) {
    _drawFloorGrid(canvas, size);
    _drawAxes(canvas, size);
    _drawCandidates(canvas, size);
    _drawCubes(canvas, size);
  }

  void _drawFloorGrid(Canvas canvas, Size size) {
    final bounds = _axisBounds();
    final maxX = bounds.$1;
    final maxY = bounds.$2;
    final gridPaint = Paint()
      ..color = const Color(0xFFD7E0EE)
      ..strokeWidth = 1.15;
    final floorPaint = Paint()
      ..color = const Color(0xFFEEF2FF).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final floor = Path()
      ..moveTo(_screen(size, 0, 0, 0).dx, _screen(size, 0, 0, 0).dy)
      ..lineTo(_screen(size, maxX, 0, 0).dx, _screen(size, maxX, 0, 0).dy)
      ..lineTo(_screen(size, maxX, maxY, 0).dx, _screen(size, maxX, maxY, 0).dy)
      ..lineTo(_screen(size, 0, maxY, 0).dx, _screen(size, 0, maxY, 0).dy)
      ..close();
    canvas.drawPath(floor, floorPaint);

    for (var x = 0; x <= maxX; x++) {
      canvas.drawLine(
        _screen(size, x, 0, 0),
        _screen(size, x, maxY, 0),
        gridPaint,
      );
      _drawText(
        canvas,
        '$x',
        _screen(size, x, 0, 0) + const Offset(-4, 16),
        const Color(0xFF64748B),
        fontSize: 12,
      );
    }
    for (var y = 0; y <= maxY; y++) {
      canvas.drawLine(
        _screen(size, 0, y, 0),
        _screen(size, maxX, y, 0),
        gridPaint,
      );
      _drawText(
        canvas,
        '$y',
        _screen(size, 0, y, 0) + const Offset(-20, -3),
        const Color(0xFF64748B),
        fontSize: 12,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final bounds = _axisBounds();
    final maxX = bounds.$1;
    final maxY = bounds.$2;
    final maxZ = bounds.$3;
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final origin = _screen(size, 0, 0, 0);
    final xEnd = _screen(size, maxX, 0, 0);
    final yEnd = _screen(size, 0, maxY, 0);
    final zEnd = _screen(size, 0, 0, maxZ);

    canvas.drawLine(origin, xEnd, paint);
    canvas.drawLine(origin, yEnd, paint);
    canvas.drawLine(origin, zEnd, paint);
    _drawArrow(canvas, origin, xEnd, paint);
    _drawArrow(canvas, origin, yEnd, paint);
    _drawArrow(canvas, origin, zEnd, paint);
    canvas.drawCircle(origin, 6.8, Paint()..color = const Color(0xFF111827));
    _drawText(
      canvas,
      'O',
      origin + const Offset(-24, 8),
      const Color(0xFF111827),
    );
    _drawText(
      canvas,
      'X+',
      xEnd + _labelOffset(origin, xEnd),
      const Color(0xFF111827),
    );
    _drawText(
      canvas,
      'Y+',
      yEnd + _labelOffset(origin, yEnd),
      const Color(0xFF111827),
    );
    _drawText(
      canvas,
      'Z+',
      zEnd + _labelOffset(origin, zEnd),
      const Color(0xFF111827),
    );

    for (var i = 1; i <= maxX; i++) {
      _drawTick(canvas, _screen(size, i, 0, 0), origin, xEnd, paint);
    }
    for (var i = 1; i <= maxY; i++) {
      _drawTick(canvas, _screen(size, 0, i, 0), origin, yEnd, paint);
    }
    for (var i = 1; i <= maxZ; i++) {
      final p = _screen(size, 0, 0, i);
      _drawTick(canvas, p, origin, zEnd, paint);
      _drawText(
        canvas,
        '$i',
        p + const Offset(-20, -8),
        const Color(0xFF64748B),
        fontSize: 12,
      );
    }
  }

  void _drawCandidates(Canvas canvas, Size size) {
    final candidates = candidateMoves.where((p) => p.dimension == 3).toList()
      ..sort((a, b) => _centerDepth(size, a).compareTo(_centerDepth(size, b)));
    for (final candidate in candidates) {
      final faces = _visibleFaces(
        size,
        candidate.x.toDouble(),
        candidate.y.toDouble(),
        candidate.z.toDouble(),
      );
      for (final face in faces) {
        canvas.drawPath(
          face.path,
          Paint()
            ..color = const Color(0xFFD8B4FE).withValues(alpha: 0.18)
            ..style = PaintingStyle.fill,
        );
        _drawDashedPath(
          canvas,
          face.path,
          Paint()
            ..color = const Color(0xFF9333EA)
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke,
        );
      }
    }
  }

  void _drawCubes(Canvas canvas, Size size) {
    final sorted = blocks.where((p) => p.dimension == 3).toList()
      ..sort((a, b) => _centerDepth(size, a).compareTo(_centerDepth(size, b)));
    for (final cube in sorted) {
      if (_isMovingFrom(cube)) {
        continue;
      }
      _drawCube(canvas, size, cube);
    }

    final step = activeStep;
    if (step?.from?.dimension == 3 && step?.to?.dimension == 3) {
      final from = step!.from!;
      final to = step.to!;
      final t = animationProgress.clamp(0.0, 1.0);
      _drawCubeAt(
        canvas,
        size,
        from,
        _lerp(from.x, to.x, t),
        _lerp(from.y, to.y, t),
        _lerp(from.z, to.z, t),
        const Color(0xFFF97316),
      );
    }
  }

  void _drawCube(Canvas canvas, Size size, BlockPosition cube) {
    _drawCubeAt(
      canvas,
      size,
      cube,
      cube.x.toDouble(),
      cube.y.toDouble(),
      cube.z.toDouble(),
      _colorFor(cube),
    );
  }

  void _drawCubeAt(
    Canvas canvas,
    Size size,
    BlockPosition cube,
    double x,
    double y,
    double z,
    Color color,
  ) {
    final faces = _visibleFaces(size, x, y, z);
    if (faces.isEmpty) {
      return;
    }

    canvas.drawPath(
      faces.first.path.shift(const Offset(0, 5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    for (final face in faces) {
      canvas.drawPath(face.path, Paint()..color = _shade(color, face.shade));
      canvas.drawPath(
        face.path,
        Paint()
          ..color = const Color(0xFF0F172A).withValues(alpha: 0.24)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    }

    if (cube == selectedBlock) {
      for (final face in faces) {
        canvas.drawPath(
          face.path,
          Paint()
            ..color = const Color(0xFF111827)
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke,
        );
      }
    }

    final labelPoint = Projection3DUtils.projectPoint3D(
      size: size,
      camera: camera,
      x: x + 0.5,
      y: y + 0.5,
      z: z + 1.08,
    ).screen;
    _drawText(
      canvas,
      '[${cube.x},${cube.y},${cube.z}]',
      labelPoint + const Offset(-18, -8),
      Colors.white,
      fontSize: 11,
      background: Colors.black.withValues(alpha: 0.35),
    );
  }

  List<_FacePath> _visibleFaces(Size size, double x, double y, double z) {
    final faceSpecs = _cubeFaceSpecsAt(x, y, z);
    final visible = faceSpecs
        .map((spec) => spec.toPath(size, camera))
        .where((face) => face.normalDepth > 0.001)
        .toList();
    final faces = visible.length >= 3
        ? visible
        : (faceSpecs.map((spec) => spec.toPath(size, camera)).toList()
                ..sort((a, b) => b.normalDepth.compareTo(a.normalDepth)))
              .take(3)
              .toList();

    return faces..sort((a, b) => a.depth.compareTo(b.depth));
  }

  (int, int, int) _axisBounds() {
    final all = [...blocks, ...candidateMoves, ?from, ?to];
    if (activeStep?.from != null) {
      all.add(activeStep!.from!);
    }
    if (activeStep?.to != null) {
      all.add(activeStep!.to!);
    }
    if (all.isEmpty) {
      return (5, 5, 4);
    }
    return (
      all.map((p) => p.x).reduce(math.max) + 2,
      all.map((p) => p.y).reduce(math.max) + 2,
      all.map((p) => p.z).reduce(math.max) + 2,
    );
  }

  Offset _screen(Size size, num x, num y, num z) {
    return Projection3DUtils.projectPoint3D(
      size: size,
      camera: camera,
      x: x.toDouble(),
      y: y.toDouble(),
      z: z.toDouble(),
    ).screen;
  }

  bool _isMovingFrom(BlockPosition cube) {
    final step = activeStep;
    return step?.from == cube && step?.to?.dimension == 3;
  }

  double _lerp(num a, num b, double t) => a + (b - a) * t;

  double _centerDepth(Size size, BlockPosition cube) {
    return Projection3DUtils.projectPoint3D(
      size: size,
      camera: camera,
      x: cube.x + 0.5,
      y: cube.y + 0.5,
      z: cube.z + 0.5,
    ).depth;
  }

  Color _colorFor(BlockPosition cube) {
    if (cube == from) return const Color(0xFFF97316);
    if (cube == to) return const Color(0xFF22C55E);
    return const Color(0xFF2563EB);
  }

  Color _shade(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Offset _labelOffset(Offset origin, Offset endpoint) {
    final vector = endpoint - origin;
    if (vector.distance == 0) {
      return const Offset(10, -18);
    }
    return Offset.fromDirection(vector.direction, 22);
  }

  void _drawTick(
    Canvas canvas,
    Offset point,
    Offset axisStart,
    Offset axisEnd,
    Paint paint,
  ) {
    final axis = axisEnd - axisStart;
    if (axis.distance == 0) {
      return;
    }
    final perpendicular = Offset(-axis.dy, axis.dx) / axis.distance * 5.5;
    canvas.drawLine(point - perpendicular, point + perpendicular, paint);
  }

  void _drawArrow(Canvas canvas, Offset start, Offset tip, Paint paint) {
    final direction = tip - start;
    if (direction.distance == 0) {
      return;
    }
    final angle = direction.direction;
    const length = 14.0;
    canvas.drawLine(
      tip,
      tip + Offset.fromDirection(angle + math.pi * 0.78, length),
      paint,
    );
    canvas.drawLine(
      tip,
      tip + Offset.fromDirection(angle - math.pi * 0.78, length),
      paint,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
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
    double fontSize = 12,
    Color? background,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    if (background != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          (offset & painter.size).inflate(4),
          const Radius.circular(5),
        ),
        Paint()..color = background,
      );
    }
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _InteractiveCubesPainter oldDelegate) {
    return oldDelegate.blocks != blocks ||
        oldDelegate.candidateMoves != candidateMoves ||
        oldDelegate.from != from ||
        oldDelegate.to != to ||
        oldDelegate.selectedBlock != selectedBlock ||
        oldDelegate.activeStep != activeStep ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.camera != camera;
  }
}

class _CubeFaceSpec {
  const _CubeFaceSpec({
    required this.corners,
    required this.normal,
    required this.shade,
  });

  final List<(double, double, double)> corners;
  final (double, double, double) normal;
  final double shade;

  _FacePath toPath(Size size, Camera3D camera) {
    final projected = corners
        .map(
          (point) => Projection3DUtils.projectPoint3D(
            size: size,
            camera: camera,
            x: point.$1,
            y: point.$2,
            z: point.$3,
          ),
        )
        .toList();
    final path = Path()
      ..moveTo(projected.first.screen.dx, projected.first.screen.dy);
    for (final point in projected.skip(1)) {
      path.lineTo(point.screen.dx, point.screen.dy);
    }
    path.close();

    final rotatedNormal = Projection3DUtils.rotatePoint(
      x: normal.$1,
      y: normal.$2,
      z: normal.$3,
      yaw: camera.yaw,
      pitch: camera.pitch,
    );
    return _FacePath(
      path: path,
      depth:
          projected.map((point) => point.depth).reduce((a, b) => a + b) /
          projected.length,
      normalDepth: rotatedNormal.depth,
      shade: shade,
    );
  }
}

class _FacePath {
  const _FacePath({
    required this.path,
    required this.depth,
    required this.normalDepth,
    required this.shade,
  });

  final Path path;
  final double depth;
  final double normalDepth;
  final double shade;
}

List<_CubeFaceSpec> _cubeFaceSpecsAt(double x, double y, double z) {
  final p000 = (x, y, z);
  final p100 = (x + 1, y, z);
  final p010 = (x, y + 1, z);
  final p110 = (x + 1, y + 1, z);
  final p001 = (x, y, z + 1);
  final p101 = (x + 1, y, z + 1);
  final p011 = (x, y + 1, z + 1);
  final p111 = (x + 1, y + 1, z + 1);

  return [
    _CubeFaceSpec(
      corners: [p001, p101, p111, p011],
      normal: (0, 0, 1),
      shade: 0.14,
    ),
    _CubeFaceSpec(
      corners: [p000, p010, p011, p001],
      normal: (-1, 0, 0),
      shade: -0.12,
    ),
    _CubeFaceSpec(
      corners: [p100, p110, p111, p101],
      normal: (1, 0, 0),
      shade: -0.04,
    ),
    _CubeFaceSpec(
      corners: [p000, p100, p101, p001],
      normal: (0, -1, 0),
      shade: -0.16,
    ),
    _CubeFaceSpec(
      corners: [p010, p110, p111, p011],
      normal: (0, 1, 0),
      shade: -0.08,
    ),
    _CubeFaceSpec(
      corners: [p000, p100, p110, p010],
      normal: (0, 0, -1),
      shade: -0.22,
    ),
  ];
}
