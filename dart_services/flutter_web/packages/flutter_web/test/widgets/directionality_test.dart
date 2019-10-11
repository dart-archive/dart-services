// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';

void main() {
  testWidgets('Directionality', (WidgetTester tester) async {
    final List<TextDirection> log = <TextDirection>[];
    final Widget inner = Builder(builder: (BuildContext context) {
      log.add(Directionality.of(context));
      return const Placeholder();
    });
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: inner,
      ),
    );
    expect(log, <TextDirection>[TextDirection.ltr]);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: inner,
      ),
    );
    expect(log, <TextDirection>[TextDirection.ltr]);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: inner,
      ),
    );
    expect(log, <TextDirection>[TextDirection.ltr, TextDirection.rtl]);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: inner,
      ),
    );
    expect(log, <TextDirection>[TextDirection.ltr, TextDirection.rtl]);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: inner,
      ),
    );
    expect(log, <TextDirection>[
      TextDirection.ltr,
      TextDirection.rtl,
      TextDirection.ltr
    ]);
  });

  testWidgets('Directionality default', (WidgetTester tester) async {
    bool good = false;
    await tester.pumpWidget(Builder(
      builder: (BuildContext context) {
        expect(Directionality.of(context), isNull);
        good = true;
        return const Placeholder();
      },
    ));
    expect(good, isTrue);
  });

  testWidgets('Directionality can\'t be null', (WidgetTester tester) async {
    expect(() {
      Directionality(textDirection: nonconst(null), child: const Placeholder());
    }, throwsAssertionError);
  });
}
