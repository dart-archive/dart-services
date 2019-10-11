// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/rendering.dart';
import 'package:test/test.dart';

import 'rendering_tester.dart';

// before using this, consider using RenderSizedBox from rendering_tester.dart
class RenderTestBox extends RenderBox {
  RenderTestBox(this._intrinsicDimensions);

  final BoxConstraints _intrinsicDimensions;

  @override
  double computeMinIntrinsicWidth(double height) {
    return _intrinsicDimensions.minWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _intrinsicDimensions.maxWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _intrinsicDimensions.minHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _intrinsicDimensions.maxHeight;
  }

  @override
  bool get sizedByParent => true;

  @override
  void performResize() {
    size = constraints.constrain(new Size(
        _intrinsicDimensions.minWidth +
            (_intrinsicDimensions.maxWidth - _intrinsicDimensions.minWidth) /
                2.0,
        _intrinsicDimensions.minHeight +
            (_intrinsicDimensions.maxHeight - _intrinsicDimensions.minHeight) /
                2.0));
  }
}

void main() {
  test('Shrink-wrapping width', () {
    final RenderBox child = new RenderTestBox(const BoxConstraints(
        minWidth: 10.0, maxWidth: 100.0, minHeight: 20.0, maxHeight: 200.0));
    final RenderBox parent = new RenderIntrinsicWidth(child: child);
    layout(parent,
        constraints: const BoxConstraints(
            minWidth: 5.0, minHeight: 8.0, maxWidth: 500.0, maxHeight: 800.0));
    expect(parent.size.width, equals(100.0));
    expect(parent.size.height, equals(110.0));

    expect(parent.getMinIntrinsicWidth(0.0), equals(100.0));
    expect(parent.getMaxIntrinsicWidth(0.0), equals(100.0));
    expect(parent.getMinIntrinsicHeight(0.0), equals(20.0));
    expect(parent.getMaxIntrinsicHeight(0.0), equals(200.0));

    expect(parent.getMinIntrinsicWidth(10.0), equals(100.0));
    expect(parent.getMaxIntrinsicWidth(10.0), equals(100.0));
    expect(parent.getMinIntrinsicHeight(10.0), equals(20.0));
    expect(parent.getMaxIntrinsicHeight(10.0), equals(200.0));

    expect(parent.getMinIntrinsicWidth(80.0), equals(100.0));
    expect(parent.getMaxIntrinsicWidth(80.0), equals(100.0));
    expect(parent.getMinIntrinsicHeight(80.0), equals(20.0));
    expect(parent.getMaxIntrinsicHeight(80.0), equals(200.0));

    expect(parent.getMinIntrinsicWidth(double.infinity), equals(100.0));
    expect(parent.getMaxIntrinsicWidth(double.infinity), equals(100.0));
    expect(parent.getMinIntrinsicHeight(double.infinity), equals(20.0));
    expect(parent.getMaxIntrinsicHeight(double.infinity), equals(200.0));
  });

  test('IntrinsicWidth without a child', () {
    final RenderBox parent = new RenderIntrinsicWidth();
    layout(parent,
        constraints: const BoxConstraints(
            minWidth: 5.0, minHeight: 8.0, maxWidth: 500.0, maxHeight: 800.0));
    expect(parent.size.width, equals(5.0));
    expect(parent.size.height, equals(8.0));

    expect(parent.getMinIntrinsicWidth(0.0), equals(0.0));
    expect(parent.getMaxIntrinsicWidth(0.0), equals(0.0));
    expect(parent.getMinIntrinsicHeight(0.0), equals(0.0));
    expect(parent.getMaxIntrinsicHeight(0.0), equals(0.0));

    expect(parent.getMinIntrinsicWidth(10.0), equals(0.0));
    expect(parent.getMaxIntrinsicWidth(10.0), equals(0.0));
    expect(parent.getMinIntrinsicHeight(10.0), equals(0.0));
    expect(parent.getMaxIntrinsicHeight(10.0), equals(0.0));

    expect(parent.getMinIntrinsicWidth(80.0), equals(0.0));
    expect(parent.getMaxIntrinsicWidth(80.0), equals(0.0));
    expect(parent.getMinIntrinsicHeight(80.0), equals(0.0));
    expect(parent.getMaxIntrinsicHeight(80.0), equals(0.0));

    expect(parent.getMinIntrinsicWidth(double.infinity), equals(0.0));
    expect(parent.getMaxIntrinsicWidth(double.infinity), equals(0.0));
    expect(parent.getMinIntrinsicHeight(double.infinity), equals(0.0));
    expect(parent.getMaxIntrinsicHeight(double.infinity), equals(0.0));
  });

  test('Shrink-wrapping width (stepped width)', () {
    final RenderBox child = new RenderTestBox(const BoxConstraints(
        minWidth: 10.0, maxWidth: 100.0, minHeight: 20.0, maxHeight: 200.0));
    final RenderBox parent =
        new RenderIntrinsicWidth(child: child, stepWidth: 47.0);
    layout(parent,
        constraints: const BoxConstraints(
            minWidth: 5.0, minHeight: 8.0, maxWidth: 500.0, maxHeight: 800.0));
    expect(parent.size.width, equals(3.0 * 47.0));
    expect(parent.size.height, equals(110.0));

    expect(parent.getMinIntrinsicWidth(0.0), equals(3.0 * 47.0));
    expect(parent.getMaxIntrinsicWidth(0.0), equals(3.0 * 47.0));
    expect(parent.getMinIntrinsicHeight(0.0), equals(20.0));
    expect(parent.getMaxIntrinsicHeight(0.0), equals(200.0));

    expect(parent.getMinIntrinsicWidth(10.0), equals(3.0 * 47.0));
    expect(parent.getMaxIntrinsicWidth(10.0), equals(3.0 * 47.0));
    expect(parent.getMinIntrinsicHeight(10.0), equals(20.0));
    expect(parent.getMaxIntrinsicHeight(10.0), equals(200.0));

    expect(parent.getMinIntrinsicWidth(80.0), equals(3.0 * 47.0));
    expect(parent.getMaxIntrinsicWidth(80.0), equals(3.0 * 47.0));
    expect(parent.getMinIntrinsicHeight(80.0), equals(20.0));
    expect(parent.getMaxIntrinsicHeight(80.0), equals(200.0));

    expect(parent.getMinIntrinsicWidth(double.infinity), equals(3.0 * 47.0));
    expect(parent.getMaxIntrinsicWidth(double.infinity), equals(3.0 * 47.0));
    expect(parent.getMinIntrinsicHeight(double.infinity), equals(20.0));
    expect(parent.getMaxIntrinsicHeight(double.infinity), equals(200.0));
  });

  test('Shrink-wrapping width (stepped height)', () {
    final RenderBox child = new RenderTestBox(const BoxConstraints(
        minWidth: 10.0, maxWidth: 100.0, minHeight: 20.0, maxHeight: 200.0));
    final RenderBox parent =
        new RenderIntrinsicWidth(child: child, stepHeight: 47.0);
    layout(parent,
        constraints: const BoxConstraints(
            minWidth: 5.0, minHeight: 8.0, maxWidth: 500.0, maxHeight: 800.0));
    expect(parent.size.width, equals(100.0));
    expect(parent.size.height, equals(235.0));

    expect(parent.getMinIntrinsicWidth(0.0), equals(100.0));
    expect(parent.getMaxIntrinsicWidth(0.0), equals(100.0));
    expect(parent.getMinIntrinsicHeight(0.0), equals(1.0 * 47.0));
    expect(parent.getMaxIntrinsicHeight(0.0), equals(5.0 * 47.0));

    expect(parent.getMinIntrinsicWidth(10.0), equals(100.0));
    expect(parent.getMaxIntrinsicWidth(10.0), equals(100.0));
    expect(parent.getMinIntrinsicHeight(10.0), equals(1.0 * 47.0));
    expect(parent.getMaxIntrinsicHeight(10.0), equals(5.0 * 47.0));

    expect(parent.getMinIntrinsicWidth(80.0), equals(100.0));
    expect(parent.getMaxIntrinsicWidth(80.0), equals(100.0));
    expect(parent.getMinIntrinsicHeight(80.0), equals(1.0 * 47.0));
    expect(parent.getMaxIntrinsicHeight(80.0), equals(5.0 * 47.0));

    expect(parent.getMinIntrinsicWidth(double.infinity), equals(100.0));
    expect(parent.getMaxIntrinsicWidth(double.infinity), equals(100.0));
    expect(parent.getMinIntrinsicHeight(double.infinity), equals(1.0 * 47.0));
    expect(parent.getMaxIntrinsicHeight(double.infinity), equals(5.0 * 47.0));
  });

  test('Shrink-wrapping width (stepped everything)', () {
    final RenderBox child = new RenderTestBox(const BoxConstraints(
        minWidth: 10.0, maxWidth: 100.0, minHeight: 20.0, maxHeight: 200.0));
    final RenderBox parent = new RenderIntrinsicWidth(
        child: child, stepHeight: 47.0, stepWidth: 37.0);
    layout(parent,
        constraints: const BoxConstraints(
            minWidth: 5.0, minHeight: 8.0, maxWidth: 500.0, maxHeight: 800.0));
    expect(parent.size.width, equals(3.0 * 37.0));
    expect(parent.size.height, equals(235.0));

    expect(parent.getMinIntrinsicWidth(0.0), equals(3.0 * 37.0));
    expect(parent.getMaxIntrinsicWidth(0.0), equals(3.0 * 37.0));
    expect(parent.getMinIntrinsicHeight(0.0), equals(1.0 * 47.0));
    expect(parent.getMaxIntrinsicHeight(0.0), equals(5.0 * 47.0));

    expect(parent.getMinIntrinsicWidth(10.0), equals(3.0 * 37.0));
    expect(parent.getMaxIntrinsicWidth(10.0), equals(3.0 * 37.0));
    expect(parent.getMinIntrinsicHeight(10.0), equals(1.0 * 47.0));
    expect(parent.getMaxIntrinsicHeight(10.0), equals(5.0 * 47.0));

    expect(parent.getMinIntrinsicWidth(80.0), equals(3.0 * 37.0));
    expect(parent.getMaxIntrinsicWidth(80.0), equals(3.0 * 37.0));
    expect(parent.getMinIntrinsicHeight(80.0), equals(1.0 * 47.0));
    expect(parent.getMaxIntrinsicHeight(80.0), equals(5.0 * 47.0));

    expect(parent.getMinIntrinsicWidth(double.infinity), equals(3.0 * 37.0));
    expect(parent.getMaxIntrinsicWidth(double.infinity), equals(3.0 * 37.0));
    expect(parent.getMinIntrinsicHeight(double.infinity), equals(1.0 * 47.0));
    expect(parent.getMaxIntrinsicHeight(double.infinity), equals(5.0 * 47.0));
  });

  test('Shrink-wrapping height', () {
    final RenderBox child = new RenderTestBox(const BoxConstraints(
        minWidth: 10.0, maxWidth: 100.0, minHeight: 20.0, maxHeight: 200.0));
    final RenderBox parent = new RenderIntrinsicHeight(child: child);
    layout(parent,
        constraints: const BoxConstraints(
            minWidth: 5.0, minHeight: 8.0, maxWidth: 500.0, maxHeight: 800.0));
    expect(parent.size.width, equals(55.0));
    expect(parent.size.height, equals(200.0));

    expect(parent.getMinIntrinsicWidth(0.0), equals(10.0));
    expect(parent.getMaxIntrinsicWidth(0.0), equals(100.0));
    expect(parent.getMinIntrinsicHeight(0.0), equals(200.0));
    expect(parent.getMaxIntrinsicHeight(0.0), equals(200.0));

    expect(parent.getMinIntrinsicWidth(10.0), equals(10.0));
    expect(parent.getMaxIntrinsicWidth(10.0), equals(100.0));
    expect(parent.getMinIntrinsicHeight(10.0), equals(200.0));
    expect(parent.getMaxIntrinsicHeight(10.0), equals(200.0));

    expect(parent.getMinIntrinsicWidth(80.0), equals(10.0));
    expect(parent.getMaxIntrinsicWidth(80.0), equals(100.0));
    expect(parent.getMinIntrinsicHeight(80.0), equals(200.0));
    expect(parent.getMaxIntrinsicHeight(80.0), equals(200.0));

    expect(parent.getMinIntrinsicWidth(double.infinity), equals(10.0));
    expect(parent.getMaxIntrinsicWidth(double.infinity), equals(100.0));
    expect(parent.getMinIntrinsicHeight(double.infinity), equals(200.0));
    expect(parent.getMaxIntrinsicHeight(double.infinity), equals(200.0));
  });

  test('IntrinsicHeight without a child', () {
    final RenderBox parent = new RenderIntrinsicHeight();
    layout(parent,
        constraints: const BoxConstraints(
            minWidth: 5.0, minHeight: 8.0, maxWidth: 500.0, maxHeight: 800.0));
    expect(parent.size.width, equals(5.0));
    expect(parent.size.height, equals(8.0));

    expect(parent.getMinIntrinsicWidth(0.0), equals(0.0));
    expect(parent.getMaxIntrinsicWidth(0.0), equals(0.0));
    expect(parent.getMinIntrinsicHeight(0.0), equals(0.0));
    expect(parent.getMaxIntrinsicHeight(0.0), equals(0.0));

    expect(parent.getMinIntrinsicWidth(10.0), equals(0.0));
    expect(parent.getMaxIntrinsicWidth(10.0), equals(0.0));
    expect(parent.getMinIntrinsicHeight(10.0), equals(0.0));
    expect(parent.getMaxIntrinsicHeight(10.0), equals(0.0));

    expect(parent.getMinIntrinsicWidth(80.0), equals(0.0));
    expect(parent.getMaxIntrinsicWidth(80.0), equals(0.0));
    expect(parent.getMinIntrinsicHeight(80.0), equals(0.0));
    expect(parent.getMaxIntrinsicHeight(80.0), equals(0.0));

    expect(parent.getMinIntrinsicWidth(double.infinity), equals(0.0));
    expect(parent.getMaxIntrinsicWidth(double.infinity), equals(0.0));
    expect(parent.getMinIntrinsicHeight(double.infinity), equals(0.0));
    expect(parent.getMaxIntrinsicHeight(double.infinity), equals(0.0));
  });

  test('Padding and boring intrinsics', () {
    final RenderBox box = new RenderPadding(
        padding: const EdgeInsets.all(15.0),
        child: new RenderSizedBox(const Size(20.0, 20.0)));

    expect(box.getMinIntrinsicWidth(0.0), 50.0);
    expect(box.getMaxIntrinsicWidth(0.0), 50.0);
    expect(box.getMinIntrinsicHeight(0.0), 50.0);
    expect(box.getMaxIntrinsicHeight(0.0), 50.0);

    expect(box.getMinIntrinsicWidth(10.0), 50.0);
    expect(box.getMaxIntrinsicWidth(10.0), 50.0);
    expect(box.getMinIntrinsicHeight(10.0), 50.0);
    expect(box.getMaxIntrinsicHeight(10.0), 50.0);

    expect(box.getMinIntrinsicWidth(80.0), 50.0);
    expect(box.getMaxIntrinsicWidth(80.0), 50.0);
    expect(box.getMinIntrinsicHeight(80.0), 50.0);
    expect(box.getMaxIntrinsicHeight(80.0), 50.0);

    expect(box.getMinIntrinsicWidth(double.infinity), 50.0);
    expect(box.getMaxIntrinsicWidth(double.infinity), 50.0);
    expect(box.getMinIntrinsicHeight(double.infinity), 50.0);
    expect(box.getMaxIntrinsicHeight(double.infinity), 50.0);

    // also a smoke test:
    layout(box,
        constraints: const BoxConstraints(
            minWidth: 10.0, minHeight: 10.0, maxWidth: 10.0, maxHeight: 10.0));
  });

  test('Padding and interesting intrinsics', () {
    final RenderBox box = new RenderPadding(
        padding: const EdgeInsets.all(15.0),
        child: new RenderAspectRatio(aspectRatio: 1.0));

    expect(box.getMinIntrinsicWidth(0.0), 30.0);
    expect(box.getMaxIntrinsicWidth(0.0), 30.0);
    expect(box.getMinIntrinsicHeight(0.0), 30.0);
    expect(box.getMaxIntrinsicHeight(0.0), 30.0);

    expect(box.getMinIntrinsicWidth(10.0), 30.0);
    expect(box.getMaxIntrinsicWidth(10.0), 30.0);
    expect(box.getMinIntrinsicHeight(10.0), 30.0);
    expect(box.getMaxIntrinsicHeight(10.0), 30.0);

    expect(box.getMinIntrinsicWidth(80.0), 80.0);
    expect(box.getMaxIntrinsicWidth(80.0), 80.0);
    expect(box.getMinIntrinsicHeight(80.0), 80.0);
    expect(box.getMaxIntrinsicHeight(80.0), 80.0);

    expect(box.getMinIntrinsicWidth(double.infinity), 30.0);
    expect(box.getMaxIntrinsicWidth(double.infinity), 30.0);
    expect(box.getMinIntrinsicHeight(double.infinity), 30.0);
    expect(box.getMaxIntrinsicHeight(double.infinity), 30.0);

    // also a smoke test:
    layout(box,
        constraints: const BoxConstraints(
            minWidth: 10.0, minHeight: 10.0, maxWidth: 10.0, maxHeight: 10.0));
  });

  test('Padding and boring intrinsics', () {
    final RenderBox box = new RenderPadding(
        padding: const EdgeInsets.all(15.0),
        child: new RenderSizedBox(const Size(20.0, 20.0)));

    expect(box.getMinIntrinsicWidth(0.0), 50.0);
    expect(box.getMaxIntrinsicWidth(0.0), 50.0);
    expect(box.getMinIntrinsicHeight(0.0), 50.0);
    expect(box.getMaxIntrinsicHeight(0.0), 50.0);

    expect(box.getMinIntrinsicWidth(10.0), 50.0);
    expect(box.getMaxIntrinsicWidth(10.0), 50.0);
    expect(box.getMinIntrinsicHeight(10.0), 50.0);
    expect(box.getMaxIntrinsicHeight(10.0), 50.0);

    expect(box.getMinIntrinsicWidth(80.0), 50.0);
    expect(box.getMaxIntrinsicWidth(80.0), 50.0);
    expect(box.getMinIntrinsicHeight(80.0), 50.0);
    expect(box.getMaxIntrinsicHeight(80.0), 50.0);

    expect(box.getMinIntrinsicWidth(double.infinity), 50.0);
    expect(box.getMaxIntrinsicWidth(double.infinity), 50.0);
    expect(box.getMinIntrinsicHeight(double.infinity), 50.0);
    expect(box.getMaxIntrinsicHeight(double.infinity), 50.0);

    // also a smoke test:
    layout(box,
        constraints: const BoxConstraints(
            minWidth: 10.0, minHeight: 10.0, maxWidth: 10.0, maxHeight: 10.0));
  });

  test('Padding and interesting intrinsics', () {
    final RenderBox box = new RenderPadding(
        padding: const EdgeInsets.all(15.0),
        child: new RenderAspectRatio(aspectRatio: 1.0));

    expect(box.getMinIntrinsicWidth(0.0), 30.0);
    expect(box.getMaxIntrinsicWidth(0.0), 30.0);
    expect(box.getMinIntrinsicHeight(0.0), 30.0);
    expect(box.getMaxIntrinsicHeight(0.0), 30.0);

    expect(box.getMinIntrinsicWidth(10.0), 30.0);
    expect(box.getMaxIntrinsicWidth(10.0), 30.0);
    expect(box.getMinIntrinsicHeight(10.0), 30.0);
    expect(box.getMaxIntrinsicHeight(10.0), 30.0);

    expect(box.getMinIntrinsicWidth(80.0), 80.0);
    expect(box.getMaxIntrinsicWidth(80.0), 80.0);
    expect(box.getMinIntrinsicHeight(80.0), 80.0);
    expect(box.getMaxIntrinsicHeight(80.0), 80.0);

    expect(box.getMinIntrinsicWidth(double.infinity), 30.0);
    expect(box.getMaxIntrinsicWidth(double.infinity), 30.0);
    expect(box.getMinIntrinsicHeight(double.infinity), 30.0);
    expect(box.getMaxIntrinsicHeight(double.infinity), 30.0);

    // also a smoke test:
    layout(box,
        constraints: const BoxConstraints(
            minWidth: 10.0, minHeight: 10.0, maxWidth: 10.0, maxHeight: 10.0));
  });
}
