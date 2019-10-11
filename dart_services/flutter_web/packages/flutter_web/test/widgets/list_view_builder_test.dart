// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';

import 'test_widgets.dart';

void main() {
  testWidgets('ListView.builder mount/dismount smoke test',
      (WidgetTester tester) async {
    final List<int> callbackTracker = <int>[];

    // the root view is 800x600 in the test environment
    // so if our widget is 100 pixels tall, it should fit exactly 6 times.

    Widget builder() {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: FlipWidget(
          left: ListView.builder(
            itemExtent: 100.0,
            itemBuilder: (BuildContext context, int index) {
              callbackTracker.add(index);
              return Container(
                key: ValueKey<int>(index),
                height: 100.0,
                child: Text('$index'),
              );
            },
          ),
          right: const Text('Not Today'),
        ),
      );
    }

    await tester.pumpWidget(builder());

    final FlipWidgetState testWidget = tester.state(find.byType(FlipWidget));

    expect(
        callbackTracker,
        equals(<int>[
          0, 1, 2, 3, 4, 5, // visible in viewport
          6, 7, 8, // in caching area
        ]));
    check(visible: <int>[0, 1, 2, 3, 4, 5], hidden: <int>[6, 7, 8]);

    callbackTracker.clear();
    testWidget.flip();
    await tester.pump();

    expect(callbackTracker, equals(<int>[]));

    callbackTracker.clear();
    testWidget.flip();
    await tester.pump();

    expect(
        callbackTracker,
        equals(<int>[
          0, 1, 2, 3, 4, 5,
          6, 7, 8, // in caching area
        ]));
    check(visible: <int>[0, 1, 2, 3, 4, 5], hidden: <int>[6, 7, 8]);
  });

  testWidgets('ListView.builder vertical', (WidgetTester tester) async {
    final List<int> callbackTracker = <int>[];

    // the root view is 800x600 in the test environment
    // so if our widget is 200 pixels tall, it should fit exactly 3 times.
    // but if we are offset by 300 pixels, there will be 4, numbered 1-4.

    final IndexedWidgetBuilder itemBuilder = (BuildContext context, int index) {
      callbackTracker.add(index);
      return Container(
          key: ValueKey<int>(index),
          width: 500.0, // this should be ignored
          height: 400.0, // should be overridden by itemExtent
          child: Text('$index', textDirection: TextDirection.ltr));
    };

    Widget buildWidget() {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: FlipWidget(
          left: ListView.builder(
            controller: ScrollController(initialScrollOffset: 300.0),
            itemExtent: 200.0,
            itemBuilder: itemBuilder,
          ),
          right: const Text('Not Today'),
        ),
      );
    }

    void jumpTo(double newScrollOffset) {
      final ScrollableState scrollable = tester.state(find.byType(Scrollable));
      scrollable.position.jumpTo(newScrollOffset);
    }

    await tester.pumpWidget(buildWidget());

    expect(
        callbackTracker,
        equals(<int>[
          0, // in caching area
          1, 2, 3, 4,
          5, // in caching area
        ]));
    check(visible: <int>[1, 2, 3, 4], hidden: <int>[0, 5]);
    callbackTracker.clear();

    jumpTo(400.0);
    // now only 3 should fit, numbered 2-4.

    await tester.pumpWidget(buildWidget());

    expect(
        callbackTracker,
        equals(<int>[
          0, 1, // in caching area
          2, 3, 4,
          5, 6, // in caching area
        ]));
    check(visible: <int>[2, 3, 4], hidden: <int>[0, 1, 5, 6]);
    callbackTracker.clear();

    jumpTo(500.0);
    // now 4 should fit, numbered 2-5.

    await tester.pumpWidget(buildWidget());

    expect(
        callbackTracker,
        equals(<int>[
          0, 1, // in caching area
          2, 3, 4, 5,
          6, // in caching area
        ]));
    check(visible: <int>[2, 3, 4, 5], hidden: <int>[0, 1, 6]);
    callbackTracker.clear();
  });

  testWidgets('ListView.builder horizontal', (WidgetTester tester) async {
    final List<int> callbackTracker = <int>[];

    // the root view is 800x600 in the test environment
    // so if our widget is 200 pixels wide, it should fit exactly 4 times.
    // but if we are offset by 300 pixels, there will be 5, numbered 1-5.

    final IndexedWidgetBuilder itemBuilder = (BuildContext context, int index) {
      callbackTracker.add(index);
      return Container(
        key: ValueKey<int>(index),
        width: 400.0, // this should be overridden by itemExtent
        height: 500.0, // this should be ignored
        child: Text('$index'),
      );
    };

    Widget buildWidget() {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: FlipWidget(
          left: ListView.builder(
            controller: ScrollController(initialScrollOffset: 300.0),
            itemBuilder: itemBuilder,
            itemExtent: 200.0,
            scrollDirection: Axis.horizontal,
          ),
          right: const Text('Not Today'),
        ),
      );
    }

    void jumpTo(double newScrollOffset) {
      final ScrollableState scrollable = tester.state(find.byType(Scrollable));
      scrollable.position.jumpTo(newScrollOffset);
    }

    await tester.pumpWidget(buildWidget());

    expect(
        callbackTracker,
        equals(<int>[
          0, // in caching area
          1, 2, 3, 4, 5,
          6, // in caching area
        ]));
    check(visible: <int>[1, 2, 3, 4, 5], hidden: <int>[0, 6]);
    callbackTracker.clear();

    jumpTo(400.0);
    // now only 4 should fit, numbered 2-5.

    await tester.pumpWidget(buildWidget());

    expect(
        callbackTracker,
        equals(<int>[
          0, 1, // in caching area
          2, 3, 4, 5,
          6, 7, // in caching area
        ]));
    check(visible: <int>[2, 3, 4, 5], hidden: <int>[0, 1, 6, 7]);
    callbackTracker.clear();

    jumpTo(500.0);
    // now only 5 should fit, numbered 2-6.

    await tester.pumpWidget(buildWidget());

    expect(
        callbackTracker,
        equals(<int>[
          0, 1, // in caching area
          2, 3, 4, 5, 6,
          7, // in caching area
        ]));
    check(visible: <int>[2, 3, 4, 5, 6], hidden: <int>[0, 1, 7]);
    callbackTracker.clear();
  });

  testWidgets('ListView.builder 10 items, 2-3 items visible',
      (WidgetTester tester) async {
    final List<int> callbackTracker = <int>[];

    // The root view is 800x600 in the test environment and our list
    // items are 300 tall. Scrolling should cause two or three items
    // to be built.

    final IndexedWidgetBuilder itemBuilder = (BuildContext context, int index) {
      callbackTracker.add(index);
      return Text('$index',
          key: ValueKey<int>(index), textDirection: TextDirection.ltr);
    };

    final Widget testWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.builder(
        itemBuilder: itemBuilder,
        itemExtent: 300.0,
        itemCount: 10,
      ),
    );

    void jumpTo(double newScrollOffset) {
      final ScrollableState scrollable = tester.state(find.byType(Scrollable));
      scrollable.position.jumpTo(newScrollOffset);
    }

    await tester.pumpWidget(testWidget);
    expect(callbackTracker, equals(<int>[0, 1, 2]));
    check(visible: <int>[0, 1], hidden: <int>[2]);
    callbackTracker.clear();

    jumpTo(150.0);
    await tester.pump();

    expect(callbackTracker, equals(<int>[3]));
    check(visible: <int>[0, 1, 2], hidden: <int>[3]);
    callbackTracker.clear();

    jumpTo(600.0);
    await tester.pump();

    expect(callbackTracker, equals(<int>[4]));
    check(visible: <int>[2, 3], hidden: <int>[0, 1, 4]);
    callbackTracker.clear();

    jumpTo(750.0);
    await tester.pump();

    expect(callbackTracker, equals(<int>[5]));
    check(visible: <int>[2, 3, 4], hidden: <int>[0, 1, 5]);
    callbackTracker.clear();
  });

  testWidgets('ListView.separated', (WidgetTester tester) async {
    Widget buildFrame({int itemCount}) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: ListView.separated(
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 100.0,
              child: Text('i$index'),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 10.0,
              child: Text('s$index'),
            );
          },
        ),
      );
    }

    await tester.pumpWidget(buildFrame(itemCount: 0));
    expect(find.text('i0'), findsNothing);
    expect(find.text('s0'), findsNothing);

    await tester.pumpWidget(buildFrame(itemCount: 1));
    expect(find.text('i0'), findsOneWidget);
    expect(find.text('s0'), findsNothing);

    await tester.pumpWidget(buildFrame(itemCount: 2));
    expect(find.text('i0'), findsOneWidget);
    expect(find.text('s0'), findsOneWidget);
    expect(find.text('i1'), findsOneWidget);
    expect(find.text('s1'), findsNothing);

    // ListView's height is 600, so items i0-i5 and s0-s4 fit.
    await tester.pumpWidget(buildFrame(itemCount: 25));
    for (String s in <String>[
      'i0',
      's0',
      'i1',
      's1',
      'i2',
      's2',
      'i3',
      's3',
      'i4',
      's4',
      'i5'
    ]) expect(find.text(s), findsOneWidget);
    expect(find.text('s5'), findsNothing);
    expect(find.text('i6'), findsNothing);
  });
}

void check(
    {List<int> visible = const <int>[], List<int> hidden = const <int>[]}) {
  for (int i in visible) {
    expect(find.text('$i'), findsOneWidget);
  }
  for (int i in hidden) {
    expect(find.text('$i'), findsNothing);
  }
}
