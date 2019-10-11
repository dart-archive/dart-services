// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-08-15T10:04:31.623147.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/gestures.dart';
import 'package:flutter_web/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

import 'gesture_tester.dart';

void main() {
  setUp(ensureGestureBinding);

  testGesture('toString control tests', (GestureTester tester) {
    expect(const PointerDownEvent(), hasOneLineDescription);
    expect(const PointerDownEvent().toStringFull(), hasOneLineDescription);
  });

  testGesture('nthMouseButton control tests', (GestureTester tester) {
    expect(nthMouseButton(2), kSecondaryMouseButton);
    expect(nthStylusButton(2), kSecondaryStylusButton);
  });

  testGesture('smallestButton tests', (GestureTester tester) {
    expect(smallestButton(0x0), equals(0x0));
    expect(smallestButton(0x1), equals(0x1));
    expect(smallestButton(0x200), equals(0x200));
    expect(smallestButton(0x220), equals(0x20));
  });

  testGesture('isSingleButton tests', (GestureTester tester) {
    expect(isSingleButton(0x0), isFalse);
    expect(isSingleButton(0x1), isTrue);
    expect(isSingleButton(0x200), isTrue);
    expect(isSingleButton(0x220), isFalse);
  });

  group('fromMouseEvent', () {
    const PointerEvent hover = PointerHoverEvent(
      timeStamp: Duration(days: 1),
      kind: PointerDeviceKind.unknown,
      device: 10,
      position: Offset(101.0, 202.0),
      buttons: 7,
      obscured: true,
      pressureMax: 2.1,
      pressureMin: 1.1,
      distance: 11,
      distanceMax: 110,
      size: 11,
      radiusMajor: 11,
      radiusMinor: 9,
      radiusMin: 1.1,
      radiusMax: 22,
      orientation: 1.1,
      tilt: 1.1,
      synthesized: true,
    );

    test('PointerEnterEvent.fromMouseEvent', () {
      final PointerEnterEvent event = PointerEnterEvent.fromMouseEvent(hover);
      const PointerEnterEvent empty = PointerEnterEvent();
      expect(event.timeStamp,   hover.timeStamp);
      expect(event.pointer,     empty.pointer);
      expect(event.kind,        hover.kind);
      expect(event.device,      hover.device);
      expect(event.position,    hover.position);
      expect(event.buttons,     hover.buttons);
      expect(event.down,        empty.down);
      expect(event.obscured,    hover.obscured);
      expect(event.pressure,    empty.pressure);
      expect(event.pressureMin, hover.pressureMin);
      expect(event.pressureMax, hover.pressureMax);
      expect(event.distance,    hover.distance);
      expect(event.distanceMax, hover.distanceMax);
      expect(event.distanceMax, hover.distanceMax);
      expect(event.size,        hover.size);
      expect(event.radiusMajor, hover.radiusMajor);
      expect(event.radiusMinor, hover.radiusMinor);
      expect(event.radiusMin,   hover.radiusMin);
      expect(event.radiusMax,   hover.radiusMax);
      expect(event.orientation, hover.orientation);
      expect(event.tilt,        hover.tilt);
      expect(event.synthesized, hover.synthesized);
    });

    test('PointerExitEvent.fromMouseEvent', () {
      final PointerExitEvent event = PointerExitEvent.fromMouseEvent(hover);
      const PointerExitEvent empty = PointerExitEvent();
      expect(event.timeStamp,   hover.timeStamp);
      expect(event.pointer,     empty.pointer);
      expect(event.kind,        hover.kind);
      expect(event.device,      hover.device);
      expect(event.position,    hover.position);
      expect(event.buttons,     hover.buttons);
      expect(event.down,        empty.down);
      expect(event.obscured,    hover.obscured);
      expect(event.pressure,    empty.pressure);
      expect(event.pressureMin, hover.pressureMin);
      expect(event.pressureMax, hover.pressureMax);
      expect(event.distance,    hover.distance);
      expect(event.distanceMax, hover.distanceMax);
      expect(event.distanceMax, hover.distanceMax);
      expect(event.size,        hover.size);
      expect(event.radiusMajor, hover.radiusMajor);
      expect(event.radiusMinor, hover.radiusMinor);
      expect(event.radiusMin,   hover.radiusMin);
      expect(event.radiusMax,   hover.radiusMax);
      expect(event.orientation, hover.orientation);
      expect(event.tilt,        hover.tilt);
      expect(event.synthesized, hover.synthesized);
    });
  });

  group('Default values of PointerEvents:', () {
    // Some parameters are intentionally set to a non-trivial value.

    test('PointerDownEvent', () {
      const PointerDownEvent event = PointerDownEvent();
      expect(event.buttons, kPrimaryButton);
    });

    test('PointerMoveEvent', () {
      const PointerMoveEvent event = PointerMoveEvent();
      expect(event.buttons, kPrimaryButton);
    });
  });

  test('paintTransformToPointerEventTransform', () {
    Matrix4 original = Matrix4.identity();
    Matrix4 changed = PointerEvent.removePerspectiveTransform(original);
    expect(changed, original);

    original = Matrix4.identity()..scale(3.0);
    changed = PointerEvent.removePerspectiveTransform(original);
    expect(changed, isNot(original));
    original
      ..setColumn(2, Vector4(0, 0, 1, 0))
      ..setRow(2, Vector4(0, 0, 1, 0));
    expect(changed, original);
  });

  test('transformPosition', () {
    const Offset position = Offset(20, 30);
    expect(PointerEvent.transformPosition(null, position), position);
    expect(PointerEvent.transformPosition(Matrix4.identity(), position), position);
    final Matrix4 transform = Matrix4.translationValues(10, 20, 0);
    expect(PointerEvent.transformPosition(transform, position), const Offset(20.0 + 10.0, 30.0 + 20.0));
  });

  test('transformDeltaViaPositions', () {
    Offset transformedDelta = PointerEvent.transformDeltaViaPositions(
      untransformedEndPosition: const Offset(20, 30),
      untransformedDelta: const Offset(5, 5),
      transform: Matrix4.identity()..scale(2.0, 2.0, 1.0),
    );
    expect(transformedDelta, const Offset(10.0, 10.0));

    transformedDelta = PointerEvent.transformDeltaViaPositions(
      untransformedEndPosition: const Offset(20, 30),
      transformedEndPosition: const Offset(40, 60),
      untransformedDelta: const Offset(5, 5),
      transform: Matrix4.identity()..scale(2.0, 2.0, 1.0),
    );
    expect(transformedDelta, const Offset(10.0, 10.0));

    transformedDelta = PointerEvent.transformDeltaViaPositions(
      untransformedEndPosition: const Offset(20, 30),
      transformedEndPosition: const Offset(40, 60),
      untransformedDelta: const Offset(5, 5),
      transform: null,
    );
    expect(transformedDelta, const Offset(5, 5));
  });

  test('transforming events', () {
    final Matrix4 transform = (Matrix4.identity()..scale(2.0, 2.0, 1.0)) * Matrix4.translationValues(10.0, 20.0, 0.0);
    const Offset localPosition = Offset(60, 100);
    const Offset localDelta = Offset(10, 10);

    const PointerAddedEvent added = PointerAddedEvent(
      timeStamp: Duration(seconds: 2),
      kind: PointerDeviceKind.mouse,
      device: 1,
      position: Offset(20, 30),
      obscured: true,
      pressureMin: 10,
      pressureMax: 60,
      distance: 12,
      distanceMax: 24,
      radiusMin: 10,
      radiusMax: 50,
      orientation: 2,
      tilt: 4,
    );
    _expectTransformedEvent(
      original: added,
      transform: transform,
      localPosition: localPosition,
    );

    const PointerCancelEvent cancel = PointerCancelEvent(
      timeStamp: Duration(seconds: 2),
      pointer: 45,
      kind: PointerDeviceKind.mouse,
      device: 1,
      position: Offset(20, 30),
      buttons: 4,
      obscured: true,
      pressureMin: 10,
      pressureMax: 60,
      distance: 12,
      distanceMax: 24,
      size: 10,
      radiusMajor: 33,
      radiusMinor: 44,
      radiusMin: 10,
      radiusMax: 50,
      orientation: 2,
      tilt: 4,
    );
    _expectTransformedEvent(
      original: cancel,
      transform: transform,
      localPosition: localPosition,
    );

    const PointerDownEvent down = PointerDownEvent(
      timeStamp: Duration(seconds: 2),
      pointer: 45,
      kind: PointerDeviceKind.mouse,
      device: 1,
      position: Offset(20, 30),
      buttons: 4,
      obscured: true,
      pressure: 34,
      pressureMin: 10,
      pressureMax: 60,
      distanceMax: 24,
      size: 10,
      radiusMajor: 33,
      radiusMinor: 44,
      radiusMin: 10,
      radiusMax: 50,
      orientation: 2,
      tilt: 4,
    );
    _expectTransformedEvent(
      original: down,
      transform: transform,
      localPosition: localPosition,
    );

    const PointerEnterEvent enter = PointerEnterEvent(
      timeStamp: Duration(seconds: 2),
      kind: PointerDeviceKind.mouse,
      device: 1,
      position: Offset(20, 30),
      delta: Offset(5, 5),
      buttons: 4,
      obscured: true,
      pressureMin: 10,
      pressureMax: 60,
      distance: 12,
      distanceMax: 24,
      size: 10,
      radiusMajor: 33,
      radiusMinor: 44,
      radiusMin: 10,
      radiusMax: 50,
      orientation: 2,
      tilt: 4,
      synthesized: true,
    );
    _expectTransformedEvent(
      original: enter,
      transform: transform,
      localPosition: localPosition,
      localDelta: localDelta,
    );

    const PointerExitEvent exit = PointerExitEvent(
      timeStamp: Duration(seconds: 2),
      kind: PointerDeviceKind.mouse,
      device: 1,
      position: Offset(20, 30),
      delta: Offset(5, 5),
      buttons: 4,
      obscured: true,
      pressureMin: 10,
      pressureMax: 60,
      distance: 12,
      distanceMax: 24,
      size: 10,
      radiusMajor: 33,
      radiusMinor: 44,
      radiusMin: 10,
      radiusMax: 50,
      orientation: 2,
      tilt: 4,
      synthesized: true,
    );
    _expectTransformedEvent(
      original: exit,
      transform: transform,
      localPosition: localPosition,
      localDelta: localDelta,
    );

    const PointerHoverEvent hover = PointerHoverEvent(
      timeStamp: Duration(seconds: 2),
      kind: PointerDeviceKind.mouse,
      device: 1,
      position: Offset(20, 30),
      delta: Offset(5, 5),
      buttons: 4,
      obscured: true,
      pressureMin: 10,
      pressureMax: 60,
      distance: 12,
      distanceMax: 24,
      size: 10,
      radiusMajor: 33,
      radiusMinor: 44,
      radiusMin: 10,
      radiusMax: 50,
      orientation: 2,
      tilt: 4,
      synthesized: true,
    );
    _expectTransformedEvent(
      original: hover,
      transform: transform,
      localPosition: localPosition,
      localDelta: localDelta,
    );

    const PointerMoveEvent move = PointerMoveEvent(
      timeStamp: Duration(seconds: 2),
      pointer: 45,
      kind: PointerDeviceKind.mouse,
      device: 1,
      position: Offset(20, 30),
      delta: Offset(5, 5),
      buttons: 4,
      obscured: true,
      pressure: 34,
      pressureMin: 10,
      pressureMax: 60,
      distanceMax: 24,
      size: 10,
      radiusMajor: 33,
      radiusMinor: 44,
      radiusMin: 10,
      radiusMax: 50,
      orientation: 2,
      tilt: 4,
      platformData: 10,
      synthesized: true,
    );
    _expectTransformedEvent(
      original: move,
      transform: transform,
      localPosition: localPosition,
      localDelta: localDelta,
    );

    const PointerRemovedEvent removed = PointerRemovedEvent(
      timeStamp: Duration(seconds: 2),
      kind: PointerDeviceKind.mouse,
      device: 1,
      position: Offset(20, 30),
      obscured: true,
      pressureMin: 10,
      pressureMax: 60,
      distanceMax: 24,
      radiusMin: 10,
      radiusMax: 50,
    );
    _expectTransformedEvent(
      original: removed,
      transform: transform,
      localPosition: localPosition,
    );

    const PointerScrollEvent scroll = PointerScrollEvent(
      timeStamp: Duration(seconds: 2),
      kind: PointerDeviceKind.mouse,
      device: 1,
      position: Offset(20, 30),
    );
    _expectTransformedEvent(
      original: scroll,
      transform: transform,
      localPosition: localPosition,
    );

    const PointerUpEvent up = PointerUpEvent(
      timeStamp: Duration(seconds: 2),
      pointer: 45,
      kind: PointerDeviceKind.mouse,
      device: 1,
      position: Offset(20, 30),
      buttons: 4,
      obscured: true,
      pressure: 34,
      pressureMin: 10,
      pressureMax: 60,
      distance: 12,
      distanceMax: 24,
      size: 10,
      radiusMajor: 33,
      radiusMinor: 44,
      radiusMin: 10,
      radiusMax: 50,
      orientation: 2,
      tilt: 4,
    );
    _expectTransformedEvent(
      original: up,
      transform: transform,
      localPosition: localPosition,
    );
  });
}

