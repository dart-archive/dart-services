// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/rendering.dart';
import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/material.dart';

void main() {
  testWidgets('!pinned && !floating && !bottom ==> fade opactiy',
      (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_TestWidget(
      pinned: false,
      floating: false,
      bottom: false,
      controller: controller,
    ));

    final RenderParagraph render =
        tester.renderObject(find.text('Hallo Welt!!1'));
    expect(render.text.style.color.opacity, 1.0);

    controller.jumpTo(200.0);
    await tester.pumpAndSettle();
    expect(render.text.style.color.opacity, 0.0);
  });

  testWidgets('!pinned && !floating && bottom ==> fade opactiy',
      (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_TestWidget(
      pinned: false,
      floating: false,
      bottom: true,
      controller: controller,
    ));

    final RenderParagraph render =
        tester.renderObject(find.text('Hallo Welt!!1'));
    expect(render.text.style.color.opacity, 1.0);

    controller.jumpTo(200.0);
    await tester.pumpAndSettle();
    expect(render.text.style.color.opacity, 0.0);
  });

  testWidgets('!pinned && floating && !bottom ==> fade opactiy',
      (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_TestWidget(
      pinned: false,
      floating: true,
      bottom: false,
      controller: controller,
    ));

    final RenderParagraph render =
        tester.renderObject(find.text('Hallo Welt!!1'));
    expect(render.text.style.color.opacity, 1.0);

    controller.jumpTo(200.0);
    await tester.pumpAndSettle();
    expect(render.text.style.color.opacity, 0.0);
  });

  testWidgets('!pinned && floating && bottom ==> fade opactiy',
      (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_TestWidget(
      pinned: false,
      floating: true,
      bottom: true,
      controller: controller,
    ));

    final RenderParagraph render =
        tester.renderObject(find.text('Hallo Welt!!1'));
    expect(render.text.style.color.opacity, 1.0);

    controller.jumpTo(200.0);
    await tester.pumpAndSettle();
    expect(render.text.style.color.opacity, 0.0);
  });

  testWidgets('pinned && !floating && !bottom ==> 1.0 opacity',
      (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_TestWidget(
      pinned: true,
      floating: false,
      bottom: false,
      controller: controller,
    ));

    final RenderParagraph render =
        tester.renderObject(find.text('Hallo Welt!!1'));
    expect(render.text.style.color.opacity, 1.0);

    controller.jumpTo(200.0);
    await tester.pumpAndSettle();
    expect(render.text.style.color.opacity, 1.0);
  });

  testWidgets('pinned && !floating && bottom ==> 1.0 opacity',
      (WidgetTester tester) async {
    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_TestWidget(
      pinned: true,
      floating: false,
      bottom: true,
      controller: controller,
    ));

    final RenderParagraph render =
        tester.renderObject(find.text('Hallo Welt!!1'));
    expect(render.text.style.color.opacity, 1.0);

    controller.jumpTo(200.0);
    await tester.pumpAndSettle();
    expect(render.text.style.color.opacity, 1.0);
  });

  testWidgets('pinned && floating && !bottom ==> 1.0 opacity',
      (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/25000.

    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_TestWidget(
      pinned: true,
      floating: true,
      bottom: false,
      controller: controller,
    ));

    final RenderParagraph render =
        tester.renderObject(find.text('Hallo Welt!!1'));
    expect(render.text.style.color.opacity, 1.0);

    controller.jumpTo(200.0);
    await tester.pumpAndSettle();
    expect(render.text.style.color.opacity, 1.0);
  });

  testWidgets('pinned && floating && bottom ==> fade opactiy',
      (WidgetTester tester) async {
    // Regression test for https://github.com/flutter/flutter/issues/25993.

    final ScrollController controller = ScrollController();
    await tester.pumpWidget(_TestWidget(
      pinned: true,
      floating: true,
      bottom: true,
      controller: controller,
    ));

    final RenderParagraph render =
        tester.renderObject(find.text('Hallo Welt!!1'));
    expect(render.text.style.color.opacity, 1.0);

    controller.jumpTo(200.0);
    await tester.pumpAndSettle();
    expect(render.text.style.color.opacity, 0.0);
  });
}

class _TestWidget extends StatelessWidget {
  const _TestWidget({
    this.pinned,
    this.floating,
    this.bottom,
    this.controller,
  });

  final bool pinned;
  final bool floating;
  final bool bottom;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CustomScrollView(
        controller: controller,
        slivers: <Widget>[
          SliverAppBar(
            pinned: pinned,
            floating: floating,
            expandedHeight: 120.0,
            title: const Text('Hallo Welt!!1'),
            bottom: !bottom
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(35.0),
                    child: Container(),
                  ),
          ),
          SliverList(
            delegate:
                SliverChildListDelegate(List<Widget>.generate(20, (int i) {
              return Container(
                child: Text('Tile $i'),
                height: 100.0,
              );
            })),
          )
        ],
      ),
    );
  }
}
