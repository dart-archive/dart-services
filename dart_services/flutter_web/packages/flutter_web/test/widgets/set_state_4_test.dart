// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';

class Changer extends StatefulWidget {
  @override
  ChangerState createState() => ChangerState();
}

class ChangerState extends State<Changer> {
  void test0() {
    setState(() {});
  }

  void test1() {
    setState(() => 1);
  }

  void test2() {
    setState(() async {});
  }

  @override
  Widget build(BuildContext context) =>
      const Text('test', textDirection: TextDirection.ltr);
}

void main() {
  testWidgets('setState() catches being used with an async callback',
      (WidgetTester tester) async {
    await tester.pumpWidget(Changer());
    final ChangerState s = tester.state(find.byType(Changer));
    expect(s.test0, isNot(throwsFlutterError));
    expect(s.test1, isNot(throwsFlutterError));
    expect(s.test2, throwsFlutterError);
  });
}
