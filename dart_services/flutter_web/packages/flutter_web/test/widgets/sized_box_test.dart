// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/widgets.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

void main() {
  testWidgets('SizedBox constructors', (WidgetTester tester) async {
    const SizedBox a = SizedBox();
    expect(a.width, isNull);
    expect(a.height, isNull);

    const SizedBox b = SizedBox(width: 10.0);
    expect(b.width, 10.0);
    expect(b.height, isNull);

    const SizedBox c = SizedBox(width: 10.0, height: 20.0);
    expect(c.width, 10.0);
    expect(c.height, 20.0);

    final SizedBox d = SizedBox.fromSize();
    expect(d.width, isNull);
    expect(d.height, isNull);

    final SizedBox e = SizedBox.fromSize(size: const Size(1.0, 2.0));
    expect(e.width, 1.0);
    expect(e.height, 2.0);

    const SizedBox f = SizedBox.expand();
    expect(f.width, double.infinity);
    expect(f.height, double.infinity);

    const SizedBox g = SizedBox.shrink();
    expect(g.width, 0.0);
    expect(g.height, 0.0);
  });

  testWidgets('SizedBox - no child', (WidgetTester tester) async {
    final GlobalKey patient = GlobalKey();

    await tester.pumpWidget(Center(
        child: SizedBox(
      key: patient,
    )));
    expect(patient.currentContext.size, equals(const Size(0.0, 0.0)));

    await tester.pumpWidget(Center(
        child: SizedBox(
      key: patient,
      height: 0.0,
    )));
    expect(patient.currentContext.size, equals(const Size(0.0, 0.0)));

    await tester.pumpWidget(Center(
        child: SizedBox(
      key: patient,
      width: 0.0,
      height: 0.0,
    )));
    expect(patient.currentContext.size, equals(const Size(0.0, 0.0)));

    await tester.pumpWidget(Center(
        child: SizedBox(
      key: patient,
      width: 100.0,
      height: 100.0,
    )));
    expect(patient.currentContext.size, equals(const Size(100.0, 100.0)));

    await tester.pumpWidget(Center(
        child: SizedBox(
      key: patient,
      width: 1000.0,
      height: 1000.0,
    )));
    expect(patient.currentContext.size, equals(const Size(800.0, 600.0)));

    await tester.pumpWidget(Center(
        child: SizedBox.expand(
      key: patient,
    )));
    expect(patient.currentContext.size, equals(const Size(800.0, 600.0)));

    await tester.pumpWidget(Center(
        child: SizedBox.shrink(
      key: patient,
    )));
    expect(patient.currentContext.size, equals(const Size(0.0, 0.0)));
  });

  testWidgets('SizedBox - container child', (WidgetTester tester) async {
    final GlobalKey patient = GlobalKey();

    await tester.pumpWidget(Center(
        child: SizedBox(
      key: patient,
      child: Container(),
    )));
    expect(patient.currentContext.size, equals(const Size(800.0, 600.0)));

    await tester.pumpWidget(Center(
        child: SizedBox(
      key: patient,
      height: 0.0,
      child: Container(),
    )));
    expect(patient.currentContext.size, equals(const Size(800.0, 0.0)));

    await tester.pumpWidget(Center(
        child: SizedBox(
      key: patient,
      width: 0.0,
      height: 0.0,
      child: Container(),
    )));
    expect(patient.currentContext.size, equals(const Size(0.0, 0.0)));

    await tester.pumpWidget(Center(
        child: SizedBox(
      key: patient,
      width: 100.0,
      height: 100.0,
      child: Container(),
    )));
    expect(patient.currentContext.size, equals(const Size(100.0, 100.0)));

    await tester.pumpWidget(Center(
        child: SizedBox(
      key: patient,
      width: 1000.0,
      height: 1000.0,
      child: Container(),
    )));
    expect(patient.currentContext.size, equals(const Size(800.0, 600.0)));

    await tester.pumpWidget(Center(
        child: SizedBox.expand(
      key: patient,
      child: Container(),
    )));
    expect(patient.currentContext.size, equals(const Size(800.0, 600.0)));

    await tester.pumpWidget(Center(
        child: SizedBox.shrink(
      key: patient,
      child: Container(),
    )));
    expect(patient.currentContext.size, equals(const Size(0.0, 0.0)));
  });
}
