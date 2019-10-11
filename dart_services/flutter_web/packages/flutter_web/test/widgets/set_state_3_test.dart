// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';

ChangerState changer;

class Changer extends StatefulWidget {
  const Changer(this.child);

  final Widget child;

  @override
  ChangerState createState() => ChangerState();
}

class ChangerState extends State<Changer> {
  bool _state = false;

  @override
  void initState() {
    super.initState();
    changer = this;
  }

  void test() {
    setState(() {
      _state = true;
    });
  }

  @override
  Widget build(BuildContext context) =>
      _state ? Wrapper(widget.child) : widget.child;
}

class Wrapper extends StatelessWidget {
  const Wrapper(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class Leaf extends StatefulWidget {
  @override
  LeafState createState() => LeafState();
}

class LeafState extends State<Leaf> {
  @override
  Widget build(BuildContext context) =>
      const Text('leaf', textDirection: TextDirection.ltr);
}

void main() {
  testWidgets('three-way setState() smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(Changer(Wrapper(Leaf())));
    await tester.pumpWidget(Changer(Wrapper(Leaf())));
    changer.test();
    await tester.pump();
  });
}
