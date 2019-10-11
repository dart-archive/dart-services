// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';

import 'package:flutter_web_test/flutter_web_test.dart';

void main() {
  testWidgets('OverflowBox control test', (WidgetTester tester) async {
    final GlobalKey inner = GlobalKey();
    await tester.pumpWidget(Align(
        alignment: const Alignment(1.0, 1.0),
        child: SizedBox(
            width: 10.0,
            height: 20.0,
            child: OverflowBox(
                minWidth: 0.0,
                maxWidth: 100.0,
                minHeight: 0.0,
                maxHeight: 50.0,
                child: Container(key: inner)))));
    final RenderBox box = inner.currentContext.findRenderObject();
    expect(box.localToGlobal(Offset.zero), equals(const Offset(745.0, 565.0)));
    expect(box.size, equals(const Size(100.0, 50.0)));
  });

  testWidgets('OverflowBox implements debugFillProperties',
      (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const OverflowBox(
            minWidth: 1.0, maxWidth: 2.0, minHeight: 3.0, maxHeight: 4.0)
        .debugFillProperties(builder);
    final List<String> description = builder.properties
        .where((DiagnosticsNode n) => !n.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode n) => n.toString())
        .toList();
    expect(description, <String>[
      'alignment: center',
      'minWidth: 1.0',
      'maxWidth: 2.0',
      'minHeight: 3.0',
      'maxHeight: 4.0',
    ]);
  });
}
