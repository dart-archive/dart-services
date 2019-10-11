// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';

import '../rendering/mock_canvas.dart';

void verify(WidgetTester tester, List<Offset> answerKey) {
  final List<Offset> testAnswers = tester.renderObjectList<RenderBox>(find.byType(SizedBox)).map<Offset>(
    (RenderBox target) => target.localToGlobal(Offset.zero)
  ).toList();
  expect(testAnswers, equals(answerKey));
}

void main() {
  testWidgets('Basic Wrap test (LTR)', (WidgetTester tester) async {
    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.start,
        textDirection: TextDirection.ltr,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(0.0, 0.0),
      const Offset(300.0, 0.0),
      const Offset(0.0, 100.0),
      const Offset(300.0, 100.0),
    ]);

    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.center,
        textDirection: TextDirection.ltr,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(100.0, 0.0),
      const Offset(400.0, 0.0),
      const Offset(100.0, 100.0),
      const Offset(400.0, 100.0),
    ]);

    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.end,
        textDirection: TextDirection.ltr,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(200.0, 0.0),
      const Offset(500.0, 0.0),
      const Offset(200.0, 100.0),
      const Offset(500.0, 100.0),
    ]);

    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        textDirection: TextDirection.ltr,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 50.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 50.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(0.0, 0.0),
      const Offset(300.0, 0.0),
      const Offset(0.0, 100.0),
      const Offset(300.0, 100.0),
    ]);

    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        textDirection: TextDirection.ltr,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 50.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 50.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(0.0, 25.0),
      const Offset(300.0, 0.0),
      const Offset(0.0, 100.0),
      const Offset(300.0, 125.0),
    ]);

    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.end,
        textDirection: TextDirection.ltr,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 50.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 50.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(0.0, 50.0),
      const Offset(300.0, 0.0),
      const Offset(0.0, 100.0),
      const Offset(300.0, 150.0),
    ]);

  });

  testWidgets('Basic Wrap test (RTL)', (WidgetTester tester) async {
    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.start,
        textDirection: TextDirection.rtl,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(500.0, 0.0),
      const Offset(200.0, 0.0),
      const Offset(500.0, 100.0),
      const Offset(200.0, 100.0),
    ]);

    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.center,
        textDirection: TextDirection.rtl,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(400.0, 0.0),
      const Offset(100.0, 0.0),
      const Offset(400.0, 100.0),
      const Offset(100.0, 100.0),
    ]);

    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.end,
        textDirection: TextDirection.rtl,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(300.0, 0.0),
      const Offset(0.0, 0.0),
      const Offset(300.0, 100.0),
      const Offset(0.0, 100.0),
    ]);

    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        textDirection: TextDirection.ltr,
        verticalDirection: VerticalDirection.up,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 50.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 50.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(0.0, 550.0),
      const Offset(300.0, 500.0),
      const Offset(0.0, 400.0),
      const Offset(300.0, 450.0),
    ]);

    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        textDirection: TextDirection.ltr,
        verticalDirection: VerticalDirection.up,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 50.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 50.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(0.0, 525.0),
      const Offset(300.0, 500.0),
      const Offset(0.0, 400.0),
      const Offset(300.0, 425.0),
    ]);

    await tester.pumpWidget(
      Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.end,
        textDirection: TextDirection.ltr,
        verticalDirection: VerticalDirection.up,
        children: const <Widget>[
          SizedBox(width: 300.0, height: 50.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 100.0),
          SizedBox(width: 300.0, height: 50.0),
        ],
      ),
    );
    verify(tester, <Offset>[
      const Offset(0.0, 500.0),
      const Offset(300.0, 500.0),
      const Offset(0.0, 400.0),
      const Offset(300.0, 400.0),
    ]);

  });

  testWidgets('Empty wrap', (WidgetTester tester) async {
    await tester.pumpWidget(Center(child: Wrap(alignment: WrapAlignment.center)));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(Size.zero));
  });

  testWidgets('Wrap alignment (LTR)', (WidgetTester tester) async {
    await tester.pumpWidget(Wrap(
      alignment: WrapAlignment.center,
      spacing: 5.0,
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(95.0, 0.0),
      const Offset(200.0, 0.0),
      const Offset(405.0, 0.0),
    ]);

    await tester.pumpWidget(Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 5.0,
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 0.0),
      const Offset(200.0, 0.0),
      const Offset(500.0, 0.0),
    ]);

    await tester.pumpWidget(Wrap(
      alignment: WrapAlignment.spaceAround,
      spacing: 5.0,
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 310.0, height: 30.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(30.0, 0.0),
      const Offset(195.0, 0.0),
      const Offset(460.0, 0.0),
    ]);

    await tester.pumpWidget(Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 5.0,
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 310.0, height: 30.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(45.0, 0.0),
      const Offset(195.0, 0.0),
      const Offset(445.0, 0.0),
    ]);
  });

  testWidgets('Wrap alignment (RTL)', (WidgetTester tester) async {
    await tester.pumpWidget(Wrap(
      alignment: WrapAlignment.center,
      spacing: 5.0,
      textDirection: TextDirection.rtl,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(605.0, 0.0),
      const Offset(400.0, 0.0),
      const Offset(95.0, 0.0),
    ]);

    await tester.pumpWidget(Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 5.0,
      textDirection: TextDirection.rtl,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(700.0, 0.0),
      const Offset(400.0, 0.0),
      const Offset(0.0, 0.0),
    ]);

    await tester.pumpWidget(Wrap(
      alignment: WrapAlignment.spaceAround,
      spacing: 5.0,
      textDirection: TextDirection.rtl,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 310.0, height: 30.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(670.0, 0.0),
      const Offset(405.0, 0.0),
      const Offset(30.0, 0.0),
    ]);

    await tester.pumpWidget(Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 5.0,
      textDirection: TextDirection.rtl,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 310.0, height: 30.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(655.0, 0.0),
      const Offset(405.0, 0.0),
      const Offset(45.0, 0.0),
    ]);
  });

  testWidgets('Wrap runAlignment (DOWN)', (WidgetTester tester) async {
    await tester.pumpWidget(Wrap(
      runAlignment: WrapAlignment.center,
      runSpacing: 5.0,
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
        SizedBox(width: 400.0, height: 40.0),
        SizedBox(width: 500.0, height: 60.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 230.0),
      const Offset(100.0, 230.0),
      const Offset(300.0, 230.0),
      const Offset(0.0, 265.0),
      const Offset(0.0, 310.0),
    ]);

    await tester.pumpWidget(Wrap(
      runAlignment: WrapAlignment.spaceBetween,
      runSpacing: 5.0,
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
        SizedBox(width: 400.0, height: 40.0),
        SizedBox(width: 500.0, height: 60.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 0.0),
      const Offset(100.0, 0.0),
      const Offset(300.0, 0.0),
      const Offset(0.0, 265.0),
      const Offset(0.0, 540.0),
    ]);

    await tester.pumpWidget(Wrap(
      runAlignment: WrapAlignment.spaceAround,
      runSpacing: 5.0,
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
        SizedBox(width: 400.0, height: 40.0),
        SizedBox(width: 500.0, height: 70.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 75.0),
      const Offset(100.0, 75.0),
      const Offset(300.0, 75.0),
      const Offset(0.0, 260.0),
      const Offset(0.0, 455.0),
    ]);

    await tester.pumpWidget(Wrap(
      runAlignment: WrapAlignment.spaceEvenly,
      runSpacing: 5.0,
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
        SizedBox(width: 400.0, height: 40.0),
        SizedBox(width: 500.0, height: 60.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 115.0),
      const Offset(100.0, 115.0),
      const Offset(300.0, 115.0),
      const Offset(0.0, 265.0),
      const Offset(0.0, 425.0),
    ]);

  });

  testWidgets('Wrap runAlignment (UP)', (WidgetTester tester) async {
    await tester.pumpWidget(Wrap(
      runAlignment: WrapAlignment.center,
      runSpacing: 5.0,
      textDirection: TextDirection.ltr,
      verticalDirection: VerticalDirection.up,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
        SizedBox(width: 400.0, height: 40.0),
        SizedBox(width: 500.0, height: 60.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 360.0),
      const Offset(100.0, 350.0),
      const Offset(300.0, 340.0),
      const Offset(0.0, 295.0),
      const Offset(0.0, 230.0),
    ]);

    await tester.pumpWidget(Wrap(
      runAlignment: WrapAlignment.spaceBetween,
      runSpacing: 5.0,
      textDirection: TextDirection.ltr,
      verticalDirection: VerticalDirection.up,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
        SizedBox(width: 400.0, height: 40.0),
        SizedBox(width: 500.0, height: 60.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 590.0),
      const Offset(100.0, 580.0),
      const Offset(300.0, 570.0),
      const Offset(0.0, 295.0),
      const Offset(0.0, 0.0),
    ]);

    await tester.pumpWidget(Wrap(
      runAlignment: WrapAlignment.spaceAround,
      runSpacing: 5.0,
      textDirection: TextDirection.ltr,
      verticalDirection: VerticalDirection.up,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
        SizedBox(width: 400.0, height: 40.0),
        SizedBox(width: 500.0, height: 70.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 515.0),
      const Offset(100.0, 505.0),
      const Offset(300.0, 495.0),
      const Offset(0.0, 300.0),
      const Offset(0.0, 75.0),
    ]);

    await tester.pumpWidget(Wrap(
      runAlignment: WrapAlignment.spaceEvenly,
      runSpacing: 5.0,
      textDirection: TextDirection.ltr,
      verticalDirection: VerticalDirection.up,
      children: const <Widget>[
        SizedBox(width: 100.0, height: 10.0),
        SizedBox(width: 200.0, height: 20.0),
        SizedBox(width: 300.0, height: 30.0),
        SizedBox(width: 400.0, height: 40.0),
        SizedBox(width: 500.0, height: 60.0),
      ],
    ));
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 475.0),
      const Offset(100.0, 465.0),
      const Offset(300.0, 455.0),
      const Offset(0.0, 295.0),
      const Offset(0.0, 115.0),
    ]);

  });

  testWidgets('Shrink-wrapping Wrap test', (WidgetTester tester) async {
    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          textDirection: TextDirection.ltr,
          children: const <Widget>[
            SizedBox(width: 100.0, height: 10.0),
            SizedBox(width: 200.0, height: 20.0),
            SizedBox(width: 300.0, height: 30.0),
            SizedBox(width: 400.0, height: 40.0),
          ],
        ),
      ),
    );
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(600.0, 70.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 20.0),
      const Offset(100.0, 10.0),
      const Offset(300.0, 0.0),
      const Offset(200.0, 30.0),
    ]);

    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          alignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          textDirection: TextDirection.ltr,
          children: const <Widget>[
            SizedBox(width: 400.0, height: 40.0),
            SizedBox(width: 300.0, height: 30.0),
            SizedBox(width: 200.0, height: 20.0),
            SizedBox(width: 100.0, height: 10.0),
          ],
        ),
      ),
    );
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(700.0, 60.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 0.0),
      const Offset(400.0, 10.0),
      const Offset(400.0, 40.0),
      const Offset(600.0, 50.0),
    ]);
  });

  testWidgets('Wrap spacing test', (WidgetTester tester) async {
    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          runSpacing: 10.0,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          textDirection: TextDirection.ltr,
          children: const <Widget>[
            SizedBox(width: 500.0, height: 10.0),
            SizedBox(width: 500.0, height: 20.0),
            SizedBox(width: 500.0, height: 30.0),
            SizedBox(width: 500.0, height: 40.0),
          ],
        ),
      ),
    );
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(500.0, 130.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 0.0),
      const Offset(0.0, 20.0),
      const Offset(0.0, 50.0),
      const Offset(0.0, 90.0),
    ]);
  });

  testWidgets('Vertical Wrap test with spacing', (WidgetTester tester) async {
    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          direction: Axis.vertical,
          spacing: 10.0,
          runSpacing: 15.0,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          textDirection: TextDirection.ltr,
          children: const <Widget>[
            SizedBox(width: 10.0, height: 250.0),
            SizedBox(width: 20.0, height: 250.0),
            SizedBox(width: 30.0, height: 250.0),
            SizedBox(width: 40.0, height: 250.0),
            SizedBox(width: 50.0, height: 250.0),
            SizedBox(width: 60.0, height: 250.0),
          ],
        ),
      ),
    );
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(150.0, 510.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 0.0),
      const Offset(0.0, 260.0),
      const Offset(35.0, 0.0),
      const Offset(35.0, 260.0),
      const Offset(90.0, 0.0),
      const Offset(90.0, 260.0),
    ]);

    await tester.pumpWidget(
      Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 12.0,
          runSpacing: 8.0,
          textDirection: TextDirection.ltr,
          children: const <Widget>[
            SizedBox(width: 10.0, height: 250.0),
            SizedBox(width: 20.0, height: 250.0),
            SizedBox(width: 30.0, height: 250.0),
            SizedBox(width: 40.0, height: 250.0),
            SizedBox(width: 50.0, height: 250.0),
            SizedBox(width: 60.0, height: 250.0),
          ],
        ),
      ),
    );
    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(270.0, 250.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 0.0),
      const Offset(22.0, 0.0),
      const Offset(54.0, 0.0),
      const Offset(96.0, 0.0),
      const Offset(148.0, 0.0),
      const Offset(210.0, 0.0),
    ]);
  });

  testWidgets('Visual overflow generates a clip', (WidgetTester tester) async {
    await tester.pumpWidget(Wrap(
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 500.0, height: 500.0),
      ],
    ));

    expect(tester.renderObject<RenderBox>(find.byType(Wrap)), isNot(paints..clipRect()));

    await tester.pumpWidget(Wrap(
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 500.0, height: 500.0),
        SizedBox(width: 500.0, height: 500.0),
      ],
    ));

    expect(tester.renderObject<RenderBox>(find.byType(Wrap)), paints..clipRect());
  });

  testWidgets('Hit test children in wrap', (WidgetTester tester) async {
    final List<String> log = <String>[];

    await tester.pumpWidget(Wrap(
      spacing: 10.0,
      runSpacing: 15.0,
      textDirection: TextDirection.ltr,
      children: <Widget>[
        const SizedBox(width: 200.0, height: 300.0),
        const SizedBox(width: 200.0, height: 300.0),
        const SizedBox(width: 200.0, height: 300.0),
        const SizedBox(width: 200.0, height: 300.0),
        SizedBox(
          width: 200.0,
          height: 300.0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () { log.add('hit'); },
          ),
        ),
      ],
    ));

    await tester.tapAt(const Offset(209.0, 314.0));
    expect(log, isEmpty);

    await tester.tapAt(const Offset(211.0, 314.0));
    expect(log, isEmpty);

    await tester.tapAt(const Offset(209.0, 316.0));
    expect(log, isEmpty);

    await tester.tapAt(const Offset(211.0, 316.0));
    expect(log, equals(<String>['hit']));
  });

  testWidgets('RenderWrap toStringShallow control test', (WidgetTester tester) async {
    await tester.pumpWidget(Wrap(alignment: WrapAlignment.center));

    final RenderBox wrap = tester.renderObject(find.byType(Wrap));
    expect(wrap.toStringShallow(), hasOneLineDescription);
  });

  testWidgets('RenderWrap toString control test', (WidgetTester tester) async {
    await tester.pumpWidget(Wrap(
      direction: Axis.vertical,
      runSpacing: 7.0,
      textDirection: TextDirection.ltr,
      children: const <Widget>[
        SizedBox(width: 500.0, height: 400.0),
        SizedBox(width: 500.0, height: 400.0),
        SizedBox(width: 500.0, height: 400.0),
        SizedBox(width: 500.0, height: 400.0),
      ],
    ));

    final RenderBox wrap = tester.renderObject(find.byType(Wrap));
    final double width = wrap.getMinIntrinsicWidth(600.0);
    expect(width, equals(2021));
  });

  testWidgets('Wrap baseline control test', (WidgetTester tester) async {
    await tester.pumpWidget(
      Center(
        child: Baseline(
          baseline: 180.0,
          baselineType: TextBaseline.alphabetic,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Ahem',
              fontSize: 100.0,
            ),
            child: Wrap(
              textDirection: TextDirection.ltr,
              children: const <Widget>[
                Text('X', textDirection: TextDirection.ltr),
              ],
            ),
          ),
        ),
      ),
    );
    expect(tester.renderObject<RenderBox>(find.text('X')).size, const Size(100.0, 100.0));
    expect(tester.renderObject<RenderBox>(find.byType(Baseline)).size,
           within<Size>(from: const Size(100.0, 200.0), distance: 0.001));
  });

  testWidgets('Spacing with slight overflow', (WidgetTester tester) async {
    await tester.pumpWidget(Wrap(
      direction: Axis.horizontal,
      textDirection: TextDirection.ltr,
      spacing: 10.0,
      runSpacing: 10.0,
      children: const <Widget>[
        SizedBox(width: 200.0, height: 10.0),
        SizedBox(width: 200.0, height: 10.0),
        SizedBox(width: 200.0, height: 10.0),
        SizedBox(width: 171.0, height: 10.0),
      ],
    ));

    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 600.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 0.0),
      const Offset(210.0, 0.0),
      const Offset(420.0, 0.0),
      const Offset(0.0, 20.0)
    ]);
  });

  testWidgets('Object exactly matches container width', (WidgetTester tester) async {
    await tester.pumpWidget(
      Column(
        children: <Widget>[
          Wrap(
            direction: Axis.horizontal,
            textDirection: TextDirection.ltr,
            spacing: 10.0,
            runSpacing: 10.0,
            children: const <Widget>[
              SizedBox(width: 800.0, height: 10.0),
            ],
          ),
        ],
      )
    );

    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 10.0)));
    verify(tester, <Offset>[const Offset(0.0, 0.0)]);

    await tester.pumpWidget(
      Column(
        children: <Widget>[
          Wrap(
            direction: Axis.horizontal,
            textDirection: TextDirection.ltr,
            spacing: 10.0,
            runSpacing: 10.0,
            children: const <Widget>[
              SizedBox(width: 800.0, height: 10.0),
              SizedBox(width: 800.0, height: 10.0),
            ],
          ),
        ],
      )
    );

    expect(tester.renderObject<RenderBox>(find.byType(Wrap)).size, equals(const Size(800.0, 30.0)));
    verify(tester, <Offset>[
      const Offset(0.0, 0.0),
      const Offset(0.0, 20.0),
    ]);
  });
}
