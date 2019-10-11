// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(yjbanov): in the Flutter version this test expects different text sizes.
import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

// TODO(yjbanov): port.
// import '../painting/image_data.dart';

void main() {
  testWidgets('CircleAvatar with dark background color',
      (WidgetTester tester) async {
    final Color backgroundColor = Colors.blue.shade900;
    await tester.pumpWidget(
      wrap(
        child: new CircleAvatar(
          backgroundColor: backgroundColor,
          radius: 50.0,
          child: const Text('Z'),
        ),
      ),
    );

    final RenderConstrainedBox box =
        tester.renderObject(find.byType(CircleAvatar));
    expect(box.size, equals(const Size(100.0, 100.0)));
    final RenderDecoratedBox child = box.child;
    final BoxDecoration decoration = child.decoration;
    expect(decoration.color, equals(backgroundColor));

    final RenderParagraph paragraph = tester.renderObject(find.text('Z'));
    expect(paragraph.text.style.color,
        equals(new ThemeData.fallback().primaryColorLight));
  });

  testWidgets('CircleAvatar with light background color',
      (WidgetTester tester) async {
    final Color backgroundColor = Colors.blue.shade100;
    await tester.pumpWidget(
      wrap(
        child: new CircleAvatar(
          backgroundColor: backgroundColor,
          radius: 50.0,
          child: const Text('Z'),
        ),
      ),
    );

    final RenderConstrainedBox box =
        tester.renderObject(find.byType(CircleAvatar));
    expect(box.size, equals(const Size(100.0, 100.0)));
    final RenderDecoratedBox child = box.child;
    final BoxDecoration decoration = child.decoration;
    expect(decoration.color, equals(backgroundColor));

    final RenderParagraph paragraph = tester.renderObject(find.text('Z'));
    expect(paragraph.text.style.color,
        equals(new ThemeData.fallback().primaryColorDark));
  });

  // TODO(yjbanov): port.
//  testWidgets('CircleAvatar with image background', (WidgetTester tester) async {
//    await tester.pumpWidget(
//      wrap(
//        child: new CircleAvatar(
//          backgroundImage: new MemoryImage(new Uint8List.fromList(kTransparentImage)),
//          radius: 50.0,
//        ),
//      ),
//    );
//
//    final RenderConstrainedBox box = tester.renderObject(find.byType(CircleAvatar));
//    expect(box.size, equals(const Size(100.0, 100.0)));
//    final RenderDecoratedBox child = box.child;
//    final BoxDecoration decoration = child.decoration;
//    expect(decoration.image.fit, equals(BoxFit.cover));
//  });

  testWidgets('CircleAvatar with foreground color',
      (WidgetTester tester) async {
    final Color foregroundColor = Colors.red.shade100;
    await tester.pumpWidget(
      wrap(
        child: new CircleAvatar(
          foregroundColor: foregroundColor,
          child: const Text('Z'),
        ),
      ),
    );

    final ThemeData fallback = new ThemeData.fallback();

    final RenderConstrainedBox box =
        tester.renderObject(find.byType(CircleAvatar));
    expect(box.size, equals(const Size(40.0, 40.0)));
    final RenderDecoratedBox child = box.child;
    final BoxDecoration decoration = child.decoration;
    expect(decoration.color, equals(fallback.primaryColorDark));

    final RenderParagraph paragraph = tester.renderObject(find.text('Z'));
    expect(paragraph.text.style.color, equals(foregroundColor));
  });

  testWidgets('CircleAvatar with light theme', (WidgetTester tester) async {
    final ThemeData theme = new ThemeData(
      primaryColor: Colors.grey.shade100,
      primaryColorBrightness: Brightness.light,
    );
    await tester.pumpWidget(
      wrap(
        child: new Theme(
          data: theme,
          child: const CircleAvatar(
            child: const Text('Z'),
          ),
        ),
      ),
    );

    final RenderConstrainedBox box =
        tester.renderObject(find.byType(CircleAvatar));
    final RenderDecoratedBox child = box.child;
    final BoxDecoration decoration = child.decoration;
    expect(decoration.color, equals(theme.primaryColorLight));

    final RenderParagraph paragraph = tester.renderObject(find.text('Z'));
    expect(
        paragraph.text.style.color, equals(theme.primaryTextTheme.title.color));
  });

  testWidgets('CircleAvatar with dark theme', (WidgetTester tester) async {
    final ThemeData theme = new ThemeData(
      primaryColor: Colors.grey.shade800,
      primaryColorBrightness: Brightness.dark,
    );
    await tester.pumpWidget(
      wrap(
        child: new Theme(
          data: theme,
          child: const CircleAvatar(
            child: const Text('Z'),
          ),
        ),
      ),
    );

    final RenderConstrainedBox box =
        tester.renderObject(find.byType(CircleAvatar));
    final RenderDecoratedBox child = box.child;
    final BoxDecoration decoration = child.decoration;
    expect(decoration.color, equals(theme.primaryColorDark));

    final RenderParagraph paragraph = tester.renderObject(find.text('Z'));
    expect(
        paragraph.text.style.color, equals(theme.primaryTextTheme.title.color));
  });

  testWidgets('CircleAvatar text does not expand with textScaleFactor',
      (WidgetTester tester) async {
    final Color foregroundColor = Colors.red.shade100;
    await tester.pumpWidget(
      wrap(
        child: new CircleAvatar(
          foregroundColor: foregroundColor,
          child: const Text('Z'),
        ),
      ),
    );

    expect(
        tester.getSize(find.text('Z')),
        anyOf(const Size(16.0, 16.0), const Size(11.0, 21.0),
            const Size(11.0, 19.0)));

    await tester.pumpWidget(
      wrap(
        child: new MediaQuery(
          data: const MediaQueryData(
              textScaleFactor: 2.0,
              size: const Size(111.0, 111.0),
              devicePixelRatio: 1.1,
              padding: const EdgeInsets.all(11.0)),
          child: new CircleAvatar(
            child: new Builder(builder: (BuildContext context) {
              final MediaQueryData data = MediaQuery.of(context);

              // These should not change.
              expect(data.size, equals(const Size(111.0, 111.0)));
              expect(data.devicePixelRatio, equals(1.1));
              expect(data.padding, equals(const EdgeInsets.all(11.0)));

              // This should be overridden to 1.0.
              expect(data.textScaleFactor, equals(1.0));
              return const Text('Z');
            }),
          ),
        ),
      ),
    );
    expect(
        tester.getSize(find.text('Z')),
        anyOf(const Size(16.0, 16.0), const Size(11.0, 21.0),
            const Size(11.0, 19.0)));
  });

  testWidgets('CircleAvatar respects minRadius', (WidgetTester tester) async {
    final Color backgroundColor = Colors.blue.shade900;
    await tester.pumpWidget(
      wrap(
        child: new UnconstrainedBox(
          child: new CircleAvatar(
            backgroundColor: backgroundColor,
            minRadius: 50.0,
            child: const Text('Z'),
          ),
        ),
      ),
    );

    final RenderConstrainedBox box =
        tester.renderObject(find.byType(CircleAvatar));
    expect(box.size, equals(const Size(100.0, 100.0)));
    final RenderDecoratedBox child = box.child;
    final BoxDecoration decoration = child.decoration;
    expect(decoration.color, equals(backgroundColor));

    final RenderParagraph paragraph = tester.renderObject(find.text('Z'));
    expect(paragraph.text.style.color,
        equals(new ThemeData.fallback().primaryColorLight));
  });

  testWidgets('CircleAvatar respects maxRadius', (WidgetTester tester) async {
    final Color backgroundColor = Colors.blue.shade900;
    await tester.pumpWidget(
      wrap(
        child: new CircleAvatar(
          backgroundColor: backgroundColor,
          maxRadius: 50.0,
          child: const Text('Z'),
        ),
      ),
    );

    final RenderConstrainedBox box =
        tester.renderObject(find.byType(CircleAvatar));
    expect(box.size, equals(const Size(100.0, 100.0)));
    final RenderDecoratedBox child = box.child;
    final BoxDecoration decoration = child.decoration;
    expect(decoration.color, equals(backgroundColor));

    final RenderParagraph paragraph = tester.renderObject(find.text('Z'));
    expect(paragraph.text.style.color,
        equals(new ThemeData.fallback().primaryColorLight));
  });

  testWidgets('CircleAvatar respects setting both minRadius and maxRadius',
      (WidgetTester tester) async {
    final Color backgroundColor = Colors.blue.shade900;
    await tester.pumpWidget(
      wrap(
        child: new CircleAvatar(
          backgroundColor: backgroundColor,
          maxRadius: 50.0,
          minRadius: 50.0,
          child: const Text('Z'),
        ),
      ),
    );

    final RenderConstrainedBox box =
        tester.renderObject(find.byType(CircleAvatar));
    expect(box.size, equals(const Size(100.0, 100.0)));
    final RenderDecoratedBox child = box.child;
    final BoxDecoration decoration = child.decoration;
    expect(decoration.color, equals(backgroundColor));

    final RenderParagraph paragraph = tester.renderObject(find.text('Z'));
    expect(paragraph.text.style.color,
        equals(new ThemeData.fallback().primaryColorLight));
  });
}

Widget wrap({Widget child}) {
  return new Directionality(
    textDirection: TextDirection.ltr,
    child: new MediaQuery(
      data: const MediaQueryData(),
      child: new Center(child: child),
    ),
  );
}
