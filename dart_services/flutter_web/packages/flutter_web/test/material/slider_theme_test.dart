// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced. * Contains Web DELTA *

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/painting.dart';

import '../rendering/mock_canvas.dart';

void main() {
  test('SliderThemeData copyWith, ==, hashCode basics', () {
    expect(const SliderThemeData(), const SliderThemeData().copyWith());
    expect(const SliderThemeData().hashCode, const SliderThemeData().copyWith().hashCode);
  });

  testWidgets('Default SliderThemeData debugFillProperties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const SliderThemeData().debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description, <String>[]);
  });


  testWidgets('SliderThemeData implements debugFillProperties', (WidgetTester tester) async {
    final DiagnosticPropertiesBuilder builder = DiagnosticPropertiesBuilder();
    const SliderThemeData(
      trackHeight: 7.0,
      activeTrackColor: Color(0xFF000001),
      inactiveTrackColor: Color(0xFF000002),
      disabledActiveTrackColor: Color(0xFF000003),
      disabledInactiveTrackColor: Color(0xFF000004),
      activeTickMarkColor: Color(0xFF000005),
      inactiveTickMarkColor: Color(0xFF000006),
      disabledActiveTickMarkColor: Color(0xFF000007),
      disabledInactiveTickMarkColor: Color(0xFF000008),
      thumbColor: Color(0xFF000009),
      overlappingShapeStrokeColor: Color(0xFF000010),
      disabledThumbColor: Color(0xFF000011),
      overlayColor: Color(0xFF000012),
      valueIndicatorColor: Color(0xFF000013),
      overlayShape: RoundSliderOverlayShape(),
      tickMarkShape: RoundSliderTickMarkShape(),
      thumbShape: RoundSliderThumbShape(),
      trackShape: RoundedRectSliderTrackShape(),
      valueIndicatorShape: PaddleSliderValueIndicatorShape(),
      rangeTickMarkShape: RoundRangeSliderTickMarkShape(),
      rangeThumbShape: RoundRangeSliderThumbShape(),
      rangeTrackShape: RoundedRectRangeSliderTrackShape(),
      rangeValueIndicatorShape: PaddleRangeSliderValueIndicatorShape(),
      showValueIndicator: ShowValueIndicator.always,
      valueIndicatorTextStyle: TextStyle(color: Colors.black),
    ).debugFillProperties(builder);

    final List<String> description = builder.properties
        .where((DiagnosticsNode node) => !node.isFiltered(DiagnosticLevel.info))
        .map((DiagnosticsNode node) => node.toString())
        .toList();

    expect(description, <String>[
      'trackHeight: 7.0',
      'activeTrackColor: Color(0xff000001)',
      'inactiveTrackColor: Color(0xff000002)',
      'disabledActiveTrackColor: Color(0xff000003)',
      'disabledInactiveTrackColor: Color(0xff000004)',
      'activeTickMarkColor: Color(0xff000005)',
      'inactiveTickMarkColor: Color(0xff000006)',
      'disabledActiveTickMarkColor: Color(0xff000007)',
      'disabledInactiveTickMarkColor: Color(0xff000008)',
      'thumbColor: Color(0xff000009)',
      'overlappingShapeStrokeColor: Color(0xff000010)',
      'disabledThumbColor: Color(0xff000011)',
      'overlayColor: Color(0xff000012)',
      'valueIndicatorColor: Color(0xff000013)',
      'overlayShape: Instance of \'RoundSliderOverlayShape\'',
      'tickMarkShape: Instance of \'RoundSliderTickMarkShape\'',
      'thumbShape: Instance of \'RoundSliderThumbShape\'',
      'trackShape: Instance of \'RoundedRectSliderTrackShape\'',
      'valueIndicatorShape: Instance of \'PaddleSliderValueIndicatorShape\'',
      'rangeTickMarkShape: Instance of \'RoundRangeSliderTickMarkShape\'',
      'rangeThumbShape: Instance of \'RoundRangeSliderThumbShape\'',
      'rangeTrackShape: Instance of \'RoundedRectRangeSliderTrackShape\'',
      'rangeValueIndicatorShape: Instance of \'PaddleRangeSliderValueIndicatorShape\'',
      'showValueIndicator: always',
      'valueIndicatorTextStyle: TextStyle(inherit: true, color: Color(0xff000000))'
    ]);
  });

  testWidgets('Slider uses ThemeData slider theme if present', (WidgetTester tester) async {
    final ThemeData theme = ThemeData(
      platform: TargetPlatform.android,
      primarySwatch: Colors.red,
    );
    final SliderThemeData sliderTheme = theme.sliderTheme;

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.5, enabled: false));
    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    expect(
      sliderBox,
      paints
        ..rect(color: sliderTheme.disabledActiveTrackColor)
        ..rect(color: sliderTheme.disabledInactiveTrackColor),
    );
  });

  testWidgets('Slider overrides ThemeData theme if SliderTheme present', (WidgetTester tester) async {
    final ThemeData theme = ThemeData(
      platform: TargetPlatform.android,
      primarySwatch: Colors.red,
    );
    final SliderThemeData sliderTheme = theme.sliderTheme;
    final SliderThemeData customTheme = sliderTheme.copyWith(
      activeTrackColor: Colors.purple,
      inactiveTrackColor: Colors.purple.withAlpha(0x3d),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.5, enabled: false));
    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    expect(
      sliderBox,
      paints
        ..rect(color: customTheme.disabledActiveTrackColor)
        ..rect(color: customTheme.disabledInactiveTrackColor),
    );
  });

  testWidgets('SliderThemeData generates correct opacities for fromPrimaryColors', (WidgetTester tester) async {
    const Color customColor1 = Color(0xcafefeed);
    const Color customColor2 = Color(0xdeadbeef);
    const Color customColor3 = Color(0xdecaface);
    const Color customColor4 = Color(0xfeedcafe);

    final SliderThemeData sliderTheme = SliderThemeData.fromPrimaryColors(
      primaryColor: customColor1,
      primaryColorDark: customColor2,
      primaryColorLight: customColor3,
      valueIndicatorTextStyle: ThemeData.fallback().accentTextTheme.body2.copyWith(color: customColor4),
    );

    expect(sliderTheme.activeTrackColor, equals(customColor1.withAlpha(0xff)));
    expect(sliderTheme.inactiveTrackColor, equals(customColor1.withAlpha(0x3d)));
    expect(sliderTheme.disabledActiveTrackColor, equals(customColor2.withAlpha(0x52)));
    expect(sliderTheme.disabledInactiveTrackColor, equals(customColor2.withAlpha(0x1f)));
    expect(sliderTheme.activeTickMarkColor, equals(customColor3.withAlpha(0x8a)));
    expect(sliderTheme.inactiveTickMarkColor, equals(customColor1.withAlpha(0x8a)));
    expect(sliderTheme.disabledActiveTickMarkColor, equals(customColor3.withAlpha(0x1f)));
    expect(sliderTheme.disabledInactiveTickMarkColor, equals(customColor2.withAlpha(0x1f)));
    expect(sliderTheme.thumbColor, equals(customColor1.withAlpha(0xff)));
    expect(sliderTheme.disabledThumbColor, equals(customColor2.withAlpha(0x52)));
    expect(sliderTheme.overlayColor, equals(customColor1.withAlpha(0x1f)));
    expect(sliderTheme.valueIndicatorColor, equals(customColor1.withAlpha(0xff)));
    expect(sliderTheme.valueIndicatorTextStyle.color, equals(customColor4));
  });

  testWidgets('SliderThemeData generates correct shapes for fromPrimaryColors', (WidgetTester tester) async {
    const Color customColor1 = Color(0xcafefeed);
    const Color customColor2 = Color(0xdeadbeef);
    const Color customColor3 = Color(0xdecaface);
    const Color customColor4 = Color(0xfeedcafe);

    final SliderThemeData sliderTheme = SliderThemeData.fromPrimaryColors(
      primaryColor: customColor1,
      primaryColorDark: customColor2,
      primaryColorLight: customColor3,
      valueIndicatorTextStyle: ThemeData.fallback().accentTextTheme.body2.copyWith(color: customColor4),
    );

    expect(sliderTheme.overlayShape, const RoundSliderOverlayShape());
    expect(sliderTheme.tickMarkShape, const RoundSliderTickMarkShape());
    expect(sliderTheme.thumbShape, const RoundSliderThumbShape());
    expect(sliderTheme.trackShape, const RoundedRectSliderTrackShape());
    expect(sliderTheme.valueIndicatorShape, const PaddleSliderValueIndicatorShape());
    expect(sliderTheme.rangeTickMarkShape, const RoundRangeSliderTickMarkShape());
    expect(sliderTheme.rangeThumbShape, const RoundRangeSliderThumbShape());
    expect(sliderTheme.rangeTrackShape, const RoundedRectRangeSliderTrackShape());
    expect(sliderTheme.rangeValueIndicatorShape, const PaddleRangeSliderValueIndicatorShape());
  });

  testWidgets('SliderThemeData lerps correctly', (WidgetTester tester) async {
    final SliderThemeData sliderThemeBlack = SliderThemeData.fromPrimaryColors(
      primaryColor: Colors.black,
      primaryColorDark: Colors.black,
      primaryColorLight: Colors.black,
      valueIndicatorTextStyle: ThemeData.fallback().accentTextTheme.body2.copyWith(color: Colors.black),
    ).copyWith(trackHeight: 2.0);
    final SliderThemeData sliderThemeWhite = SliderThemeData.fromPrimaryColors(
      primaryColor: Colors.white,
      primaryColorDark: Colors.white,
      primaryColorLight: Colors.white,
      valueIndicatorTextStyle: ThemeData.fallback().accentTextTheme.body2.copyWith(color: Colors.white),
    ).copyWith(trackHeight: 6.0);
    final SliderThemeData lerp = SliderThemeData.lerp(sliderThemeBlack, sliderThemeWhite, 0.5);
    const Color middleGrey = Color(0xff7f7f7f);

    expect(lerp.trackHeight, equals(4.0));
    expect(lerp.activeTrackColor, equals(middleGrey.withAlpha(0xff)));
    expect(lerp.inactiveTrackColor, equals(middleGrey.withAlpha(0x3d)));
    expect(lerp.disabledActiveTrackColor, equals(middleGrey.withAlpha(0x52)));
    expect(lerp.disabledInactiveTrackColor, equals(middleGrey.withAlpha(0x1f)));
    expect(lerp.activeTickMarkColor, equals(middleGrey.withAlpha(0x8a)));
    expect(lerp.inactiveTickMarkColor, equals(middleGrey.withAlpha(0x8a)));
    expect(lerp.disabledActiveTickMarkColor, equals(middleGrey.withAlpha(0x1f)));
    expect(lerp.disabledInactiveTickMarkColor, equals(middleGrey.withAlpha(0x1f)));
    expect(lerp.thumbColor, equals(middleGrey.withAlpha(0xff)));
    expect(lerp.disabledThumbColor, equals(middleGrey.withAlpha(0x52)));
    expect(lerp.overlayColor, equals(middleGrey.withAlpha(0x1f)));
    expect(lerp.valueIndicatorColor, equals(middleGrey.withAlpha(0xff)));
    expect(lerp.valueIndicatorTextStyle.color, equals(middleGrey.withAlpha(0xff)));
  });

  testWidgets('Default slider track draws correctly', (WidgetTester tester) async {
    final ThemeData theme = ThemeData(
      platform: TargetPlatform.android,
      primarySwatch: Colors.blue,
    );
    final SliderThemeData sliderTheme = theme.sliderTheme.copyWith(thumbColor: Colors.red.shade500);

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.25));
    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    // The enabled slider thumb has track segments that extend to and from
    // the center of the thumb.
    expect(
      sliderBox,
      paints
        ..rect(rect: const Rect.fromLTRB(25.0, 299.0, 202.0, 301.0), color: sliderTheme.activeTrackColor)
        ..rect(rect: const Rect.fromLTRB(222.0, 299.0, 776.0, 301.0), color: sliderTheme.inactiveTrackColor),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.25, enabled: false));
    await tester.pumpAndSettle(); // wait for disable animation

    // The disabled slider thumb has a horizontal gap between itself and the
    // track segments. Therefore, the track segments are shorter since they do
    // not extend to the center of the thumb, but rather the outer edge of th
    // gap. As a result, the `right` value of the first segment is less than it
    // is above, and the `left` value of the second segment is more than it is
    // above.
    expect(
      sliderBox,
      paints
        ..rect(rect: const Rect.fromLTRB(25.0, 299.0, 202.0, 301.0), color: sliderTheme.disabledActiveTrackColor)
        ..rect(rect: const Rect.fromLTRB(222.0, 299.0, 776.0, 301.0), color: sliderTheme.disabledInactiveTrackColor),
    );
  });

  testWidgets('Default slider overlay draws correctly', (WidgetTester tester) async {
    final ThemeData theme = ThemeData(
      platform: TargetPlatform.android,
      primarySwatch: Colors.blue,
    );
    final SliderThemeData sliderTheme = theme.sliderTheme.copyWith(thumbColor: Colors.red.shade500);

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.25));
    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    // With no touch, paints only the thumb.
    expect(
      sliderBox,
      paints
        ..circle(
          color: sliderTheme.thumbColor,
          x: 212.0,
          y: 300.0,
          radius: 10.0,
        ),
    );

    final Offset center = tester.getCenter(find.byType(Slider));
    final TestGesture gesture = await tester.startGesture(center);
    // Wait for overlay animation to finish.
    await tester.pumpAndSettle();

    // After touch, paints thumb and overlay.
    expect(
      sliderBox,
      paints
        ..circle(
          color: sliderTheme.overlayColor,
          x: 212.0,
          y: 300.0,
          radius: 24.0,
        )
        ..circle(
          color: sliderTheme.thumbColor,
          x: 212.0,
          y: 300.0,
          radius: 10.0,
        ),
    );

    await gesture.up();
    await tester.pumpAndSettle();

    // After the gesture is up and complete, it again paints only the thumb.
    expect(
      sliderBox,
      paints
        ..circle(
          color: sliderTheme.thumbColor,
          x: 212.0,
          y: 300.0,
          radius: 10.0,
        ),
    );
  });

  testWidgets('Default slider ticker and thumb shape draw correctly', (WidgetTester tester) async {
    final ThemeData theme = ThemeData(
      platform: TargetPlatform.android,
      primarySwatch: Colors.blue,
    );
    final SliderThemeData sliderTheme = theme.sliderTheme.copyWith(thumbColor: Colors.red.shade500);

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.45));
    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    expect(sliderBox, paints..circle(color: sliderTheme.thumbColor, radius: 10.0));

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.45, enabled: false));
    await tester.pumpAndSettle(); // wait for disable animation

    expect(sliderBox, paints..circle(color: sliderTheme.disabledThumbColor, radius: 10.0));

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.45, divisions: 3));
    await tester.pumpAndSettle(); // wait for enable animation

    expect(
      sliderBox,
      paints
        ..circle(color: sliderTheme.activeTickMarkColor)
        ..circle(color: sliderTheme.activeTickMarkColor)
        ..circle(color: sliderTheme.inactiveTickMarkColor)
        ..circle(color: sliderTheme.inactiveTickMarkColor)
        ..circle(color: sliderTheme.thumbColor, radius: 10.0),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.45, divisions: 3, enabled: false));
    await tester.pumpAndSettle(); // wait for disable animation

    expect(
      sliderBox,
      paints
        ..circle(color: sliderTheme.disabledActiveTickMarkColor)
        ..circle(color: sliderTheme.disabledInactiveTickMarkColor)
        ..circle(color: sliderTheme.disabledInactiveTickMarkColor)
        ..circle(color: sliderTheme.disabledInactiveTickMarkColor)
        ..circle(color: sliderTheme.disabledThumbColor, radius: 10.0),
    );
  });

  testWidgets('The slider track height can be overridden', (WidgetTester tester) async {
    final SliderThemeData sliderTheme = ThemeData().sliderTheme.copyWith(trackHeight: 16);

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.25));

    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    // Top and bottom are centerY (300) + and - trackRadius (8).
    expect(
      sliderBox,
      paints
        ..rect(rect: const Rect.fromLTRB(32.0, 292.0, 202.0, 308.0), color: sliderTheme.activeTrackColor)
        ..rect(rect: const Rect.fromLTRB(222.0, 292.0, 776.0, 308.0), color: sliderTheme.inactiveTrackColor),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.25, enabled: false));
    await tester.pumpAndSettle(); // wait for disable animation

    // The disabled thumb is smaller so the active track has to paint longer to
    // get to the edge.
    expect(
      sliderBox,
      paints
        ..rect(rect: const Rect.fromLTRB(32.0, 292.0, 202.0, 308.0), color: sliderTheme.disabledActiveTrackColor)
        ..rect(rect: const Rect.fromLTRB(222.0, 292.0, 776.0, 308.0), color: sliderTheme.disabledInactiveTrackColor),
    );
  });

  testWidgets('The default slider thumb shape sizes can be overridden', (WidgetTester tester) async {
    final SliderThemeData sliderTheme = ThemeData().sliderTheme.copyWith(
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 7,
          disabledThumbRadius: 11,
        ),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.25));
    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    expect(
      sliderBox,
      paints..circle(x: 212, y: 300, radius: 7, color: sliderTheme.thumbColor),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.25, enabled: false));
    await tester.pumpAndSettle(); // wait for disable animation

    expect(
      sliderBox,
      paints..circle(x: 212, y: 300, radius: 11, color: sliderTheme.disabledThumbColor),
    );
  });

  testWidgets('The default slider thumb shape disabled size can be inferred from the enabled size', (WidgetTester tester) async {
    final SliderThemeData sliderTheme = ThemeData().sliderTheme.copyWith(
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 9,
      ),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.25));
    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    expect(
      sliderBox,
      paints..circle(x: 212, y: 300, radius: 9, color: sliderTheme.thumbColor),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.25, enabled: false));
    await tester.pumpAndSettle(); // wait for disable animation
    expect(
      sliderBox,
      paints..circle(x: 212, y: 300, radius: 9, color: sliderTheme.disabledThumbColor),
    );
  });


  testWidgets('The default slider tick mark shape size can be overridden', (WidgetTester tester) async {
    final SliderThemeData sliderTheme = ThemeData().sliderTheme.copyWith(
      tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 5),
      activeTickMarkColor: const Color(0xfadedead),
      inactiveTickMarkColor: const Color(0xfadebeef),
      disabledActiveTickMarkColor: const Color(0xfadecafe),
      disabledInactiveTickMarkColor: const Color(0xfadeface),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.5, divisions: 2));

    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    expect(
      sliderBox,
      paints
        ..circle(x: 29, y: 300, radius: 5, color: sliderTheme.activeTickMarkColor)
        ..circle(x: 400, y: 300, radius: 5, color: sliderTheme.activeTickMarkColor)
        ..circle(x: 771, y: 300, radius: 5, color: sliderTheme.inactiveTickMarkColor),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.5, divisions: 2,  enabled: false));
    await tester.pumpAndSettle();

    expect(
      sliderBox,
      paints
        ..circle(x: 29, y: 300, radius: 5, color: sliderTheme.disabledActiveTickMarkColor)
        ..circle(x: 400, y: 300, radius: 5, color: sliderTheme.disabledActiveTickMarkColor)
        ..circle(x: 771, y: 300, radius: 5, color: sliderTheme.disabledInactiveTickMarkColor),
    );
  });

  testWidgets('The default slider overlay shape size can be overridden', (WidgetTester tester) async {
    const double uniqueOverlayRadius = 23;
    final SliderThemeData sliderTheme = ThemeData().sliderTheme.copyWith(
      overlayShape: const RoundSliderOverlayShape(
        overlayRadius: uniqueOverlayRadius,
      ),
    );

    await tester.pumpWidget(_buildApp(sliderTheme, value: 0.5));
    // Tap center and wait for animation.
    final Offset center = tester.getCenter(find.byType(Slider));
    await tester.startGesture(center);
    await tester.pumpAndSettle();

    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));
    expect(
      sliderBox,
      paints..circle(
        x: center.dx,
        y: center.dy,
        radius: uniqueOverlayRadius,
        color: sliderTheme.overlayColor,
      ),
    );
  });

  // Only the thumb, overlay, and tick mark have special shortcuts to provide
  // no-op or empty shapes.
  //
  // The track can also be skipped by providing 0 height.
  //
  // The value indicator can be skipped by passing the appropriate
  // [ShowValueIndicator].
  testWidgets('The slider can skip all of its comoponent painting', (WidgetTester tester) async {
    // Pump a slider with all shapes skipped.
    await tester.pumpWidget(_buildApp(
      ThemeData().sliderTheme.copyWith(
        trackHeight: 0,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: SliderComponentShape.noThumb,
        tickMarkShape: SliderTickMarkShape.noTickMark,
        showValueIndicator: ShowValueIndicator.never,
      ),
      value: 0.5,
      divisions: 4,
    ));

    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    expect(sliderBox, paintsNothing);
  });

  testWidgets('The slider can skip all component painting except the track', (WidgetTester tester) async {
    // Pump a slider with just a track.
    await tester.pumpWidget(_buildApp(
      ThemeData().sliderTheme.copyWith(
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: SliderComponentShape.noThumb,
        tickMarkShape: SliderTickMarkShape.noTickMark,
        showValueIndicator: ShowValueIndicator.never,
      ),
      value: 0.5,
      divisions: 4,
    ));

    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    // Only 2 track segments.
    expect(sliderBox, paintsExactlyCountTimes(#drawRect, 2));
    expect(sliderBox, paintsExactlyCountTimes(#drawCircle, 0));
    expect(sliderBox, paintsExactlyCountTimes(#drawPath, 0));
  });

  testWidgets('The slider can skip all component painting except the tick marks', (WidgetTester tester) async {
    // Pump a slider with just tick marks.
    await tester.pumpWidget(_buildApp(
      ThemeData().sliderTheme.copyWith(
        trackHeight: 0,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: SliderComponentShape.noThumb,
        showValueIndicator: ShowValueIndicator.never,
        // When the track is hidden to 0 height, a tick mark radius
        // must be provided to get a non-zero radius.
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1),
      ),
      value: 0.5,
      divisions: 4,
    ));

    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    // Only 5 tick marks.
    expect(sliderBox, paintsExactlyCountTimes(#drawRect, 0));
    expect(sliderBox, paintsExactlyCountTimes(#drawCircle, 5));
    expect(sliderBox, paintsExactlyCountTimes(#drawPath, 0));
  });

  testWidgets('The slider can skip all component painting except the thumb', (WidgetTester tester) async {
    // Pump a slider with just a thumb.
    await tester.pumpWidget(_buildApp(
      ThemeData().sliderTheme.copyWith(
        trackHeight: 0,
        overlayShape: SliderComponentShape.noOverlay,
        tickMarkShape: SliderTickMarkShape.noTickMark,
        showValueIndicator: ShowValueIndicator.never,
      ),
      value: 0.5,
      divisions: 4,
    ));

    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    // Only 1 thumb.
    expect(sliderBox, paintsExactlyCountTimes(#drawRect, 0));
    expect(sliderBox, paintsExactlyCountTimes(#drawCircle, 1));
    expect(sliderBox, paintsExactlyCountTimes(#drawPath, 0));
  });

  testWidgets('The slider can skip all component painting except the overlay', (WidgetTester tester) async {
    // Pump a slider with just an overlay.
    await tester.pumpWidget(_buildApp(
      ThemeData().sliderTheme.copyWith(
        trackHeight: 0,
        thumbShape: SliderComponentShape.noThumb,
        tickMarkShape: SliderTickMarkShape.noTickMark,
        showValueIndicator: ShowValueIndicator.never,
      ),
      value: 0.5,
      divisions: 4,
    ));

    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    // Tap the center of the track and wait for animations to finish.
    final Offset center = tester.getCenter(find.byType(Slider));
    final TestGesture gesture = await tester.startGesture(center);
    await tester.pumpAndSettle();

    // Only 1 overlay.
    expect(sliderBox, paintsExactlyCountTimes(#drawRect, 0));
    expect(sliderBox, paintsExactlyCountTimes(#drawCircle, 1));
    expect(sliderBox, paintsExactlyCountTimes(#drawPath, 0));

    await gesture.up();
  });

  testWidgets('The slider can skip all component painting except the value indicator', (WidgetTester tester) async {
    // Pump a slider with just a value indicator.
    await tester.pumpWidget(_buildApp(
      ThemeData().sliderTheme.copyWith(
        trackHeight: 0,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: SliderComponentShape.noThumb,
        tickMarkShape: SliderTickMarkShape.noTickMark,
        showValueIndicator: ShowValueIndicator.always,
      ),
      value: 0.5,
      divisions: 4,
    ));

    final RenderBox sliderBox = tester.firstRenderObject<RenderBox>(find.byType(Slider));

    // Tap the center of the track and wait for animations to finish.
    final Offset center = tester.getCenter(find.byType(Slider));
    final TestGesture gesture = await tester.startGesture(center);
    await tester.pumpAndSettle();

    // Only 1 value indicator.
    expect(sliderBox, paintsExactlyCountTimes(#drawRect, 0));
    expect(sliderBox, paintsExactlyCountTimes(#drawCircle, 0));
    expect(sliderBox, paintsExactlyCountTimes(#drawPath, 1));

    await gesture.up();
  });
}



Widget _buildApp(
  SliderThemeData sliderTheme, {
  double value = 0.0,
  bool enabled = true,
  int divisions,
}) {
  final ValueChanged<double> onChanged = enabled ? (double d) => value = d : null;
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SliderTheme(
          data: sliderTheme,
          child: Slider(
            value: value,
            label: '$value',
            onChanged: onChanged,
            divisions: divisions,
          ),
        ),
      ),
    ),
  );
}


