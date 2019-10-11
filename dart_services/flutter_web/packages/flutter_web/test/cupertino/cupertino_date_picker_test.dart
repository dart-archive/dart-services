// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_ui/ui.dart';

import 'package:flutter_web/cupertino.dart';
import 'package:flutter_web/semantics.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

import '../flutter_test_alternative.dart';

// scrolling by this offset will move the picker to the next item
const Offset _kRowOffset = Offset(0.0, -50.0);

void main() {
  group('Countdown timer picker', () {
    testWidgets('onTimerDurationChanged is not null', (WidgetTester tester) async {
      expect(
            () {
          CupertinoTimerPicker(onTimerDurationChanged: null);
        },
        throwsAssertionError,
      );
    });

    testWidgets('initialTimerDuration falls within limit', (WidgetTester tester) async {
      expect(
            () {
          CupertinoTimerPicker(
            onTimerDurationChanged: (_) { },
            initialTimerDuration: const Duration(days: 1),
          );
        },
        throwsAssertionError,
      );

      expect(
            () {
          CupertinoTimerPicker(
            onTimerDurationChanged: (_) { },
            initialTimerDuration: const Duration(seconds: -1),
          );
        },
        throwsAssertionError,
      );
    });

    testWidgets('minuteInterval is positive and is a factor of 60', (WidgetTester tester) async {
      expect(
            () {
          CupertinoTimerPicker(
            onTimerDurationChanged: (_) { },
            minuteInterval: 0,
          );
        },
        throwsAssertionError,
      );
      expect(
            () {
          CupertinoTimerPicker(
            onTimerDurationChanged: (_) { },
            minuteInterval: -1,
          );
        },
        throwsAssertionError,
      );
      expect(
            () {
          CupertinoTimerPicker(
            onTimerDurationChanged: (_) { },
            minuteInterval: 7,
          );
        },
        throwsAssertionError,
      );
    });

    testWidgets('secondInterval is positive and is a factor of 60', (WidgetTester tester) async {
      expect(
            () {
          CupertinoTimerPicker(
            onTimerDurationChanged: (_) { },
            secondInterval: 0,
          );
        },
        throwsAssertionError,
      );
      expect(
            () {
          CupertinoTimerPicker(
            onTimerDurationChanged: (_) { },
            secondInterval: -1,
          );
        },
        throwsAssertionError,
      );
      expect(
            () {
          CupertinoTimerPicker(
            onTimerDurationChanged: (_) { },
            secondInterval: 7,
          );
        },
        throwsAssertionError,
      );
    });

    testWidgets('columns are ordered correctly when text direction is ltr', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoTimerPicker(
            onTimerDurationChanged: (_) { },
            initialTimerDuration: const Duration(hours: 12, minutes: 30, seconds: 59),
          ),
        ),
      );

      Offset lastOffset = tester.getTopLeft(find.text('12'));

      expect(tester.getTopLeft(find.text('hours')).dx > lastOffset.dx, true);
      lastOffset = tester.getTopLeft(find.text('hours'));

      expect(tester.getTopLeft(find.text('30')).dx > lastOffset.dx, true);
      lastOffset = tester.getTopLeft(find.text('30'));

      expect(tester.getTopLeft(find.text('min.')).dx > lastOffset.dx, true);
      lastOffset = tester.getTopLeft(find.text('min.'));

      expect(tester.getTopLeft(find.text('59')).dx > lastOffset.dx, true);
      lastOffset = tester.getTopLeft(find.text('59'));

      expect(tester.getTopLeft(find.text('sec.')).dx > lastOffset.dx, true);
    });

    testWidgets('columns are ordered correctly when text direction is rtl', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: CupertinoTimerPicker(
              onTimerDurationChanged: (_) { },
              initialTimerDuration: const Duration(hours: 12, minutes: 30, seconds: 59),
            ),
          ),
        ),
      );

      Offset lastOffset = tester.getTopLeft(find.text('12'));

      expect(tester.getTopLeft(find.text('hours')).dx > lastOffset.dx, false);
      lastOffset = tester.getTopLeft(find.text('hours'));

      expect(tester.getTopLeft(find.text('30')).dx > lastOffset.dx, false);
      lastOffset = tester.getTopLeft(find.text('30'));

      expect(tester.getTopLeft(find.text('min.')).dx > lastOffset.dx, false);
      lastOffset = tester.getTopLeft(find.text('min.'));

      expect(tester.getTopLeft(find.text('59')).dx > lastOffset.dx, false);
      lastOffset = tester.getTopLeft(find.text('59'));

      expect(tester.getTopLeft(find.text('sec.')).dx > lastOffset.dx, false);
    });

    testWidgets('width of picker is consistent', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: SizedBox(
            height: 400.0,
            width: 400.0,
            child: CupertinoTimerPicker(
              onTimerDurationChanged: (_) { },
              initialTimerDuration: const Duration(hours: 12, minutes: 30, seconds: 59),
            ),
          ),
        ),
      );

      // Distance between the first column and the last column.
      final double distance =
          tester.getCenter(find.text('sec.')).dx - tester.getCenter(find.text('12')).dx;

      await tester.pumpWidget(
        CupertinoApp(
          home: SizedBox(
            height: 400.0,
            width: 800.0,
            child: CupertinoTimerPicker(
              onTimerDurationChanged: (_) { },
              initialTimerDuration: const Duration(hours: 12, minutes: 30, seconds: 59),
            ),
          ),
        ),
      );

      // Distance between the first and the last column should be the same.
      expect(
        tester.getCenter(find.text('sec.')).dx - tester.getCenter(find.text('12')).dx,
        distance,
      );
    });
  });

  testWidgets('picker honors minuteInterval and secondInterval', (WidgetTester tester) async {
    Duration duration;
    await tester.pumpWidget(
      CupertinoApp(
        home: SizedBox(
          height: 400.0,
          width: 400.0,
          child: CupertinoTimerPicker(
            minuteInterval: 10,
            secondInterval: 15,
            initialTimerDuration: const Duration(hours: 10, minutes: 40, seconds: 45),
            mode: CupertinoTimerPickerMode.hms,
            onTimerDurationChanged: (Duration d) {
              duration = d;
            },
          ),
        ),
      ),
    );

    await tester.drag(find.text('40'), _kRowOffset);
    await tester.pump();
    await tester.drag(find.text('45'), -_kRowOffset);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      duration,
      const Duration(hours: 10, minutes: 50, seconds: 30),
    );
  });

  group('Date picker', () {
    testWidgets('mode is not null', (WidgetTester tester) async {
      expect(
            () {
          CupertinoDatePicker(
            mode: null,
            onDateTimeChanged: (_) { },
            initialDateTime: DateTime.now(),
          );
        },
        throwsAssertionError,
      );
    });

    testWidgets('onDateTimeChanged is not null', (WidgetTester tester) async {
      expect(
            () {
          CupertinoDatePicker(
            onDateTimeChanged: null,
            initialDateTime: DateTime.now(),
          );
        },
        throwsAssertionError,
      );
    });

    testWidgets('initial date is set to default value', (WidgetTester tester) async {
      final CupertinoDatePicker picker = CupertinoDatePicker(
        onDateTimeChanged: (_) { },
      );
      expect(picker.initialDateTime, isNotNull);
    });

    testWidgets('initial date honors minuteInterval', (WidgetTester tester) async {
      DateTime newDateTime;
      await tester.pumpWidget(
          CupertinoApp(
              home: Center(
                child: SizedBox(
                    width: 400,
                    height: 400,
                    child: CupertinoDatePicker(
                      onDateTimeChanged: (DateTime d) => newDateTime = d,
                      initialDateTime: DateTime(2018, 10, 10, 10, 3),
                      minuteInterval: 3,
                    )
                ),
              )
          )
      );

      // Drag the minute picker to the next slot (03 -> 06).
      // The `initialDateTime` and the `minuteInterval` values are specifically chosen
      // so that `find.text` finds exactly one widget.
      await tester.drag(find.text('03'), _kRowOffset);
      await tester.pump();

      expect(newDateTime.minute, 6);
    });

    testWidgets('changing initialDateTime after first build does not do anything', (WidgetTester tester) async {
      DateTime selectedDateTime;
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 400.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                onDateTimeChanged: (DateTime dateTime) => selectedDateTime = dateTime,
                initialDateTime: DateTime(2018, 1, 1, 10, 30),
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.text('10'), const Offset(0.0, 32.0), touchSlopY: 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(selectedDateTime, DateTime(2018, 1, 1, 9, 30));

      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 400.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                onDateTimeChanged: (DateTime dateTime) => selectedDateTime = dateTime,
                // Change the initial date, but it shouldn't affect the present state.
                initialDateTime: DateTime(2016, 4, 5, 15, 00),
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.text('9'), const Offset(0.0, 32.0), touchSlopY: 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Moving up an hour is still based on the original initial date time.
      expect(selectedDateTime, DateTime(2018, 1, 1, 8, 30));
    });

    testWidgets('date picker has expected string', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 400.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (_) { },
                initialDateTime: DateTime(2018, 9, 15, 0, 0),
              ),
            ),
          ),
        ),
      );

      expect(find.text('September'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('2018'), findsOneWidget);
    });

    testWidgets('datetime picker has expected string', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 400.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                onDateTimeChanged: (_) { },
                initialDateTime: DateTime(2018, 9, 15, 3, 14),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Sat Sep 15'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('AM'), findsOneWidget);
    });

    testWidgets('width of picker in date and time mode is consistent', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Directionality(
            textDirection: TextDirection.ltr,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              onDateTimeChanged: (_) { },
              initialDateTime: DateTime(2018, 1, 1, 10, 30),
            ),
          ),
        ),
      );

      // Distance between the first column and the last column.
      final double distance =
          tester.getCenter(find.text('Mon Jan 1 ')).dx - tester.getCenter(find.text('AM')).dx;

      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 800.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                onDateTimeChanged: (_) { },
                initialDateTime: DateTime(2018, 1, 1, 10, 30),
              ),
            ),
          ),
        ),
      );

      // Distance between the first and the last column should be the same.
      expect(
        tester.getCenter(find.text('Mon Jan 1 ')).dx - tester.getCenter(find.text('AM')).dx,
        distance,
      );
    });

    testWidgets('width of picker in date mode is consistent', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 400.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (_) { },
                initialDateTime: DateTime(2018, 1, 1, 10, 30),
              ),
            ),
          ),
        ),
      );

      // Distance between the first column and the last column.
      final double distance =
          tester.getCenter(find.text('January')).dx - tester.getCenter(find.text('2018')).dx;

      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 800.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (_) { },
                initialDateTime: DateTime(2018, 1, 1, 10, 30),
              ),
            ),
          ),
        ),
      );

      // Distance between the first and the last column should be the same.
      expect(
        tester.getCenter(find.text('January')).dx - tester.getCenter(find.text('2018')).dx,
        distance,
      );
    });

    testWidgets('width of picker in time mode is consistent', (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 400.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                onDateTimeChanged: (_) { },
                initialDateTime: DateTime(2018, 1, 1, 10, 30),
              ),
            ),
          ),
        ),
      );

      // Distance between the first column and the last column.
      final double distance =
          tester.getCenter(find.text('10')).dx - tester.getCenter(find.text('AM')).dx;

      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 800.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                onDateTimeChanged: (_) { },
                initialDateTime: DateTime(2018, 1, 1, 10, 30),
              ),
            ),
          ),
        ),
      );

      // Distance between the first and the last column should be the same.
      expect(
        tester.getCenter(find.text('10')).dx - tester.getCenter(find.text('AM')).dx,
        distance,
      );
    });

    testWidgets('picker automatically scrolls away from invalid date on month change', (WidgetTester tester) async {
      DateTime date;
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 400.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime newDate) {
                  date = newDate;
                },
                initialDateTime: DateTime(2018, 3, 30),
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.text('March'), const Offset(0, 32.0), touchSlopY: 0.0);

      // Momentarily, the 2018 and the incorrect 30 of February is aligned.
      expect(
        tester.getTopLeft(find.text('2018')).dy,
        tester.getTopLeft(find.text('30')).dy,
      );
      await tester.pump(); // Once to trigger the post frame animate call.
      await tester.pump(); // Once to start the DrivenScrollActivity.
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        date,
        DateTime(2018, 2, 28),
      );
      expect(
        tester.getTopLeft(find.text('2018')).dy,
        tester.getTopLeft(find.text('28')).dy,
      );
    });

    testWidgets('picker automatically scrolls away from invalid date on day change', (WidgetTester tester) async {
      DateTime date;
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 400.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (DateTime newDate) {
                  date = newDate;
                },
                initialDateTime: DateTime(2018, 2, 27), // 2018 has 28 days in Feb.
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.text('27'), const Offset(0.0, -32.0), touchSlopY: 0.0);
      await tester.pump();
      expect(
        date,
        DateTime(2018, 2, 28),
      );

      await tester.drag(find.text('28'), const Offset(0.0, -32.0), touchSlopY: 0.0);
      await tester.pump(); // Once to trigger the post frame animate call.

      // Callback doesn't transiently go into invalid dates.
      expect(
        date,
        DateTime(2018, 2, 28),
      );
      // Momentarily, the invalid 29th of Feb is dragged into the middle.
      expect(
        tester.getTopLeft(find.text('2018')).dy,
        tester.getTopLeft(find.text('29')).dy,
      );

      await tester.pump(); // Once to start the DrivenScrollActivity.
      await tester.pump(const Duration(milliseconds: 500));

      expect(
        date,
        DateTime(2018, 2, 28),
      );
      expect(
        tester.getTopLeft(find.text('2018')).dy,
        tester.getTopLeft(find.text('28')).dy,
      );
    });

    group('Picker handles initial noon/midnight times', () {
      testWidgets('midnight', (WidgetTester tester) async {
        DateTime date;
        await tester.pumpWidget(
          CupertinoApp(
            home: Center(
              child: SizedBox(
                height: 400.0,
                width: 400.0,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  onDateTimeChanged: (DateTime newDate) {
                    date = newDate;
                  },
                  initialDateTime: DateTime(2019, 1, 1, 0, 15),
                ),
              ),
            ),
          ),
        );

        // 0:15 -> 0:16
        await tester.drag(find.text('15'), _kRowOffset);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(date, DateTime(2019, 1, 1, 0, 16));
      });

      testWidgets('noon', (WidgetTester tester) async {
        DateTime date;
        await tester.pumpWidget(
          CupertinoApp(
            home: Center(
              child: SizedBox(
                height: 400.0,
                width: 400.0,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  onDateTimeChanged: (DateTime newDate) {
                    date = newDate;
                  },
                  initialDateTime: DateTime(2019, 1, 1, 12, 15),
                ),
              ),
            ),
          ),
        );

        // 12:15 -> 12:16
        await tester.drag(find.text('15'), _kRowOffset);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(date, DateTime(2019, 1, 1, 12, 16));
      });

      testWidgets('noon in 24 hour time', (WidgetTester tester) async {
        DateTime date;
        await tester.pumpWidget(
          CupertinoApp(
            home: Center(
              child: SizedBox(
                height: 400.0,
                width: 400.0,
                child: CupertinoDatePicker(
                  use24hFormat: true,
                  mode: CupertinoDatePickerMode.time,
                  onDateTimeChanged: (DateTime newDate) {
                    date = newDate;
                  },
                  initialDateTime: DateTime(2019, 1, 1, 12, 25),
                ),
              ),
            ),
          ),
        );

        // 12:25 -> 12:26
        await tester.drag(find.text('25'), _kRowOffset);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(date, DateTime(2019, 1, 1, 12, 26));
      });
    });

    testWidgets('picker persists am/pm value when scrolling hours', (WidgetTester tester) async {
      DateTime date;
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 400.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                onDateTimeChanged: (DateTime newDate) {
                  date = newDate;
                },
                initialDateTime: DateTime(2019, 1, 1, 3),
              ),
            ),
          ),
        ),
      );

      // 3:00 -> 15:00
      await tester.drag(find.text('AM'), _kRowOffset);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(date, DateTime(2019, 1, 1, 15));

      // 15:00 -> 16:00
      await tester.drag(find.text('3'), _kRowOffset);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(date, DateTime(2019, 1, 1, 16));

      // 16:00 -> 4:00
      await tester.drag(find.text('PM'), -_kRowOffset);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(date, DateTime(2019, 1, 1, 4));

      // 4:00 -> 3:00
      await tester.drag(find.text('4'), -_kRowOffset);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(date, DateTime(2019, 1, 1, 3));
    });

    testWidgets('picker automatically scrolls the am/pm column when the hour column changes enough', (WidgetTester tester) async {
      DateTime date;
      await tester.pumpWidget(
        CupertinoApp(
          home: Center(
            child: SizedBox(
              height: 400.0,
              width: 400.0,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                onDateTimeChanged: (DateTime newDate) {
                  date = newDate;
                },
                initialDateTime: DateTime(2018, 1, 1, 11, 59),
              ),
            ),
          ),
        ),
      );

      const Offset deltaOffset = Offset(0.0, -18.0);

      // 11:59 -> 12:59
      await tester.drag(find.text('11'), _kRowOffset);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(date, DateTime(2018, 1, 1, 12, 59));

      // 12:59 -> 11:59
      await tester.drag(find.text('12'), -_kRowOffset);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(date, DateTime(2018, 1, 1, 11, 59));

      // 11:59 -> 9:59
      await tester.drag(find.text('11'), -((_kRowOffset - deltaOffset) * 2 + deltaOffset));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(date, DateTime(2018, 1, 1, 9, 59));

      // 9:59 -> 15:59
      await tester.drag(find.text('9'), (_kRowOffset - deltaOffset) * 6 + deltaOffset);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(date, DateTime(2018, 1, 1, 15, 59));
    });

    testWidgets('date picker given too narrow space horizontally shows message', (WidgetTester tester) async {
      await tester.pumpWidget(
          CupertinoApp(
              home: Center(
                child: SizedBox(
                  // This is too small to draw the picker out fully.
                    width: 100,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.dateAndTime,
                      initialDateTime: DateTime(2019, 1, 1, 4),
                      onDateTimeChanged: (_) {},
                    )
                ),
              )
          )
      );

      final dynamic exception = tester.takeException();
      expect(exception, isFlutterError);
      expect(
        exception.toString(),
        contains('Insufficient horizontal space to render the CupertinoDatePicker'),
      );
    });

    testWidgets('DatePicker golden tests', (WidgetTester tester) async {
      await tester.pumpWidget(
          CupertinoApp(
              home: Center(
                child: SizedBox(
                    width: 400,
                    height: 400,
                    child: RepaintBoundary(
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: DateTime(2019, 1, 1, 4),
                        onDateTimeChanged: (_) {},
                      ),
                    )
                ),
              )
          )
      );

      await expectLater(
        find.byType(CupertinoDatePicker),
        matchesGoldenFile(
          'date_picker_test.datetime.initial.png',
          version: 1,
        ),
      );

      // Slightly drag the hour component to make the current hour off-center.
      await tester.drag(find.text('4'), Offset(0, _kRowOffset.dy / 2));
      await tester.pump();

      await expectLater(
        find.byType(CupertinoDatePicker),
        matchesGoldenFile(
          'date_picker_test.datetime.drag.png',
          version: 1,
        ),
      );
    }, skip: isBrowser);
  });

  testWidgets('scrollController can be removed or added', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    int lastSelectedItem;
    void onSelectedItemChanged(int index) {
      lastSelectedItem = index;
    }
    await tester.pumpWidget(_buildPicker(
      controller: FixedExtentScrollController(),
      onSelectedItemChanged: onSelectedItemChanged,
    ));

    tester.binding.pipelineOwner.semanticsOwner.performAction(1, SemanticsAction.increase);
    await tester.pumpAndSettle();
    expect(lastSelectedItem, 1);

    await tester.pumpWidget(_buildPicker(
      onSelectedItemChanged: onSelectedItemChanged,
    ));

    tester.binding.pipelineOwner.semanticsOwner.performAction(1, SemanticsAction.increase);
    await tester.pumpAndSettle();
    expect(lastSelectedItem, 2);

    await tester.pumpWidget(_buildPicker(
      controller: FixedExtentScrollController(),
      onSelectedItemChanged: onSelectedItemChanged,
    ));

    tester.binding.pipelineOwner.semanticsOwner.performAction(1, SemanticsAction.increase);
    await tester.pumpAndSettle();
    expect(lastSelectedItem, 3);

    handle.dispose();
  });

  testWidgets('picker exports semantics', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    debugResetSemanticsIdCounter();
    int lastSelectedItem;
    await tester.pumpWidget(_buildPicker(onSelectedItemChanged: (int index) {
      lastSelectedItem = index;
    }));

    expect(tester.getSemantics(find.byType(CupertinoPicker)), matchesSemantics(
      children: <Matcher>[
        matchesSemantics(
          hasIncreaseAction: true,
          hasDecreaseAction: false,
          increasedValue: '1',
          value: '0',
          textDirection: TextDirection.ltr,
        ),
      ],
    ));

    tester.binding.pipelineOwner.semanticsOwner.performAction(1, SemanticsAction.increase);
    await tester.pumpAndSettle();

    expect(tester.getSemantics(find.byType(CupertinoPicker)), matchesSemantics(
      children: <Matcher>[
        matchesSemantics(
          hasIncreaseAction: true,
          hasDecreaseAction: true,
          increasedValue: '2',
          decreasedValue: '0',
          value: '1',
          textDirection: TextDirection.ltr,
        ),
      ],
    ));
    expect(lastSelectedItem, 1);
    handle.dispose();
  });
}

Widget _buildPicker({ FixedExtentScrollController controller, ValueChanged<int> onSelectedItemChanged }) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: CupertinoPicker(
      scrollController: controller,
      itemExtent: 100.0,
      onSelectedItemChanged: onSelectedItemChanged,
      children: List<Widget>.generate(100, (int index) {
        return Center(
          child: Container(
            width: 400.0,
            height: 100.0,
            child: Text(index.toString()),
          ),
        );
      }),
    ),
  );
}
