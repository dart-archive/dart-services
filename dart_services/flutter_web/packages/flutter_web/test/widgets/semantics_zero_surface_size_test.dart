// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

import 'semantics_tester.dart';

void main() {
  testWidgets('has only root node if surface size is 0x0',
      (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    await tester.pumpWidget(Semantics(
      selected: true,
    ));

    expect(
        semantics,
        hasSemantics(
          TestSemantics(
            id: 0,
            rect: Rect.fromLTRB(0.0, 0.0, 2400.0, 1800.0),
            children: <TestSemantics>[
              TestSemantics(
                id: 1,
                rect: Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
                flags: <SemanticsFlag>[SemanticsFlag.isSelected],
              ),
            ],
          ),
          ignoreTransform: true,
        ));

    await tester.binding.setSurfaceSize(const Size(0.0, 0.0));
    await tester.pumpAndSettle();

    expect(
        semantics,
        hasSemantics(
          TestSemantics(
            id: 0,
            rect: Rect.fromLTRB(0.0, 0.0, 0.0, 0.0),
          ),
          ignoreTransform: true,
        ));

    await tester.binding.setSurfaceSize(null);
    semantics.dispose();
  });
}