void _expectTransformedEvent({
  @required PointerEvent original,
  @required Matrix4 transform,
  Offset localDelta,
  Offset localPosition,
}) {
  expect(original.position, original.localPosition);
  expect(original.delta, original.localDelta);
  expect(original.original, isNull);
  expect(original.transform, isNull);

  final PointerEvent transformed = original.transformed(transform);
  expect(transformed.original, same(original));
  expect(transformed.transform, transform);
  expect(transformed.localDelta, localDelta ?? original.localDelta);
  expect(transformed.localPosition, localPosition ?? original.localPosition);

  expect(transformed.buttons, original.buttons);
  expect(transformed.delta, original.delta);
  expect(transformed.device, original.device);
  expect(transformed.distance, original.distance);
  expect(transformed.distanceMax, original.distanceMax);
  expect(transformed.distanceMin, original.distanceMin);
  expect(transformed.down, original.down);
  expect(transformed.kind, original.kind);
  expect(transformed.obscured, original.obscured);
  expect(transformed.orientation, original.orientation);
  expect(transformed.platformData, original.platformData);
  expect(transformed.pointer, original.pointer);
  expect(transformed.position, original.position);
  expect(transformed.pressure, original.pressure);
  expect(transformed.pressureMax, original.pressureMax);
  expect(transformed.pressureMin, original.pressureMin);
  expect(transformed.radiusMajor, original.radiusMajor);
  expect(transformed.radiusMax, original.radiusMax);
  expect(transformed.radiusMin, original.radiusMin);
  expect(transformed.radiusMinor, original.radiusMinor);
  expect(transformed.size, original.size);
  expect(transformed.synthesized, original.synthesized);
  expect(transformed.tilt, original.tilt);
  expect(transformed.timeStamp, original.timeStamp);
}
