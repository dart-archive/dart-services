// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web/rendering.dart';

void main() {
  testWidgets('GridView default control', (WidgetTester tester) async {
    await tester.pumpWidget(
      new Directionality(
        textDirection: TextDirection.ltr,
        child: new Center(
          child: new GridView.count(
            crossAxisCount: 1,
          ),
        ),
      ),
    );
  });

  // Tests https://github.com/flutter/flutter/issues/5522
  testWidgets('GridView displays correct children with nonzero padding',
      (WidgetTester tester) async {
    const EdgeInsets padding = const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0);

    final Widget testWidget = new Directionality(
      textDirection: TextDirection.ltr,
      child: new Align(
        child: new SizedBox(
          height: 800.0,
          width: 300.0, // forces the grid children to be 300..300
          child: new GridView.count(
            crossAxisCount: 1,
            padding: padding,
            children: new List<Widget>.generate(10, (int index) {
              return new Text('$index', key: new ValueKey<int>(index));
            }).toList(),
          ),
        ),
      ),
    );

    await tester.pumpWidget(testWidget);

    // screen is 600px high, and has the following items:
    //   100..400 = 0
    //   400..700 = 1
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsNothing);
    expect(find.text('3'), findsNothing);

    await tester.drag(find.text('1'), const Offset(0.0, -500.0));
    await tester.pump();
    //  -100..300 = 1
    //   300..600 = 2
    //   600..600 = 3
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsNothing);
    expect(find.text('5'), findsNothing);

    await tester.drag(find.text('1'), const Offset(0.0, 150.0));
    await tester.pump();
    // Child '0' is now back onscreen, but by less than `padding.top`.
    //  -250..050 = 0
    //   050..450 = 1
    //   450..750 = 2
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsNothing);
    expect(find.text('4'), findsNothing);
  });

  testWidgets(
      'GridView.count() fixed itemExtent, scroll to end, append, scroll',
      (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/9506
    Widget buildFrame(int itemCount) {
      return new Directionality(
        textDirection: TextDirection.ltr,
        child: new GridView.count(
          crossAxisCount: itemCount,
          children: new List<Widget>.generate(itemCount, (int index) {
            return new SizedBox(
              height: 200.0,
              child: new Text('item $index'),
            );
          }),
        ),
      );
    }

    await tester.pumpWidget(buildFrame(3));
    expect(find.text('item 0'), findsOneWidget);
    expect(find.text('item 1'), findsOneWidget);
    expect(find.text('item 2'), findsOneWidget);

    await tester.pumpWidget(buildFrame(4));
    final TestGesture gesture =
        await tester.startGesture(const Offset(0.0, 300.0));
    await gesture.moveBy(const Offset(0.0, -200.0));
    await tester.pumpAndSettle();
    expect(find.text('item 3'), findsOneWidget);
  });
}
