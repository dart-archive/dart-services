// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-06-12T10:31:55.351773.

import 'package:flutter_web/painting.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

import '../rendering/mock_canvas.dart';
import 'common_matchers.dart';

void main() {
  test('CircleBorder', () {
    const CircleBorder c10 = CircleBorder(side: BorderSide(width: 10.0));
    const CircleBorder c15 = CircleBorder(side: BorderSide(width: 15.0));
    const CircleBorder c20 = CircleBorder(side: BorderSide(width: 20.0));
    expect(c10.dimensions, const EdgeInsets.all(10.0));
    expect(c10.scale(2.0), c20);
    expect(c20.scale(0.5), c10);
    expect(ShapeBorder.lerp(c10, c20, 0.0), c10);
    expect(ShapeBorder.lerp(c10, c20, 0.5), c15);
    expect(ShapeBorder.lerp(c10, c20, 1.0), c20);
    expect(c10.getInnerPath(Rect.fromCircle(center: Offset.zero, radius: 1.0).inflate(10.0)), isUnitCircle);
    expect(c10.getOuterPath(Rect.fromCircle(center: Offset.zero, radius: 1.0)), isUnitCircle);
    expect(
      (Canvas canvas) => c10.paint(canvas, const Rect.fromLTWH(10.0, 20.0, 30.0, 40.0)),
      paints
        ..circle(x: 25.0, y: 40.0, radius: 10.0, strokeWidth: 10.0),
    );
  });
}
