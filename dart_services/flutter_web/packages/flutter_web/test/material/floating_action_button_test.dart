// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced. * Contains Web DELTA *

// TODO(flutter_web): implement golden file tests.
import 'package:flutter_web/io.dart';
import 'package:flutter_web_ui/ui.dart';

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

import '../rendering/mock_canvas.dart';
import '../widgets/semantics_tester.dart';

void main() {
  testWidgets('Floating Action Button control test', (WidgetTester tester) async {
    bool didPressButton = false;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: FloatingActionButton(
            onPressed: () {
              didPressButton = true;
            },
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    expect(didPressButton, isFalse);
    await tester.tap(find.byType(Icon));
    expect(didPressButton, isTrue);
  });

  testWidgets('Floating Action Button tooltip', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            tooltip: 'Add',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(Icon));
    expect(find.byTooltip('Add'), findsOneWidget);
  });

  // Regression test for: https://github.com/flutter/flutter/pull/21084
  testWidgets('Floating Action Button tooltip (long press button edge)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            tooltip: 'Add',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    expect(find.text('Add'), findsNothing);
    await tester.longPressAt(_rightEdgeOfFab(tester));
    await tester.pumpAndSettle();

    expect(find.text('Add'), findsOneWidget);
  });

  // Regression test for: https://github.com/flutter/flutter/pull/21084
  testWidgets('Floating Action Button tooltip (long press button edge - no child)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            tooltip: 'Add',
          ),
        ),
      ),
    );

    expect(find.text('Add'), findsNothing);
    await tester.longPressAt(_rightEdgeOfFab(tester));
    await tester.pumpAndSettle();

    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('Floating Action Button tooltip (no child)', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            tooltip: 'Add',
          ),
        ),
      ),
    );

    expect(find.text('Add'), findsNothing);

    // Test hover for tooltip.
    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer();
    await gesture.moveTo(tester.getCenter(find.byType(FloatingActionButton)));
    await tester.pumpAndSettle();

    expect(find.text('Add'), findsOneWidget);

    await gesture.moveTo(Offset.zero);
    await gesture.removePointer();
    await tester.pumpAndSettle();

    expect(find.text('Add'), findsNothing);

    // Test long press for tooltip.
    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Add'), findsOneWidget);
  }, skip: true); // TODO(flutter_web): fix: with no child hit test returns empty.

  testWidgets('Floating Action Button tooltip reacts when disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: null,
            tooltip: 'Add',
          ),
        ),
      ),
    );

    expect(find.text('Add'), findsNothing);

    // Test hover for tooltip.
    final TestGesture gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    try {
      await gesture.addPointer();
      await gesture.moveTo(tester.getCenter(find.byType(FloatingActionButton)));
      await tester.pumpAndSettle();

      expect(find.text('Add'), findsOneWidget);

      await gesture.moveTo(Offset.zero);
    } finally {
      await gesture.removePointer();
    }
    await tester.pumpAndSettle();

    expect(find.text('Add'), findsNothing);

    // Test long press for tooltip.
    await tester.longPress(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Add'), findsOneWidget);
  }, skip: true); // TODO(flutter_web): re-enable.

  testWidgets('Floating Action Button elevation when highlighted - effect', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () { },
          ),
        ),
      ),
    );
    expect(tester.widget<PhysicalShape>(find.byType(PhysicalShape)).elevation, 6.0);
    final TestGesture gesture = await tester.press(find.byType(PhysicalShape));
    await tester.pump();
    expect(tester.widget<PhysicalShape>(find.byType(PhysicalShape)).elevation, 6.0);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<PhysicalShape>(find.byType(PhysicalShape)).elevation, 12.0);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () { },
            highlightElevation: 20.0,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.widget<PhysicalShape>(find.byType(PhysicalShape)).elevation, 12.0);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<PhysicalShape>(find.byType(PhysicalShape)).elevation, 20.0);
    await gesture.up();
    await tester.pump();
    expect(tester.widget<PhysicalShape>(find.byType(PhysicalShape)).elevation, 20.0);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<PhysicalShape>(find.byType(PhysicalShape)).elevation, 6.0);
  });


  testWidgets('FloatingActionButton.isExtended', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(onPressed: null),
        ),
      ),
    );

    final Finder fabFinder = find.byType(FloatingActionButton);

    FloatingActionButton getFabWidget() {
      return tester.widget<FloatingActionButton>(fabFinder);
    }

    final Finder materialButtonFinder = find.byType(RawMaterialButton);

    RawMaterialButton getRawMaterialButtonWidget() {
      return tester.widget<RawMaterialButton>(materialButtonFinder);
    }

    expect(getFabWidget().isExtended, false);
    expect(getRawMaterialButtonWidget().shape, const CircleBorder());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            label: const SizedBox(
              width: 100.0,
              child: Text('label'),
            ),
            icon: const Icon(Icons.android),
            onPressed: null,
          ),
        ),
      ),
    );

    expect(getFabWidget().isExtended, true);
    expect(getRawMaterialButtonWidget().shape, const StadiumBorder());
    expect(find.text('label'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);

    // Verify that the widget's height is 48 and that its internal
    /// horizontal layout is: 16 icon 8 label 20
    expect(tester.getSize(fabFinder).height, 48.0);

    final double fabLeft = tester.getTopLeft(fabFinder).dx;
    final double fabRight = tester.getTopRight(fabFinder).dx;
    final double iconLeft = tester.getTopLeft(find.byType(Icon)).dx;
    final double iconRight = tester.getTopRight(find.byType(Icon)).dx;
    final double labelLeft = tester.getTopLeft(find.text('label')).dx;
    final double labelRight = tester.getTopRight(find.text('label')).dx;
    expect(iconLeft - fabLeft, 16.0);
    expect(labelLeft - iconRight, 8.0);
    expect(fabRight - labelRight, 20.0);

    // The overall width of the button is:
    // 168 = 16 + 24(icon) + 8 + 100(label) + 20
    expect(tester.getSize(find.byType(Icon)).width, 24.0);
    expect(tester.getSize(find.text('label')).width, 100.0);
    expect(tester.getSize(fabFinder).width, 168);
  });

  testWidgets('FloatingActionButton.isExtended (without icon)', (WidgetTester tester) async {
    final Finder fabFinder = find.byType(FloatingActionButton);

    FloatingActionButton getFabWidget() {
      return tester.widget<FloatingActionButton>(fabFinder);
    }

    final Finder materialButtonFinder = find.byType(RawMaterialButton);

    RawMaterialButton getRawMaterialButtonWidget() {
      return tester.widget<RawMaterialButton>(materialButtonFinder);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            label: const SizedBox(
              width: 100.0,
              child: Text('label'),
            ),
            onPressed: null,
          ),
        ),
      ),
    );

    expect(getFabWidget().isExtended, true);
    expect(getRawMaterialButtonWidget().shape, const StadiumBorder());
    expect(find.text('label'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);

    // Verify that the widget's height is 48 and that its internal
    /// horizontal layout is: 20 label 20
    expect(tester.getSize(fabFinder).height, 48.0);

    final double fabLeft = tester.getTopLeft(fabFinder).dx;
    final double fabRight = tester.getTopRight(fabFinder).dx;
    final double labelLeft = tester.getTopLeft(find.text('label')).dx;
    final double labelRight = tester.getTopRight(find.text('label')).dx;
    expect(labelLeft - fabLeft, 20.0);
    expect(fabRight - labelRight, 20.0);

    // The overall width of the button is:
    // 140 = 20 + 100(label) + 20
    expect(tester.getSize(find.text('label')).width, 100.0);
    expect(tester.getSize(fabFinder).width, 140);
  });

  testWidgets('Floating Action Button heroTag', (WidgetTester tester) async {
    BuildContext theContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              theContext = context;
              return const FloatingActionButton(heroTag: 1, onPressed: null);
            },
          ),
          floatingActionButton: const FloatingActionButton(heroTag: 2, onPressed: null),
        ),
      ),
    );
    Navigator.push(theContext, PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return const Placeholder();
      },
    ));
    await tester.pump(); // this would fail if heroTag was the same on both FloatingActionButtons (see below).
  });

  testWidgets('Floating Action Button heroTag - with duplicate', (WidgetTester tester) async {
    BuildContext theContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              theContext = context;
              return const FloatingActionButton(onPressed: null);
            },
          ),
          floatingActionButton: const FloatingActionButton(onPressed: null),
        ),
      ),
    );
    Navigator.push(theContext, PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return const Placeholder();
      },
    ));
    await tester.pump();
    expect(tester.takeException().toString(), contains('FloatingActionButton'));
  });

  testWidgets('Floating Action Button heroTag - with duplicate', (WidgetTester tester) async {
    BuildContext theContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              theContext = context;
              return const FloatingActionButton(heroTag: 'xyzzy', onPressed: null);
            },
          ),
          floatingActionButton: const FloatingActionButton(heroTag: 'xyzzy', onPressed: null),
        ),
      ),
    );
    Navigator.push(theContext, PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return const Placeholder();
      },
    ));
    await tester.pump();
    expect(tester.takeException().toString(), contains('xyzzy'));
  });

  testWidgets('Floating Action Button semantics (enabled)', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: FloatingActionButton(
            onPressed: () { },
            child: const Icon(Icons.add, semanticLabel: 'Add'),
          ),
        ),
      ),
    );

    expect(semantics, hasSemantics(TestSemantics.root(
      children: <TestSemantics>[
        TestSemantics.rootChild(
          label: 'Add',
          flags: <SemanticsFlag>[
            SemanticsFlag.isButton,
            SemanticsFlag.hasEnabledState,
            SemanticsFlag.isEnabled,
          ],
          actions: <SemanticsAction>[
            SemanticsAction.tap,
          ],
        ),
      ],
    ), ignoreTransform: true, ignoreId: true, ignoreRect: true));

    semantics.dispose();
  });

  testWidgets('Floating Action Button semantics (disabled)', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: FloatingActionButton(
            onPressed: null,
            child: Icon(Icons.add, semanticLabel: 'Add'),
          ),
        ),
      ),
    );

    expect(semantics, hasSemantics(TestSemantics.root(
      children: <TestSemantics>[
        TestSemantics.rootChild(
          label: 'Add',
          flags: <SemanticsFlag>[
            SemanticsFlag.isButton,
            SemanticsFlag.hasEnabledState,
          ],
        ),
      ],
    ), ignoreTransform: true, ignoreId: true, ignoreRect: true));

    semantics.dispose();
  });

  testWidgets('Tooltip is used as semantics label', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () { },
            tooltip: 'Add Photo',
            child: const Icon(Icons.add_a_photo),
          ),
        ),
      ),
    );

    expect(semantics, hasSemantics(TestSemantics.root(
      children: <TestSemantics>[
        TestSemantics.rootChild(
          children: <TestSemantics>[
            TestSemantics(
              flags: <SemanticsFlag>[
                SemanticsFlag.scopesRoute,
              ],
              children: <TestSemantics>[
                TestSemantics(
                  label: 'Add Photo',
                  actions: <SemanticsAction>[
                    SemanticsAction.tap,
                  ],
                  flags: <SemanticsFlag>[
                    SemanticsFlag.isButton,
                    SemanticsFlag.hasEnabledState,
                    SemanticsFlag.isEnabled,
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ), ignoreTransform: true, ignoreId: true, ignoreRect: true));

    semantics.dispose();
  });

  testWidgets('extended FAB hero transitions succeed', (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/18782

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: Builder(
            builder: (BuildContext context) { // define context of Navigator.push()
              return FloatingActionButton.extended(
                icon: const Icon(Icons.add),
                label: const Text('A long FAB label'),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return Scaffold(
                        floatingActionButton: FloatingActionButton.extended(
                          icon: const Icon(Icons.add),
                          label: const Text('X'),
                          onPressed: () { },
                        ),
                        body: Center(
                          child: RaisedButton(
                            child: const Text('POP'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ));
                },
              );
            },
          ),
          body: const Center(
            child: Text('Hello World'),
          ),
        ),
      ),
    );

    final Finder longFAB = find.text('A long FAB label');
    final Finder shortFAB = find.text('X');
    final Finder helloWorld = find.text('Hello World');

    expect(longFAB, findsOneWidget);
    expect(shortFAB, findsNothing);
    expect(helloWorld, findsOneWidget);

    await tester.tap(longFAB);
    await tester.pumpAndSettle();

    expect(shortFAB, findsOneWidget);
    expect(longFAB, findsNothing);

    // Trigger a hero transition from shortFAB to longFAB.
    await tester.tap(find.text('POP'));
    await tester.pumpAndSettle();

    expect(longFAB, findsOneWidget);
    expect(shortFAB, findsNothing);
    expect(helloWorld, findsOneWidget);
  });

  // This test prevents https://github.com/flutter/flutter/issues/20483
  testWidgets('Floating Action Button clips ink splash and highlight', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: FloatingActionButton(
                onPressed: () { },
                child: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.press(find.byKey(key));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await expectLater(
      find.byKey(key),
      matchesGoldenFile('floating_action_button_test.clip.2.png'), // .clip.1.png is obsolete and can be removed
      skip: !Platform.isLinux,
    );
  }, skip: true); // TODO(flutter_web): reenable after golden support.

  testWidgets('Floating Action Button has no clip by default', (WidgetTester tester) async {
    final FocusNode focusNode = FocusNode();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          child: FloatingActionButton(
            focusNode: focusNode,
            onPressed: () { /* to make sure the button is enabled */ },
          ),
        ),
      ),
    );

    focusNode.unfocus();
    await tester.pump();

    expect(
      tester.renderObject(find.byType(FloatingActionButton)),
      paintsExactlyCountTimes(#clipPath, 0),
    );
  });
}

Offset _rightEdgeOfFab(WidgetTester tester) {
  final Finder fab = find.byType(FloatingActionButton);
  return tester.getRect(fab).centerRight - const Offset(1.0, 0.0);
}
