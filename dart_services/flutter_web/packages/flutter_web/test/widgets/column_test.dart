// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';

void main() {
  // DOWN (default)

  testWidgets('Column with one flexible child', (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // Default is MainAxisAlignment.start so children so the children's
    // top edges should be at 0, 100, 500, child2's height should be 400.
    await tester.pumpWidget(Center(
        child: Column(key: columnKey, children: <Widget>[
      Container(key: child0Key, width: 100.0, height: 100.0),
      Expanded(child: Container(key: child1Key, width: 100.0, height: 100.0)),
      Container(key: child2Key, width: 100.0, height: 100.0),
    ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(0.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(400.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(100.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(500.0));
  });

  testWidgets('Column with default main axis parameters',
      (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // Default is MainAxisAlignment.start so children so the children's
    // top edges should be at 0, 100, 200
    await tester.pumpWidget(Center(
        child: Column(key: columnKey, children: <Widget>[
      Container(key: child0Key, width: 100.0, height: 100.0),
      Container(key: child1Key, width: 100.0, height: 100.0),
      Container(key: child2Key, width: 100.0, height: 100.0),
    ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(0.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(100.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(200.0));
  });

  testWidgets('Column with MainAxisAlignment.center',
      (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // The 100x100 children's top edges should be at 200, 300
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 100.0),
          Container(key: child1Key, width: 100.0, height: 100.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(200.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(300.0));
  });

  testWidgets('Column with MainAxisAlignment.end', (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // The 100x100 children's top edges should be at 300, 400, 500.
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 100.0),
          Container(key: child1Key, width: 100.0, height: 100.0),
          Container(key: child2Key, width: 100.0, height: 100.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(300.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(400.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(500.0));
  });

  testWidgets('Column with MainAxisAlignment.spaceBetween',
      (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // The 100x100 children's top edges should be at 0, 250, 500
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 100.0),
          Container(key: child1Key, width: 100.0, height: 100.0),
          Container(key: child2Key, width: 100.0, height: 100.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(0.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(250.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(500.0));
  });

  testWidgets('Column with MainAxisAlignment.spaceAround',
      (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');
    const Key child3Key = Key('child3');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // The 100x100 children's top edges should be at 25, 175, 325, 475
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 100.0),
          Container(key: child1Key, width: 100.0, height: 100.0),
          Container(key: child2Key, width: 100.0, height: 100.0),
          Container(key: child3Key, width: 100.0, height: 100.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(25.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(175.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(325.0));

    renderBox = tester.renderObject(find.byKey(child3Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(475.0));
  });

  testWidgets('Column with MainAxisAlignment.spaceEvenly',
      (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // The 100x20 children's top edges should be at 135, 290, 445
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 20.0),
          Container(key: child1Key, width: 100.0, height: 20.0),
          Container(key: child2Key, width: 100.0, height: 20.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(20.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(135.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(20.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(290.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(20.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(445.0));
  });

  testWidgets('Column and MainAxisSize.min', (WidgetTester tester) async {
    const Key flexKey = Key('flexKey');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    await tester.pumpWidget(Center(
        child: Column(key: flexKey, children: <Widget>[
      Container(width: 100.0, height: 100.0),
      Container(width: 100.0, height: 150.0)
    ])));
    RenderBox renderBox = tester.renderObject(find.byKey(flexKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    // Column with MainAxisSize.min without flexible children shrink wraps.
    await tester.pumpWidget(Center(
        child: Column(
            key: flexKey,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
          Container(width: 100.0, height: 100.0),
          Container(width: 100.0, height: 150.0)
        ])));
    renderBox = tester.renderObject(find.byKey(flexKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(250.0));
  });

  testWidgets('Column MainAxisSize.min layout at zero size',
      (WidgetTester tester) async {
    const Key childKey = Key('childKey');

    await tester.pumpWidget(Center(
        child: Container(
            width: 0.0,
            height: 0.0,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Container(key: childKey, width: 100.0, height: 100.0)
            ]))));

    final RenderBox renderBox = tester.renderObject(find.byKey(childKey));
    expect(renderBox.size.width, equals(0.0));
    expect(renderBox.size.height, equals(100.0));
  });

  // UP

  testWidgets('Column with one flexible child', (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // Default is MainAxisAlignment.start so children so the children's
    // bottom edges should be at 0, 100, 500 from bottom, child2's height should be 400.
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 100.0),
          Expanded(
              child: Container(key: child1Key, width: 100.0, height: 100.0)),
          Container(key: child2Key, width: 100.0, height: 100.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(500.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(400.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(100.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(0.0));
  });

  testWidgets('Column with default main axis parameters',
      (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // Default is MainAxisAlignment.start so children so the children's
    // bottom edges should be at 0, 100, 200 from bottom
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 100.0),
          Container(key: child1Key, width: 100.0, height: 100.0),
          Container(key: child2Key, width: 100.0, height: 100.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(500.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(400.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(300.0));
  });

  testWidgets('Column with MainAxisAlignment.center',
      (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // The 100x100 children's bottom edges should be at 200, 300 from bottom
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.center,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 100.0),
          Container(key: child1Key, width: 100.0, height: 100.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(300.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(200.0));
  });

  testWidgets('Column with MainAxisAlignment.end', (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // The 100x100 children's bottom edges should be at 300, 400, 500 from bottom.
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.end,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 100.0),
          Container(key: child1Key, width: 100.0, height: 100.0),
          Container(key: child2Key, width: 100.0, height: 100.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(200.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(100.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(0.0));
  });

  testWidgets('Column with MainAxisAlignment.spaceBetween',
      (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // The 100x100 children's bottom edges should be at 0, 250, 500 from bottom
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 100.0),
          Container(key: child1Key, width: 100.0, height: 100.0),
          Container(key: child2Key, width: 100.0, height: 100.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(500.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(250.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(0.0));
  });

  testWidgets('Column with MainAxisAlignment.spaceAround',
      (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');
    const Key child3Key = Key('child3');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // The 100x100 children's bottom edges should be at 25, 175, 325, 475 from bottom
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 100.0),
          Container(key: child1Key, width: 100.0, height: 100.0),
          Container(key: child2Key, width: 100.0, height: 100.0),
          Container(key: child3Key, width: 100.0, height: 100.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(500.0 - 25.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(500.0 - 175.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(500.0 - 325.0));

    renderBox = tester.renderObject(find.byKey(child3Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(100.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(500.0 - 475.0));
  });

  testWidgets('Column with MainAxisAlignment.spaceEvenly',
      (WidgetTester tester) async {
    const Key columnKey = Key('column');
    const Key child0Key = Key('child0');
    const Key child1Key = Key('child1');
    const Key child2Key = Key('child2');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    // The 100x20 children's bottom edges should be at 135, 290, 445 from bottom
    await tester.pumpWidget(Center(
        child: Column(
            key: columnKey,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
          Container(key: child0Key, width: 100.0, height: 20.0),
          Container(key: child1Key, width: 100.0, height: 20.0),
          Container(key: child2Key, width: 100.0, height: 20.0),
        ])));

    RenderBox renderBox;
    BoxParentData boxParentData;

    renderBox = tester.renderObject(find.byKey(columnKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    renderBox = tester.renderObject(find.byKey(child0Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(20.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(600.0 - 135.0 - 20.0));

    renderBox = tester.renderObject(find.byKey(child1Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(20.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(600.0 - 290.0 - 20.0));

    renderBox = tester.renderObject(find.byKey(child2Key));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(20.0));
    boxParentData = renderBox.parentData;
    expect(boxParentData.offset.dy, equals(600.0 - 445.0 - 20.0));
  });

  testWidgets('Column and MainAxisSize.min', (WidgetTester tester) async {
    const Key flexKey = Key('flexKey');

    // Default is MainAxisSize.max so the Column should be as high as the test: 600.
    await tester.pumpWidget(Center(
        child: Column(
            key: flexKey,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
          Container(width: 100.0, height: 100.0),
          Container(width: 100.0, height: 150.0)
        ])));
    RenderBox renderBox = tester.renderObject(find.byKey(flexKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(600.0));

    // Column with MainAxisSize.min without flexible children shrink wraps.
    await tester.pumpWidget(Center(
        child: Column(
            key: flexKey,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
          Container(width: 100.0, height: 100.0),
          Container(width: 100.0, height: 150.0)
        ])));
    renderBox = tester.renderObject(find.byKey(flexKey));
    expect(renderBox.size.width, equals(100.0));
    expect(renderBox.size.height, equals(250.0));
  });

  testWidgets('Column MainAxisSize.min layout at zero size',
      (WidgetTester tester) async {
    const Key childKey = Key('childKey');

    await tester.pumpWidget(Center(
        child: Container(
            width: 0.0,
            height: 0.0,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                verticalDirection: VerticalDirection.up,
                children: <Widget>[
                  Container(key: childKey, width: 100.0, height: 100.0)
                ]))));

    final RenderBox renderBox = tester.renderObject(find.byKey(childKey));
    expect(renderBox.size.width, equals(0.0));
    expect(renderBox.size.height, equals(100.0));
  });
}
