// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web/rendering.dart';
import 'package:test/test.dart' as test;

class TestFlowDelegate extends FlowDelegate {
  TestFlowDelegate({this.startOffset}) : super(repaint: startOffset);

  final Animation<double> startOffset;

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double dy = startOffset.value;
    for (int i = 0; i < context.childCount; ++i) {
      context.paintChild(i, transform: Matrix4.translationValues(0.0, dy, 0.0));
      dy += 0.75 * context.getChildSize(i).height;
    }
  }

  @override
  bool shouldRepaint(TestFlowDelegate oldDelegate) =>
      startOffset == oldDelegate.startOffset;
}

class OpacityFlowDelegate extends FlowDelegate {
  OpacityFlowDelegate(this.opacity);

  double opacity;

  @override
  void paintChildren(FlowPaintingContext context) {
    for (int i = 0; i < context.childCount; ++i) {
      context.paintChild(i, opacity: opacity);
    }
  }

  @override
  bool shouldRepaint(OpacityFlowDelegate oldDelegate) =>
      opacity != oldDelegate.opacity;
}

void main() {
  testWidgets('Flow control test', (WidgetTester tester) async {
    final AnimationController startOffset = AnimationController.unbounded(
      vsync: tester,
    );
    final List<int> log = <int>[];

    Widget buildBox(int i) {
      return GestureDetector(
          onTap: () {
            log.add(i);
          },
          child: Container(
              width: 100.0,
              height: 100.0,
              color: const Color(0xFF0000FF),
              child: Text('$i', textDirection: TextDirection.ltr)));
    }

    await tester.pumpWidget(Flow(
        delegate: TestFlowDelegate(startOffset: startOffset),
        children: <Widget>[
          buildBox(0),
          buildBox(1),
          buildBox(2),
          buildBox(3),
          buildBox(4),
          buildBox(5),
          buildBox(6),
        ]));

    await tester.tap(find.text('0'));
    expect(log, equals(<int>[0]));
    await tester.tap(find.text('1'));
    expect(log, equals(<int>[0, 1]));
    await tester.tap(find.text('2'));
    expect(log, equals(<int>[0, 1, 2]));

    log.clear();
    await tester.tapAt(const Offset(20.0, 90.0));
    expect(log, equals(<int>[1]));

    startOffset.value = 50.0;
    await tester.pump();

    log.clear();
    await tester.tapAt(const Offset(20.0, 90.0));
    expect(log, equals(<int>[0]));
  });

  testWidgets('Flow opacity layer', (WidgetTester tester) async {
    const double opacity = 0.2;
    await tester.pumpWidget(
        Flow(delegate: OpacityFlowDelegate(opacity), children: <Widget>[
      Container(width: 100.0, height: 100.0),
    ]));
    ContainerLayer layer = RendererBinding.instance.renderView.debugLayer;
    while (layer != null && !(layer is OpacityLayer)) layer = layer.firstChild;
    expect(layer, isInstanceOf<OpacityLayer>());
    final OpacityLayer opacityLayer = layer;
    expect(opacityLayer.alpha, equals(opacity * 255));
    expect(layer.firstChild, new test.TypeMatcher<TransformLayer>());
  });
}
