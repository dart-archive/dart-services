// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/painting.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

void main() {
  test('EdgeInsets control test', () {
    const EdgeInsets insets = EdgeInsets.fromLTRB(5.0, 7.0, 11.0, 13.0);

    expect(insets, hasOneLineDescription);
    expect(insets.hashCode,
        equals(const EdgeInsets.fromLTRB(5.0, 7.0, 11.0, 13.0).hashCode));

    expect(insets.topLeft, const Offset(5.0, 7.0));
    expect(insets.topRight, const Offset(-11.0, 7.0));
    expect(insets.bottomLeft, const Offset(5.0, -13.0));
    expect(insets.bottomRight, const Offset(-11.0, -13.0));

    expect(insets.collapsedSize, const Size(16.0, 20.0));
    expect(insets.flipped, const EdgeInsets.fromLTRB(11.0, 13.0, 5.0, 7.0));

    expect(insets.along(Axis.horizontal), equals(16.0));
    expect(insets.along(Axis.vertical), equals(20.0));

    expect(insets.inflateRect(Rect.fromLTRB(23.0, 32.0, 124.0, 143.0)),
        Rect.fromLTRB(18.0, 25.0, 135.0, 156.0));

    expect(insets.deflateRect(Rect.fromLTRB(23.0, 32.0, 124.0, 143.0)),
        Rect.fromLTRB(28.0, 39.0, 113.0, 130.0));

    expect(
        insets.inflateSize(const Size(100.0, 125.0)), const Size(116.0, 145.0));
    expect(
        insets.deflateSize(const Size(100.0, 125.0)), const Size(84.0, 105.0));

    expect(insets / 2.0, const EdgeInsets.fromLTRB(2.5, 3.5, 5.5, 6.5));
    expect(insets ~/ 2.0, const EdgeInsets.fromLTRB(2.0, 3.0, 5.0, 6.0));
    expect(insets % 5.0, const EdgeInsets.fromLTRB(0.0, 2.0, 1.0, 3.0));
  });

  test('EdgeInsets.lerp()', () {
    const EdgeInsets a = EdgeInsets.all(10.0);
    const EdgeInsets b = EdgeInsets.all(20.0);
    expect(EdgeInsets.lerp(a, b, 0.25), equals(a * 1.25));
    expect(EdgeInsets.lerp(a, b, 0.25), equals(b * 0.625));
    expect(EdgeInsets.lerp(a, b, 0.25), equals(a + const EdgeInsets.all(2.5)));
    expect(EdgeInsets.lerp(a, b, 0.25), equals(b - const EdgeInsets.all(7.5)));

    expect(EdgeInsets.lerp(null, null, 0.25), isNull);
    expect(EdgeInsets.lerp(null, b, 0.25), equals(b * 0.25));
    expect(EdgeInsets.lerp(a, null, 0.25), equals(a * 0.75));
  });

  test('EdgeInsets.resolve()', () {
    expect(
        const EdgeInsetsDirectional.fromSTEB(10.0, 20.0, 30.0, 40.0)
            .resolve(TextDirection.ltr),
        const EdgeInsets.fromLTRB(10.0, 20.0, 30.0, 40.0));
    expect(
        const EdgeInsetsDirectional.fromSTEB(99.0, 98.0, 97.0, 96.0)
            .resolve(TextDirection.rtl),
        const EdgeInsets.fromLTRB(97.0, 98.0, 99.0, 96.0));
    expect(
        const EdgeInsetsDirectional.only(start: 963.25)
            .resolve(TextDirection.ltr),
        const EdgeInsets.fromLTRB(963.25, 0.0, 0.0, 0.0));
    expect(
        const EdgeInsetsDirectional.only(top: 963.25)
            .resolve(TextDirection.ltr),
        const EdgeInsets.fromLTRB(0.0, 963.25, 0.0, 0.0));
    expect(
        const EdgeInsetsDirectional.only(end: 963.25)
            .resolve(TextDirection.ltr),
        const EdgeInsets.fromLTRB(0.0, 0.0, 963.25, 0.0));
    expect(
        const EdgeInsetsDirectional.only(bottom: 963.25)
            .resolve(TextDirection.ltr),
        const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 963.25));
    expect(
        const EdgeInsetsDirectional.only(start: 963.25)
            .resolve(TextDirection.rtl),
        const EdgeInsets.fromLTRB(0.0, 0.0, 963.25, 0.0));
    expect(
        const EdgeInsetsDirectional.only(top: 963.25)
            .resolve(TextDirection.rtl),
        const EdgeInsets.fromLTRB(0.0, 963.25, 0.0, 0.0));
    expect(
        const EdgeInsetsDirectional.only(end: 963.25)
            .resolve(TextDirection.rtl),
        const EdgeInsets.fromLTRB(963.25, 0.0, 0.0, 0.0));
    expect(
        const EdgeInsetsDirectional.only(bottom: 963.25)
            .resolve(TextDirection.rtl),
        const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 963.25));
    expect(EdgeInsetsDirectional.only(),
        EdgeInsetsDirectional.only()); // ignore: prefer_const_constructors
    expect(const EdgeInsetsDirectional.only(top: 1.0),
        isNot(const EdgeInsetsDirectional.only(bottom: 1.0)));
    expect(
        const EdgeInsetsDirectional.fromSTEB(10.0, 20.0, 30.0, 40.0)
            .resolve(TextDirection.ltr),
        const EdgeInsetsDirectional.fromSTEB(30.0, 20.0, 10.0, 40.0)
            .resolve(TextDirection.rtl));
    expect(
        const EdgeInsetsDirectional.fromSTEB(10.0, 20.0, 30.0, 40.0)
            .resolve(TextDirection.ltr),
        isNot(const EdgeInsetsDirectional.fromSTEB(30.0, 20.0, 10.0, 40.0)
            .resolve(TextDirection.ltr)));
    expect(
        const EdgeInsetsDirectional.fromSTEB(10.0, 20.0, 30.0, 40.0)
            .resolve(TextDirection.ltr),
        isNot(const EdgeInsetsDirectional.fromSTEB(10.0, 20.0, 30.0, 40.0)
            .resolve(TextDirection.rtl)));
  });

  test('EdgeInsets equality', () {
    final double $5 = nonconst(5.0);
    expect(EdgeInsetsDirectional.only(top: $5, bottom: 7.0),
        EdgeInsetsDirectional.only(top: $5, bottom: 7.0));
    expect(EdgeInsets.only(top: $5, bottom: 7.0),
        EdgeInsetsDirectional.only(top: $5, bottom: 7.0));
    expect(EdgeInsetsDirectional.only(top: $5, bottom: 7.0),
        EdgeInsets.only(top: $5, bottom: 7.0));
    expect(EdgeInsets.only(top: $5, bottom: 7.0),
        EdgeInsets.only(top: $5, bottom: 7.0));
    expect(EdgeInsetsDirectional.only(start: $5),
        EdgeInsetsDirectional.only(start: $5));
    expect(const EdgeInsets.only(left: 5.0),
        isNot(const EdgeInsetsDirectional.only(start: 5.0)));
    expect(const EdgeInsetsDirectional.only(start: 5.0),
        isNot(const EdgeInsets.only(left: 5.0)));
    expect(EdgeInsets.only(left: $5), EdgeInsets.only(left: $5));
    expect(EdgeInsetsDirectional.only(end: $5),
        EdgeInsetsDirectional.only(end: $5));
    expect(const EdgeInsets.only(right: 5.0),
        isNot(const EdgeInsetsDirectional.only(end: 5.0)));
    expect(const EdgeInsetsDirectional.only(end: 5.0),
        isNot(const EdgeInsets.only(right: 5.0)));
    expect(EdgeInsets.only(right: $5), EdgeInsets.only(right: $5));
    expect(
        const EdgeInsetsDirectional.only(end: 5.0)
            .add(const EdgeInsets.only(right: 5.0)),
        const EdgeInsetsDirectional.only(end: 5.0)
            .add(const EdgeInsets.only(right: 5.0)));
    expect(
        const EdgeInsetsDirectional.only(end: 5.0)
            .add(const EdgeInsets.only(right: 5.0)),
        isNot(const EdgeInsetsDirectional.only(end: 5.0)
            .add(const EdgeInsets.only(left: 5.0))));
    expect(
        const EdgeInsetsDirectional.only(top: 1.0)
            .add(const EdgeInsets.only(top: 2.0)),
        const EdgeInsetsDirectional.only(top: 3.0)
            .add(const EdgeInsets.only(top: 0.0)));
    expect(
        const EdgeInsetsDirectional.only(top: 1.0)
            .add(const EdgeInsets.only(top: 2.0)),
        const EdgeInsets.only(top: 3.0)
            .add(const EdgeInsetsDirectional.only(top: 0.0)));
    expect(
        const EdgeInsetsDirectional.only(top: 1.0)
            .add(const EdgeInsets.only(top: 2.0)),
        const EdgeInsetsDirectional.only(top: 3.0));
    expect(
        const EdgeInsetsDirectional.only(top: 1.0)
            .add(const EdgeInsets.only(top: 2.0)),
        const EdgeInsets.only(top: 3.0));
  });

  test('EdgeInsets copyWith', () {
    const EdgeInsets sourceEdgeInsets =
        EdgeInsets.only(left: 1.0, top: 2.0, bottom: 3.0, right: 4.0);
    final EdgeInsets copy = sourceEdgeInsets.copyWith(left: 5.0, top: 6.0);
    expect(copy,
        const EdgeInsets.only(left: 5.0, top: 6.0, bottom: 3.0, right: 4.0));
  });

  test('EdgeInsetsGeometry.lerp(...)', () {
    expect(
        EdgeInsetsGeometry.lerp(
            const EdgeInsetsDirectional.only(end: 10.0), null, 0.5),
        const EdgeInsetsDirectional.only(end: 5.0));
    expect(
        EdgeInsetsGeometry.lerp(
            const EdgeInsetsDirectional.only(start: 10.0), null, 0.5),
        const EdgeInsetsDirectional.only(start: 5.0));
    expect(
        EdgeInsetsGeometry.lerp(
            const EdgeInsetsDirectional.only(top: 10.0), null, 0.5),
        const EdgeInsetsDirectional.only(top: 5.0));
    expect(
        EdgeInsetsGeometry.lerp(
            const EdgeInsetsDirectional.only(bottom: 10.0), null, 0.5),
        const EdgeInsetsDirectional.only(bottom: 5.0));
    expect(
        EdgeInsetsGeometry.lerp(const EdgeInsetsDirectional.only(bottom: 10.0),
            EdgeInsetsDirectional.zero, 0.5),
        const EdgeInsetsDirectional.only(bottom: 5.0));
    expect(
        EdgeInsetsGeometry.lerp(const EdgeInsetsDirectional.only(bottom: 10.0),
            EdgeInsets.zero, 0.5),
        const EdgeInsetsDirectional.only(bottom: 5.0));
    expect(
        EdgeInsetsGeometry.lerp(const EdgeInsetsDirectional.only(start: 10.0),
            const EdgeInsets.only(left: 20.0), 0.5),
        const EdgeInsetsDirectional.only(start: 5.0)
            .add(const EdgeInsets.only(left: 10.0)));
    expect(
        EdgeInsetsGeometry.lerp(
            const EdgeInsetsDirectional.only(start: 0.0, bottom: 1.0),
            const EdgeInsetsDirectional.only(start: 1.0, bottom: 1.0)
                .add(const EdgeInsets.only(right: 2.0, bottom: 0.0)),
            0.5),
        const EdgeInsetsDirectional.only(start: 0.5)
            .add(const EdgeInsets.only(right: 1.0, bottom: 1.0)));
    expect(
        EdgeInsetsGeometry.lerp(
            const EdgeInsets.only(left: 0.0, bottom: 1.0),
            const EdgeInsetsDirectional.only(end: 1.0, bottom: 1.0)
                .add(const EdgeInsets.only(right: 2.0, bottom: 0.0)),
            0.5),
        const EdgeInsetsDirectional.only(start: 0.0, end: 0.5)
            .add(const EdgeInsets.only(right: 1.0, bottom: 1.0)));
  });

  test('EdgeInsetsGeometry.lerp(normal, ...)', () {
    const EdgeInsets a = EdgeInsets.all(10.0);
    const EdgeInsets b = EdgeInsets.all(20.0);
    expect(EdgeInsetsGeometry.lerp(a, b, 0.25), equals(a * 1.25));
    expect(EdgeInsetsGeometry.lerp(a, b, 0.25), equals(b * 0.625));
    expect(EdgeInsetsGeometry.lerp(a, b, 0.25),
        equals(a + const EdgeInsets.all(2.5)));
    expect(EdgeInsetsGeometry.lerp(a, b, 0.25),
        equals(b - const EdgeInsets.all(7.5)));

    expect(EdgeInsetsGeometry.lerp(null, null, 0.25), isNull);
    expect(EdgeInsetsGeometry.lerp(null, b, 0.25), equals(b * 0.25));
    expect(EdgeInsetsGeometry.lerp(a, null, 0.25), equals(a * 0.75));
  });

  test('EdgeInsetsGeometry.lerp(directional, ...)', () {
    const EdgeInsetsDirectional a =
        EdgeInsetsDirectional.only(start: 10.0, end: 10.0);
    const EdgeInsetsDirectional b =
        EdgeInsetsDirectional.only(start: 20.0, end: 20.0);
    expect(EdgeInsetsGeometry.lerp(a, b, 0.25), equals(a * 1.25));
    expect(EdgeInsetsGeometry.lerp(a, b, 0.25), equals(b * 0.625));
    expect(EdgeInsetsGeometry.lerp(a, b, 0.25),
        equals(a + const EdgeInsetsDirectional.only(start: 2.5, end: 2.5)));
    expect(EdgeInsetsGeometry.lerp(a, b, 0.25),
        equals(b - const EdgeInsetsDirectional.only(start: 7.5, end: 7.5)));

    expect(EdgeInsetsGeometry.lerp(null, null, 0.25), isNull);
    expect(EdgeInsetsGeometry.lerp(null, b, 0.25), equals(b * 0.25));
    expect(EdgeInsetsGeometry.lerp(a, null, 0.25), equals(a * 0.75));
  });

  test('EdgeInsetsGeometry.lerp(mixed, ...)', () {
    final EdgeInsetsGeometry a =
        const EdgeInsetsDirectional.only(start: 10.0, end: 10.0)
            .add(const EdgeInsets.all(1.0));
    final EdgeInsetsGeometry b =
        const EdgeInsetsDirectional.only(start: 20.0, end: 20.0)
            .add(const EdgeInsets.all(2.0));
    expect(EdgeInsetsGeometry.lerp(a, b, 0.25), equals(a * 1.25));
    expect(EdgeInsetsGeometry.lerp(a, b, 0.25), equals(b * 0.625));

    expect(EdgeInsetsGeometry.lerp(null, null, 0.25), isNull);
    expect(EdgeInsetsGeometry.lerp(null, b, 0.25), equals(b * 0.25));
    expect(EdgeInsetsGeometry.lerp(a, null, 0.25), equals(a * 0.75));
  });

  test('EdgeInsets operators', () {
    const EdgeInsets a = EdgeInsets.fromLTRB(1.0, 2.0, 3.0, 5.0);
    expect(a * 2.0, const EdgeInsets.fromLTRB(2.0, 4.0, 6.0, 10.0));
    expect(a / 2.0, const EdgeInsets.fromLTRB(0.5, 1.0, 1.5, 2.5));
    expect(a % 2.0, const EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 1.0));
    expect(a ~/ 2.0, const EdgeInsets.fromLTRB(0.0, 1.0, 1.0, 2.0));
    expect(a + a, a * 2.0);
    expect(a - a, EdgeInsets.zero);
    expect(a.add(a), a * 2.0);
    expect(a.subtract(a), EdgeInsets.zero);
  });

  test('EdgeInsetsDirectional operators', () {
    const EdgeInsetsDirectional a =
        EdgeInsetsDirectional.fromSTEB(1.0, 2.0, 3.0, 5.0);
    expect(a * 2.0, const EdgeInsetsDirectional.fromSTEB(2.0, 4.0, 6.0, 10.0));
    expect(a / 2.0, const EdgeInsetsDirectional.fromSTEB(0.5, 1.0, 1.5, 2.5));
    expect(a % 2.0, const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 1.0, 1.0));
    expect(a ~/ 2.0, const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 1.0, 2.0));
    expect(a + a, a * 2.0);
    expect(a - a, EdgeInsetsDirectional.zero);
    expect(a.add(a), a * 2.0);
    expect(a.subtract(a), EdgeInsetsDirectional.zero);
  });

  test('EdgeInsetsGeometry operators', () {
    final EdgeInsetsGeometry a =
        const EdgeInsetsDirectional.fromSTEB(1.0, 2.0, 3.0, 5.0)
            .add(EdgeInsets.zero);
    expect(a, isNot(isInstanceOf<EdgeInsetsDirectional>()));
    expect(a * 2.0, const EdgeInsetsDirectional.fromSTEB(2.0, 4.0, 6.0, 10.0));
    expect(a / 2.0, const EdgeInsetsDirectional.fromSTEB(0.5, 1.0, 1.5, 2.5));
    expect(a % 2.0, const EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 1.0, 1.0));
    expect(a ~/ 2.0, const EdgeInsetsDirectional.fromSTEB(0.0, 1.0, 1.0, 2.0));
    expect(a.add(a), a * 2.0);
    expect(a.subtract(a), EdgeInsetsDirectional.zero);
    expect(a.subtract(a), EdgeInsets.zero);
  });

  test('EdgeInsetsGeometry toString', () {
    expect(const EdgeInsets.only().toString(), 'EdgeInsets.zero');
    expect(
        const EdgeInsets.only(top: 1.01, left: 1.01, right: 1.01, bottom: 1.01)
            .toString(),
        'EdgeInsets.all(1.0)');
    expect(const EdgeInsetsDirectional.only().toString(), 'EdgeInsets.zero');
    expect(
        const EdgeInsetsDirectional.only(
                start: 1.01, end: 1.01, top: 1.01, bottom: 1.01)
            .toString(),
        'EdgeInsetsDirectional(1.0, 1.0, 1.0, 1.0)');
    expect(
        (const EdgeInsetsDirectional.only(start: 4.0)
                .add(const EdgeInsets.only(top: 3.0)))
            .toString(),
        'EdgeInsetsDirectional(4.0, 3.0, 0.0, 0.0)');
    expect(
        (const EdgeInsetsDirectional.only(top: 4.0)
                .add(const EdgeInsets.only(right: 3.0)))
            .toString(),
        'EdgeInsets(0.0, 4.0, 3.0, 0.0)');
    expect(
        (const EdgeInsetsDirectional.only(start: 4.0)
                .add(const EdgeInsets.only(left: 3.0)))
            .toString(),
        'EdgeInsets(3.0, 0.0, 0.0, 0.0) + EdgeInsetsDirectional(4.0, 0.0, 0.0, 0.0)');
  });
}
