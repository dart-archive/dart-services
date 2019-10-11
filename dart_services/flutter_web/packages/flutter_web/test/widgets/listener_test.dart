// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-08-15T10:02:08.383977.

import 'dart:math' as math;

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web/gestures.dart';
import 'package:flutter_web_ui/ui.dart';

void main() {
  testWidgets('Events bubble up the tree', (WidgetTester tester) async {
    final List<String> log = <String>[];

    await tester.pumpWidget(
      Listener(
        onPointerDown: (_) {
          log.add('top');
        },
        child: Listener(
          onPointerDown: (_) {
            log.add('middle');
          },
          child: DecoratedBox(
            decoration: const BoxDecoration(),
            child: Listener(
              onPointerDown: (_) {
                log.add('bottom');
              },
              child: const Text('X', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      )
    );

    await tester.tap(find.text('X'));

    expect(log, equals(<String>[
      'bottom',
      'middle',
      'top',
    ]));
  });

  group('transformed events', () {
    testWidgets('simple offset for touch/signal', (WidgetTester tester) async {
      final List<PointerEvent> events = <PointerEvent>[];
      final Key key = UniqueKey();

      await tester.pumpWidget(
        Center(
          child: Listener(
            onPointerDown: (PointerDownEvent event) {
              events.add(event);
            },
            onPointerUp: (PointerUpEvent event) {
            events.add(event);
            },
            onPointerMove: (PointerMoveEvent event) {
              events.add(event);
            },
            onPointerSignal: (PointerSignalEvent event) {
              events.add(event);
            },
            child: Container(
              key: key,
              color: Colors.red,
              height: 100,
              width: 100,
            ),
          ),
        ),
      );
      const Offset moved = Offset(20, 30);
      final Offset center = tester.getCenter(find.byKey(key));
      final Offset topLeft = tester.getTopLeft(find.byKey(key));
      final TestGesture gesture = await tester.startGesture(center);
      await gesture.moveBy(moved);
      await gesture.up();

      expect(events, hasLength(3));
      final PointerDownEvent down = events[0];
      final PointerMoveEvent move = events[1];
      final PointerUpEvent up = events[2];

      final Matrix4 expectedTransform = Matrix4.translationValues(-topLeft.dx, -topLeft.dy, 0);

      expect(center, isNot(const Offset(50, 50)));

      expect(down.localPosition, const Offset(50, 50));
      expect(down.position, center);
      expect(down.delta, Offset.zero);
      expect(down.localDelta, Offset.zero);
      expect(down.transform, expectedTransform);

      expect(move.localPosition, const Offset(50, 50) + moved);
      expect(move.position, center + moved);
      expect(move.delta, moved);
      expect(move.localDelta, moved);
      expect(move.transform, expectedTransform);

      expect(up.localPosition, const Offset(50, 50) + moved);
      expect(up.position, center + moved);
      expect(up.delta, Offset.zero);
      expect(up.localDelta, Offset.zero);
      expect(up.transform, expectedTransform);

      events.clear();
      await scrollAt(center, tester);
      expect(events.single.localPosition, const Offset(50, 50));
      expect(events.single.position, center);
      expect(events.single.delta, Offset.zero);
      expect(events.single.localDelta, Offset.zero);
      expect(events.single.transform, expectedTransform);
    });

    testWidgets('scaled for touch/signal', (WidgetTester tester) async {
      final List<PointerEvent> events = <PointerEvent>[];
      final Key key = UniqueKey();

      const double scaleFactor = 2;

      await tester.pumpWidget(
        Align(
          alignment: Alignment.topLeft,
          child: Transform(
            transform: Matrix4.identity()..scale(scaleFactor),
            child: Listener(
              onPointerDown: (PointerDownEvent event) {
                events.add(event);
              },
              onPointerUp: (PointerUpEvent event) {
                events.add(event);
              },
              onPointerMove: (PointerMoveEvent event) {
                events.add(event);
              },
              onPointerSignal: (PointerSignalEvent event) {
                events.add(event);
              },
              child: Container(
                key: key,
                color: Colors.red,
                height: 100,
                width: 100,
              ),
            ),
          ),
        ),
      );
      const Offset moved = Offset(20, 30);
      final Offset center = tester.getCenter(find.byKey(key));
      final TestGesture gesture = await tester.startGesture(center);
      await gesture.moveBy(moved);
      await gesture.up();

      expect(events, hasLength(3));
      final PointerDownEvent down = events[0];
      final PointerMoveEvent move = events[1];
      final PointerUpEvent up = events[2];

      final Matrix4 expectedTransform = Matrix4.identity()
        ..scale(1 / scaleFactor, 1 / scaleFactor, 1.0);

      expect(center, isNot(const Offset(50, 50)));

      expect(down.localPosition, const Offset(50, 50));
      expect(down.position, center);
      expect(down.delta, Offset.zero);
      expect(down.localDelta, Offset.zero);
      expect(down.transform, expectedTransform);

      expect(move.localPosition, const Offset(50, 50) + moved / scaleFactor);
      expect(move.position, center + moved);
      expect(move.delta, moved);
      expect(move.localDelta, moved / scaleFactor);
      expect(move.transform, expectedTransform);

      expect(up.localPosition, const Offset(50, 50) + moved / scaleFactor);
      expect(up.position, center + moved);
      expect(up.delta, Offset.zero);
      expect(up.localDelta, Offset.zero);
      expect(up.transform, expectedTransform);

      events.clear();
      await scrollAt(center, tester);
      expect(events.single.localPosition, const Offset(50, 50));
      expect(events.single.position, center);
      expect(events.single.delta, Offset.zero);
      expect(events.single.localDelta, Offset.zero);
      expect(events.single.transform, expectedTransform);

      await gesture.removePointer();
    });

    testWidgets('scaled and offset for touch/signal', (WidgetTester tester) async {
      final List<PointerEvent> events = <PointerEvent>[];
      final Key key = UniqueKey();

      const double scaleFactor = 2;

      await tester.pumpWidget(
        Center(
          child: Transform(
            transform: Matrix4.identity()..scale(scaleFactor),
            child: Listener(
              onPointerDown: (PointerDownEvent event) {
                events.add(event);
              },
              onPointerUp: (PointerUpEvent event) {
                events.add(event);
              },
              onPointerMove: (PointerMoveEvent event) {
                events.add(event);
              },
              onPointerSignal: (PointerSignalEvent event) {
                events.add(event);
              },
              child: Container(
                key: key,
                color: Colors.red,
                height: 100,
                width: 100,
              ),
            ),
          ),
        ),
      );
      const Offset moved = Offset(20, 30);
      final Offset center = tester.getCenter(find.byKey(key));
      final Offset topLeft = tester.getTopLeft(find.byKey(key));
      final TestGesture gesture = await tester.startGesture(center);
      await gesture.moveBy(moved);
      await gesture.up();

      expect(events, hasLength(3));
      final PointerDownEvent down = events[0];
      final PointerMoveEvent move = events[1];
      final PointerUpEvent up = events[2];

      final Matrix4 expectedTransform = Matrix4.identity()
        ..scale(1 / scaleFactor, 1 / scaleFactor, 1.0)
        ..translate(-topLeft.dx, -topLeft.dy, 0);

      expect(center, isNot(const Offset(50, 50)));

      expect(down.localPosition, const Offset(50, 50));
      expect(down.position, center);
      expect(down.delta, Offset.zero);
      expect(down.localDelta, Offset.zero);
      expect(down.transform, expectedTransform);

      expect(move.localPosition, const Offset(50, 50) + moved / scaleFactor);
      expect(move.position, center + moved);
      expect(move.delta, moved);
      expect(move.localDelta, moved / scaleFactor);
      expect(move.transform, expectedTransform);

      expect(up.localPosition, const Offset(50, 50) + moved / scaleFactor);
      expect(up.position, center + moved);
      expect(up.delta, Offset.zero);
      expect(up.localDelta, Offset.zero);
      expect(up.transform, expectedTransform);

      events.clear();
      await scrollAt(center, tester);
      expect(events.single.localPosition, const Offset(50, 50));
      expect(events.single.position, center);
      expect(events.single.delta, Offset.zero);
      expect(events.single.localDelta, Offset.zero);
      expect(events.single.transform, expectedTransform);

      await gesture.removePointer();
    });

    testWidgets('rotated for touch/signal', (WidgetTester tester) async {
      final List<PointerEvent> events = <PointerEvent>[];
      final Key key = UniqueKey();

      await tester.pumpWidget(
        Center(
          child: Transform(
            transform: Matrix4.identity()
              ..rotateZ(math.pi / 2), // 90 degrees clockwise around Container origin
            child: Listener(
              onPointerDown: (PointerDownEvent event) {
                events.add(event);
              },
              onPointerUp: (PointerUpEvent event) {
                events.add(event);
              },
              onPointerMove: (PointerMoveEvent event) {
                events.add(event);
              },
              onPointerSignal: (PointerSignalEvent event) {
                events.add(event);
              },
              child: Container(
                key: key,
                color: Colors.red,
                height: 100,
                width: 100,
              ),
            ),
          ),
        ),
      );
      const Offset moved = Offset(20, 30);
      final Offset downPosition = tester.getCenter(find.byKey(key)) + const Offset(10, 5);
      final TestGesture gesture = await tester.startGesture(downPosition);
      await gesture.moveBy(moved);
      await gesture.up();

      expect(events, hasLength(3));
      final PointerDownEvent down = events[0];
      final PointerMoveEvent move = events[1];
      final PointerUpEvent up = events[2];

      const Offset offset = Offset((800 - 100) / 2, (600 - 100) / 2);
      final Matrix4 expectedTransform = Matrix4.identity()
        ..rotateZ(-math.pi / 2)
        ..translate(-offset.dx, -offset.dy, 0.0);

      final Offset localDownPosition = const Offset(50, 50) + const Offset(5, -10);
      expect(down.localPosition, within(distance: 0.001, from: localDownPosition));
      expect(down.position, downPosition);
      expect(down.delta, Offset.zero);
      expect(down.localDelta, Offset.zero);
      expect(down.transform, expectedTransform);

      const Offset localDelta = Offset(30, -20);
      expect(move.localPosition, within(distance: 0.001, from: localDownPosition + localDelta));
      expect(move.position, downPosition + moved);
      expect(move.delta, moved);
      expect(move.localDelta, localDelta);
      expect(move.transform, expectedTransform);

      expect(up.localPosition, within(distance: 0.001, from: localDownPosition + localDelta));
      expect(up.position, downPosition + moved);
      expect(up.delta, Offset.zero);
      expect(up.localDelta, Offset.zero);
      expect(up.transform, expectedTransform);

      events.clear();
      await scrollAt(downPosition, tester);
      expect(events.single.localPosition, within(distance: 0.001, from: localDownPosition));
      expect(events.single.position, downPosition);
      expect(events.single.delta, Offset.zero);
      expect(events.single.localDelta, Offset.zero);
      expect(events.single.transform, expectedTransform);

      await gesture.removePointer();
    });
  });
}

Future<void> scrollAt(Offset position, WidgetTester tester) {
  final TestPointer testPointer = TestPointer(1, PointerDeviceKind.mouse);
  // Create a hover event so that |testPointer| has a location when generating the scroll.
  testPointer.hover(position);
  final HitTestResult result = tester.hitTestOnBinding(position);
  return tester.sendEventToBinding(testPointer.scroll(const Offset(0.0, 20.0)), result);
}
