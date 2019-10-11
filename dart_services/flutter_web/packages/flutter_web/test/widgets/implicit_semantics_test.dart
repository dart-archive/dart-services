// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

import 'semantics_tester.dart';

void main() {
  testWidgets('Implicit Semantics merge behavior', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Semantics(
          container: true,
          explicitChildNodes: false,
          child: Column(
            children: const <Widget>[
              Text('Michael Goderbauer'),
              Text('goderbauer@google.com'),
            ],
          ),
        ),
      ),
    );

    // SemanticsNode#0()
    //  └SemanticsNode#1(label: "Michael Goderbauer\ngoderbauer@google.com", textDirection: ltr)
    expect(
      semantics,
      hasSemantics(
        TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 1,
              label: 'Michael Goderbauer\ngoderbauer@google.com',
            ),
          ],
        ),
        ignoreRect: true,
        ignoreTransform: true,
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: Column(
            children: const <Widget>[
              Text('Michael Goderbauer'),
              Text('goderbauer@google.com'),
            ],
          ),
        ),
      ),
    );

    // SemanticsNode#0()
    //  └SemanticsNode#1()
    //    ├SemanticsNode#2(label: "Michael Goderbauer", textDirection: ltr)
    //    └SemanticsNode#3(label: "goderbauer@google.com", textDirection: ltr)
    expect(
      semantics,
      hasSemantics(
        TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 1,
              children: <TestSemantics>[
                TestSemantics(
                  id: 2,
                  label: 'Michael Goderbauer',
                ),
                TestSemantics(
                  id: 3,
                  label: 'goderbauer@google.com',
                ),
              ],
            ),
          ],
        ),
        ignoreRect: true,
        ignoreTransform: true,
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: Semantics(
            label: 'Signed in as',
            child: Column(
              children: const <Widget>[
                Text('Michael Goderbauer'),
                Text('goderbauer@google.com'),
              ],
            ),
          ),
        ),
      ),
    );

    // SemanticsNode#0()
    //  └SemanticsNode#1()
    //    └SemanticsNode#4(label: "Signed in as\nMichael Goderbauer\ngoderbauer@google.com", textDirection: ltr)
    expect(
      semantics,
      hasSemantics(
        TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 1,
              children: <TestSemantics>[
                TestSemantics(
                  id: 4,
                  label:
                      'Signed in as\nMichael Goderbauer\ngoderbauer@google.com',
                ),
              ],
            ),
          ],
        ),
        ignoreRect: true,
        ignoreTransform: true,
      ),
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Semantics(
          container: true,
          explicitChildNodes: false,
          child: Semantics(
            label: 'Signed in as',
            child: Column(
              children: const <Widget>[
                Text('Michael Goderbauer'),
                Text('goderbauer@google.com'),
              ],
            ),
          ),
        ),
      ),
    );

    // SemanticsNode#0()
    //  └SemanticsNode#1(label: "Signed in as\nMichael Goderbauer\ngoderbauer@google.com", textDirection: ltr)
    expect(
      semantics,
      hasSemantics(
        TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 1,
              label: 'Signed in as\nMichael Goderbauer\ngoderbauer@google.com',
            ),
          ],
        ),
        ignoreRect: true,
        ignoreTransform: true,
      ),
    );

    semantics.dispose();
  });

  testWidgets('Do not merge with conflicts', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Semantics(
          container: true,
          explicitChildNodes: false,
          child: Column(
            children: <Widget>[
              Semantics(
                label: 'node 1',
                selected: true,
                child: Container(
                  width: 10.0,
                  height: 10.0,
                ),
              ),
              Semantics(
                label: 'node 2',
                selected: true,
                child: Container(
                  width: 10.0,
                  height: 10.0,
                ),
              ),
              Semantics(
                label: 'node 3',
                selected: true,
                child: Container(
                  width: 10.0,
                  height: 10.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // SemanticsNode#0()
    //  └SemanticsNode#8()
    //   ├SemanticsNode#5(selected, label: "node 1", textDirection: ltr)
    //   ├SemanticsNode#6(selected, label: "node 2", textDirection: ltr)
    //   └SemanticsNode#7(selected, label: "node 3", textDirection: ltr)
    expect(
      semantics,
      hasSemantics(
        TestSemantics.root(
          children: <TestSemantics>[
            TestSemantics.rootChild(
              id: 5,
              children: <TestSemantics>[
                TestSemantics(
                  id: 6,
                  flags: SemanticsFlag.isSelected.index,
                  label: 'node 1',
                ),
                TestSemantics(
                  id: 7,
                  flags: SemanticsFlag.isSelected.index,
                  label: 'node 2',
                ),
                TestSemantics(
                  id: 8,
                  flags: SemanticsFlag.isSelected.index,
                  label: 'node 3',
                ),
              ],
            ),
          ],
        ),
        ignoreRect: true,
        ignoreTransform: true,
      ),
    );

    semantics.dispose();
  });
}
