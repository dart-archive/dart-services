// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

void main() {
  testWidgets('Passes textAlign to underlying TextField',
      (WidgetTester tester) async {
    const TextAlign alignment = TextAlign.center;

    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Center(
            child: new TextFormField(
              textAlign: alignment,
            ),
          ),
        ),
      ),
    );

    final Finder textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    final TextField textFieldWidget = tester.widget(textFieldFinder);
    expect(textFieldWidget.textAlign, alignment);
  });

  testWidgets('onFieldSubmit callbacks are called',
      (WidgetTester tester) async {
    bool _called = false;

    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Center(
            child: new TextFormField(
              onFieldSubmitted: (String value) {
                _called = true;
              },
            ),
          ),
        ),
      ),
    );

    await tester.showKeyboard(find.byType(TextField));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(_called, true);
  });

  testWidgets('autovalidate is passed to super', (WidgetTester tester) async {
    int _validateCalled = 0;

    await tester.pumpWidget(
      new MaterialApp(
        home: new Material(
          child: new Center(
            child: new TextFormField(
              autovalidate: true,
              validator: (String value) {
                _validateCalled++;
                return null;
              },
            ),
          ),
        ),
      ),
    );

    expect(_validateCalled, 1);
    await tester.showKeyboard(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();
    expect(_validateCalled, 2);
  });
}
