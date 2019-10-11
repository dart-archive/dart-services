// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';

import '../rendering/mock_canvas.dart';
import '../rendering/rendering_tester.dart';

void main() {
  group('construction check', () {
    testWidgets('ListWheelScrollView needs positive diameter ratio',
        (WidgetTester tester) async {
      try {
        ListWheelScrollView(
          diameterRatio: nonconst(-2.0),
          itemExtent: 20.0,
          children: const <Widget>[],
        );
        fail('Expected failure with negative diameterRatio');
      } on AssertionError catch (exception) {
        expect(
            exception.message, contains("You can't set a diameterRatio of 0"));
      }
    });

    testWidgets('ListWheelScrollView needs positive item extent',
        (WidgetTester tester) async {
      expect(
        () {
          ListWheelScrollView(
            itemExtent: null,
            children: <Widget>[Container()],
          );
        },
        throwsAssertionError,
      );
    });

    testWidgets('ListWheelScrollView can have zero child',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            itemExtent: 50.0,
            children: const <Widget>[],
          ),
        ),
      );
      expect(tester.getSize(find.byType(ListWheelScrollView)),
          const Size(800.0, 600.0));
    });

    testWidgets('ListWheelScrollView needs positive magnification',
        (WidgetTester tester) async {
      expect(
        () {
          ListWheelScrollView(
            useMagnifier: true,
            magnification: -1.0,
            itemExtent: 20.0,
            children: <Widget>[Container()],
          );
        },
        throwsAssertionError,
      );
    });
  });

  group('infinite scrolling', () {
    testWidgets('infinite looping list', (WidgetTester tester) async {
      final FixedExtentScrollController controller =
          FixedExtentScrollController();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 100.0,
            onSelectedItemChanged: (_) {},
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(10, (int index) {
                return Container(
                  width: 400.0,
                  height: 100.0,
                  child: Text(index.toString()),
                );
              }),
            ),
          ),
        ),
      );

      // The first item is at the center of the viewport.
      expect(tester.getTopLeft(find.widgetWithText(Container, '0')),
          const Offset(0.0, 250.0));

      // The last item is just before the first item.
      expect(tester.getTopLeft(find.widgetWithText(Container, '9')),
          const Offset(0.0, 150.0));

      controller.jumpTo(1000.0);
      await tester.pump();

      // We have passed the end of the list, the list should have looped back.
      expect(tester.getTopLeft(find.widgetWithText(Container, '0')),
          const Offset(0.0, 250.0));
    });

    testWidgets('infinite child builder', (WidgetTester tester) async {
      final FixedExtentScrollController controller =
          FixedExtentScrollController();

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 100.0,
          onSelectedItemChanged: (_) {},
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (BuildContext context, int index) {
              return Container(
                width: 400.0,
                height: 100.0,
                child: Text(index.toString()),
              );
            },
          ),
        ),
      ));

      // Can be scrolled infinitely for negative indexes.
      controller.jumpTo(-100000.0);
      await tester.pump();
      expect(tester.getTopLeft(find.widgetWithText(Container, '-1000')),
          const Offset(0.0, 250.0));

      // Can be scrolled infinitely for positive indexes.
      controller.jumpTo(100000.0);
      await tester.pump();
      expect(tester.getTopLeft(find.widgetWithText(Container, '1000')),
          const Offset(0.0, 250.0));
    });

    testWidgets('child builder with lower and upper limits',
        (WidgetTester tester) async {
      final List<int> paintedChildren = <int>[];

      final FixedExtentScrollController controller =
          FixedExtentScrollController(initialItem: -10);

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 100.0,
          onSelectedItemChanged: (_) {},
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (BuildContext context, int index) {
              if (index < -15 || index > -5) return null;
              return Container(
                width: 400.0,
                height: 100.0,
                child: CustomPaint(
                  painter: TestCallbackPainter(onPaint: () {
                    paintedChildren.add(index);
                  }),
                ),
              );
            },
          ),
        ),
      ));

      expect(paintedChildren, <int>[-13, -12, -11, -10, -9, -8, -7]);

      // Flings with high velocity and stop at the lower limit.
      paintedChildren.clear();
      await tester.fling(
        find.byType(ListWheelScrollView),
        const Offset(0.0, 1000.0),
        1000.0,
      );
      await tester.pumpAndSettle();
      expect(controller.selectedItem, -15);

      // Flings with high velocity and stop at the upper limit.
      await tester.fling(
        find.byType(ListWheelScrollView),
        const Offset(0.0, -1000.0),
        1000.0,
      );
      await tester.pumpAndSettle();
      expect(controller.selectedItem, -5);
    });
  });

  group('layout', () {
    testWidgets("ListWheelScrollView takes parent's size with small children",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            // Inner children smaller than the outer window.
            itemExtent: 50.0,
            children: <Widget>[
              Container(
                height: 50.0,
                color: const Color(0xFFFFFFFF),
              ),
            ],
          ),
        ),
      );
      expect(tester.getTopLeft(find.byType(ListWheelScrollView)),
          const Offset(0.0, 0.0));
      // Standard test screen size.
      expect(tester.getBottomRight(find.byType(ListWheelScrollView)),
          const Offset(800.0, 600.0));
    });

    testWidgets("ListWheelScrollView takes parent's size with large children",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            // Inner children 5000.0px.
            itemExtent: 50.0,
            children: List<Widget>.generate(100, (int index) {
              return Container(
                height: 50.0,
                color: const Color(0xFFFFFFFF),
              );
            }),
          ),
        ),
      );
      expect(tester.getTopLeft(find.byType(ListWheelScrollView)),
          const Offset(0.0, 0.0));
      // Still fills standard test screen size.
      expect(tester.getBottomRight(find.byType(ListWheelScrollView)),
          const Offset(800.0, 600.0));
    });

    testWidgets("ListWheelScrollView children can't be bigger than itemExtent",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            itemExtent: 50.0,
            children: const <Widget>[
              SizedBox(
                height: 200.0,
                width: 200.0,
                child: Center(
                  child: Text('blah'),
                ),
              ),
            ],
          ),
        ),
      );
      expect(tester.getSize(find.byType(SizedBox)), const Size(200.0, 50.0));
      expect(find.text('blah'), findsOneWidget);
    });

    testWidgets('builder is never called twice for same index',
        (WidgetTester tester) async {
      final Set<int> builtChildren = Set<int>();
      final FixedExtentScrollController controller =
          FixedExtentScrollController();

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 100.0,
          onSelectedItemChanged: (_) {},
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (BuildContext context, int index) {
              expect(builtChildren.contains(index), false);
              builtChildren.add(index);

              return Container(
                width: 400.0,
                height: 100.0,
                child: Text(index.toString()),
              );
            },
          ),
        ),
      ));

      // Scrolls up and down to check if builder is called twice.
      controller.jumpTo(-10000.0);
      await tester.pump();
      controller.jumpTo(10000.0);
      await tester.pump();
      controller.jumpTo(-10000.0);
      await tester.pump();
    });

    testWidgets(
        'only visible children are maintained as children of the rendered viewport',
        (WidgetTester tester) async {
      final FixedExtentScrollController controller =
          FixedExtentScrollController();

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: ListWheelScrollView(
          controller: controller,
          itemExtent: 100.0,
          onSelectedItemChanged: (_) {},
          children: List<Widget>.generate(16, (int index) {
            return Text(index.toString());
          }),
        ),
      ));

      final RenderListWheelViewport viewport =
          tester.firstRenderObject(find.byType(Text)).parent.parent;

      // Item 0 is in the middle. There are 3 children visible after it, so the
      // value of childCount should be 4.
      expect(viewport.childCount, 4);

      controller.jumpToItem(8);
      await tester.pump();
      // Item 8 is in the middle. There are 3 children visible before it and 3
      // after it, so the value of childCount should be 7.
      expect(viewport.childCount, 7);

      controller.jumpToItem(15);
      await tester.pump();
      // Item 15 is in the middle. There are 3 children visible before it, so the
      // value of childCount should be 4.
      expect(viewport.childCount, 4);
    });
  });

  group('pre-transform viewport', () {
    testWidgets('ListWheelScrollView starts and ends from the middle',
        (WidgetTester tester) async {
      final ScrollController controller = ScrollController();
      final List<int> paintedChildren = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            children: List<Widget>.generate(100, (int index) {
              return CustomPaint(
                painter: TestCallbackPainter(onPaint: () {
                  paintedChildren.add(index);
                }),
              );
            }),
          ),
        ),
      );

      // Screen is 600px tall and the first item starts at 250px. The first 4
      // children are visible.
      expect(paintedChildren, <int>[0, 1, 2, 3]);

      controller.jumpTo(1000.0);
      paintedChildren.clear();

      await tester.pump();
      // Item number 10 is now in the middle of the screen at 250px. 9, 8, 7 are
      // visible before it and 11, 12, 13 are visible after it.
      expect(paintedChildren, <int>[7, 8, 9, 10, 11, 12, 13]);

      // Move to the last item.
      controller.jumpTo(9900.0);
      paintedChildren.clear();

      await tester.pump();
      // Item 99 is in the middle at 250px.
      expect(paintedChildren, <int>[96, 97, 98, 99]);
    });

    testWidgets(
        'A child gets painted as soon as its first pixel is in the viewport',
        (WidgetTester tester) async {
      final ScrollController controller =
          ScrollController(initialScrollOffset: 50.0);
      final List<int> paintedChildren = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            children: List<Widget>.generate(10, (int index) {
              return CustomPaint(
                painter: TestCallbackPainter(onPaint: () {
                  paintedChildren.add(index);
                }),
              );
            }),
          ),
        ),
      );

      // Screen is 600px tall and the first item starts at 200px. The first 4
      // children are visible.
      expect(paintedChildren, <int>[0, 1, 2, 3]);

      paintedChildren.clear();
      // Move down by 1px.
      await tester.drag(
          find.byType(ListWheelScrollView), const Offset(0.0, -1.0));
      await tester.pump();

      // Now the first pixel of item 5 enters the viewport.
      expect(paintedChildren, <int>[0, 1, 2, 3, 4]);
    });

    testWidgets(
        'A child is no longer painted after its last pixel leaves the viewport',
        (WidgetTester tester) async {
      final ScrollController controller =
          ScrollController(initialScrollOffset: 250.0);
      final List<int> paintedChildren = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            children: List<Widget>.generate(10, (int index) {
              return CustomPaint(
                painter: TestCallbackPainter(onPaint: () {
                  paintedChildren.add(index);
                }),
              );
            }),
          ),
        ),
      );

      // The first item is at 0px and the 600px screen is full in the
      // **untransformed plane's viewport painting coordinates**
      expect(paintedChildren, <int>[0, 1, 2, 3, 4, 5]);

      paintedChildren.clear();
      // Go down another 99px.
      controller.jumpTo(349.0);
      await tester.pump();

      // One more item now visible with the last pixel of 0 showing.
      expect(paintedChildren, <int>[0, 1, 2, 3, 4, 5, 6]);

      paintedChildren.clear();
      // Go down one more pixel.
      controller.jumpTo(350.0);
      await tester.pump();

      // Item 0 no longer visible.
      expect(paintedChildren, <int>[1, 2, 3, 4, 5, 6]);
    });
  });

  group('viewport transformation', () {
    testWidgets('Center child is magnified', (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: const Key('list_wheel_scroll_view'),
            child: ListWheelScrollView(
              useMagnifier: true,
              magnification: 2.0,
              itemExtent: 50.0,
              children: List<Widget>.generate(10, (int index) {
                return const Placeholder();
              }),
            ),
          ),
        ),
      );

      await expectLater(
          find.byKey(const Key('list_wheel_scroll_view')),
          matchesGoldenFile(
              'list_wheel_scroll_view.center_child.magnified.png'),
          skip: true);
    }, skip: true);

    testWidgets('Default middle transform', (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            itemExtent: 100.0,
            children: <Widget>[
              Container(
                width: 200.0,
                child: const Center(
                  child: Text('blah'),
                ),
              ),
            ],
          ),
        ),
      );

      final RenderListWheelViewport viewport =
          tester.firstRenderObject(find.byType(Container)).parent.parent;
      expect(
          viewport,
          paints
            ..transform(
              matrix4: equals(<dynamic>[
                1.0,
                0.0,
                0.0,
                0.0,
                0.0,
                1.0,
                0.0,
                0.0,
                -1.2 /* origin centering multiplied */,
                -0.9 /* origin centering multiplied*/,
                1.0,
                -0.003 /* inverse of perspective */,
                moreOrLessEquals(0.0),
                moreOrLessEquals(0.0),
                0.0,
                moreOrLessEquals(1.0),
              ]),
            ));
    });

    testWidgets('Curve the wheel to the left', (WidgetTester tester) async {
      final ScrollController controller =
          ScrollController(initialScrollOffset: 300.0);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: RepaintBoundary(
            key: const Key('list_wheel_scroll_view'),
            child: ListWheelScrollView(
              controller: controller,
              offAxisFraction: 0.5,
              itemExtent: 50.0,
              children: List<Widget>.generate(32, (int index) {
                return const Placeholder();
              }),
            ),
          ),
        ),
      );

      await expectLater(
        find.byKey(const Key('list_wheel_scroll_view')),
        matchesGoldenFile('list_wheel_scroll_view.curved_wheel.left.png'),
        skip: true,
      );
    }, skip: true);

    testWidgets('Scrolling, diameterRatio, perspective all changes matrix',
        (WidgetTester tester) async {
      final ScrollController controller =
          ScrollController(initialScrollOffset: 200.0);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            children: <Widget>[
              Container(
                width: 200.0,
                child: const Center(
                  child: Text('blah'),
                ),
              ),
            ],
          ),
        ),
      );

      final RenderListWheelViewport viewport =
          tester.firstRenderObject(find.byType(Container)).parent.parent;
      expect(
          viewport,
          paints
            ..transform(
              matrix4: equals(<dynamic>[
                1.0,
                0.0,
                0.0,
                0.0,
                moreOrLessEquals(-0.41042417199080244),
                moreOrLessEquals(0.6318744917928065),
                moreOrLessEquals(0.3420201433256687),
                moreOrLessEquals(-0.0010260604299770061),
                moreOrLessEquals(-1.12763114494309),
                moreOrLessEquals(-1.1877435020329863),
                moreOrLessEquals(0.9396926207859084),
                moreOrLessEquals(-0.0028190778623577253),
                moreOrLessEquals(166.54856463138663),
                moreOrLessEquals(-62.20844875763376),
                moreOrLessEquals(-138.79047052615562),
                moreOrLessEquals(1.4163714115784667),
              ]),
            ));

      // Increase diameter.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            diameterRatio: 3.0,
            itemExtent: 100.0,
            children: <Widget>[
              Container(
                width: 200.0,
                child: const Center(
                  child: Text('blah'),
                ),
              ),
            ],
          ),
        ),
      );

      expect(
          viewport,
          paints
            ..transform(
              matrix4: equals(<dynamic>[
                1.0,
                0.0,
                0.0,
                0.0,
                moreOrLessEquals(-0.26954971336161726),
                moreOrLessEquals(0.7722830529455648),
                moreOrLessEquals(0.22462476113468105),
                moreOrLessEquals(-0.0006738742834040432),
                moreOrLessEquals(-1.1693344055601331),
                moreOrLessEquals(-1.101625565304781),
                moreOrLessEquals(0.9744453379667777),
                moreOrLessEquals(-0.002923336013900333),
                moreOrLessEquals(108.46394900436536),
                moreOrLessEquals(-113.14792465797223),
                moreOrLessEquals(-90.38662417030434),
                moreOrLessEquals(1.2711598725109134),
              ]),
            ));

      // Decrease perspective.
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            perspective: 0.0001,
            itemExtent: 100.0,
            children: <Widget>[
              Container(
                width: 200.0,
                child: const Center(
                  child: Text('blah'),
                ),
              ),
            ],
          ),
        ),
      );

      expect(
          viewport,
          paints
            ..transform(
              matrix4: equals(<dynamic>[
                1.0,
                0.0,
                0.0,
                0.0,
                moreOrLessEquals(-0.01368080573302675),
                moreOrLessEquals(0.9294320164861384),
                moreOrLessEquals(0.3420201433256687),
                moreOrLessEquals(-0.000034202014332566874),
                moreOrLessEquals(-0.03758770483143634),
                moreOrLessEquals(-0.370210921949246),
                moreOrLessEquals(0.9396926207859084),
                moreOrLessEquals(-0.00009396926207859085),
                moreOrLessEquals(5.551618821046304),
                moreOrLessEquals(-182.95615811538906),
                moreOrLessEquals(-138.79047052615562),
                moreOrLessEquals(1.0138790470526158),
              ]),
            ));

      // Scroll a bit.
      controller.jumpTo(300.0);
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            children: <Widget>[
              Container(
                width: 200.0,
                child: const Center(
                  child: Text('blah'),
                ),
              ),
            ],
          ),
        ),
      );

      expect(
          viewport,
          paints
            ..transform(
              matrix4: equals(<dynamic>[
                1.0,
                0.0,
                0.0,
                0.0,
                -0.6,
                moreOrLessEquals(0.41602540378443875),
                moreOrLessEquals(0.5),
                moreOrLessEquals(-0.0015),
                moreOrLessEquals(-1.0392304845413265),
                moreOrLessEquals(-1.2794228634059948),
                moreOrLessEquals(0.8660254037844387),
                moreOrLessEquals(-0.0025980762113533163),
                moreOrLessEquals(276.46170927520404),
                moreOrLessEquals(-52.46133917892857),
                moreOrLessEquals(-230.38475772933677),
                moreOrLessEquals(1.69115427318801),
              ]),
            ));
    });

    testWidgets('offAxisFraction, magnification changes matrix',
        (WidgetTester tester) async {
      final ScrollController controller =
          ScrollController(initialScrollOffset: 200.0);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            offAxisFraction: 0.5,
            children: <Widget>[
              Container(
                width: 200.0,
                child: const Center(
                  child: Text('blah'),
                ),
              ),
            ],
          ),
        ),
      );

      final RenderListWheelViewport viewport =
          tester.firstRenderObject(find.byType(Container)).parent.parent;
      expect(
          viewport,
          paints
            ..transform(
              matrix4: equals(<dynamic>[
                1.0,
                0.0,
                0.0,
                0.0,
                0.0,
                moreOrLessEquals(0.6318744917928063),
                moreOrLessEquals(0.3420201433256688),
                moreOrLessEquals(-0.0010260604299770066),
                0.0,
                moreOrLessEquals(-1.1877435020329863),
                moreOrLessEquals(0.9396926207859083),
                moreOrLessEquals(-0.002819077862357725),
                0.0,
                moreOrLessEquals(-62.20844875763376),
                moreOrLessEquals(-138.79047052615562),
                moreOrLessEquals(1.4163714115784667),
              ]),
            ));

      controller.jumpTo(0.0);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            offAxisFraction: 0.5,
            useMagnifier: true,
            magnification: 1.5,
            children: <Widget>[
              Container(
                width: 200.0,
                child: const Center(
                  child: Text('blah'),
                ),
              ),
            ],
          ),
        ),
      );

      expect(
          viewport,
          paints
            ..transform(
              matrix4: equals(<dynamic>[
                1.5,
                0.0,
                0.0,
                0.0,
                0.0,
                1.5,
                0.0,
                0.0,
                0.0,
                0.0,
                1.5,
                0.0,
                0.0,
                -150.0,
                0.0,
                1.0,
              ]),
            ));
    });
  });

  group('scroll notifications', () {
    testWidgets('no onSelectedItemChanged callback on first build',
        (WidgetTester tester) async {
      bool itemChangeCalled = false;
      final ValueChanged<int> onItemChange = (_) {
        itemChangeCalled = true;
      };

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            itemExtent: 100.0,
            onSelectedItemChanged: onItemChange,
            children: <Widget>[
              Container(
                width: 200.0,
                child: const Center(
                  child: Text('blah'),
                ),
              ),
            ],
          ),
        ),
      );

      expect(itemChangeCalled, false);
    });

    testWidgets('onSelectedItemChanged when a new item is closest to center',
        (WidgetTester tester) async {
      final List<int> selectedItems = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            itemExtent: 100.0,
            onSelectedItemChanged: (int index) {
              selectedItems.add(index);
            },
            children: List<Widget>.generate(10, (int index) {
              return const Placeholder();
            }),
          ),
        ),
      );

      final TestGesture scrollGesture =
          await tester.startGesture(const Offset(10.0, 10.0));
      // Item 0 is still closest to the center. No updates.
      await scrollGesture.moveBy(const Offset(0.0, -49.0));
      expect(selectedItems.isEmpty, true);

      // Now item 1 is closest to the center.
      await scrollGesture.moveBy(const Offset(0.0, -1.0));
      expect(selectedItems, <int>[1]);

      // Now item 1 is still closest to the center for another full itemExtent (100px).
      await scrollGesture.moveBy(const Offset(0.0, -99.0));
      expect(selectedItems, <int>[1]);

      await scrollGesture.moveBy(const Offset(0.0, -1.0));
      expect(selectedItems, <int>[1, 2]);

      // Going back triggers previous item indices.
      await scrollGesture.moveBy(const Offset(0.0, 50.0));
      expect(selectedItems, <int>[1, 2, 1]);
    });

    testWidgets('onSelectedItemChanged reports only in valid range',
        (WidgetTester tester) async {
      final List<int> selectedItems = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            itemExtent: 100.0,
            onSelectedItemChanged: (int index) {
              selectedItems.add(index);
            },
            // So item 0 is at 0 and item 9 is at 900 in the scrollable range.
            children: List<Widget>.generate(10, (int index) {
              return const Placeholder();
            }),
          ),
        ),
      );

      final TestGesture scrollGesture =
          await tester.startGesture(const Offset(10.0, 10.0));

      // First move back past the beginning.
      await scrollGesture.moveBy(const Offset(0.0, 70.0));

      for (double verticalOffset = 0.0;
          verticalOffset > -2000.0;
          verticalOffset -= 10.0) {
        // Then gradually move down by a total vertical extent much higher than
        // the scrollable extent.
        await scrollGesture.moveTo(Offset(0.0, verticalOffset));
      }

      // The list should only cover the list of valid items. Item 0 would not
      // be included because the current item never left the 0 index until it
      // went to 1.
      expect(selectedItems, <int>[1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });
  });

  group('scroll controller', () {
    testWidgets('initialItem', (WidgetTester tester) async {
      final FixedExtentScrollController controller =
          FixedExtentScrollController(initialItem: 10);
      final List<int> paintedChildren = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            children: List<Widget>.generate(100, (int index) {
              return CustomPaint(
                painter: TestCallbackPainter(onPaint: () {
                  paintedChildren.add(index);
                }),
              );
            }),
          ),
        ),
      );

      // Screen is 600px tall. Item 10 is in the center and each item is 100px tall.
      expect(paintedChildren, <int>[7, 8, 9, 10, 11, 12, 13]);
      expect(controller.selectedItem, 10);
    });

    testWidgets('controller jump', (WidgetTester tester) async {
      final FixedExtentScrollController controller =
          FixedExtentScrollController(initialItem: 10);
      final List<int> paintedChildren = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            children: List<Widget>.generate(100, (int index) {
              return CustomPaint(
                painter: TestCallbackPainter(onPaint: () {
                  paintedChildren.add(index);
                }),
              );
            }),
          ),
        ),
      );

      // Screen is 600px tall. Item 10 is in the center and each item is 100px tall.
      expect(paintedChildren, <int>[7, 8, 9, 10, 11, 12, 13]);

      paintedChildren.clear();
      controller.jumpToItem(0);
      await tester.pump();

      expect(paintedChildren, <int>[0, 1, 2, 3]);
      expect(controller.selectedItem, 0);
    });

    testWidgets('controller animateToItem', (WidgetTester tester) async {
      final FixedExtentScrollController controller =
          FixedExtentScrollController(initialItem: 10);
      final List<int> paintedChildren = <int>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            children: List<Widget>.generate(100, (int index) {
              return CustomPaint(
                painter: TestCallbackPainter(onPaint: () {
                  paintedChildren.add(index);
                }),
              );
            }),
          ),
        ),
      );

      // Screen is 600px tall. Item 10 is in the center and each item is 100px tall.
      expect(paintedChildren, <int>[7, 8, 9, 10, 11, 12, 13]);

      paintedChildren.clear();
      controller.animateToItem(
        0,
        duration: const Duration(seconds: 1),
        curve: Curves.linear,
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(paintedChildren, <int>[0, 1, 2, 3]);
      expect(controller.selectedItem, 0);
    });

    testWidgets('onSelectedItemChanged and controller are in sync',
        (WidgetTester tester) async {
      final List<int> selectedItems = <int>[];
      final FixedExtentScrollController controller =
          FixedExtentScrollController(initialItem: 10);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: controller,
            itemExtent: 100.0,
            onSelectedItemChanged: (int index) {
              selectedItems.add(index);
            },
            children: List<Widget>.generate(100, (int index) {
              return const Placeholder();
            }),
          ),
        ),
      );

      final TestGesture scrollGesture =
          await tester.startGesture(const Offset(10.0, 10.0));
      await scrollGesture.moveBy(const Offset(0.0, -49.0));
      await tester.pump();
      expect(selectedItems.isEmpty, true);
      expect(controller.selectedItem, 10);

      await scrollGesture.moveBy(const Offset(0.0, -1.0));
      await tester.pump();
      expect(selectedItems, <int>[11]);
      expect(controller.selectedItem, 11);

      await scrollGesture.moveBy(const Offset(0.0, 70.0));
      await tester.pump();
      expect(selectedItems, <int>[11, 10]);
      expect(controller.selectedItem, 10);
    });

    testWidgets('controller hot swappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            itemExtent: 100.0,
            children: List<Widget>.generate(100, (int index) {
              return const Placeholder();
            }),
          ),
        ),
      );

      // Item 5 is now selected.
      await tester.drag(
          find.byType(ListWheelScrollView), const Offset(0.0, -500.0));
      await tester.pump();

      final FixedExtentScrollController newController =
          FixedExtentScrollController(initialItem: 30);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            controller: newController,
            itemExtent: 100.0,
            children: List<Widget>.generate(100, (int index) {
              return const Placeholder();
            }),
          ),
        ),
      );

      // initialItem doesn't do anything since the scroll position was already
      // created.
      expect(newController.selectedItem, 5);

      newController.jumpToItem(50);
      expect(newController.selectedItem, 50);
      expect(newController.position.pixels, 5000.0);

      // Now remove the controller
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListWheelScrollView(
            itemExtent: 100.0,
            children: List<Widget>.generate(100, (int index) {
              return const Placeholder();
            }),
          ),
        ),
      );

      // Internally, that same controller is still attached and still at the
      // same place.
      expect(newController.selectedItem, 50);
    });
  });

  group('physics', () {
    testWidgets('fling velocities too low snaps back to the same item',
        (WidgetTester tester) async {
      final FixedExtentScrollController controller =
          FixedExtentScrollController(initialItem: 40);
      final List<double> scrolledPositions = <double>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification)
                scrolledPositions.add(notification.metrics.pixels);
              return false;
            },
            child: ListWheelScrollView(
              controller: controller,
              physics: const FixedExtentScrollPhysics(),
              itemExtent: 1000.0,
              children: List<Widget>.generate(100, (int index) {
                return const Placeholder();
              }),
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(ListWheelScrollView),
        const Offset(0.0, -50.0),
        800.0,
      );

      // At this moment, the ballistics is started but 50px is still inside the
      // initial item.
      expect(controller.selectedItem, 40);
      // A tester.fling creates and pumps 50 pointer events.
      expect(scrolledPositions.length, 50);
      expect(scrolledPositions.last,
          moreOrLessEquals(40 * 1000.0 + 50.0, epsilon: 0.2));

      // Let the spring back simulation finish.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // The simulation actually did stuff after start ballistics.
      expect(scrolledPositions.length, greaterThan(50));
      // Though it still lands back to the same item with the same scroll offset.
      expect(controller.selectedItem, 40);
      expect(
          scrolledPositions.last, moreOrLessEquals(40 * 1000.0, epsilon: 0.2));
    });

    testWidgets('high fling velocities lands exactly on items',
        (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final FixedExtentScrollController controller =
          FixedExtentScrollController(initialItem: 40);
      final List<double> scrolledPositions = <double>[];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification)
                scrolledPositions.add(notification.metrics.pixels);
              return false;
            },
            child: ListWheelScrollView(
              controller: controller,
              physics: const FixedExtentScrollPhysics(),
              itemExtent: 100.0,
              children: List<Widget>.generate(100, (int index) {
                return const Placeholder();
              }),
            ),
          ),
        ),
      );

      await tester.fling(
        find.byType(ListWheelScrollView),
        // High and random numbers that's unlikely to land on exact multiples of 100.
        const Offset(0.0, -567.0),
        678.0,
      );

      // After the drag, 40 + 567px should be on the 46th item.
      expect(controller.selectedItem, 46);
      // A tester.fling creates and pumps 50 pointer events.
      expect(scrolledPositions.length, 50);
      // iOS flings ease-in initially.
      expect(scrolledPositions.last,
          moreOrLessEquals(40 * 100.0 + 556.826666666673, epsilon: 0.2));

      // Let the spring back simulation finish.
      await tester.pumpAndSettle();

      // The simulation actually did stuff after start ballistics.
      expect(scrolledPositions.length, greaterThan(50));
      // Lands on 49.
      expect(controller.selectedItem, 49);
      // More importantly, lands tightly on 49.
      expect(
          scrolledPositions.last, moreOrLessEquals(49 * 100.0, epsilon: 0.3));

      debugDefaultTargetPlatformOverride = null;
    });
  });

  testWidgets('ListWheelScrollView getOffsetToReveal',
      (WidgetTester tester) async {
    List<Widget> outerChildren;
    final List<Widget> innerChildren = List<Widget>(10);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Container(
            height: 500.0,
            width: 300.0,
            child: ListWheelScrollView(
              controller: ScrollController(initialScrollOffset: 300.0),
              itemExtent: 100.0,
              children: outerChildren = List<Widget>.generate(10, (int i) {
                return Container(
                  child: Center(
                    child: innerChildren[i] = Container(
                      height: 50.0,
                      width: 50.0,
                      child: Text('Item $i'),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );

    final RenderListWheelViewport viewport = tester.allRenderObjects
        .firstWhere((RenderObject r) => r is RenderListWheelViewport);

    // direct child of viewport
    RenderObject target = tester.renderObject(find.byWidget(outerChildren[5]));
    RevealedOffset revealed = viewport.getOffsetToReveal(target, 0.0);
    expect(revealed.offset, 500.0);
    expect(revealed.rect, Rect.fromLTWH(0.0, 200.0, 300.0, 100.0));

    revealed = viewport.getOffsetToReveal(target, 1.0);
    expect(revealed.offset, 500.0);
    expect(revealed.rect, Rect.fromLTWH(0.0, 200.0, 300.0, 100.0));

    revealed = viewport.getOffsetToReveal(target, 0.0,
        rect: Rect.fromLTWH(40.0, 40.0, 10.0, 10.0));
    expect(revealed.offset, 500.0);
    expect(revealed.rect, Rect.fromLTWH(40.0, 240.0, 10.0, 10.0));

    revealed = viewport.getOffsetToReveal(target, 1.0,
        rect: Rect.fromLTWH(40.0, 40.0, 10.0, 10.0));
    expect(revealed.offset, 500.0);
    expect(revealed.rect, Rect.fromLTWH(40.0, 240.0, 10.0, 10.0));

    // descendant of viewport, not direct child
    target = tester.renderObject(find.byWidget(innerChildren[5]));
    revealed = viewport.getOffsetToReveal(target, 0.0);
    expect(revealed.offset, 500.0);
    expect(revealed.rect, Rect.fromLTWH(125.0, 225.0, 50.0, 50.0));

    revealed = viewport.getOffsetToReveal(target, 1.0);
    expect(revealed.offset, 500.0);
    expect(revealed.rect, Rect.fromLTWH(125.0, 225.0, 50.0, 50.0));

    revealed = viewport.getOffsetToReveal(target, 0.0,
        rect: Rect.fromLTWH(40.0, 40.0, 10.0, 10.0));
    expect(revealed.offset, 500.0);
    expect(revealed.rect, Rect.fromLTWH(165.0, 265.0, 10.0, 10.0));

    revealed = viewport.getOffsetToReveal(target, 1.0,
        rect: Rect.fromLTWH(40.0, 40.0, 10.0, 10.0));
    expect(revealed.offset, 500.0);
    expect(revealed.rect, Rect.fromLTWH(165.0, 265.0, 10.0, 10.0));
  });

  testWidgets('ListWheelScrollView showOnScreen', (WidgetTester tester) async {
    List<Widget> outerChildren;
    final List<Widget> innerChildren = List<Widget>(10);
    ScrollController controller;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Container(
            height: 500.0,
            width: 300.0,
            child: ListWheelScrollView(
              controller: controller =
                  ScrollController(initialScrollOffset: 300.0),
              itemExtent: 100.0,
              children: outerChildren = List<Widget>.generate(10, (int i) {
                return Container(
                  child: Center(
                    child: innerChildren[i] = Container(
                      height: 50.0,
                      width: 50.0,
                      child: Text('Item $i'),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );

    expect(controller.offset, 300.0);

    tester.renderObject(find.byWidget(outerChildren[5])).showOnScreen();
    await tester.pumpAndSettle();
    expect(controller.offset, 500.0);

    tester.renderObject(find.byWidget(outerChildren[7])).showOnScreen();
    await tester.pumpAndSettle();
    expect(controller.offset, 700.0);

    tester.renderObject(find.byWidget(innerChildren[9])).showOnScreen();
    await tester.pumpAndSettle();
    expect(controller.offset, 900.0);

    tester
        .renderObject(find.byWidget(outerChildren[7]))
        .showOnScreen(duration: const Duration(seconds: 2));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isTrue);
    expect(controller.offset, lessThan(900.0));
    expect(controller.offset, greaterThan(700.0));
    await tester.pumpAndSettle();
    expect(controller.offset, 700.0);
  });
}
