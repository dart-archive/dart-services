// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_ui/ui.dart';

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web/material.dart';

import 'semantics_tester.dart';

void main() {
  group('Sliver Semantics', () {
    setUp(() {
      debugResetSemanticsIdCounter();
    });

    _tests();
  });
}

void _tests() {
  testWidgets('excludeFromScrollable works correctly', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    const double appBarExpandedHeight = 200.0;

    final ScrollController scrollController = ScrollController();
    final List<Widget> listChildren = List<Widget>.generate(30, (int i) {
      return Container(
        height: appBarExpandedHeight,
        child: Text('Item $i'),
      );
    });
    await tester.pumpWidget(
      Semantics(
        textDirection: TextDirection.ltr,
        child: Localizations(
          locale: const Locale('en', 'us'),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: const MediaQueryData(),
              child: CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  const SliverAppBar(
                    pinned: true,
                    expandedHeight: appBarExpandedHeight,
                    title: Text('Semantics Test with Slivers'),
                  ),
                   SliverList(
                    delegate: SliverChildListDelegate(listChildren),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // AppBar is child of node with semantic scroll actions.
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            id: 1,
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                id: 2,
                children: <TestSemantics>[
                  TestSemantics(
                    id: 9,
                    flags: <SemanticsFlag>[
                      SemanticsFlag.hasImplicitScrolling,
                    ],
                    actions: <SemanticsAction>[SemanticsAction.scrollUp],
                    children: <TestSemantics>[
                      TestSemantics(
                        id: 7,
                        children: <TestSemantics>[
                          TestSemantics(
                            id: 8,
                            flags: <SemanticsFlag>[
                              SemanticsFlag.namesRoute,
                              SemanticsFlag.isHeader,
                            ],
                            label: 'Semantics Test with Slivers',
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                      TestSemantics(
                        id: 3,
                        label: 'Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        id: 4,
                        label: 'Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        id: 5,
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        id: 6,
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ignoreRect: true,
      ignoreTransform: true,
    ));

    // Scroll down far enough to reach the pinned state of the app bar.
    scrollController.jumpTo(appBarExpandedHeight);
    await tester.pump();

    // App bar is NOT a child of node with semantic scroll actions.
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            id: 1,
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                id: 2,
                children: <TestSemantics>[
                  TestSemantics(
                    id: 7,
                    tags: <SemanticsTag>[RenderViewport.excludeFromScrolling],
                    children: <TestSemantics>[
                      TestSemantics(
                        id: 8,
                        flags: <SemanticsFlag>[
                          SemanticsFlag.namesRoute,
                          SemanticsFlag.isHeader,
                        ],
                        label: 'Semantics Test with Slivers',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  TestSemantics(
                    id: 9,
                    actions: <SemanticsAction>[
                      SemanticsAction.scrollUp,
                      SemanticsAction.scrollDown,
                    ],
                    children: <TestSemantics>[
                      TestSemantics(
                        id: 3,
                        label: 'Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        id: 4,
                        label: 'Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        id: 5,
                        label: 'Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        id: 6,
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        id: 10,
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 4',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ignoreRect: true,
      ignoreTransform: true,
    ));

    // Scroll halfway back to the top, app bar is no longer in pinned state.
    scrollController.jumpTo(appBarExpandedHeight / 2);
    await tester.pump();

    // AppBar is child of node with semantic scroll actions.
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            id: 1,
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                id: 2,
                children: <TestSemantics>[
                  TestSemantics(
                    id: 9,
                    flags: <SemanticsFlag>[
                      SemanticsFlag.hasImplicitScrolling,
                    ],
                    actions: <SemanticsAction>[
                      SemanticsAction.scrollUp,
                      SemanticsAction.scrollDown,
                    ],
                    children: <TestSemantics>[
                      TestSemantics(
                        id: 7,
                        children: <TestSemantics>[
                          TestSemantics(
                            id: 8,
                            flags: <SemanticsFlag>[
                              SemanticsFlag.namesRoute,
                              SemanticsFlag.isHeader,
                            ],
                            label: 'Semantics Test with Slivers',
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                      TestSemantics(
                        id: 3,
                        label: 'Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        id: 4,
                        label: 'Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        id: 5,
                        label: 'Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        id: 6,
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ignoreRect: true,
      ignoreTransform: true,
    ));

    semantics.dispose();
  });

  testWidgets('Offscreen sliver are hidden in semantics tree', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    const double containerHeight = 200.0;

    final ScrollController scrollController = ScrollController(
      initialScrollOffset: containerHeight * 1.5,
    );
    final List<Widget> slivers = List<Widget>.generate(30, (int i) {
      return SliverToBoxAdapter(
        child: Container(
          height: containerHeight,
          child: Text('Item $i', textDirection: TextDirection.ltr),
        ),
      );
    });
    await tester.pumpWidget(
      Semantics(
        textDirection: TextDirection.ltr,
        child: Localizations(
          locale: const Locale('en', 'us'),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                height: containerHeight,
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: slivers,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                children: <TestSemantics>[
                  TestSemantics(
                    flags: <SemanticsFlag>[
                      SemanticsFlag.hasImplicitScrolling,
                    ],
                    actions: <SemanticsAction>[
                      SemanticsAction.scrollUp,
                      SemanticsAction.scrollDown,
                    ],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ignoreRect: true,
      ignoreTransform: true,
      ignoreId: true,
    ));

    semantics.dispose();
  });

  testWidgets('SemanticsNodes of Slivers are in paint order', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    final List<Widget> slivers = List<Widget>.generate(5, (int i) {
      return SliverToBoxAdapter(
        child: Container(
          height: 20.0,
          child: Text('Item $i'),
        ),
      );
    });
    await tester.pumpWidget(
      Semantics(
        textDirection: TextDirection.ltr,
        child: Localizations(
          locale: const Locale('en', 'us'),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: CustomScrollView(
              slivers: slivers,
            ),
          ),
        ),
      ),
    );

    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                children: <TestSemantics>[
                  TestSemantics(
                    flags: <SemanticsFlag>[
                      SemanticsFlag.hasImplicitScrolling,
                    ],
                    children: <TestSemantics>[
                      TestSemantics(
                        label: 'Item 4',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ignoreRect: true,
      ignoreTransform: true,
      ignoreId: true,
      childOrder: DebugSemanticsDumpOrder.inverseHitTest,
    ));

    semantics.dispose();
  });

  testWidgets('SemanticsNodes of a sliver fully covered by another overlapping sliver are excluded', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    final List<Widget> listChildren = List<Widget>.generate(10, (int i) {
      return Container(
        height: 200.0,
        child: Text('Item $i', textDirection: TextDirection.ltr),
      );
    });
    final ScrollController controller = ScrollController(initialScrollOffset: 280.0);
    await tester.pumpWidget(Semantics(
      textDirection: TextDirection.ltr,
      child: Localizations(
        locale: const Locale('en', 'us'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: CustomScrollView(
              slivers: <Widget>[
                const SliverAppBar(
                  pinned: true,
                  expandedHeight: 100.0,
                  title: Text('AppBar'),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(listChildren),
                ),
              ],
              controller: controller,
            ),
          ),
        ),
      ),
    ));

    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                children: <TestSemantics>[
                  TestSemantics(
                    tags: <SemanticsTag>[RenderViewport.excludeFromScrolling],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[
                          SemanticsFlag.namesRoute,
                          SemanticsFlag.isHeader,
                        ],
                        label: 'AppBar',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  TestSemantics(
                    actions: <SemanticsAction>[
                      SemanticsAction.scrollUp,
                      SemanticsAction.scrollDown,
                    ],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 4',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 5',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ignoreTransform: true,
      ignoreId: true,
      ignoreRect: true,
    ));

    semantics.dispose();
  });

  testWidgets('Slivers fully covered by another overlapping sliver are hidden', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    final ScrollController controller = ScrollController(initialScrollOffset: 280.0);
    final List<Widget> slivers = List<Widget>.generate(10, (int i) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200.0,
          child: Text('Item $i', textDirection: TextDirection.ltr),
        ),
      );
    });
    await tester.pumpWidget(Semantics(
      textDirection: TextDirection.ltr,
      child: Localizations(
        locale: const Locale('en', 'us'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: CustomScrollView(
              controller: controller,
              slivers: <Widget>[
                const SliverAppBar(
                  pinned: true,
                  expandedHeight: 100.0,
                  title: Text('AppBar'),
                ),
              ]..addAll(slivers),
            ),
          ),
        ),
      ),
    ));

    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                children: <TestSemantics>[
                  TestSemantics(
                    tags: <SemanticsTag>[RenderViewport.excludeFromScrolling],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[
                          SemanticsFlag.namesRoute,
                          SemanticsFlag.isHeader,
                        ],
                        label: 'AppBar',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  TestSemantics(
                    actions: <SemanticsAction>[
                      SemanticsAction.scrollUp,
                      SemanticsAction.scrollDown,
                    ],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 4',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 5',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ignoreTransform: true,
      ignoreRect: true,
      ignoreId: true,
    ));

    semantics.dispose();
  });

  testWidgets('SemanticsNodes of a sliver fully covered by another overlapping sliver are excluded (reverse)', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    final List<Widget> listChildren = List<Widget>.generate(10, (int i) {
      return Container(
        height: 200.0,
        child: Text('Item $i', textDirection: TextDirection.ltr),
      );
    });
    final ScrollController controller = ScrollController(initialScrollOffset: 280.0);
    await tester.pumpWidget(Semantics(
      textDirection: TextDirection.ltr,
      child: Localizations(
        locale: const Locale('en', 'us'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: CustomScrollView(
              reverse: true, // This is the important setting for this test.
              slivers: <Widget>[
                const SliverAppBar(
                  pinned: true,
                  expandedHeight: 100.0,
                  title: Text('AppBar'),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(listChildren),
                ),
              ],
              controller: controller,
            ),
          ),
        ),
      ),
    ));

    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                children: <TestSemantics>[
                  TestSemantics(
                    flags: <SemanticsFlag>[
                      SemanticsFlag.hasImplicitScrolling,
                    ],
                    actions: <SemanticsAction>[
                      SemanticsAction.scrollUp,
                      SemanticsAction.scrollDown,
                    ],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 5',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 4',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  TestSemantics(
                    tags: <SemanticsTag>[RenderViewport.excludeFromScrolling],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[
                          SemanticsFlag.namesRoute,
                          SemanticsFlag.isHeader,
                        ],
                        label: 'AppBar',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ignoreTransform: true,
      ignoreId: true,
      ignoreRect: true,
    ));

    semantics.dispose();
  });

  testWidgets('Slivers fully covered by another overlapping sliver are hidden (reverse)', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    final ScrollController controller = ScrollController(initialScrollOffset: 280.0);
    final List<Widget> slivers = List<Widget>.generate(10, (int i) {
      return SliverToBoxAdapter(
        child: Container(
          height: 200.0,
          child: Text('Item $i', textDirection: TextDirection.ltr),
        ),
      );
    });
    await tester.pumpWidget(Semantics(
      textDirection: TextDirection.ltr,
      child: Localizations(
        locale: const Locale('en', 'us'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
        ],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: CustomScrollView(
              reverse: true, // This is the important setting for this test.
              controller: controller,
              slivers: <Widget>[
                const SliverAppBar(
                  pinned: true,
                  expandedHeight: 100.0,
                  title: Text('AppBar'),
                ),
              ]..addAll(slivers),
            ),
          ),
        ),
      ),
    ));

    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                children: <TestSemantics>[
                  TestSemantics(
                    flags: <SemanticsFlag>[
                      SemanticsFlag.hasImplicitScrolling,
                    ],
                    actions: <SemanticsAction>[
                      SemanticsAction.scrollUp,
                      SemanticsAction.scrollDown,
                    ],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 5',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 4',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  TestSemantics(
                    tags: <SemanticsTag>[RenderViewport.excludeFromScrolling],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[
                          SemanticsFlag.namesRoute,
                          SemanticsFlag.isHeader,
                        ],
                        label: 'AppBar',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ignoreTransform: true,
      ignoreId: true,
      ignoreRect: true,
    ));

    semantics.dispose();
  });

  testWidgets('Slivers fully covered by another overlapping sliver are hidden (with center sliver)', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    final ScrollController controller = ScrollController(initialScrollOffset: 280.0);
    final GlobalKey forwardAppBarKey = GlobalKey(debugLabel: 'forward app bar');
    final List<Widget> forwardChildren = List<Widget>.generate(10, (int i) {
      return Container(
        height: 200.0,
        child: Text('Forward Item $i', textDirection: TextDirection.ltr),
      );
    });
    final List<Widget> backwardChildren = List<Widget>.generate(10, (int i) {
      return Container(
        height: 200.0,
        child: Text('Backward Item $i', textDirection: TextDirection.ltr),
      );
    });
    await tester.pumpWidget(Semantics(
      textDirection: TextDirection.ltr,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Localizations(
          locale: const Locale('en', 'us'),
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          child: MediaQuery(
            data: const MediaQueryData(),
            child: Scrollable(
              controller: controller,
              viewportBuilder: (BuildContext context, ViewportOffset offset) {
                return Viewport(
                  offset: offset,
                  center: forwardAppBarKey,
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(backwardChildren),
                    ),
                    const SliverAppBar(
                      pinned: true,
                      expandedHeight: 100.0,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text('Backward app bar', textDirection: TextDirection.ltr),
                      ),
                    ),
                    SliverAppBar(
                      pinned: true,
                      key: forwardAppBarKey,
                      expandedHeight: 100.0,
                      flexibleSpace: const FlexibleSpaceBar(
                        title: Text('Forward app bar', textDirection: TextDirection.ltr),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(forwardChildren),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    ));

    // 'Forward Item 0' is covered by app bar.
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                children: <TestSemantics>[
                  TestSemantics(
                    tags: <SemanticsTag>[RenderViewport.excludeFromScrolling],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[
                          SemanticsFlag.namesRoute,
                          SemanticsFlag.isHeader,
                        ],
                        label: 'Forward app bar',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  TestSemantics(
                    actions: <SemanticsAction>[
                      SemanticsAction.scrollUp,
                      SemanticsAction.scrollDown,
                    ],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Forward Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Forward Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Forward Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Forward Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Forward Item 4',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Forward Item 5',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ignoreTransform: true,
      ignoreRect: true,
      ignoreId: true,
    ));

    controller.jumpTo(-880.0);
    await tester.pumpAndSettle();

    // 'Backward Item 0' is covered by app bar.
    expect(semantics, hasSemantics(
      TestSemantics.root(
        children: <TestSemantics>[
          TestSemantics(
            textDirection: TextDirection.ltr,
            children: <TestSemantics>[
              TestSemantics(
                children: <TestSemantics>[
                  TestSemantics(
                    flags: <SemanticsFlag>[
                      SemanticsFlag.hasImplicitScrolling,
                    ],
                    actions: <SemanticsAction>[
                      SemanticsAction.scrollUp,
                      SemanticsAction.scrollDown,
                    ],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Backward Item 5',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Backward Item 4',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Backward Item 3',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Backward Item 2',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        label: 'Backward Item 1',
                        textDirection: TextDirection.ltr,
                      ),
                      TestSemantics(
                        flags: <SemanticsFlag>[SemanticsFlag.isHidden],
                        label: 'Backward Item 0',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  TestSemantics(
                    tags: <SemanticsTag>[RenderViewport.excludeFromScrolling],
                    children: <TestSemantics>[
                      TestSemantics(
                        flags: <SemanticsFlag>[
                          SemanticsFlag.namesRoute,
                          SemanticsFlag.isHeader,
                        ],
                        label: 'Backward app bar',
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ), ignoreTransform: true, ignoreRect: true, ignoreId: true,
    ));

    semantics.dispose();
  });

}
