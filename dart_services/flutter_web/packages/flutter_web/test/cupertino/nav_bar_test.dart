// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced. * Contains Web DELTA *

import 'package:flutter_web/cupertino.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/services.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

import '../flutter_test_alternative.dart';
import '../widgets/semantics_tester.dart';

int count = 0;

void main() {
  testWidgets('Middle still in center with asymmetrical actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoNavigationBar(
          leading: CupertinoButton(child: Text('Something'), onPressed: null,),
          middle: Text('Title'),
        ),
      ),
    );

    // Expect the middle of the title to be exactly in the middle of the screen.
    expect(tester.getCenter(find.text('Title')).dx, 400.0);
  });

  testWidgets('Middle still in center with back button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoNavigationBar(
          middle: Text('Title'),
        ),
      ),
    );

    tester.state<NavigatorState>(find.byType(Navigator)).push(CupertinoPageRoute<void>(
      builder: (BuildContext context) {
        return const CupertinoNavigationBar(
          middle: Text('Page 2'),
        );
      },
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Expect the middle of the title to be exactly in the middle of the screen.
    expect(tester.getCenter(find.text('Page 2')).dx, 400.0);
  });

  testWidgets('Opaque background does not add blur effects', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoNavigationBar(
          middle: Text('Title'),
          backgroundColor: Color(0xFFE5E5E5),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('Non-opaque background adds blur effects', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoNavigationBar(
          middle: Text('Title'),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('Can specify custom padding', (WidgetTester tester) async {
    final Key middleBox = GlobalKey();
    await tester.pumpWidget(
      CupertinoApp(
        home: Align(
          alignment: Alignment.topCenter,
          child: CupertinoNavigationBar(
            leading: const CupertinoButton(child: Text('Cheetah'), onPressed: null),
            // Let the box take all the vertical space to test vertical padding but let
            // the nav bar position it horizontally.
            middle: Align(
              key: middleBox,
              alignment: Alignment.center,
              widthFactor: 1.0,
              child: const Text('Title'),
            ),
            trailing: const CupertinoButton(child: Text('Puma'), onPressed: null),
            padding: const EdgeInsetsDirectional.only(
              start: 10.0,
              end: 20.0,
              top: 3.0,
              bottom: 4.0,
            ),
          ),
        ),
      ),
    );

    expect(tester.getRect(find.byKey(middleBox)).top, 3.0);
    // 44 is the standard height of the nav bar.
    expect(
      tester.getRect(find.byKey(middleBox)).bottom,
      // 44 is the standard height of the nav bar.
      44.0 - 4.0,
    );

    expect(tester.getTopLeft(find.widgetWithText(CupertinoButton, 'Cheetah')).dx, 10.0);
    expect(tester.getTopRight(find.widgetWithText(CupertinoButton, 'Puma')).dx, 800.0 - 20.0);

    // Title is still exactly centered.
    expect(tester.getCenter(find.text('Title')).dx, 400.0);
  });

  testWidgets('Padding works in RTL', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Align(
            alignment: Alignment.topCenter,
            child: CupertinoNavigationBar(
              leading: CupertinoButton(child: Text('Cheetah'), onPressed: null),
              // Let the box take all the vertical space to test vertical padding but let
              // the nav bar position it horizontally.
              middle: Text('Title'),
              trailing: CupertinoButton(child: Text('Puma'), onPressed: null),
              padding: EdgeInsetsDirectional.only(
                start: 10.0,
                end: 20.0,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getTopRight(find.widgetWithText(CupertinoButton, 'Cheetah')).dx, 800.0 - 10.0);
    expect(tester.getTopLeft(find.widgetWithText(CupertinoButton, 'Puma')).dx, 20.0);

    // Title is still exactly centered.
    expect(tester.getCenter(find.text('Title')).dx, 400.0);
  });

  testWidgets('Nav bar uses theme defaults', (WidgetTester tester) async {
    count = 0x000000;
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoNavigationBar(
          leading: CupertinoButton(
            onPressed: () { },
            child: const _ExpectStyles(color: CupertinoColors.activeBlue, index: 0x000001),
          ),
          middle: const _ExpectStyles(color: CupertinoColors.black, index: 0x000100),
          trailing: CupertinoButton(
            onPressed: () { },
            child: const _ExpectStyles(color: CupertinoColors.activeBlue, index: 0x010000),
          ),
        ),
      ),
    );
    expect(count, 0x010101);
  });

  testWidgets('Nav bar respects themes', (WidgetTester tester) async {
    count = 0x000000;
    await tester.pumpWidget(
      CupertinoApp(
        theme: const CupertinoThemeData(brightness: Brightness.dark),
        home: CupertinoNavigationBar(
          leading: CupertinoButton(
            onPressed: () { },
            child: const _ExpectStyles(color: CupertinoColors.activeOrange, index: 0x000001),
          ),
          middle: const _ExpectStyles(color: CupertinoColors.white, index: 0x000100),
          trailing: CupertinoButton(
            onPressed: () { },
            child: const _ExpectStyles(color: CupertinoColors.activeOrange, index: 0x010000),
          ),
        ),
      ),
    );
    expect(count, 0x010101);
  });

  testWidgets('Theme active color can be overriden', (WidgetTester tester) async {
    count = 0x000000;
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoNavigationBar(
          leading: CupertinoButton(
            onPressed: () { },
            child: const _ExpectStyles(color: Color(0xFF001122), index: 0x000001),
          ),
          middle: const _ExpectStyles(color: Color(0xFF000000), index: 0x000100),
          trailing: CupertinoButton(
            onPressed: () { },
            child: const _ExpectStyles(color: Color(0xFF001122), index: 0x010000),
          ),
          actionsForegroundColor: const Color(0xFF001122),
        ),
      ),
    );
    expect(count, 0x010101);
  });

  testWidgets('No slivers with no large titles', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Title'),
          ),
          child: Center(),
        ),
      ),
    );

    expect(find.byType(SliverPersistentHeader), findsNothing);
  });

  testWidgets('Media padding is applied to CupertinoSliverNavigationBar', (WidgetTester tester) async {
    final ScrollController scrollController = ScrollController();
    final Key leadingKey = GlobalKey();
    final Key middleKey = GlobalKey();
    final Key trailingKey = GlobalKey();
    final Key titleKey = GlobalKey();
    await tester.pumpWidget(
      CupertinoApp(
        home: MediaQuery(
          data: const MediaQueryData(
            padding: EdgeInsets.only(
              top: 10.0,
              left: 20.0,
              bottom: 30.0,
              right: 40.0,
            ),
          ),
          child: CupertinoPageScaffold(
            child: CustomScrollView(
              controller: scrollController,
              slivers: <Widget>[
                CupertinoSliverNavigationBar(
                  leading: Placeholder(key: leadingKey),
                  middle: Placeholder(key: middleKey),
                  largeTitle: Text('Large Title', key: titleKey),
                  trailing: Placeholder(key: trailingKey),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 1200.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Media padding applied to leading (T,L), middle (T), trailing (T, R).
    expect(tester.getTopLeft(find.byKey(leadingKey)), const Offset(16.0 + 20.0, 10.0));
    expect(tester.getRect(find.byKey(middleKey)).top, 10.0);
    expect(tester.getTopRight(find.byKey(trailingKey)), const Offset(800.0 - 16.0 - 40.0, 10.0));

    // Top and left padding is applied to large title.
    expect(tester.getTopLeft(find.byKey(titleKey)), const Offset(16.0 + 20.0, 54.0 + 10.0));
  });

  testWidgets('Large title nav bar scrolls', (WidgetTester tester) async {
    final ScrollController scrollController = ScrollController();
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              const CupertinoSliverNavigationBar(
                largeTitle: Text('Title'),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 1200.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(scrollController.offset, 0.0);
    expect(tester.getTopLeft(find.byType(NavigationToolbar)).dy, 0.0);
    expect(tester.getSize(find.byType(NavigationToolbar)).height, 44.0);

    expect(find.text('Title'), findsNWidgets(2)); // Though only one is visible.

    List<Element> titles = tester.elementList(find.text('Title'))
        .toList()
        ..sort((Element a, Element b) {
          final RenderParagraph aParagraph = a.renderObject;
          final RenderParagraph bParagraph = b.renderObject;
          return aParagraph.text.style.fontSize.compareTo(bParagraph.text.style.fontSize);
        });

    Iterable<double> opacities = titles.map<double>((Element element) {
      final RenderAnimatedOpacity renderOpacity = element.ancestorRenderObjectOfType(const TypeMatcher<RenderAnimatedOpacity>());
      return renderOpacity.opacity.value;
    });

    expect(opacities, <double> [
        0.0, // Initially the smaller font title is invisible.
        1.0, // The larger font title is visible.
    ]);

    expect(tester.getTopLeft(find.widgetWithText(OverflowBox, 'Title')).dy, 44.0);
    expect(tester.getSize(find.widgetWithText(OverflowBox, 'Title')).height, 52.0);

    scrollController.jumpTo(600.0);
    await tester.pump(); // Once to trigger the opacity animation.
    await tester.pump(const Duration(milliseconds: 300));

    titles = tester.elementList(find.text('Title'))
        .toList()
        ..sort((Element a, Element b) {
          final RenderParagraph aParagraph = a.renderObject;
          final RenderParagraph bParagraph = b.renderObject;
          return aParagraph.text.style.fontSize.compareTo(bParagraph.text.style.fontSize);
        });

    opacities = titles.map<double>((Element element) {
      final RenderAnimatedOpacity renderOpacity = element.ancestorRenderObjectOfType(const TypeMatcher<RenderAnimatedOpacity>());
      return renderOpacity.opacity.value;
    });

    expect(opacities, <double> [
        1.0, // Smaller font title now visible
        0.0, // Larger font title invisible.
    ]);

    // The persistent toolbar doesn't move or change size.
    expect(tester.getTopLeft(find.byType(NavigationToolbar)).dy, 0.0);
    expect(tester.getSize(find.byType(NavigationToolbar)).height, 44.0);

    expect(tester.getTopLeft(find.widgetWithText(OverflowBox, 'Title')).dy, 44.0);
    // The OverflowBox is squished with the text in it.
    expect(tester.getSize(find.widgetWithText(OverflowBox, 'Title')).height, 0.0);
  });

  testWidgets('User specified middle is always visible in sliver', (WidgetTester tester) async {
    final ScrollController scrollController = ScrollController();
    final Key segmentedControlsKey = UniqueKey();
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                middle: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200.0),
                  child: CupertinoSegmentedControl<int>(
                    key: segmentedControlsKey,
                    children: const <int, Widget>{
                      0: Text('Option A'),
                      1: Text('Option B'),
                    },
                    onValueChanged: (int selected) { },
                    groupValue: 0,
                  ),
                ),
                largeTitle: const Text('Title'),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 1200.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(scrollController.offset, 0.0);
    expect(tester.getTopLeft(find.byType(NavigationToolbar)).dy, 0.0);
    expect(tester.getSize(find.byType(NavigationToolbar)).height, 44.0);

    expect(find.text('Title'), findsOneWidget);
    expect(tester.getCenter(find.byKey(segmentedControlsKey)).dx, 400.0);

    expect(tester.getTopLeft(find.widgetWithText(OverflowBox, 'Title')).dy, 44.0);
    expect(tester.getSize(find.widgetWithText(OverflowBox, 'Title')).height, 52.0);

    scrollController.jumpTo(600.0);
    await tester.pump(); // Once to trigger the opacity animation.
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.getCenter(find.byKey(segmentedControlsKey)).dx, 400.0);
    // The large title is invisible now.
    expect(
      tester.renderObject<RenderAnimatedOpacity>(
        find.widgetWithText(AnimatedOpacity, 'Title')
      ).opacity.value,
      0.0,
    );
  });

  testWidgets('Small title can be overridden', (WidgetTester tester) async {
    final ScrollController scrollController = ScrollController();
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: CustomScrollView(
            controller: scrollController,
            slivers: <Widget>[
              const CupertinoSliverNavigationBar(
                middle: Text('Different title'),
                largeTitle: Text('Title'),
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 1200.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(scrollController.offset, 0.0);
    expect(tester.getTopLeft(find.byType(NavigationToolbar)).dy, 0.0);
    expect(tester.getSize(find.byType(NavigationToolbar)).height, 44.0);

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Different title'), findsOneWidget);

    RenderAnimatedOpacity largeTitleOpacity =
        tester.element(find.text('Title')).ancestorRenderObjectOfType(const TypeMatcher<RenderAnimatedOpacity>());
    // Large title initially visible.
    expect(
      largeTitleOpacity.opacity.value,
      1.0,
    );
    // Middle widget not even wrapped with RenderOpacity, i.e. is always visible.
    expect(
      tester.element(find.text('Different title')).ancestorRenderObjectOfType(const TypeMatcher<RenderOpacity>()),
      isNull,
    );

    expect(tester.getBottomLeft(find.text('Title')).dy, 44.0 + 52.0 - 8.0); // Static part + extension - padding.

    scrollController.jumpTo(600.0);
    await tester.pump(); // Once to trigger the opacity animation.
    await tester.pump(const Duration(milliseconds: 300));

    largeTitleOpacity =
        tester.element(find.text('Title')).ancestorRenderObjectOfType(const TypeMatcher<RenderAnimatedOpacity>());
    // Large title no longer visible.
    expect(
      largeTitleOpacity.opacity.value,
      0.0,
    );

    // The persistent toolbar doesn't move or change size.
    expect(tester.getTopLeft(find.byType(NavigationToolbar)).dy, 0.0);
    expect(tester.getSize(find.byType(NavigationToolbar)).height, 44.0);

    expect(tester.getBottomLeft(find.text('Title')).dy, 44.0 - 8.0); // Extension gone, (static part - padding) left.
  });

  testWidgets('Auto back/close button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoNavigationBar(
          middle: Text('Home page'),
        ),
      ),
    );

    expect(find.byType(CupertinoButton), findsNothing);

    tester.state<NavigatorState>(find.byType(Navigator)).push(CupertinoPageRoute<void>(
      builder: (BuildContext context) {
        return const CupertinoNavigationBar(
          middle: Text('Page 2'),
        );
      },
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CupertinoButton), findsOneWidget);
    expect(find.text(String.fromCharCode(CupertinoIcons.back.codePoint)), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).push(CupertinoPageRoute<void>(
      fullscreenDialog: true,
      builder: (BuildContext context) {
        return const CupertinoNavigationBar(
          middle: Text('Dialog page'),
        );
      },
    ));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.widgetWithText(CupertinoButton, 'Close'), findsOneWidget);

    // Test popping goes back correctly.
    await tester.tap(find.text('Close'));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Page 2'), findsOneWidget);

    await tester.tap(find.text(String.fromCharCode(CupertinoIcons.back.codePoint)));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Home page'), findsOneWidget);
  });

  testWidgets('Long back label turns into "back"', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: Placeholder(),
      ),
    );

    tester.state<NavigatorState>(find.byType(Navigator)).push(
      CupertinoPageRoute<void>(
        builder: (BuildContext context) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              previousPageTitle: '012345678901',
            ),
            child: Placeholder(),
          );
        }
      )
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.widgetWithText(CupertinoButton, '012345678901'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).push(
      CupertinoPageRoute<void>(
        builder: (BuildContext context) {
          return const CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              previousPageTitle: '0123456789012',
            ),
            child: Placeholder(),
          );
        }
      )
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.widgetWithText(CupertinoButton, 'Back'), findsOneWidget);
  });

  testWidgets('Border should be displayed by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoNavigationBar(
          middle: Text('Title'),
        ),
      ),
    );

    final DecoratedBox decoratedBox = tester.widgetList(find.descendant(
      of: find.byType(CupertinoNavigationBar),
      matching: find.byType(DecoratedBox),
    )).first;
    expect(decoratedBox.decoration.runtimeType, BoxDecoration);

    final BoxDecoration decoration = decoratedBox.decoration;
    expect(decoration.border, isNotNull);

    final BorderSide side = decoration.border.bottom;
    expect(side, isNotNull);
  });

  testWidgets('Overrides border color', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoNavigationBar(
          middle: Text('Title'),
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFAABBCC),
              width: 0.0,
            ),
          ),
        ),
      ),
    );

    final DecoratedBox decoratedBox = tester.widgetList(find.descendant(
      of: find.byType(CupertinoNavigationBar),
      matching: find.byType(DecoratedBox),
    )).first;
    expect(decoratedBox.decoration.runtimeType, BoxDecoration);

    final BoxDecoration decoration = decoratedBox.decoration;
    expect(decoration.border, isNotNull);

    final BorderSide side = decoration.border.bottom;
    expect(side, isNotNull);
    expect(side.color, const Color(0xFFAABBCC));
  });

  testWidgets('Border should not be displayed when null', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoNavigationBar(
          middle: Text('Title'),
          border: null,
        ),
      ),
    );

    final DecoratedBox decoratedBox = tester.widgetList(find.descendant(
      of: find.byType(CupertinoNavigationBar),
      matching: find.byType(DecoratedBox),
    )).first;
    expect(decoratedBox.decoration.runtimeType, BoxDecoration);

    final BoxDecoration decoration = decoratedBox.decoration;
    expect(decoration.border, isNull);
  });

  testWidgets('Border is displayed by default in sliver nav bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: Text('Large Title'),
              ),
            ],
          ),
        ),
      ),
    );

    final DecoratedBox decoratedBox = tester.widgetList(find.descendant(
      of: find.byType(CupertinoSliverNavigationBar),
      matching: find.byType(DecoratedBox),
    )).first;
    expect(decoratedBox.decoration.runtimeType, BoxDecoration);

    final BoxDecoration decoration = decoratedBox.decoration;
    expect(decoration.border, isNotNull);

    final BorderSide bottom = decoration.border.bottom;
    expect(bottom, isNotNull);
  });

  testWidgets('Border is not displayed when null in sliver nav bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: Text('Large Title'),
                border: null,
              ),
            ],
          ),
        ),
      ),
    );

    final DecoratedBox decoratedBox = tester.widgetList(find.descendant(
      of: find.byType(CupertinoSliverNavigationBar),
      matching: find.byType(DecoratedBox),
    )).first;
    expect(decoratedBox.decoration.runtimeType, BoxDecoration);

    final BoxDecoration decoration = decoratedBox.decoration;
    expect(decoration.border, isNull);
  });

  testWidgets('CupertinoSliverNavigationBar has semantics', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    await tester.pumpWidget(const CupertinoApp(
      home: CupertinoPageScaffold(
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('Large Title'),
              border: null,
            ),
          ],
        ),
      ),
    ));

    expect(semantics.nodesWith(
      label: 'Large Title',
      flags: <SemanticsFlag>[SemanticsFlag.isHeader],
      textDirection: TextDirection.ltr,
    ), hasLength(1));

    semantics.dispose();
  });

  testWidgets('CupertinoNavigationBar has semantics', (WidgetTester tester) async {
    final SemanticsTester semantics = SemanticsTester(tester);

    await tester.pumpWidget(CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Fixed Title'),
        ),
        child: Container(),
      ),
    ));

    expect(semantics.nodesWith(
      label: 'Fixed Title',
      flags: <SemanticsFlag>[SemanticsFlag.isHeader],
      textDirection: TextDirection.ltr,
    ), hasLength(1));

    semantics.dispose();
  });

  testWidgets('Border can be overridden in sliver nav bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: CustomScrollView(
            slivers: <Widget>[
              CupertinoSliverNavigationBar(
                largeTitle: Text('Large Title'),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFAABBCC),
                    width: 0.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final DecoratedBox decoratedBox = tester.widgetList(find.descendant(
      of: find.byType(CupertinoSliverNavigationBar),
      matching: find.byType(DecoratedBox),
    )).first;
    expect(decoratedBox.decoration.runtimeType, BoxDecoration);

    final BoxDecoration decoration = decoratedBox.decoration;
    expect(decoration.border, isNotNull);

    final BorderSide top = decoration.border.top;
    expect(top, isNotNull);
    expect(top, BorderSide.none);
    final BorderSide bottom = decoration.border.bottom;
    expect(bottom, isNotNull);
    expect(bottom.color, const Color(0xFFAABBCC));
  });

  testWidgets(
    'Standard title golden',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: RepaintBoundary(
            child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text('Bling bling'),
              ),
              child: Center(),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile(
          'nav_bar_test.standard_title.png',
          version: 1,
        ),
      );
    }, skip: isBrowser
  );

  testWidgets(
    'Large title golden',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: RepaintBoundary(
            child: CupertinoPageScaffold(
              child: CustomScrollView(
                slivers: <Widget>[
                  const CupertinoSliverNavigationBar(
                    largeTitle: Text('Bling bling'),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 1200.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(RepaintBoundary).last,
        matchesGoldenFile(
          'nav_bar_test.large_title.png',
          version: 1,
        ),
      );
    }, skip: isBrowser,
  );


  testWidgets('NavBar draws a light system bar for a dark background', (WidgetTester tester) async {
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFFFFFFFF),
        onGenerateRoute: (RouteSettings settings) {
          return CupertinoPageRoute<void>(
            settings: settings,
            builder: (BuildContext context) {
              return const CupertinoNavigationBar(
                middle: Text('Test'),
                backgroundColor: Color(0xFF000000),
              );
            },
          );
        },
      ),
    );
    expect(SystemChrome.latestStyle, SystemUiOverlayStyle.light);
  });

  testWidgets('NavBar draws a dark system bar for a light background', (WidgetTester tester) async {
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFFFFFFFF),
        onGenerateRoute: (RouteSettings settings) {
          return CupertinoPageRoute<void>(
            settings: settings,
            builder: (BuildContext context) {
              return const CupertinoNavigationBar(
                middle: Text('Test'),
                backgroundColor: Color(0xFFFFFFFF),
              );
            },
          );
        },
      ),
    );
    expect(SystemChrome.latestStyle, SystemUiOverlayStyle.dark);
  });

  testWidgets('CupertinoNavigationBarBackButton shows an error when manually added outside a route', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoNavigationBarBackButton()
    );

    final dynamic exception = tester.takeException();
    expect(exception, isAssertionError);
    expect(exception.toString(), contains('CupertinoNavigationBarBackButton should only be used in routes that can be popped'));
  });

  testWidgets('CupertinoNavigationBarBackButton shows an error when placed in a route that cannot be popped', (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoNavigationBarBackButton(),
      ),
    );

    final dynamic exception = tester.takeException();
    expect(exception, isAssertionError);
    expect(exception.toString(), contains('CupertinoNavigationBarBackButton should only be used in routes that can be popped'));
  });

  testWidgets('CupertinoNavigationBarBackButton with a custom onPressed callback can be placed anywhere', (WidgetTester tester) async {
    bool backPressed = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoNavigationBarBackButton(
          onPressed: () => backPressed = true,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(String.fromCharCode(CupertinoIcons.back.codePoint)), findsOneWidget);

    await tester.tap(find.byType(CupertinoNavigationBarBackButton));

    expect(backPressed, true);
  });

  testWidgets(
    'Manually inserted CupertinoNavigationBarBackButton still automatically '
        'show previous page title when possible',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: Placeholder(),
        ),
      );

      tester.state<NavigatorState>(find.byType(Navigator)).push(
        CupertinoPageRoute<void>(
          title: 'An iPod',
          builder: (BuildContext context) {
            return const CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(),
              child: Placeholder(),
            );
          },
        )
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      tester.state<NavigatorState>(find.byType(Navigator)).push(
        CupertinoPageRoute<void>(
          title: 'A Phone',
          builder: (BuildContext context) {
            return const CupertinoNavigationBarBackButton();
          },
        )
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.widgetWithText(CupertinoButton, 'An iPod'), findsOneWidget);
    }
  );

  testWidgets(
    'CupertinoNavigationBarBackButton onPressed overrides default pop behavior',
    (WidgetTester tester) async {
      bool backPressed = false;
      await tester.pumpWidget(
        const CupertinoApp(
          home: Placeholder(),
        ),
      );

      tester.state<NavigatorState>(find.byType(Navigator)).push(
        CupertinoPageRoute<void>(
          title: 'An iPod',
          builder: (BuildContext context) {
            return const CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(),
              child: Placeholder(),
            );
          },
        )
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      tester.state<NavigatorState>(find.byType(Navigator)).push(
        CupertinoPageRoute<void>(
          title: 'A Phone',
          builder: (BuildContext context) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                leading: CupertinoNavigationBarBackButton(
                  onPressed: () => backPressed = true,
                ),
              ),
              child: const Placeholder(),
            );
          },
        )
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // The second page is still on top and didn't pop.
      expect(find.text('A Phone'), findsOneWidget);
      // Custom onPressed called.
      expect(backPressed, true);
    }
  );
}

class _ExpectStyles extends StatelessWidget {
  const _ExpectStyles({ this.color, this.index });

  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = DefaultTextStyle.of(context).style;
    expect(style.color, color);
    expect(style.fontFamily, '.SF Pro Text');
    expect(style.fontSize, 17.0);
    expect(style.letterSpacing, -0.41);
    count += index;
    return Container();
  }
}
