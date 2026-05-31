import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sliding_cubes/app.dart';

void main() {
  testWidgets('shows sliding cubes workspace', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    await tester.pumpWidget(const SlidingCubesApp());

    expect(find.text('Sliding Cubes'), findsOneWidget);
    expect(find.text('Oxy Coordinate Plane'), findsOneWidget);
    expect(find.text('Run compaction'), findsOneWidget);

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
