// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';

void main() {
  testWidgets('Can be placed in an infinite box', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
          textDirection: TextDirection.ltr,
          child: ListView(children: const <Widget>[Center()])),
    );
  });
}
