// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import '../flutter_test_alternative.dart';

import 'rendering_tester.dart';

void main() {
  test('overflow should not affect baseline', () {
    RenderBox root, child, text;
    double baseline1, baseline2, height1, height2;

    root = RenderPositionedBox(
      child: RenderCustomPaint(
        child: child = text = RenderParagraph(
          const TextSpan(text: 'Hello World'),
          textDirection: TextDirection.ltr,
        ),
        painter: TestCallbackPainter(
          onPaint: () {
            baseline1 = child.getDistanceToBaseline(TextBaseline.alphabetic);
            height1 = text.size.height;
          },
        ),
      ),
    );
    layout(root, phase: EnginePhase.paint);

    root = RenderPositionedBox(
      child: RenderCustomPaint(
        child: child = RenderConstrainedOverflowBox(
          child: text = RenderParagraph(
            const TextSpan(text: 'Hello World'),
            textDirection: TextDirection.ltr,
          ),
          maxHeight: height1 / 2.0,
          alignment: Alignment.topLeft,
        ),
        painter: TestCallbackPainter(
          onPaint: () {
            baseline2 = child.getDistanceToBaseline(TextBaseline.alphabetic);
            height2 = text.size.height;
          },
        ),
      ),
    );
    layout(root, phase: EnginePhase.paint);

    expect(baseline1, lessThan(height1));
    expect(height2, equals(height1 / 2.0));
    expect(baseline2, equals(baseline1));
    expect(baseline2, greaterThan(height2));
  });
}
