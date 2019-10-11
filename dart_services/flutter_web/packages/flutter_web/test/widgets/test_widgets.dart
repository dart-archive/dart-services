// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';

const BoxDecoration kBoxDecorationA = const BoxDecoration(
  color: const Color(0xFFFF0000),
);

const BoxDecoration kBoxDecorationB = const BoxDecoration(
  color: const Color(0xFF00FF00),
);

const BoxDecoration kBoxDecorationC = const BoxDecoration(
  color: const Color(0xFF0000FF),
);

class TestBuildCounter extends StatelessWidget {
  static int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount += 1;
    return const DecoratedBox(decoration: kBoxDecorationA);
  }
}

class FlipWidget extends StatefulWidget {
  const FlipWidget({Key key, this.left, this.right}) : super(key: key);

  final Widget left;
  final Widget right;

  @override
  FlipWidgetState createState() => new FlipWidgetState();
}

class FlipWidgetState extends State<FlipWidget> {
  bool _showLeft = true;

  void flip() {
    setState(() {
      _showLeft = !_showLeft;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLeft ? widget.left : widget.right;
  }
}

void flipStatefulWidget(WidgetTester tester, {bool skipOffstage = true}) {
  tester
      .state<FlipWidgetState>(
          find.byType(FlipWidget, skipOffstage: skipOffstage))
      .flip();
}
