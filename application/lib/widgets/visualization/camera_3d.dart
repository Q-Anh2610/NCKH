import 'dart:math' as math;

import 'package:flutter/material.dart';

enum CameraMode3D { rotate, pan }

enum ViewPreset3D {
  isometric('Iso', -45, 30),
  top('Top', 0, 8),
  front('Front', 0, 90),
  side('Side', 90, 90);

  const ViewPreset3D(this.label, this.yawDegrees, this.pitchDegrees);

  final String label;
  final double yawDegrees;
  final double pitchDegrees;
}

class Camera3D {
  const Camera3D({
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.panOffset,
    required this.mode,
    required this.preset,
  });

  factory Camera3D.initial() {
    return Camera3D(
      yaw: _degToRad(ViewPreset3D.isometric.yawDegrees),
      pitch: _degToRad(ViewPreset3D.isometric.pitchDegrees),
      zoom: 56,
      panOffset: Offset.zero,
      mode: CameraMode3D.rotate,
      preset: ViewPreset3D.isometric,
    );
  }

  final double yaw;
  final double pitch;
  final double zoom;
  final Offset panOffset;
  final CameraMode3D mode;
  final ViewPreset3D preset;

  Camera3D copyWith({
    double? yaw,
    double? pitch,
    double? zoom,
    Offset? panOffset,
    CameraMode3D? mode,
    ViewPreset3D? preset,
  }) {
    return Camera3D(
      yaw: yaw ?? this.yaw,
      pitch: pitch ?? this.pitch,
      zoom: zoom ?? this.zoom,
      panOffset: panOffset ?? this.panOffset,
      mode: mode ?? this.mode,
      preset: preset ?? this.preset,
    );
  }

  Camera3D withPreset(ViewPreset3D value) {
    return copyWith(
      yaw: _degToRad(value.yawDegrees),
      pitch: _degToRad(value.pitchDegrees),
      preset: value,
    );
  }

  static double _degToRad(double degrees) => degrees * math.pi / 180;
}

class ProjectedPoint {
  const ProjectedPoint({required this.screen, required this.depth});

  final Offset screen;
  final double depth;
}

class RotatedPoint3D {
  const RotatedPoint3D({required this.x, required this.y, required this.depth});

  final double x;
  final double y;
  final double depth;
}
