// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/rendering.dart';
import '../flutter_test_alternative.dart';

import 'rendering_tester.dart';

int layouts = 0;

class RenderLayoutWatcher extends RenderProxyBox {
  RenderLayoutWatcher(RenderBox child) : super(child);
  @override
  void performLayout() {
    layouts += 1;
    super.performLayout();
  }
}

void main() {
  test('RenderViewport basic test - impact of layout', () {
    RenderSliverToBoxAdapter sliver;
    RenderViewport viewport;
    RenderBox box;
    final RenderObject root = RenderLayoutWatcher(
      viewport = RenderViewport(
        crossAxisDirection: AxisDirection.right,
        offset: ViewportOffset.zero(),
        children: <RenderSliver>[
          sliver = RenderSliverToBoxAdapter(child: box = RenderSizedBox(const Size(100.0, 400.0))),
        ],
      ),
    );
    expect(layouts, 0);
    layout(root);
    expect(layouts, 1);
    expect(box.localToGlobal(box.size.center(Offset.zero)), const Offset(400.0, 200.0));

    sliver.child = box = RenderSizedBox(const Size(100.0, 300.0));
    expect(layouts, 1);
    pumpFrame();
    expect(layouts, 1);
    expect(box.localToGlobal(box.size.center(Offset.zero)), const Offset(400.0, 150.0));

    viewport.offset = ViewportOffset.fixed(20.0);
    expect(layouts, 1);
    pumpFrame();
    expect(layouts, 1);
    expect(box.localToGlobal(box.size.center(Offset.zero)), const Offset(400.0, 130.0));

    viewport.offset = ViewportOffset.fixed(-20.0);
    expect(layouts, 1);
    pumpFrame();
    expect(layouts, 1);
    expect(box.localToGlobal(box.size.center(Offset.zero)), const Offset(400.0, 170.0));

    viewport.anchor = 20.0 / 600.0;
    expect(layouts, 1);
    pumpFrame();
    expect(layouts, 1);
    expect(box.localToGlobal(box.size.center(Offset.zero)), const Offset(400.0, 190.0));

    viewport.axisDirection = AxisDirection.up;
    expect(layouts, 1);
    pumpFrame();
    expect(layouts, 1);
    expect(box.localToGlobal(box.size.center(Offset.zero)), const Offset(400.0, 600.0 - 190.0));
  });

}
