// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-05-30T14:20:56.953642.

import 'package:flutter_web/gestures.dart';
import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

import 'rendering_tester.dart';

void main() {
  test('should size to render view', () {
    final RenderBox root = RenderDecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF00FF00),
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.8,
          colors: <Color>[Colors.yellow[500], Colors.blue[500]],
        ),
        boxShadow: kElevationToShadow[3],
      ),
    );
    layout(root);
    expect(root.size.width, equals(800.0));
    expect(root.size.height, equals(600.0));
  });

  test('Flex and padding', () {
    final RenderBox size = RenderConstrainedBox(
      additionalConstraints: const BoxConstraints().tighten(height: 100.0),
    );
    final RenderBox inner = RenderDecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF00FF00),
      ),
      child: size,
    );
    final RenderBox padding = RenderPadding(
      padding: const EdgeInsets.all(50.0),
      child: inner,
    );
    final RenderBox flex = RenderFlex(
      children: <RenderBox>[padding],
      direction: Axis.vertical,
      crossAxisAlignment: CrossAxisAlignment.stretch,
    );
    final RenderBox outer = RenderDecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF0000FF),
      ),
      child: flex,
    );

    layout(outer);

    expect(size.size.width, equals(700.0));
    expect(size.size.height, equals(100.0));
    expect(inner.size.width, equals(700.0));
    expect(inner.size.height, equals(100.0));
    expect(padding.size.width, equals(800.0));
    expect(padding.size.height, equals(200.0));
    expect(flex.size.width, equals(800.0));
    expect(flex.size.height, equals(600.0));
    expect(outer.size.width, equals(800.0));
    expect(outer.size.height, equals(600.0));
  });

  test('should not have a 0 sized colored Box', () {
    final RenderBox coloredBox = RenderDecoratedBox(
      decoration: const BoxDecoration(),
    );

    expect(coloredBox, hasAGoodToStringDeep);
    expect(
        coloredBox.toStringDeep(minLevel: DiagnosticLevel.info),
        equalsIgnoringHashCodes(
          'RenderDecoratedBox#00000 NEEDS-LAYOUT NEEDS-PAINT DETACHED\n'
          '   parentData: MISSING\n'
          '   constraints: MISSING\n'
          '   size: MISSING\n'
          '   decoration: BoxDecoration:\n'
          '     <no decorations specified>\n'
          '   configuration: ImageConfiguration()\n'),
    );

    final RenderBox paddingBox = RenderPadding(
      padding: const EdgeInsets.all(10.0),
      child: coloredBox,
    );
    final RenderBox root = RenderDecoratedBox(
      decoration: const BoxDecoration(),
      child: paddingBox,
    );
    layout(root);
    expect(coloredBox.size.width, equals(780.0));
    expect(coloredBox.size.height, equals(580.0));

    expect(coloredBox, hasAGoodToStringDeep);
    expect(
      coloredBox.toStringDeep(minLevel: DiagnosticLevel.info),
      equalsIgnoringHashCodes(
        'RenderDecoratedBox#00000 NEEDS-PAINT\n'
        '   parentData: offset=Offset(10.0, 10.0) (can use size)\n'
        '   constraints: BoxConstraints(w=780.0, h=580.0)\n'
        '   size: Size(780.0, 580.0)\n'
        '   decoration: BoxDecoration:\n'
        '     <no decorations specified>\n'
        '   configuration: ImageConfiguration()\n',
      ),
    );
  });

  test('reparenting should clear position', () {
    final RenderDecoratedBox coloredBox = RenderDecoratedBox(
      decoration: const BoxDecoration(),
    );

    final RenderPadding paddedBox = RenderPadding(
      child: coloredBox,
      padding: const EdgeInsets.all(10.0),
    );
    layout(paddedBox);
    final BoxParentData parentData = coloredBox.parentData;
    expect(parentData.offset.dx, isNot(equals(0.0)));
    paddedBox.child = null;

    final RenderConstrainedBox constraintedBox = RenderConstrainedBox(
      child: coloredBox,
      additionalConstraints: const BoxConstraints(),
    );
    layout(constraintedBox);
    expect(coloredBox.parentData?.runtimeType, ParentData);
  });

  test('UnconstrainedBox expands to fit children', () {
    final RenderUnconstrainedBox unconstrained = RenderUnconstrainedBox(
      constrainedAxis: Axis.horizontal, // This is reset to null below.
      textDirection: TextDirection.ltr,
      child: RenderConstrainedBox(
        additionalConstraints: const BoxConstraints.tightFor(width: 200.0, height: 200.0),
      ),
      alignment: Alignment.center,
    );
    layout(
      unconstrained,
      constraints: const BoxConstraints(
        minWidth: 200.0,
        maxWidth: 200.0,
        minHeight: 200.0,
        maxHeight: 200.0,
      ),
    );
    // Check that we can update the constrained axis to null.
    unconstrained.constrainedAxis = null;
    renderer.reassembleApplication();

    expect(unconstrained.size.width, equals(200.0), reason: 'unconstrained width');
    expect(unconstrained.size.height, equals(200.0), reason: 'unconstrained height');
  });

  test('UnconstrainedBox handles vertical overflow', () {
    final RenderUnconstrainedBox unconstrained = RenderUnconstrainedBox(
      textDirection: TextDirection.ltr,
      child: RenderConstrainedBox(
        additionalConstraints: const BoxConstraints.tightFor(height: 200.0),
      ),
      alignment: Alignment.center,
    );
    const BoxConstraints viewport = BoxConstraints(maxHeight: 100.0, maxWidth: 100.0);
    layout(unconstrained, constraints: viewport);
    expect(unconstrained.getMinIntrinsicHeight(100.0), equals(200.0));
    expect(unconstrained.getMaxIntrinsicHeight(100.0), equals(200.0));
    expect(unconstrained.getMinIntrinsicWidth(100.0), equals(0.0));
    expect(unconstrained.getMaxIntrinsicWidth(100.0), equals(0.0));
  });

  test('UnconstrainedBox handles horizontal overflow', () {
    final RenderUnconstrainedBox unconstrained = RenderUnconstrainedBox(
      textDirection: TextDirection.ltr,
      child: RenderConstrainedBox(
        additionalConstraints: const BoxConstraints.tightFor(width: 200.0),
      ),
      alignment: Alignment.center,
    );
    const BoxConstraints viewport = BoxConstraints(maxHeight: 100.0, maxWidth: 100.0);
    layout(unconstrained, constraints: viewport);
    expect(unconstrained.getMinIntrinsicHeight(100.0), equals(0.0));
    expect(unconstrained.getMaxIntrinsicHeight(100.0), equals(0.0));
    expect(unconstrained.getMinIntrinsicWidth(100.0), equals(200.0));
    expect(unconstrained.getMaxIntrinsicWidth(100.0), equals(200.0));
  });

  test('UnconstrainedBox.toStringDeep returns useful information', () {
    final RenderUnconstrainedBox unconstrained = RenderUnconstrainedBox(
      textDirection: TextDirection.ltr,
      alignment: Alignment.center,
    );
    expect(unconstrained.alignment, Alignment.center);
    expect(unconstrained.textDirection, TextDirection.ltr);
    expect(unconstrained, hasAGoodToStringDeep);
    expect(
      unconstrained.toStringDeep(minLevel: DiagnosticLevel.info),
      equalsIgnoringHashCodes(
        'RenderUnconstrainedBox#00000 NEEDS-LAYOUT NEEDS-PAINT DETACHED\n'
          '   parentData: MISSING\n'
          '   constraints: MISSING\n'
          '   size: MISSING\n'
          '   alignment: center\n'
          '   textDirection: ltr\n'),
    );
  });

  test('UnconstrainedBox honors constrainedAxis=Axis.horizontal', () {
    final RenderConstrainedBox flexible =
        RenderConstrainedBox(additionalConstraints: const BoxConstraints.expand(height: 200.0));
    final RenderUnconstrainedBox unconstrained = RenderUnconstrainedBox(
      constrainedAxis: Axis.horizontal,
      textDirection: TextDirection.ltr,
      child: RenderFlex(
        direction: Axis.horizontal,
        textDirection: TextDirection.ltr,
        children: <RenderBox>[flexible],
      ),
      alignment: Alignment.center,
    );
    final FlexParentData flexParentData = flexible.parentData;
    flexParentData.flex = 1;
    flexParentData.fit = FlexFit.tight;

    const BoxConstraints viewport = BoxConstraints(maxWidth: 100.0);
    layout(unconstrained, constraints: viewport);

    expect(unconstrained.size.width, equals(100.0), reason: 'constrained width');
    expect(unconstrained.size.height, equals(200.0), reason: 'unconstrained height');
  });

  test('UnconstrainedBox honors constrainedAxis=Axis.vertical', () {
    final RenderConstrainedBox flexible =
    RenderConstrainedBox(additionalConstraints: const BoxConstraints.expand(width: 200.0));
    final RenderUnconstrainedBox unconstrained = RenderUnconstrainedBox(
      constrainedAxis: Axis.vertical,
      textDirection: TextDirection.ltr,
      child: RenderFlex(
        direction: Axis.vertical,
        textDirection: TextDirection.ltr,
        children: <RenderBox>[flexible],
      ),
      alignment: Alignment.center,
    );
    final FlexParentData flexParentData = flexible.parentData;
    flexParentData.flex = 1;
    flexParentData.fit = FlexFit.tight;

    const BoxConstraints viewport = BoxConstraints(maxHeight: 100.0);
    layout(unconstrained, constraints: viewport);

    expect(unconstrained.size.width, equals(200.0), reason: 'unconstrained width');
    expect(unconstrained.size.height, equals(100.0), reason: 'constrained height');
  });

  group('hit testing', () {
    test('BoxHitTestResult wrapping HitTestResult', () {
      final HitTestEntry entry1 = HitTestEntry(_DummyHitTestTarget());
      final HitTestEntry entry2 = HitTestEntry(_DummyHitTestTarget());
      final HitTestEntry entry3 = HitTestEntry(_DummyHitTestTarget());

      final HitTestResult wrapped = HitTestResult();
      wrapped.add(entry1);
      expect(wrapped.path, equals(<HitTestEntry>[entry1]));

      final BoxHitTestResult wrapping = BoxHitTestResult.wrap(wrapped);
      expect(wrapping.path, equals(<HitTestEntry>[entry1]));
      expect(wrapping.path, same(wrapped.path));

      wrapping.add(entry2);
      expect(wrapping.path, equals(<HitTestEntry>[entry1, entry2]));
      expect(wrapped.path, equals(<HitTestEntry>[entry1, entry2]));

      wrapped.add(entry3);
      expect(wrapping.path, equals(<HitTestEntry>[entry1, entry2, entry3]));
      expect(wrapped.path, equals(<HitTestEntry>[entry1, entry2, entry3]));
    });

    test('addWithPaintTransform', () {
      final BoxHitTestResult result = BoxHitTestResult();
      final List<Offset> positions = <Offset>[];

      bool isHit = result.addWithPaintTransform(
        transform: null,
        position: null,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, isNull);
      positions.clear();

      isHit = result.addWithPaintTransform(
        transform: Matrix4.translationValues(20, 30, 0),
        position: null,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, isNull);
      positions.clear();

      const Offset position = Offset(3, 4);
      isHit = result.addWithPaintTransform(
        transform: null,
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return false;
        },
      );
      expect(isHit, isFalse);
      expect(positions.single, position);
      positions.clear();

      isHit = result.addWithPaintTransform(
        transform: Matrix4.identity(),
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, position);
      positions.clear();

      isHit = result.addWithPaintTransform(
        transform: Matrix4.translationValues(20, 30, 0),
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, position - const Offset(20, 30));
      positions.clear();

      isHit = result.addWithPaintTransform(
        transform: MatrixUtils.forceToPoint(position), // cannot be inverted
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isFalse);
      expect(positions, isEmpty);
      positions.clear();
    });

    test('addWithPaintOffset', () {
      final BoxHitTestResult result = BoxHitTestResult();
      final List<Offset> positions = <Offset>[];

      bool isHit = result.addWithPaintOffset(
        offset: null,
        position: null,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, isNull);
      positions.clear();

      isHit = result.addWithPaintOffset(
        offset: const Offset(55, 32),
        position: null,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, isNull);
      positions.clear();

      const Offset position = Offset(3, 4);
      isHit = result.addWithPaintOffset(
        offset: null,
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return false;
        },
      );
      expect(isHit, isFalse);
      expect(positions.single, position);
      positions.clear();

      isHit = result.addWithPaintOffset(
        offset: Offset.zero,
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, position);
      positions.clear();

      isHit = result.addWithPaintOffset(
        offset: const Offset(20, 30),
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, position - const Offset(20, 30));
      positions.clear();
    });

    test('addWithRawTransform', () {
      final BoxHitTestResult result = BoxHitTestResult();
      final List<Offset> positions = <Offset>[];

      bool isHit = result.addWithRawTransform(
        transform: null,
        position: null,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, isNull);
      positions.clear();

      isHit = result.addWithRawTransform(
        transform: Matrix4.translationValues(20, 30, 0),
        position: null,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, isNull);
      positions.clear();

      const Offset position = Offset(3, 4);
      isHit = result.addWithRawTransform(
        transform: null,
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return false;
        },
      );
      expect(isHit, isFalse);
      expect(positions.single, position);
      positions.clear();

      isHit = result.addWithRawTransform(
        transform: Matrix4.identity(),
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, position);
      positions.clear();

      isHit = result.addWithRawTransform(
        transform: Matrix4.translationValues(20, 30, 0),
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          expect(result, isNotNull);
          positions.add(position);
          return true;
        },
      );
      expect(isHit, isTrue);
      expect(positions.single, position + const Offset(20, 30));
      positions.clear();
    });
  });
}

class _DummyHitTestTarget implements HitTestTarget {
  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    // Nothing to do.
  }
}
