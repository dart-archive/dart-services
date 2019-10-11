// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';

class StateMarker extends StatefulWidget {
  const StateMarker({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  StateMarkerState createState() => StateMarkerState();
}

class StateMarkerState extends State<StateMarker> {
  String marker;

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) return widget.child;
    return Container();
  }
}

class DeactivateLogger extends StatefulWidget {
  const DeactivateLogger({Key key, this.log}) : super(key: key);

  final List<String> log;

  @override
  DeactivateLoggerState createState() => DeactivateLoggerState();
}

class DeactivateLoggerState extends State<DeactivateLogger> {
  @override
  void deactivate() {
    widget.log.add('deactivate');
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    widget.log.add('build');
    return Container();
  }
}

void main() {
  testWidgets('can reparent state', (WidgetTester tester) async {
    final GlobalKey left = GlobalKey();
    final GlobalKey right = GlobalKey();

    const StateMarker grandchild = StateMarker();
    await tester
        .pumpWidget(Stack(textDirection: TextDirection.ltr, children: <Widget>[
      Container(child: StateMarker(key: left)),
      Container(child: StateMarker(key: right, child: grandchild)),
    ]));

    final StateMarkerState leftState = left.currentState;
    leftState.marker = 'left';
    final StateMarkerState rightState = right.currentState;
    rightState.marker = 'right';

    final StateMarkerState grandchildState =
        tester.state(find.byWidget(grandchild));
    expect(grandchildState, isNotNull);
    grandchildState.marker = 'grandchild';

    const StateMarker newGrandchild = StateMarker();
    await tester
        .pumpWidget(Stack(textDirection: TextDirection.ltr, children: <Widget>[
      Container(child: StateMarker(key: right, child: newGrandchild)),
      Container(child: StateMarker(key: left)),
    ]));

    expect(left.currentState, equals(leftState));
    expect(leftState.marker, equals('left'));
    expect(right.currentState, equals(rightState));
    expect(rightState.marker, equals('right'));

    final StateMarkerState newGrandchildState =
        tester.state(find.byWidget(newGrandchild));
    expect(newGrandchildState, isNotNull);
    expect(newGrandchildState, equals(grandchildState));
    expect(newGrandchildState.marker, equals('grandchild'));

    await tester.pumpWidget(Center(
        child: Container(child: StateMarker(key: left, child: Container()))));

    expect(left.currentState, equals(leftState));
    expect(leftState.marker, equals('left'));
    expect(right.currentState, isNull);
  });

  testWidgets('can reparent state with multichild widgets',
      (WidgetTester tester) async {
    final GlobalKey left = GlobalKey();
    final GlobalKey right = GlobalKey();

    const StateMarker grandchild = StateMarker();
    await tester.pumpWidget(Stack(
        textDirection: TextDirection.ltr,
        children: <Widget>[
          StateMarker(key: left),
          StateMarker(key: right, child: grandchild)
        ]));

    final StateMarkerState leftState = left.currentState;
    leftState.marker = 'left';
    final StateMarkerState rightState = right.currentState;
    rightState.marker = 'right';

    final StateMarkerState grandchildState =
        tester.state(find.byWidget(grandchild));
    expect(grandchildState, isNotNull);
    grandchildState.marker = 'grandchild';

    const StateMarker newGrandchild = StateMarker();
    await tester.pumpWidget(Stack(
        textDirection: TextDirection.ltr,
        children: <Widget>[
          StateMarker(key: right, child: newGrandchild),
          StateMarker(key: left)
        ]));

    expect(left.currentState, equals(leftState));
    expect(leftState.marker, equals('left'));
    expect(right.currentState, equals(rightState));
    expect(rightState.marker, equals('right'));

    final StateMarkerState newGrandchildState =
        tester.state(find.byWidget(newGrandchild));
    expect(newGrandchildState, isNotNull);
    expect(newGrandchildState, equals(grandchildState));
    expect(newGrandchildState.marker, equals('grandchild'));

    await tester.pumpWidget(Center(
        child: Container(child: StateMarker(key: left, child: Container()))));

    expect(left.currentState, equals(leftState));
    expect(leftState.marker, equals('left'));
    expect(right.currentState, isNull);
  });

  testWidgets('can with scrollable list', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();

    await tester.pumpWidget(StateMarker(key: key));

    final StateMarkerState keyState = key.currentState;
    keyState.marker = 'marked';

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ListView(
          itemExtent: 100.0,
          children: <Widget>[
            Container(
              key: const Key('container'),
              height: 100.0,
              child: StateMarker(key: key),
            ),
          ],
        ),
      ),
    );

    expect(key.currentState, equals(keyState));
    expect(keyState.marker, equals('marked'));

    await tester.pumpWidget(StateMarker(key: key));

    expect(key.currentState, equals(keyState));
    expect(keyState.marker, equals('marked'));
  });

  testWidgets('Reparent during update children', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();

    await tester
        .pumpWidget(Stack(textDirection: TextDirection.ltr, children: <Widget>[
      StateMarker(key: key),
      Container(width: 100.0, height: 100.0),
    ]));

    final StateMarkerState keyState = key.currentState;
    keyState.marker = 'marked';

    await tester
        .pumpWidget(Stack(textDirection: TextDirection.ltr, children: <Widget>[
      Container(width: 100.0, height: 100.0),
      StateMarker(key: key),
    ]));

    expect(key.currentState, equals(keyState));
    expect(keyState.marker, equals('marked'));

    await tester
        .pumpWidget(Stack(textDirection: TextDirection.ltr, children: <Widget>[
      StateMarker(key: key),
      Container(width: 100.0, height: 100.0),
    ]));

    expect(key.currentState, equals(keyState));
    expect(keyState.marker, equals('marked'));
  });

  testWidgets('Reparent to child during update children',
      (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();

    await tester
        .pumpWidget(Stack(textDirection: TextDirection.ltr, children: <Widget>[
      Container(width: 100.0, height: 100.0),
      StateMarker(key: key),
      Container(width: 100.0, height: 100.0),
    ]));

    final StateMarkerState keyState = key.currentState;
    keyState.marker = 'marked';

    await tester
        .pumpWidget(Stack(textDirection: TextDirection.ltr, children: <Widget>[
      Container(width: 100.0, height: 100.0, child: StateMarker(key: key)),
      Container(width: 100.0, height: 100.0),
    ]));

    expect(key.currentState, equals(keyState));
    expect(keyState.marker, equals('marked'));

    await tester
        .pumpWidget(Stack(textDirection: TextDirection.ltr, children: <Widget>[
      Container(width: 100.0, height: 100.0),
      StateMarker(key: key),
      Container(width: 100.0, height: 100.0),
    ]));

    expect(key.currentState, equals(keyState));
    expect(keyState.marker, equals('marked'));

    await tester
        .pumpWidget(Stack(textDirection: TextDirection.ltr, children: <Widget>[
      Container(width: 100.0, height: 100.0),
      Container(width: 100.0, height: 100.0, child: StateMarker(key: key)),
    ]));

    expect(key.currentState, equals(keyState));
    expect(keyState.marker, equals('marked'));

    await tester
        .pumpWidget(Stack(textDirection: TextDirection.ltr, children: <Widget>[
      Container(width: 100.0, height: 100.0),
      StateMarker(key: key),
      Container(width: 100.0, height: 100.0),
    ]));

    expect(key.currentState, equals(keyState));
    expect(keyState.marker, equals('marked'));
  });

  testWidgets('Deactivate implies build', (WidgetTester tester) async {
    final GlobalKey key = GlobalKey();
    final List<String> log = <String>[];
    final DeactivateLogger logger = DeactivateLogger(key: key, log: log);

    await tester.pumpWidget(Container(key: UniqueKey(), child: logger));

    expect(log, equals(<String>['build']));

    await tester.pumpWidget(Container(key: UniqueKey(), child: logger));

    expect(log, equals(<String>['build', 'deactivate', 'build']));
    log.clear();

    await tester.pump();
    expect(log, isEmpty);
  });

  testWidgets('Reparenting with multiple moves', (WidgetTester tester) async {
    final GlobalKey key1 = GlobalKey();
    final GlobalKey key2 = GlobalKey();
    final GlobalKey key3 = GlobalKey();

    await tester
        .pumpWidget(Row(textDirection: TextDirection.ltr, children: <Widget>[
      StateMarker(
          key: key1,
          child: StateMarker(
              key: key2,
              child: StateMarker(
                  key: key3,
                  child: StateMarker(child: Container(width: 100.0)))))
    ]));

    await tester
        .pumpWidget(Row(textDirection: TextDirection.ltr, children: <Widget>[
      StateMarker(
          key: key2, child: StateMarker(child: Container(width: 100.0))),
      StateMarker(
          key: key1,
          child: StateMarker(
              key: key3, child: StateMarker(child: Container(width: 100.0)))),
    ]));
  });
}
