// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';

class TestStatusTransitionWidget extends StatusTransitionWidget {
  const TestStatusTransitionWidget({
    Key key,
    this.builder,
    Animation<double> animation,
  }) : super(key: key, animation: animation);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => builder(context);
}

void main() {
  testWidgets('Status transition control test', (WidgetTester tester) async {
    bool didBuild = false;
    final AnimationController controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: const TestVSync(),
    );

    await tester.pumpWidget(TestStatusTransitionWidget(
      animation: controller,
      builder: (BuildContext context) {
        expect(didBuild, isFalse);
        didBuild = true;
        return Container();
      },
    ));

    expect(didBuild, isTrue);
    didBuild = false;

    controller.forward();

    expect(didBuild, isFalse);
    await tester.pump();
    expect(didBuild, isTrue);
    didBuild = false;
    await tester.pump(const Duration(milliseconds: 100));
    expect(didBuild, isFalse);
    await tester.pump(const Duration(milliseconds: 850));
    expect(didBuild, isFalse);
    await tester.pump(const Duration(milliseconds: 100));
    expect(didBuild, isTrue);
    didBuild = false;
    controller.forward();
    await tester.pump(const Duration(milliseconds: 100));
    expect(didBuild, isFalse);
    controller.stop();
    await tester.pump(const Duration(milliseconds: 100));
    expect(didBuild, isFalse);

    final AnimationController anotherController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: const TestVSync(),
    );

    await tester.pumpWidget(TestStatusTransitionWidget(
      animation: anotherController,
      builder: (BuildContext context) {
        expect(didBuild, isFalse);
        didBuild = true;
        return Container();
      },
    ));

    expect(didBuild, isTrue);
    didBuild = false;
    controller.reverse();
    await tester.pump(const Duration(milliseconds: 100));
    expect(didBuild, isFalse);
    anotherController.forward();
    await tester.pump(const Duration(milliseconds: 100));
    expect(didBuild, isTrue);
    didBuild = false;

    controller.stop();
    anotherController.stop();
  });
}
