// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_ui/ui.dart';

import 'package:flutter_web/material.dart';
import 'package:flutter_web/services.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

import '../widgets/semantics_tester.dart';
import 'feedback_tester.dart';

void main() {
  const Duration kWaitDuration = Duration(seconds: 1);

  FeedbackTester feedback;

  setUp(() {
    feedback = FeedbackTester();
  });

  tearDown(() {
    feedback?.dispose();
  });

  group('Feedback on Android', () {
    List<Map<String, Object>> semanticEvents;

    setUp(() {
      semanticEvents = <Map<String, Object>>[];
      SystemChannels.accessibility
          .setMockMessageHandler((dynamic message) async {
        final Map<dynamic, dynamic> typedMessage = message;
        semanticEvents.add(typedMessage.cast<String, Object>());
      });
    });

    tearDown(() {
      SystemChannels.accessibility.setMockMessageHandler(null);
    });

    testWidgets('forTap', (WidgetTester tester) async {
      final SemanticsTester semanticsTester = SemanticsTester(tester);

      await tester.pumpWidget(TestWidget(
        tapHandler: (BuildContext context) {
          return () => Feedback.forTap(context);
        },
      ));
      await tester.pumpAndSettle(kWaitDuration);
      expect(feedback.hapticCount, 0);
      expect(feedback.clickSoundCount, 0);
      expect(semanticEvents, isEmpty);

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle(kWaitDuration);
      final RenderObject object =
          tester.firstRenderObject(find.byType(GestureDetector));

      expect(feedback.hapticCount, 0);
      expect(feedback.clickSoundCount, 1);
      expect(semanticEvents.single, <String, dynamic>{
        'type': 'tap',
        'nodeId': object.debugSemantics.id,
        'data': <String, dynamic>{},
      });
      expect(
          object.debugSemantics
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          true);

      semanticsTester.dispose();
    });

    testWidgets('forTap Wrapper', (WidgetTester tester) async {
      final SemanticsTester semanticsTester = SemanticsTester(tester);

      int callbackCount = 0;
      final VoidCallback callback = () {
        callbackCount++;
      };

      await tester.pumpWidget(TestWidget(
        tapHandler: (BuildContext context) {
          return Feedback.wrapForTap(callback, context);
        },
      ));
      await tester.pumpAndSettle(kWaitDuration);
      expect(feedback.hapticCount, 0);
      expect(feedback.clickSoundCount, 0);
      expect(callbackCount, 0);

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle(kWaitDuration);
      final RenderObject object =
          tester.firstRenderObject(find.byType(GestureDetector));

      expect(feedback.hapticCount, 0);
      expect(feedback.clickSoundCount, 1);
      expect(callbackCount, 1);
      expect(semanticEvents.single, <String, dynamic>{
        'type': 'tap',
        'nodeId': object.debugSemantics.id,
        'data': <String, dynamic>{},
      });
      expect(
          object.debugSemantics
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          true);

      semanticsTester.dispose();
    });

    testWidgets('forLongPress', (WidgetTester tester) async {
      final SemanticsTester semanticsTester = SemanticsTester(tester);

      await tester.pumpWidget(TestWidget(
        longPressHandler: (BuildContext context) {
          return () => Feedback.forLongPress(context);
        },
      ));
      await tester.pumpAndSettle(kWaitDuration);
      expect(feedback.hapticCount, 0);
      expect(feedback.clickSoundCount, 0);

      await tester.longPress(find.text('X'));
      await tester.pumpAndSettle(kWaitDuration);
      final RenderObject object =
          tester.firstRenderObject(find.byType(GestureDetector));

      expect(feedback.hapticCount, 1);
      expect(feedback.clickSoundCount, 0);
      expect(semanticEvents.single, <String, dynamic>{
        'type': 'longPress',
        'nodeId': object.debugSemantics.id,
        'data': <String, dynamic>{},
      });
      expect(
          object.debugSemantics
              .getSemanticsData()
              .hasAction(SemanticsAction.longPress),
          true);

      semanticsTester.dispose();
    });

    testWidgets('forLongPress Wrapper', (WidgetTester tester) async {
      final SemanticsTester semanticsTester = SemanticsTester(tester);
      int callbackCount = 0;
      final VoidCallback callback = () {
        callbackCount++;
      };

      await tester.pumpWidget(TestWidget(
        longPressHandler: (BuildContext context) {
          return Feedback.wrapForLongPress(callback, context);
        },
      ));
      await tester.pumpAndSettle(kWaitDuration);
      final RenderObject object =
          tester.firstRenderObject(find.byType(GestureDetector));

      expect(feedback.hapticCount, 0);
      expect(feedback.clickSoundCount, 0);
      expect(callbackCount, 0);

      await tester.longPress(find.text('X'));
      await tester.pumpAndSettle(kWaitDuration);
      expect(feedback.hapticCount, 1);
      expect(feedback.clickSoundCount, 0);
      expect(callbackCount, 1);
      expect(semanticEvents.single, <String, dynamic>{
        'type': 'longPress',
        'nodeId': object.debugSemantics.id,
        'data': <String, dynamic>{},
      });
      expect(
          object.debugSemantics
              .getSemanticsData()
              .hasAction(SemanticsAction.longPress),
          true);

      semanticsTester.dispose();
    });
  });

  group('Feedback on iOS', () {
    testWidgets('forTap', (WidgetTester tester) async {
      await tester.pumpWidget(Theme(
        data: ThemeData(platform: TargetPlatform.iOS),
        child: TestWidget(
          tapHandler: (BuildContext context) {
            return () => Feedback.forTap(context);
          },
        ),
      ));

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle(kWaitDuration);
      expect(feedback.hapticCount, 0);
      expect(feedback.clickSoundCount, 0);
    });

    testWidgets('forLongPress', (WidgetTester tester) async {
      await tester.pumpWidget(Theme(
        data: ThemeData(platform: TargetPlatform.iOS),
        child: TestWidget(
          longPressHandler: (BuildContext context) {
            return () => Feedback.forLongPress(context);
          },
        ),
      ));

      await tester.longPress(find.text('X'));
      await tester.pumpAndSettle(kWaitDuration);
      expect(feedback.hapticCount, 0);
      expect(feedback.clickSoundCount, 0);
    });
  });
}

class TestWidget extends StatelessWidget {
  const TestWidget({
    this.tapHandler = nullHandler,
    this.longPressHandler = nullHandler,
  });

  final HandlerCreator tapHandler;
  final HandlerCreator longPressHandler;

  static VoidCallback nullHandler(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapHandler(context),
      onLongPress: longPressHandler(context),
      child: const Text('X', textDirection: TextDirection.ltr),
    );
  }
}

typedef HandlerCreator = VoidCallback Function(BuildContext context);
