// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

void main() {
  testWidgets('toString control test', (WidgetTester tester) async {
    final Widget widget = Title(
      color: const Color(0xFF00FF00),
      title: 'Awesome app',
      child: Container(),
    );
    expect(widget.toString, isNot(throwsException));
  });

  testWidgets('should handle having no title', (WidgetTester tester) async {
    final Title widget = Title(
      child: Container(),
      color: const Color(0xFF00FF00),
    );
    expect(widget.toString, isNot(throwsException));
    expect(widget.title, equals(''));
    expect(widget.color, equals(const Color(0xFF00FF00)));
  });

  testWidgets('should not allow null title or color',
      (WidgetTester tester) async {
    expect(
        () => Title(
              title: null,
              color: const Color(0xFF00FF00),
              child: Container(),
            ),
        throwsAssertionError);
    expect(
        () => Title(
              color: null,
              child: Container(),
            ),
        throwsAssertionError);
  });

  testWidgets('should not allow non-opaque color', (WidgetTester tester) async {
    expect(
        () => Title(
              color: const Color(0),
              child: Container(),
            ),
        throwsAssertionError);
  });

  testWidgets('should not pass "null" to setApplicationSwitcherDescription',
      (WidgetTester tester) async {
    final List<MethodCall> log = <MethodCall>[];

    SystemChannels.platform
        .setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
    });

    await tester.pumpWidget(Title(
      child: Container(),
      color: const Color(0xFF00FF00),
    ));

    expect(log, hasLength(1));
    expect(
        log.single,
        isMethodCall(
          'SystemChrome.setApplicationSwitcherDescription',
          arguments: <String, dynamic>{'label': '', 'primaryColor': 4278255360},
        ));
  });
}
