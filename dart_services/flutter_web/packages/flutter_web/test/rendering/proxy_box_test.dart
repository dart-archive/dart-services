// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced. * Contains Web DELTA *

import 'dart:typed_data';
import 'package:flutter_web/animation.dart';
import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/gestures.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/src/scheduler/ticker.dart';
import 'package:flutter_web_ui/ui.dart' as ui show Image, isWeb;
import 'package:flutter_web_test/flutter_web_test.dart';

import 'rendering_tester.dart';

void main() {
  test('RenderFittedBox does not paint with empty sizes', () {
    bool painted;
    RenderFittedBox makeFittedBox(Size size) {
      return RenderFittedBox(
        child: RenderCustomPaint(
          preferredSize: size,
          painter: TestCallbackPainter(onPaint: () {
            painted = true;
          }),
        ),
      );
    }

    // The RenderFittedBox paints if both its size and its child's size are nonempty.
    painted = false;
    layout(makeFittedBox(const Size(1, 1)), phase: EnginePhase.paint);
    expect(painted, equals(true));

    // The RenderFittedBox should not paint if its child is empty-sized.
    painted = false;
    layout(makeFittedBox(Size.zero), phase: EnginePhase.paint);
    expect(painted, equals(false));

    // The RenderFittedBox should not paint if it is empty.
    painted = false;
    layout(makeFittedBox(const Size(1, 1)), constraints: BoxConstraints.tight(Size.zero), phase: EnginePhase.paint);
    expect(painted, equals(false));
  });

  test('RenderPhysicalModel compositing on Fuchsia', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

    final RenderPhysicalModel root = RenderPhysicalModel(color: const Color(0xffff00ff));
    layout(root, phase: EnginePhase.composite);
    expect(root.needsCompositing, isTrue);

    // On Fuchsia, the system compositor is responsible for drawing shadows
    // for physical model layers with non-zero elevation.
    root.elevation = 1.0;
    pumpFrame(phase: EnginePhase.composite);
    expect(root.needsCompositing, isTrue);

    root.elevation = 0.0;
    pumpFrame(phase: EnginePhase.composite);
    expect(root.needsCompositing, isTrue);

    debugDefaultTargetPlatformOverride = null;
  });

  test('RenderPhysicalModel compositing on non-Fuchsia', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final RenderPhysicalModel root = RenderPhysicalModel(color: const Color(0xffff00ff));
    layout(root, phase: EnginePhase.composite);
    expect(root.needsCompositing, isTrue);

    // Flutter now composites physical shapes on all platforms.
    root.elevation = 1.0;
    pumpFrame(phase: EnginePhase.composite);
    expect(root.needsCompositing, isTrue);

    root.elevation = 0.0;
    pumpFrame(phase: EnginePhase.composite);
    expect(root.needsCompositing, isTrue);

    debugDefaultTargetPlatformOverride = null;
  });

  test('RenderSemanticsGestureHandler adds/removes correct semantic actions', () {
    final RenderSemanticsGestureHandler renderObj = RenderSemanticsGestureHandler(
      onTap: () { },
      onHorizontalDragUpdate: (DragUpdateDetails details) { },
    );

    SemanticsConfiguration config = SemanticsConfiguration();
    renderObj.describeSemanticsConfiguration(config);
    expect(config.getActionHandler(SemanticsAction.tap), isNotNull);
    expect(config.getActionHandler(SemanticsAction.scrollLeft), isNotNull);
    expect(config.getActionHandler(SemanticsAction.scrollRight), isNotNull);

    config = SemanticsConfiguration();
    renderObj.validActions = <SemanticsAction>{SemanticsAction.tap, SemanticsAction.scrollLeft};

    renderObj.describeSemanticsConfiguration(config);
    expect(config.getActionHandler(SemanticsAction.tap), isNotNull);
    expect(config.getActionHandler(SemanticsAction.scrollLeft), isNotNull);
    expect(config.getActionHandler(SemanticsAction.scrollRight), isNull);
  });

  group('RenderPhysicalShape', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    });

    test('shape change triggers repaint', () {
      final RenderPhysicalShape root = RenderPhysicalShape(
        color: const Color(0xffff00ff),
        clipper: const ShapeBorderClipper(shape: CircleBorder()),
      );
      layout(root, phase: EnginePhase.composite);
      expect(root.debugNeedsPaint, isFalse);

      // Same shape, no repaint.
      root.clipper = const ShapeBorderClipper(shape: CircleBorder());
      expect(root.debugNeedsPaint, isFalse);

      // Different shape triggers repaint.
      root.clipper = const ShapeBorderClipper(shape: StadiumBorder());
      expect(root.debugNeedsPaint, isTrue);
    });

    test('compositing on non-Fuchsia', () {
      final RenderPhysicalShape root = RenderPhysicalShape(
        color: const Color(0xffff00ff),
        clipper: const ShapeBorderClipper(shape: CircleBorder()),
      );
      layout(root, phase: EnginePhase.composite);
      expect(root.needsCompositing, isTrue);

      // On non-Fuchsia platforms, we composite physical shape layers
      root.elevation = 1.0;
      pumpFrame(phase: EnginePhase.composite);
      expect(root.needsCompositing, isTrue);

      root.elevation = 0.0;
      pumpFrame(phase: EnginePhase.composite);
      expect(root.needsCompositing, isTrue);

      debugDefaultTargetPlatformOverride = null;
    });
  });

  test('RenderRepaintBoundary can capture images of itself', () async {
    RenderRepaintBoundary boundary = RenderRepaintBoundary();
    layout(boundary, constraints: BoxConstraints.tight(const Size(100.0, 200.0)));
    pumpFrame(phase: EnginePhase.composite);
    ui.Image image = await boundary.toImage();
    expect(image.width, equals(100));
    expect(image.height, equals(200));

    // Now with pixel ratio set to something other than 1.0.
    boundary = RenderRepaintBoundary();
    layout(boundary, constraints: BoxConstraints.tight(const Size(100.0, 200.0)));
    pumpFrame(phase: EnginePhase.composite);
    image = await boundary.toImage(pixelRatio: 2.0);
    expect(image.width, equals(200));
    expect(image.height, equals(400));

    // Try building one with two child layers and make sure it renders them both.
    boundary = RenderRepaintBoundary();
    final RenderStack stack = RenderStack()..alignment = Alignment.topLeft;
    final RenderDecoratedBox blackBox = RenderDecoratedBox(
        decoration: const BoxDecoration(color: Color(0xff000000)),
        child: RenderConstrainedBox(
          additionalConstraints: BoxConstraints.tight(const Size.square(20.0)),
        ));
    stack.add(RenderOpacity()
      ..opacity = 0.5
      ..child = blackBox);
    final RenderDecoratedBox whiteBox = RenderDecoratedBox(
        decoration: const BoxDecoration(color: Color(0xffffffff)),
        child: RenderConstrainedBox(
          additionalConstraints: BoxConstraints.tight(const Size.square(10.0)),
        ));
    final RenderPositionedBox positioned = RenderPositionedBox(
      widthFactor: 2.0,
      heightFactor: 2.0,
      alignment: Alignment.topRight,
      child: whiteBox,
    );
    stack.add(positioned);
    boundary.child = stack;
    layout(boundary, constraints: BoxConstraints.tight(const Size(20.0, 20.0)));
    pumpFrame(phase: EnginePhase.composite);
    image = await boundary.toImage();
    expect(image.width, equals(20));
    expect(image.height, equals(20));
    ByteData data = await image.toByteData();

    int getPixel(int x, int y) => data.getUint32((x + y * image.width) * 4);

    expect(data.lengthInBytes, equals(20 * 20 * 4));
    expect(data.elementSizeInBytes, equals(1));
    expect(getPixel(0, 0), equals(0x00000080));
    expect(getPixel(image.width - 1, 0 ), equals(0xffffffff));

    final OffsetLayer layer = boundary.layer;

    image = await layer.toImage(Offset.zero & const Size(20.0, 20.0));
    expect(image.width, equals(20));
    expect(image.height, equals(20));
    data = await image.toByteData();
    expect(getPixel(0, 0), equals(0x00000080));
    expect(getPixel(image.width - 1, 0 ), equals(0xffffffff));

    // non-zero offsets.
    image = await layer.toImage(const Offset(-10.0, -10.0) & const Size(30.0, 30.0));
    expect(image.width, equals(30));
    expect(image.height, equals(30));
    data = await image.toByteData();
    expect(getPixel(0, 0), equals(0x00000000));
    expect(getPixel(10, 10), equals(0x00000080));
    expect(getPixel(image.width - 1, 0), equals(0x00000000));
    expect(getPixel(image.width - 1, 10), equals(0xffffffff));

    // offset combined with a custom pixel ratio.
    image = await layer.toImage(const Offset(-10.0, -10.0) & const Size(30.0, 30.0), pixelRatio: 2.0);
    expect(image.width, equals(60));
    expect(image.height, equals(60));
    data = await image.toByteData();
    expect(getPixel(0, 0), equals(0x00000000));
    expect(getPixel(20, 20), equals(0x00000080));
    expect(getPixel(image.width - 1, 0), equals(0x00000000));
    expect(getPixel(image.width - 1, 20), equals(0xffffffff));
  }, skip: ui.isWeb);

  test('RenderOpacity does not composite if it is transparent', () {
    final RenderOpacity renderOpacity = RenderOpacity(
      opacity: 0.0,
      child: RenderSizedBox(const Size(1.0, 1.0)), // size doesn't matter
    );

    layout(renderOpacity, phase: EnginePhase.composite);
    expect(renderOpacity.needsCompositing, false);
  });

  test('RenderOpacity does not composite if it is opaque', () {
    final RenderOpacity renderOpacity = RenderOpacity(
      opacity: 1.0,
      child: RenderSizedBox(const Size(1.0, 1.0)), // size doesn't matter
    );

    layout(renderOpacity, phase: EnginePhase.composite);
    expect(renderOpacity.needsCompositing, false);
  });

  test('RenderAnimatedOpacity does not composite if it is transparent', () async {
    final Animation<double> opacityAnimation = AnimationController(
      vsync: _FakeTickerProvider(),
    )..value = 0.0;

    final RenderAnimatedOpacity renderAnimatedOpacity = RenderAnimatedOpacity(
      alwaysIncludeSemantics: false,
      opacity: opacityAnimation,
      child: RenderSizedBox(const Size(1.0, 1.0)), // size doesn't matter
    );

    layout(renderAnimatedOpacity, phase: EnginePhase.composite);
    expect(renderAnimatedOpacity.needsCompositing, false);
  });

  test('RenderAnimatedOpacity does not composite if it is opaque', () {
    final Animation<double> opacityAnimation = AnimationController(
      vsync: _FakeTickerProvider(),
    )..value = 1.0;

    final RenderAnimatedOpacity renderAnimatedOpacity = RenderAnimatedOpacity(
      alwaysIncludeSemantics: false,
      opacity: opacityAnimation,
      child: RenderSizedBox(const Size(1.0, 1.0)), // size doesn't matter
    );

    layout(renderAnimatedOpacity, phase: EnginePhase.composite);
    expect(renderAnimatedOpacity.needsCompositing, false);
  });
}

class _FakeTickerProvider implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick, [ bool disableAnimations = false ]) {
    return _FakeTicker();
  }
}

class _FakeTicker implements Ticker {
  @override
  bool muted;

  @override
  void absorbTicker(Ticker originalTicker) { }

  @override
  String get debugLabel => null;

  @override
  bool get isActive => null;

  @override
  bool get isTicking => null;

  @override
  bool get scheduled => null;

  @override
  bool get shouldScheduleTick => null;

  @override
  void dispose() { }

  @override
  void scheduleTick({ bool rescheduling = false }) { }

  @override
  TickerFuture start() {
    return null;
  }

  @override
  void stop({ bool canceled = false }) { }

  @override
  void unscheduleTick() { }

  @override
  String toString({ bool debugIncludeStack = false }) => super.toString();
}
