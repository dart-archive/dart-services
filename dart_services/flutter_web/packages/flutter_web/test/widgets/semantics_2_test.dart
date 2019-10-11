// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

import 'semantics_tester.dart';

void main() {
  testWidgets('Semantics 2', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    // this test is the same as the test in Semantics 1, but
    // starting with the second branch being ignored and then
    // switching to not ignoring it.

    // forking semantics
    await tester.pumpWidget(
      Semantics(
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 10.0,
              child: Semantics(
                label: 'child1',
                textDirection: TextDirection.ltr,
                selected: true,
              ),
            ),
            Container(
              height: 10.0,
              child: IgnorePointer(
                ignoring: false,
                child: Semantics(
                  label: 'child2',
                  textDirection: TextDirection.ltr,
                  selected: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    expect(
        semantics,
        hasSemantics(
            TestSemantics.root(
              children: <TestSemantics>[
                TestSemantics.rootChild(
                  id: 1,
                  rect: TestSemantics.fullScreen,
                  children: <TestSemantics>[
                    TestSemantics(
                      id: 2,
                      label: 'child1',
                      rect: Rect.fromLTRB(0.0, 0.0, 800.0, 10.0),
                      flags: SemanticsFlag.isSelected.index,
                    ),
                    TestSemantics(
                      id: 3,
                      label: 'child2',
                      rect: Rect.fromLTRB(0.0, 0.0, 800.0, 10.0),
                      flags: SemanticsFlag.isSelected.index,
                    ),
                  ],
                ),
              ],
            ),
            ignoreTransform: true));

    // toggle a branch off
    await tester.pumpWidget(
      Semantics(
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 10.0,
              child: Semantics(
                label: 'child1',
                textDirection: TextDirection.ltr,
                selected: true,
              ),
            ),
            Container(
              height: 10.0,
              child: IgnorePointer(
                ignoring: true,
                child: Semantics(
                  label: 'child2',
                  textDirection: TextDirection.ltr,
                  selected: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    expect(
        semantics,
        hasSemantics(TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 1,
              label: 'child1',
              rect: TestSemantics.fullScreen,
              flags: SemanticsFlag.isSelected.index,
            )
          ],
        )));

    // toggle a branch back on
    await tester.pumpWidget(
      Semantics(
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 10.0,
              child: Semantics(
                label: 'child1',
                textDirection: TextDirection.ltr,
                selected: true,
              ),
            ),
            Container(
              height: 10.0,
              child: IgnorePointer(
                ignoring: false,
                child: Semantics(
                  label: 'child2',
                  textDirection: TextDirection.ltr,
                  selected: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    expect(
        semantics,
        hasSemantics(
            TestSemantics.root(
              children: <TestSemantics>[
                TestSemantics.rootChild(
                  id: 1,
                  rect: TestSemantics.fullScreen,
                  children: <TestSemantics>[
                    TestSemantics(
                      id: 4,
                      label: 'child1',
                      rect: Rect.fromLTRB(0.0, 0.0, 800.0, 10.0),
                      flags: SemanticsFlag.isSelected.index,
                    ),
                    TestSemantics(
                      id: 3,
                      label: 'child2',
                      rect: Rect.fromLTRB(0.0, 0.0, 800.0, 10.0),
                      flags: SemanticsFlag.isSelected.index,
                    ),
                  ],
                ),
              ],
            ),
            ignoreTransform: true));

    semantics.dispose();
  });
}
