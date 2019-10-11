// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/material.dart';

const TextStyle testFont = const TextStyle(
  color: const Color(0xFF00FF00),
  fontFamily: 'Ahem',
);

Future<void> pumpTest(WidgetTester tester, TargetPlatform platform) async {
  await tester.pumpWidget(new Container());
  await tester.pumpWidget(new MaterialApp(
    theme: new ThemeData(
      platform: platform,
    ),
    home: new Container(
      color: const Color(0xFF111111),
      child: new ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return new Text('$index', style: testFont);
        },
      ),
    ),
  ));
  return null;
}

const double dragOffset = 213.82;

void main() {
  testWidgets('Flings on different platforms', (WidgetTester tester) async {
    double getCurrentOffset() {
      return tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position
          .pixels;
    }

    await pumpTest(tester, TargetPlatform.android);
    await tester.fling(
        find.byType(ListView), const Offset(0.0, -dragOffset), 1000.0);
    expect(getCurrentOffset(), dragOffset);
    await tester.pump(); // trigger fling
    expect(getCurrentOffset(), dragOffset);
    await tester.pump(const Duration(seconds: 5));
    final double result1 = getCurrentOffset();

    await pumpTest(tester, TargetPlatform.iOS);
    await tester.fling(
        find.byType(ListView), const Offset(0.0, -dragOffset), 1000.0);
    // Scroll starts ease into the scroll on iOS.
    expect(getCurrentOffset(), moreOrLessEquals(210.71026666666666));
    await tester.pump(); // trigger fling
    expect(getCurrentOffset(), moreOrLessEquals(210.71026666666666));
    await tester.pump(const Duration(seconds: 5));
    final double result2 = getCurrentOffset();

    expect(
        result1,
        lessThan(
            result2)); // iOS (result2) is slipperier than Android (result1)
  });

  testWidgets('fling and tap to stop', (WidgetTester tester) async {
    final List<String> log = <String>[];

    final List<Widget> textWidgets = <Widget>[];
    for (int i = 0; i < 250; i += 1)
      textWidgets.add(new GestureDetector(
          onTap: () {
            log.add('tap $i');
          },
          child: new Text('$i', style: testFont)));
    await tester.pumpWidget(
      new Directionality(
          textDirection: TextDirection.ltr,
          child: new ListView(children: textWidgets)),
    );

    expect(log, equals(<String>[]));
    await tester.tap(find.byType(Scrollable));
    await tester.pump(const Duration(milliseconds: 50));
    expect(log, equals(<String>['tap 21']));
    await tester.fling(
        find.byType(Scrollable), const Offset(0.0, -200.0), 1000.0);
    await tester.pump(const Duration(milliseconds: 50));
    expect(log, equals(<String>['tap 21']));
    await tester.tap(
        find.byType(Scrollable)); // should stop the fling but not tap anything
    await tester.pump(const Duration(milliseconds: 50));
    expect(log, equals(<String>['tap 21']));
    await tester.tap(find.byType(Scrollable));
    await tester.pump(const Duration(milliseconds: 50));
    expect(log, equals(<String>['tap 21', 'tap 35']));
  });

  testWidgets('fling and wait and tap', (WidgetTester tester) async {
    final List<String> log = <String>[];

    final List<Widget> textWidgets = <Widget>[];
    for (int i = 0; i < 250; i += 1)
      textWidgets.add(new GestureDetector(
          onTap: () {
            log.add('tap $i');
          },
          child: new Text('$i', style: testFont)));
    await tester.pumpWidget(
      new Directionality(
          textDirection: TextDirection.ltr,
          child: new ListView(children: textWidgets)),
    );

    expect(log, equals(<String>[]));
    await tester.tap(find.byType(Scrollable));
    await tester.pump(const Duration(milliseconds: 50));
    expect(log, equals(<String>['tap 21']));
    await tester.fling(
        find.byType(Scrollable), const Offset(0.0, -200.0), 1000.0);
    await tester.pump(const Duration(milliseconds: 50));
    expect(log, equals(<String>['tap 21']));
    await tester.pump(const Duration(
        seconds:
            50)); // long wait, so the fling will have ended at the end of it
    expect(log, equals(<String>['tap 21']));
    await tester.tap(find.byType(Scrollable));
    await tester.pump(const Duration(milliseconds: 50));
    expect(log, equals(<String>['tap 21', 'tap 48']));
  });
}
