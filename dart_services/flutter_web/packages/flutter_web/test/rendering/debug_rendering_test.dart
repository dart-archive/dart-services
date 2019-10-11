// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/rendering.dart';
import 'package:vector_math/vector_math_64.dart';

import '../flutter_test_alternative.dart';
import 'mock_canvas.dart';
import 'rendering_tester.dart';

void main() {
  test('Describe transform control test', () {
    final Matrix4 identity = Matrix4.identity();
    final List<String> description = debugDescribeTransform(identity);
    expect(description, equals(<String>[
      '[0] 1.0,0.0,0.0,0.0',
      '[1] 0.0,1.0,0.0,0.0',
      '[2] 0.0,0.0,1.0,0.0',
      '[3] 0.0,0.0,0.0,1.0',
    ]));
  });

  test('transform property test', () {
    final Matrix4 transform = Matrix4.diagonal3(Vector3.all(2.0));
    final TransformProperty simple = TransformProperty(
      'transform',
      transform,
    );
    expect(simple.name, equals('transform'));
    expect(simple.value, same(transform));
    expect(
      simple.toString(parentConfiguration: sparseTextConfiguration),
      equals(
        'transform:\n'
        '  [0] 2.0,0.0,0.0,0.0\n'
        '  [1] 0.0,2.0,0.0,0.0\n'
        '  [2] 0.0,0.0,2.0,0.0\n'
        '  [3] 0.0,0.0,0.0,1.0',
      ),
    );
    expect(
      simple.toString(parentConfiguration: singleLineTextConfiguration),
      equals('transform: [2.0,0.0,0.0,0.0; 0.0,2.0,0.0,0.0; 0.0,0.0,2.0,0.0; 0.0,0.0,0.0,1.0]'),
    );

    final TransformProperty nullProperty = TransformProperty(
      'transform',
      null,
    );
    expect(nullProperty.name, equals('transform'));
    expect(nullProperty.value, isNull);
    expect(nullProperty.toString(), equals('transform: null'));

    final TransformProperty hideNull = TransformProperty(
      'transform',
      null,
      defaultValue: null,
    );
    expect(hideNull.value, isNull);
    expect(hideNull.toString(), equals('transform: null'));
  });

  test('debugPaintPadding', () {
    expect((Canvas canvas) {
      debugPaintPadding(canvas, Rect.fromLTRB(10.0, 10.0, 20.0, 20.0), null);
    }, paints..rect(color: const Color(0x90909090)));
    expect((Canvas canvas) {
      debugPaintPadding(canvas, Rect.fromLTRB(10.0, 10.0, 20.0, 20.0), Rect.fromLTRB(11.0, 11.0, 19.0, 19.0));
    }, paints..path(color: const Color(0x900090FF))..path(color: const Color(0xFF0090FF)));
    expect((Canvas canvas) {
      debugPaintPadding(canvas, Rect.fromLTRB(10.0, 10.0, 20.0, 20.0), Rect.fromLTRB(15.0, 15.0, 15.0, 15.0));
    }, paints..rect(rect: Rect.fromLTRB(10.0, 10.0, 20.0, 20.0), color: const Color(0x90909090)));
  });

  test('debugPaintPadding from render objects', () {
    debugPaintSizeEnabled = true;
    RenderSliver s;
    RenderBox b;
    final RenderViewport root = RenderViewport(
      crossAxisDirection: AxisDirection.right,
      offset: ViewportOffset.zero(),
      children: <RenderSliver>[
        s = RenderSliverPadding(
          padding: const EdgeInsets.all(10.0),
          child: RenderSliverToBoxAdapter(
            child: b = RenderPadding(
              padding: const EdgeInsets.all(10.0),
            ),
          ),
        ),
      ],
    );
    layout(root);
    expect(b.debugPaint, paints..rect(color: const Color(0xFF00FFFF))..rect(color: const Color(0x90909090)));
    expect(b.debugPaint, isNot(paints..path()));
    expect(s.debugPaint, paints..circle(hasMaskFilter: true)..line(hasMaskFilter: true)..path(hasMaskFilter: true)..path(hasMaskFilter: true)
                               ..path(color: const Color(0x900090FF))..path(color: const Color(0xFF0090FF)));
    expect(s.debugPaint, isNot(paints..rect()));
    debugPaintSizeEnabled = false;
  });

  test('debugPaintPadding from render objects', () {
    debugPaintSizeEnabled = true;
    RenderSliver s;
    final RenderBox b = RenderPadding(
      padding: const EdgeInsets.all(10.0),
      child: RenderViewport(
        crossAxisDirection: AxisDirection.right,
        offset: ViewportOffset.zero(),
        children: <RenderSliver>[
          s = RenderSliverPadding(
            padding: const EdgeInsets.all(10.0),
          ),
        ],
      ),
    );
    layout(b);
    expect(s.debugPaint, paints..rect(color: const Color(0x90909090)));
    expect(s.debugPaint, isNot(paints..circle(hasMaskFilter: true)..line(hasMaskFilter: true)..path(hasMaskFilter: true)..path(hasMaskFilter: true)
                                     ..path(color: const Color(0x900090FF))..path(color: const Color(0xFF0090FF))));
    expect(b.debugPaint, paints..rect(color: const Color(0xFF00FFFF))..path(color: const Color(0x900090FF))..path(color: const Color(0xFF0090FF)));
    expect(b.debugPaint, isNot(paints..rect(color: const Color(0x90909090))));
    debugPaintSizeEnabled = false;
  });
}
