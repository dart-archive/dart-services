// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/material.dart';

const double kHeight = 10.0;
const double kFlingOffset = kHeight * 20.0;

void main() {
  testWidgets('Flings don\'t stutter', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return Container(height: kHeight);
          },
        ),
      ),
    );

    double getCurrentOffset() {
      return tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position
          .pixels;
    }

    await tester.fling(
        find.byType(ListView), const Offset(0.0, -kFlingOffset), 1000.0);
    expect(getCurrentOffset(), kFlingOffset);
    while (tester.binding.transientCallbackCount > 0) {
      final double lastOffset = getCurrentOffset();
      await tester.pump(const Duration(milliseconds: 20));
      expect(getCurrentOffset(), greaterThan(lastOffset));
    }
  }, skip: true); // see https://github.com/flutter/flutter/issues/5339
}
