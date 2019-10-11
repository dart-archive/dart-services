// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced. * Contains Web DELTA *

import 'package:flutter_web/material.dart';
import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/rendering.dart';
import '../rendering/mock_canvas.dart';

void main() {
  testWidgets('FlatButton implements debugFillProperties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    FlatButton(
      onPressed: () { },
      textColor: const Color(0xFF00FF00),
      disabledTextColor: const Color(0xFFFF0000),
      color: const Color(0xFF000000),
      highlightColor: const Color(0xFF1565C0),
      splashColor: const Color(0xFF9E9E9E),
      child: const Text('Hello'),
    ).debugFillProperties(builder);
    final List<String> description = builder.properties
        .where((DiagnosticsNode n) => !n.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode n) => n.toString()).toList();
    expect(description, <String>[
      'textColor: Color(0xff00ff00)',
      'disabledTextColor: Color(0xffff0000)',
      'color: Color(0xff000000)',
      'highlightColor: Color(0xff1565c0)',
      'splashColor: Color(0xff9e9e9e)',
    ]);
  });

  testWidgets('Default FlatButton meets a11y contrast guidelines', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: FlatButton(
              child: const Text('FlatButton'),
              onPressed: () { },
            ),
          ),
        ),
      ),
    );

    // Default, not disabled.
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    // Highlighted (pressed).
    final Offset center = tester.getCenter(find.byType(FlatButton));
    await tester.startGesture(center);
    await tester.pump(); // Start the splash and highlight animations.
    await tester.pump(const Duration(milliseconds: 800)); // Wait for splash and highlight to be well under way.
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  },
    semanticsEnabled: true,
    skip: true, // TODO(flutter_web): enable after toImage API is supported.
  );

  testWidgets('FlatButton has no clip by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          child: FlatButton(
            child: Container(),
            onPressed: () { /* to make sure the button is enabled */ },
          ),
        ),
      ),
    );

    expect(
      tester.renderObject(find.byType(FlatButton)),
      paintsExactlyCountTimes(#clipPath, 0),
    );
  });
}
