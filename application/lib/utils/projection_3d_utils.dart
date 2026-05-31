import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/visualization/camera_3d.dart';

class Projection3DUtils {
  const Projection3DUtils._();

  static RotatedPoint3D rotatePoint({
    required double x,
    required double y,
    required double z,
    required double yaw,
    required double pitch,
  }) {
    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);
    final yawX = x * cosYaw + y * sinYaw;
    final yawY = -x * sinYaw + y * cosYaw;

    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);
    final screenY = yawY * cosPitch + z * sinPitch;
    final depth = -yawY * sinPitch + z * cosPitch;

    return RotatedPoint3D(x: yawX, y: screenY, depth: depth);
  }

  static ProjectedPoint projectPoint3D({
    required Size size,
    required Camera3D camera,
    required double x,
    required double y,
    required double z,
  }) {
    final rotated = rotatePoint(
      x: x,
      y: y,
      z: z,
      yaw: camera.yaw,
      pitch: camera.pitch,
    );
    return ProjectedPoint(
      screen:
          Offset(size.width / 2, size.height / 2) +
          camera.panOffset +
          Offset(rotated.x * camera.zoom, -rotated.y * camera.zoom),
      depth: rotated.depth,
    );
  }
}
