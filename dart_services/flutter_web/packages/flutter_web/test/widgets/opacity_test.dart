// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/io.dart';
import 'package:flutter_web_ui/ui.dart';

import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/material.dart';

import '../rendering/mock_canvas.dart';
import 'semantics_tester.dart';

void main() {
  testWidgets('Opacity', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    // Opacity 1.0: Semantics and painting
    await tester.pumpWidget(
      const Opacity(
        child: Text('a', textDirection: TextDirection.rtl),
        opacity: 1.0,
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
            label: 'a',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ));
    expect(find.byType(Opacity), paints..paragraph());

    // Opacity 0.0: Nothing
    await tester.pumpWidget(
      const Opacity(
        child: Text('a', textDirection: TextDirection.rtl),
        opacity: 0.0,
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(),
    ));
    expect(find.byType(Opacity), paintsNothing);

    // Opacity 0.0 with semantics: Just semantics
    await tester.pumpWidget(
      const Opacity(
        child: Text('a', textDirection: TextDirection.rtl),
        opacity: 0.0,
        alwaysIncludeSemantics: true,
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
            label: 'a',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ));
    expect(find.byType(Opacity), paintsNothing);

    // Opacity 0.0 without semantics: Nothing
    await tester.pumpWidget(
      const Opacity(
        child: Text('a', textDirection: TextDirection.rtl),
        opacity: 0.0,
        alwaysIncludeSemantics: false,
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(),
    ));
    expect(find.byType(Opacity), paintsNothing);

    // Opacity 0.1: Semantics and painting
    await tester.pumpWidget(
      const Opacity(
        child: Text('a', textDirection: TextDirection.rtl),
        opacity: 0.1,
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
            label: 'a',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ));
    expect(find.byType(Opacity), paints..paragraph());

    // Opacity 0.1 without semantics: Still has semantics and painting
    await tester.pumpWidget(
      const Opacity(
        child: Text('a', textDirection: TextDirection.rtl),
        opacity: 0.1,
        alwaysIncludeSemantics: false,
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
            label: 'a',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ));
    expect(find.byType(Opacity), paints..paragraph());

    // Opacity 0.1 with semantics: Semantics and painting
    await tester.pumpWidget(
      const Opacity(
        child: Text('a', textDirection: TextDirection.rtl),
        opacity: 0.1,
        alwaysIncludeSemantics: true,
      ),
    );
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics.rootChild(
            id: 1,
            rect: const Rect.fromLTRB(0.0, 0.0, 800.0, 600.0),
            label: 'a',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    ));
    expect(find.byType(Opacity), paints..paragraph());

    semantics.dispose();
  });

  testWidgets('offset is correctly handled in Opacity', (WidgetTester tester) async {
    await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RepaintBoundary(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List<Widget>.generate(10, (int index) {
                    return Opacity(
                      opacity: 0.5,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          color: Colors.blue,
                          height: 50,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        )
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('opacity_test.offset.1.png'),
      skip: !Platform.isLinux,
    );
  }, skip: true);

  testWidgets('empty opacity does not crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      RepaintBoundary(child: Opacity(opacity: 0.5, child: Container())),
    );
    final Element element = find.byType(RepaintBoundary).first.evaluate().single;
    // The following line will send the layer to engine and cause crash if an
    // empty opacity layer is sent.
    final OffsetLayer offsetLayer = element.renderObject.layer;
    await offsetLayer.toImage(const Rect.fromLTRB(0.0, 0.0, 1.0, 1.0));
  }, skip: true);
}
