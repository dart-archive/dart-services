// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/widgets.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

class Foo extends StatefulWidget {
  @override
  FooState createState() => FooState();
}

class FooState extends State<Foo> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ScrollConfiguration(
          behavior: FooScrollBehavior(),
          child: ListView(
            controller: scrollController,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() { /* this is needed to trigger the original bug this is regression-testing */ });
                  scrollController.animateTo(200.0, duration: const Duration(milliseconds: 500), curve: Curves.linear);
                },
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: Color(0)),
                  child: SizedBox(
                    height: 200.0,
                  ),
                )
              ),
              const DecoratedBox(
                decoration: BoxDecoration(color: Color(0)),
                child: SizedBox(
                  height: 200.0,
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(color: Color(0)),
                child: SizedBox(
                  height: 200.0,
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(color: Color(0)),
                child: SizedBox(
                  height: 200.0,
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(color: Color(0)),
                child: SizedBox(
                  height: 200.0,
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(color: Color(0)),
                child: SizedBox(
                  height: 200.0,
                ),
              ),
            ],
          )
        );
      }
    );
  }
}

class FooScrollBehavior extends ScrollBehavior {
  @override
  bool shouldNotify(FooScrollBehavior old) => true;
}

void main() {
  testWidgets('Can animate scroll after setState', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Foo(),
      ),
    );
    expect(tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels, 0.0);
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    expect(tester.state<ScrollableState>(find.byType(Scrollable)).position.pixels, 200.0);
  });
}
