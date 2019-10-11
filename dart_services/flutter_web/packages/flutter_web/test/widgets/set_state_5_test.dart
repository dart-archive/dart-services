// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';

class BadWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BadWidgetState();
}

class BadWidgetState extends State<BadWidget> {
  BadWidgetState() {
    setState(() {
      _count = 1;
    });
  }

  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Text(_count.toString());
  }
}

void main() {
  testWidgets('setState() catches being used inside a constructor',
      (WidgetTester tester) async {
    await tester.pumpWidget(BadWidget());
    expect(tester.takeException(), isInstanceOf<FlutterError>());
  });
}
