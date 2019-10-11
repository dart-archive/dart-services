// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

import 'semantics_tester.dart';

void main() {
  testWidgets('Semantics 3', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    // implicit annotators
    await tester.pumpWidget(
      Semantics(
        container: true,
        child: Container(
          child: Semantics(
            label: 'test',
            textDirection: TextDirection.ltr,
            child: Container(
              child: Semantics(checked: true),
            ),
          ),
        ),
      ),
    );

    expect(
        semantics,
        hasSemantics(TestSemantics.root(children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            flags: SemanticsFlag.hasCheckedState.index |
                SemanticsFlag.isChecked.index,
            label: 'test',
            rect: TestSemantics.fullScreen,
          )
        ])));

    // remove one
    await tester.pumpWidget(
      Semantics(
        container: true,
        child: Container(
          child: Semantics(
            checked: true,
          ),
        ),
      ),
    );

    expect(
        semantics,
        hasSemantics(TestSemantics.root(children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            flags: SemanticsFlag.hasCheckedState.index |
                SemanticsFlag.isChecked.index,
            rect: TestSemantics.fullScreen,
          ),
        ])));

    // change what it says
    await tester.pumpWidget(
      Semantics(
        container: true,
        child: Container(
          child: Semantics(
            label: 'test',
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );

    expect(
        semantics,
        hasSemantics(TestSemantics.root(children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            label: 'test',
            textDirection: TextDirection.ltr,
            rect: TestSemantics.fullScreen,
          ),
        ])));

    // add a node
    await tester.pumpWidget(
      Semantics(
        container: true,
        child: Container(
          child: Semantics(
            checked: true,
            child: Semantics(
              label: 'test',
              textDirection: TextDirection.ltr,
            ),
          ),
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
                flags: SemanticsFlag.hasCheckedState.index |
                    SemanticsFlag.isChecked.index,
                label: 'test',
                rect: TestSemantics.fullScreen,
              )
            ],
          ),
        ));

    int changeCount = 0;
    tester.binding.pipelineOwner.semanticsOwner.addListener(() {
      changeCount += 1;
    });

    // make no changes
    await tester.pumpWidget(
      Semantics(
        container: true,
        child: Container(
          child: Semantics(
            checked: true,
            child: Semantics(
              label: 'test',
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ),
    );

    expect(changeCount, 0);

    semantics.dispose();
  });
}
