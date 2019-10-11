// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/widgets.dart';

void main() {
  SpyStringValueNotifier valueListenable;
  Widget textBuilderUnderTest;

  Widget builderForValueListenable(
    ValueListenable<String> valueListenable,
  ) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ValueListenableBuilder<String>(
        valueListenable: valueListenable,
        builder: (BuildContext context, String value, Widget child) {
          if (value == null) return const Placeholder();
          return Text(value);
        },
      ),
    );
  }

  setUp(() {
    valueListenable = SpyStringValueNotifier(null);
    textBuilderUnderTest = builderForValueListenable(valueListenable);
  });

  testWidgets('Null value is ok', (WidgetTester tester) async {
    await tester.pumpWidget(textBuilderUnderTest);

    expect(find.byType(Placeholder), findsOneWidget);
  });

  testWidgets('Widget builds with initial value', (WidgetTester tester) async {
    valueListenable = SpyStringValueNotifier('Bachman');

    await tester.pumpWidget(builderForValueListenable(valueListenable));

    expect(find.text('Bachman'), findsOneWidget);
  });

  testWidgets('Widget updates when value changes', (WidgetTester tester) async {
    await tester.pumpWidget(textBuilderUnderTest);

    valueListenable.value = 'Gilfoyle';
    await tester.pump();
    expect(find.text('Gilfoyle'), findsOneWidget);

    valueListenable.value = 'Dinesh';
    await tester.pump();
    expect(find.text('Gilfoyle'), findsNothing);
    expect(find.text('Dinesh'), findsOneWidget);
  });

  testWidgets('Can change listenable', (WidgetTester tester) async {
    await tester.pumpWidget(textBuilderUnderTest);

    valueListenable.value = 'Gilfoyle';
    await tester.pump();
    expect(find.text('Gilfoyle'), findsOneWidget);

    final ValueListenable<String> differentListenable =
        SpyStringValueNotifier('Hendricks');

    await tester.pumpWidget(builderForValueListenable(differentListenable));

    expect(find.text('Gilfoyle'), findsNothing);
    expect(find.text('Hendricks'), findsOneWidget);
  });

  testWidgets('Stops listening to old listenable after chainging listenable',
      (WidgetTester tester) async {
    await tester.pumpWidget(textBuilderUnderTest);

    valueListenable.value = 'Gilfoyle';
    await tester.pump();
    expect(find.text('Gilfoyle'), findsOneWidget);

    final ValueListenable<String> differentListenable =
        SpyStringValueNotifier('Hendricks');

    await tester.pumpWidget(builderForValueListenable(differentListenable));

    expect(find.text('Gilfoyle'), findsNothing);
    expect(find.text('Hendricks'), findsOneWidget);

    // Change value of the (now) disconnected listenable.
    valueListenable.value = 'Big Head';

    expect(find.text('Gilfoyle'), findsNothing);
    expect(find.text('Big Head'), findsNothing);
    expect(find.text('Hendricks'), findsOneWidget);
  });

  testWidgets('Self-cleans when removed', (WidgetTester tester) async {
    await tester.pumpWidget(textBuilderUnderTest);

    valueListenable.value = 'Gilfoyle';
    await tester.pump();
    expect(find.text('Gilfoyle'), findsOneWidget);

    await tester.pumpWidget(const Placeholder());

    expect(find.text('Gilfoyle'), findsNothing);
    expect(valueListenable.hasListeners, false);
  });
}

class SpyStringValueNotifier extends ValueNotifier<String> {
  SpyStringValueNotifier(String initialValue) : super(initialValue);

  /// Override for test visibility only.
  @override
  bool get hasListeners => super.hasListeners;
}
