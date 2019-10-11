// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-07-16T14:31:01.469155.

import 'dart:math' as math;
import 'package:flutter_web_ui/ui.dart' show Path, lerpDouble;

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';

import 'colors.dart';
import 'theme.dart';
import 'theme_data.dart';

/// {@template flutter.material.slider.seeAlso.sliderComponentShape}
///  * [SliderComponentShape], which can be used to create custom shapes for
///    the [Slider]'s thumb, overlay, and value indicator and the
///    [RangeSlider]'s overlay.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.sliderTrackShape}
///  * [SliderTrackShape], which can be used to create custom shapes for the
///    [Slider]'s track.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.sliderTickMarkShape}
///  * [SliderTickMarkShape], which can be used to create custom shapes for the
///    [Slider]'s tick marks.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.rangeSliderThumbShape}
///  * [RangeSliderThumbShape], which can be used to create custom shapes for
///    the [RangeSlider]'s thumb.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.rangeSliderValueIndicatorShape}
///  * [RangeSliderValueIndicatorShape], which can be used to create custom
///    shapes for the [RangeSlider]'s value indicator.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.rangeSliderTrackShape}
///  * [RangeSliderTrackShape], which can be used to create custom shapes for
///    the [RangeSlider]'s track.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.rangeSliderTickMarkShape}
///  * [RangeSliderTickMarkShape], which can be used to create custom shapes for
///    the [RangeSlider]'s tick marks.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.roundSliderThumbShape}
///  * [RoundSliderThumbShape], which is the default [Slider]'s thumb shape that
///     paints a solid circle.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.roundSliderOverlayShape}
///  * [RoundSliderOverlayShape], which is the default [Slider] and
///   [RangeSlider]'s overlay shape that paints a transparent circle.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.paddleSliderValueIndicatorShape}
///  * [PaddleSliderValueIndicatorShape], which is the default [Slider]'s value
///    indicator shape that paints a custom path with text in it.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.roundSliderTickMarkShape}
///  * [RoundSliderTickMarkShape], which is the the default [Slider]'s tick mark
///    shape that paints a solid circle.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.roundedRectSliderTrackShape}
///  * [RoundedRectSliderTrackShape] for the default [Slider]'s track shape that
///  paints a stadium-like track.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.roundRangeSliderThumbShape}
///  * [RoundRangeSliderThumbShape] for the default [RangeSlider]'s thumb shape
///    that paints a solid circle.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.paddleRangeSliderValueIndicatorShape}
///  * [PaddleRangeSliderValueIndicatorShape] for the default [RangeSlider]'s
///     value indicator shape that paints a custom path with text in it.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.roundRangeSliderTickMarkShape}
///  * [RoundRangeSliderTickMarkShape] for the default [RangeSlider]'s tick mark
///    shape that paints a solid circle.
/// {@endtemplate}
///
/// {@template flutter.material.slider.seeAlso.roundedRectRangeSliderTrackShape}
///  * [RoundedRectRangeSliderTrackShape] for the default [RangeSlider]'s track
///     shape that paints a stadium-like track.
/// {@endtemplate}
///
/// {@template flutter.material.slider.trackSegment}
/// The track segment between the start of the slider and the thumb is the
/// active track segment. The track segment between the thumb and the end of the
/// slider is the inactive track segment. In [TextDirection.ltr], the start of
/// the slider is on the left, and in [TextDirection.rtl], the start of the
/// slider is on the right.
/// {@endtemplate}
///
/// {@template flutter.material.rangeSlider.trackSegment}
/// The track segment between the two thumbs is the active track segment. The
/// track segments between the thumb and each end of the slider are the inactive
/// track segments. In [TextDirection.ltr], the start of the slider is on the
/// left, and in [TextDirection.rtl], the start of the slider is on the right.
/// {@endtemplate}

/// Applies a slider theme to descendant [Slider] widgets.
///
/// A slider theme describes the colors and shape choices of the slider
/// components.
///
/// Descendant widgets obtain the current theme's [SliderThemeData] object using
/// [SliderTheme.of]. When a widget uses [SliderTheme.of], it is automatically
/// rebuilt if the theme later changes.
///
/// The slider is as big as the largest of
/// the [SliderComponentShape.getPreferredSize] of the thumb shape,
/// the [SliderComponentShape.getPreferredSize] of the overlay shape,
/// and the [SliderTickMarkShape.getPreferredSize] of the tick mark shape
///
/// See also:
///
///  * [SliderThemeData], which describes the actual configuration of a slider
///    theme.
/// {@macro flutter.material.slider.seeAlso.sliderComponentShape}
/// {@macro flutter.material.slider.seeAlso.sliderTrackShape}
/// {@macro flutter.material.slider.seeAlso.sliderTickMarkShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderThumbShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderValueIndicatorShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderTrackShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderTickMarkShape}
class SliderTheme extends InheritedWidget {
  /// Applies the given theme [data] to [child].
  ///
  /// The [data] and [child] arguments must not be null.
  const SliderTheme({
    Key key,
    @required this.data,
    @required Widget child,
  }) : assert(child != null),
       assert(data != null),
       super(key: key, child: child);

  /// Specifies the color and shape values for descendant slider widgets.
  final SliderThemeData data;

  /// Returns the data from the closest [SliderTheme] instance that encloses
  /// the given context.
  ///
  /// Defaults to the ambient [ThemeData.sliderTheme] if there is no
  /// [SliderTheme] in the given build context.
  ///
  /// {@tool sample}
  ///
  /// ```dart
  /// class Launch extends StatefulWidget {
  ///   @override
  ///   State createState() => LaunchState();
  /// }
  ///
  /// class LaunchState extends State<Launch> {
  ///   double _rocketThrust;
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return SliderTheme(
  ///       data: SliderTheme.of(context).copyWith(activeTrackColor: const Color(0xff804040)),
  ///       child: Slider(
  ///         onChanged: (double value) { setState(() { _rocketThrust = value; }); },
  ///         value: _rocketThrust,
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [SliderThemeData], which describes the actual configuration of a slider
  ///    theme.
  static SliderThemeData of(BuildContext context) {
    final SliderTheme inheritedTheme = context.inheritFromWidgetOfExactType(SliderTheme);
    return inheritedTheme != null ? inheritedTheme.data : Theme.of(context).sliderTheme;
  }

  @override
  bool updateShouldNotify(SliderTheme oldWidget) => data != oldWidget.data;
}

/// Describes the conditions under which the value indicator on a [Slider]
/// will be shown. Used with [SliderThemeData.showValueIndicator].
///
/// See also:
///
///  * [Slider], a Material Design slider widget.
///  * [SliderThemeData], which describes the actual configuration of a slider
///    theme.
enum ShowValueIndicator {
  /// The value indicator will only be shown for discrete sliders (sliders
  /// where [Slider.divisions] is non-null).
  onlyForDiscrete,

  /// The value indicator will only be shown for continuous sliders (sliders
  /// where [Slider.divisions] is null).
  onlyForContinuous,

  /// The value indicator will be shown for all types of sliders.
  always,

  /// The value indicator will never be shown.
  never,
}

/// Identifier for a thumb.
///
/// There are 2 thumbs in a [RangeSlider], [start] and [end].
///
/// For [TextDirection.ltr], the [start] thumb is the left-most thumb and the
/// [end] thumb is the right-most thumb. For [TextDirection.rtl] the [start]
/// thumb is the right-most thumb, and the [end] thumb is the left-most thumb.
enum Thumb {
  /// Left-most thumb for [TextDirection.ltr], otherwise, right-most thumb.
  start,

  /// Right-most thumb for [TextDirection.ltr], otherwise, left-most thumb.
  end,
}

/// Holds the color, shape, and typography values for a material design slider
/// theme.
///
/// Use this class to configure a [SliderTheme] widget, or to set the
/// [ThemeData.sliderTheme] for a [Theme] widget.
///
/// To obtain the current ambient slider theme, use [SliderTheme.of].
///
/// This theme is for both the [Slider] and the [RangeSlider]. The properties
/// that are only for the [Slider] are: [tickMarkShape], [thumbShape],
/// [trackShape], and [valueIndicatorShape]. The properties that are only for
/// the [RangeSlider] are [rangeTickMarkShape], [rangeThumbShape],
/// [rangeTrackShape], [rangeValueIndicatorShape],
/// [overlappingShapeStrokeColor], [minThumbSeparation], and [thumbSelector].
/// All other properties are used by both the [Slider] and the [RangeSlider].
///
/// The parts of a slider are:
///
///  * The "thumb", which is a shape that slides horizontally when the user
///    drags it.
///  * The "track", which is the line that the slider thumb slides along.
///  * The "tick marks", which are regularly spaced marks that are drawn when
///    using discrete divisions.
///  * The "value indicator", which appears when the user is dragging the thumb
///    to indicate the value being selected.
///  * The "overlay", which appears around the thumb, and is shown when the
///    thumb is pressed, focused, or hovered. It is painted underneath the
///    thumb, so it must extend beyond the bounds of the thumb itself to
///    actually be visible.
///  * The "active" side of the slider is the side between the thumb and the
///    minimum value.
///  * The "inactive" side of the slider is the side between the thumb and the
///    maximum value.
///  * The [Slider] is disabled when it is not accepting user input. See
///    [Slider] for details on when this happens.
///
/// The thumb, track, tick marks, value indicator, and overlay can be customized
/// by creating subclasses of [SliderTrackShape],
/// [SliderComponentShape], and/or [SliderTickMarkShape]. See
/// [RoundSliderThumbShape], [RectangularSliderTrackShape],
/// [RoundSliderTickMarkShape], [PaddleSliderValueIndicatorShape], and
/// [RoundSliderOverlayShape] for examples.
///
/// The track painting can be skipped by specifying 0 for [trackHeight].
/// The thumb painting can be skipped by specifying
/// [SliderComponentShape.noThumb] for [SliderThemeData.thumbShape].
/// The overlay painting can be skipped by specifying
/// [SliderComponentShape.noOverlay] for [SliderThemeData.overlayShape].
/// The tick mark painting can be skipped by specifying
/// [SliderTickMarkShape.noTickMark] for [SliderThemeData.tickMarkShape].
/// The value indicator painting can be skipped by specifying the
/// appropriate [ShowValueIndicator] for [SliderThemeData.showValueIndicator].
///
/// See also:
///
///  * [SliderTheme] widget, which can override the slider theme of its
///    children.
///  * [Theme] widget, which performs a similar function to [SliderTheme],
///    but for overall themes.
///  * [ThemeData], which has a default [SliderThemeData].
/// {@macro flutter.material.slider.seeAlso.sliderComponentShape}
/// {@macro flutter.material.slider.seeAlso.sliderTrackShape}
/// {@macro flutter.material.slider.seeAlso.sliderTickMarkShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderThumbShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderValueIndicatorShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderTrackShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderTickMarkShape}
class SliderThemeData extends Diagnosticable {
  /// Create a [SliderThemeData] given a set of exact values. All the values
  /// must be specified.
  ///
  /// This will rarely be used directly. It is used by [lerp] to
  /// create intermediate themes based on two themes.
  ///
  /// The simplest way to create a SliderThemeData is to use
  /// [copyWith] on the one you get from [SliderTheme.of], or create an
  /// entirely new one with [SliderThemeData.fromPrimaryColors].
  ///
  /// {@tool sample}
  ///
  /// ```dart
  /// class Blissful extends StatefulWidget {
  ///   @override
  ///   State createState() => BlissfulState();
  /// }
  ///
  /// class BlissfulState extends State<Blissful> {
  ///   double _bliss;
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return SliderTheme(
  ///       data: SliderTheme.of(context).copyWith(activeTrackColor: const Color(0xff404080)),
  ///       child: Slider(
  ///         onChanged: (double value) { setState(() { _bliss = value; }); },
  ///         value: _bliss,
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  const SliderThemeData({
    this.trackHeight,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.disabledActiveTrackColor,
    this.disabledInactiveTrackColor,
    this.activeTickMarkColor,
    this.inactiveTickMarkColor,
    this.disabledActiveTickMarkColor,
    this.disabledInactiveTickMarkColor,
    this.thumbColor,
    this.overlappingShapeStrokeColor,
    this.disabledThumbColor,
    this.overlayColor,
    this.valueIndicatorColor,
    this.overlayShape,
    this.tickMarkShape,
    this.thumbShape,
    this.trackShape,
    this.valueIndicatorShape,
    this.rangeTickMarkShape,
    this.rangeThumbShape,
    this.rangeTrackShape,
    this.rangeValueIndicatorShape,
    this.showValueIndicator,
    this.valueIndicatorTextStyle,
    this.minThumbSeparation,
    this.thumbSelector,
  });

  /// Generates a SliderThemeData from three main colors.
  ///
  /// Usually these are the primary, dark and light colors from
  /// a [ThemeData].
  ///
  /// The opacities of these colors will be overridden with the Material Design
  /// defaults when assigning them to the slider theme component colors.
  ///
  /// This is used to generate the default slider theme for a [ThemeData].
  factory SliderThemeData.fromPrimaryColors({
    @required Color primaryColor,
    @required Color primaryColorDark,
    @required Color primaryColorLight,
    @required TextStyle valueIndicatorTextStyle,
  }) {
    assert(primaryColor != null);
    assert(primaryColorDark != null);
    assert(primaryColorLight != null);
    assert(valueIndicatorTextStyle != null);

    // These are Material Design defaults, and are used to derive
    // component Colors (with opacity) from base colors.
    const int activeTrackAlpha = 0xff;
    const int inactiveTrackAlpha = 0x3d; // 24% opacity
    const int disabledActiveTrackAlpha = 0x52; // 32% opacity
    const int disabledInactiveTrackAlpha = 0x1f; // 12% opacity
    const int activeTickMarkAlpha = 0x8a; // 54% opacity
    const int inactiveTickMarkAlpha = 0x8a; // 54% opacity
    const int disabledActiveTickMarkAlpha = 0x1f; // 12% opacity
    const int disabledInactiveTickMarkAlpha = 0x1f; // 12% opacity
    const int thumbAlpha = 0xff;
    const int disabledThumbAlpha = 0x52; // 32% opacity
    const int overlayAlpha = 0x1f; // 12% opacity
    const int valueIndicatorAlpha = 0xff;

    return SliderThemeData(
      trackHeight: 2.0,
      activeTrackColor: primaryColor.withAlpha(activeTrackAlpha),
      inactiveTrackColor: primaryColor.withAlpha(inactiveTrackAlpha),
      disabledActiveTrackColor: primaryColorDark.withAlpha(disabledActiveTrackAlpha),
      disabledInactiveTrackColor: primaryColorDark.withAlpha(disabledInactiveTrackAlpha),
      activeTickMarkColor: primaryColorLight.withAlpha(activeTickMarkAlpha),
      inactiveTickMarkColor: primaryColor.withAlpha(inactiveTickMarkAlpha),
      disabledActiveTickMarkColor: primaryColorLight.withAlpha(disabledActiveTickMarkAlpha),
      disabledInactiveTickMarkColor: primaryColorDark.withAlpha(disabledInactiveTickMarkAlpha),
      thumbColor: primaryColor.withAlpha(thumbAlpha),
      overlappingShapeStrokeColor: Colors.white,
      disabledThumbColor: primaryColorDark.withAlpha(disabledThumbAlpha),
      overlayColor: primaryColor.withAlpha(overlayAlpha),
      valueIndicatorColor: primaryColor.withAlpha(valueIndicatorAlpha),
      overlayShape: const RoundSliderOverlayShape(),
      tickMarkShape: const RoundSliderTickMarkShape(),
      thumbShape: const RoundSliderThumbShape(),
      trackShape: const RoundedRectSliderTrackShape(),
      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      rangeTickMarkShape: const RoundRangeSliderTickMarkShape(),
      rangeThumbShape: const RoundRangeSliderThumbShape(),
      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
      rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
      valueIndicatorTextStyle: valueIndicatorTextStyle,
      showValueIndicator: ShowValueIndicator.onlyForDiscrete,
    );
  }

  /// The height of the [Slider] track.
  final double trackHeight;

  /// The color of the [Slider] track between the [Slider.min] position and the
  /// current thumb position.
  final Color activeTrackColor;

  /// The color of the [Slider] track between the current thumb position and the
  /// [Slider.max] position.
  final Color inactiveTrackColor;

  /// The color of the [Slider] track between the [Slider.min] position and the
  /// current thumb position when the [Slider] is disabled.
  final Color disabledActiveTrackColor;

  /// The color of the [Slider] track between the current thumb position and the
  /// [Slider.max] position when the [Slider] is disabled.
  final Color disabledInactiveTrackColor;

  /// The color of the track's tick marks that are drawn between the [Slider.min]
  /// position and the current thumb position.
  final Color activeTickMarkColor;

  /// The color of the track's tick marks that are drawn between the current
  /// thumb position and the [Slider.max] position.
  final Color inactiveTickMarkColor;

  /// The color of the track's tick marks that are drawn between the [Slider.min]
  /// position and the current thumb position when the [Slider] is disabled.
  final Color disabledActiveTickMarkColor;

  /// The color of the track's tick marks that are drawn between the current
  /// thumb position and the [Slider.max] position when the [Slider] is
  /// disabled.
  final Color disabledInactiveTickMarkColor;

  /// The color given to the [thumbShape] to draw itself with.
  final Color thumbColor;

  /// The color given to the perimeter of the top [rangeThumbShape] when the
  /// thumbs are overlapping and the top [rangeValueIndicatorShape] when the
  /// value indicators are overlapping.
  final Color overlappingShapeStrokeColor;

  /// The color given to the [thumbShape] to draw itself with when the
  /// [Slider] is disabled.
  final Color disabledThumbColor;

  /// The color of the overlay drawn around the slider thumb when it is pressed.
  ///
  /// This is typically a semi-transparent color.
  final Color overlayColor;

  /// The color given to the [valueIndicatorShape] to draw itself with.
  final Color valueIndicatorColor;

  /// The shape that will be used to draw the [Slider]'s overlay.
  ///
  /// Both the [overlayColor] and a non default [overlayShape] may be specified.
  /// The default [overlayShape] refers to the [overlayColor].
  ///
  /// The default value is [RoundSliderOverlayShape].
  final SliderComponentShape overlayShape;

  /// The shape that will be used to draw the [Slider]'s tick marks.
  ///
  /// The [SliderTickMarkShape.getPreferredSize] is used to help determine the
  /// location of each tick mark on the track. The slider's minimum size will
  /// be at least this big.
  ///
  /// The default value is [RoundSliderTickMarkShape].
  ///
  /// See also:
  ///
  ///  * [RoundRangeSliderTickMarkShape], which is the the default tick mark
  ///    shape for the range slider.
  final SliderTickMarkShape tickMarkShape;

  /// The shape that will be used to draw the [Slider]'s thumb.
  ///
  /// The default value is [RoundSliderThumbShape].
  ///
  /// See also:
  ///
  ///  * [RoundRangeSliderThumbShape], which is the the default thumb shape for
  ///    the [RangeSlider].
  final SliderComponentShape thumbShape;

  /// The shape that will be used to draw the [Slider]'s track.
  ///
  /// The [SliderTrackShape.getPreferredRect] method is used to map
  /// slider-relative gesture coordinates to the correct thumb position on the
  /// track. It is also used to horizontally position tick marks, when the
  /// slider is discrete.
  ///
  /// The default value is [RoundedRectSliderTrackShape].
  ///
  /// See also:
  ///
  ///  * [RoundedRectRangeSliderTrackShape], which is the the default track
  ///    shape for the [RangeSlider].
  final SliderTrackShape trackShape;

  /// The shape that will be used to draw the [Slider]'s value
  /// indicator.
  ///
  /// The default value is [PaddleSliderValueIndicatorShape].
  ///
  /// See also:
  ///
  ///  * [PaddleRangeSliderValueIndicatorShape], which is the the default value
  ///    indicator shape for the [RangeSlider].
  final SliderComponentShape valueIndicatorShape;

  /// The shape that will be used to draw the [RangeSlider]'s tick marks.
  ///
  /// The [RangeSliderTickMarkShape.getPreferredSize] is used to help determine
  /// the location of each tick mark on the track. The slider's minimum size
  /// will be at least this big.
  ///
  /// The default value is [RoundRangeSliderTickMarkShape].
  ///
  /// See also:
  ///
  ///  * [RoundSliderTickMarkShape], which is the the default tick mark shape
  ///    for the [Slider].
  final RangeSliderTickMarkShape rangeTickMarkShape;

  /// The shape that will be used for the [RangeSlider]'s thumbs.
  ///
  /// By default the same shape is used for both thumbs, but strokes the top
  /// thumb when it overlaps the bottom thumb. The top thumb is always the last
  /// selected thumb.
  ///
  /// The default value is [RoundRangeSliderThumbShape].
  ///
  /// See also:
  ///
  ///  * [RoundSliderThumbShape], which is the the default thumb shape for the
  ///    [Slider].
  final RangeSliderThumbShape rangeThumbShape;

  /// The shape that will be used to draw the [RangeSlider]'s track.
  ///
  /// The [SliderTrackShape.getPreferredRect] method is used to to map
  /// slider-relative gesture coordinates to the correct thumb position on the
  /// track. It is also used to horizontally position the tick marks, when the
  /// slider is discrete.
  ///
  /// The default value is [RoundedRectRangeSliderTrackShape].
  ///
  /// See also:
  ///
  ///  * [RoundedRectSliderTrackShape], which is the the default track
  ///    shape for the [Slider].
  final RangeSliderTrackShape rangeTrackShape;

  /// The shape that will be used for the [RangeSlider]'s value indicators.
  ///
  /// The default shape uses the same value indicator for each thumb, but
  /// strokes the top value indicator when it overlaps the bottom value
  /// indicator. The top indicator corresponds to the top thumb, which is always
  /// the most recently selected thumb.
  ///
  /// The default value is [PaddleRangeSliderValueIndicatorShape].
  ///
  /// See also:
  ///
  ///  * [PaddleSliderValueIndicatorShape], which is the the default value
  ///    indicator shape for the [Slider].
  final RangeSliderValueIndicatorShape rangeValueIndicatorShape;

  /// Whether the value indicator should be shown for different types of
  /// sliders.
  ///
  /// By default, [showValueIndicator] is set to
  /// [ShowValueIndicator.onlyForDiscrete]. The value indicator is only shown
  /// when the thumb is being touched.
  final ShowValueIndicator showValueIndicator;

  /// The text style for the text on the value indicator.
  ///
  /// By default this is the [ThemeData.accentTextTheme.body2] text theme.
  final TextStyle valueIndicatorTextStyle;

  /// Limits the thumb's separation distance.
  ///
  /// Use this only if you want to control the visual appearance of the thumbs
  /// in terms of a logical pixel value. This can be done when you want a
  /// specific look for thumbs when they are close together. To limit with the
  /// real values, rather than logical pixels, the [values] can be restricted by
  /// the parent.
  final double minThumbSeparation;

  /// Determines which thumb should be selected when the slider is interacted
  /// with.
  ///
  /// If null, the default thumb selector finds the closest thumb, excluding
  /// taps that are between the thumbs and not within any one touch target.
  /// When the selection is within the touch target bounds of both thumbs, no
  /// thumb is selected until the selection is moved.
  ///
  /// Override this for custom thumb selection.
  final RangeThumbSelector thumbSelector;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  SliderThemeData copyWith({
    double trackHeight,
    Color activeTrackColor,
    Color inactiveTrackColor,
    Color disabledActiveTrackColor,
    Color disabledInactiveTrackColor,
    Color activeTickMarkColor,
    Color inactiveTickMarkColor,
    Color disabledActiveTickMarkColor,
    Color disabledInactiveTickMarkColor,
    Color thumbColor,
    Color overlappingShapeStrokeColor,
    Color disabledThumbColor,
    Color overlayColor,
    Color valueIndicatorColor,
    SliderComponentShape overlayShape,
    SliderTickMarkShape tickMarkShape,
    SliderComponentShape thumbShape,
    SliderTrackShape trackShape,
    SliderComponentShape valueIndicatorShape,
    RangeSliderTickMarkShape rangeTickMarkShape,
    RangeSliderThumbShape rangeThumbShape,
    RangeSliderTrackShape rangeTrackShape,
    RangeSliderValueIndicatorShape rangeValueIndicatorShape,
    ShowValueIndicator showValueIndicator,
    TextStyle valueIndicatorTextStyle,
    double minThumbSeparation,
    RangeThumbSelector thumbSelector,
  }) {
    return SliderThemeData(
      trackHeight: trackHeight ?? this.trackHeight,
      activeTrackColor: activeTrackColor ?? this.activeTrackColor,
      inactiveTrackColor: inactiveTrackColor ?? this.inactiveTrackColor,
      disabledActiveTrackColor: disabledActiveTrackColor ?? this.disabledActiveTrackColor,
      disabledInactiveTrackColor: disabledInactiveTrackColor ?? this.disabledInactiveTrackColor,
      activeTickMarkColor: activeTickMarkColor ?? this.activeTickMarkColor,
      inactiveTickMarkColor: inactiveTickMarkColor ?? this.inactiveTickMarkColor,
      disabledActiveTickMarkColor: disabledActiveTickMarkColor ?? this.disabledActiveTickMarkColor,
      disabledInactiveTickMarkColor: disabledInactiveTickMarkColor ?? this.disabledInactiveTickMarkColor,
      thumbColor: thumbColor ?? this.thumbColor,
      overlappingShapeStrokeColor: overlappingShapeStrokeColor ?? this.overlappingShapeStrokeColor,
      disabledThumbColor: disabledThumbColor ?? this.disabledThumbColor,
      overlayColor: overlayColor ?? this.overlayColor,
      valueIndicatorColor: valueIndicatorColor ?? this.valueIndicatorColor,
      overlayShape: overlayShape ?? this.overlayShape,
      tickMarkShape: tickMarkShape ?? this.tickMarkShape,
      thumbShape: thumbShape ?? this.thumbShape,
      trackShape: trackShape ?? this.trackShape,
      valueIndicatorShape: valueIndicatorShape ?? this.valueIndicatorShape,
      rangeTickMarkShape: rangeTickMarkShape ?? this.rangeTickMarkShape,
      rangeThumbShape: rangeThumbShape ?? this.rangeThumbShape,
      rangeTrackShape: rangeTrackShape ?? this.rangeTrackShape,
      rangeValueIndicatorShape: rangeValueIndicatorShape ?? this.rangeValueIndicatorShape,
      showValueIndicator: showValueIndicator ?? this.showValueIndicator,
      valueIndicatorTextStyle: valueIndicatorTextStyle ?? this.valueIndicatorTextStyle,
      minThumbSeparation: minThumbSeparation ?? this.minThumbSeparation,
      thumbSelector: thumbSelector ?? this.thumbSelector,
    );
  }

  /// Linearly interpolate between two slider themes.
  ///
  /// The arguments must not be null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static SliderThemeData lerp(SliderThemeData a, SliderThemeData b, double t) {
    assert(a != null);
    assert(b != null);
    assert(t != null);
    return SliderThemeData(
      trackHeight: lerpDouble(a.trackHeight, b.trackHeight, t),
      activeTrackColor: Color.lerp(a.activeTrackColor, b.activeTrackColor, t),
      inactiveTrackColor: Color.lerp(a.inactiveTrackColor, b.inactiveTrackColor, t),
      disabledActiveTrackColor: Color.lerp(a.disabledActiveTrackColor, b.disabledActiveTrackColor, t),
      disabledInactiveTrackColor: Color.lerp(a.disabledInactiveTrackColor, b.disabledInactiveTrackColor, t),
      activeTickMarkColor: Color.lerp(a.activeTickMarkColor, b.activeTickMarkColor, t),
      inactiveTickMarkColor: Color.lerp(a.inactiveTickMarkColor, b.inactiveTickMarkColor, t),
      disabledActiveTickMarkColor: Color.lerp(a.disabledActiveTickMarkColor, b.disabledActiveTickMarkColor, t),
      disabledInactiveTickMarkColor: Color.lerp(a.disabledInactiveTickMarkColor, b.disabledInactiveTickMarkColor, t),
      thumbColor: Color.lerp(a.thumbColor, b.thumbColor, t),
      overlappingShapeStrokeColor: Color.lerp(a.overlappingShapeStrokeColor, b.overlappingShapeStrokeColor, t),
      disabledThumbColor: Color.lerp(a.disabledThumbColor, b.disabledThumbColor, t),
      overlayColor: Color.lerp(a.overlayColor, b.overlayColor, t),
      valueIndicatorColor: Color.lerp(a.valueIndicatorColor, b.valueIndicatorColor, t),
      overlayShape: t < 0.5 ? a.overlayShape : b.overlayShape,
      tickMarkShape: t < 0.5 ? a.tickMarkShape : b.tickMarkShape,
      thumbShape: t < 0.5 ? a.thumbShape : b.thumbShape,
      trackShape: t < 0.5 ? a.trackShape : b.trackShape,
      valueIndicatorShape: t < 0.5 ? a.valueIndicatorShape : b.valueIndicatorShape,
      rangeTickMarkShape: t < 0.5 ? a.rangeTickMarkShape : b.rangeTickMarkShape,
      rangeThumbShape: t < 0.5 ? a.rangeThumbShape : b.rangeThumbShape,
      rangeTrackShape: t < 0.5 ? a.rangeTrackShape : b.rangeTrackShape,
      rangeValueIndicatorShape: t < 0.5 ? a.rangeValueIndicatorShape : b.rangeValueIndicatorShape,
      showValueIndicator: t < 0.5 ? a.showValueIndicator : b.showValueIndicator,
      valueIndicatorTextStyle: TextStyle.lerp(a.valueIndicatorTextStyle, b.valueIndicatorTextStyle, t),
      minThumbSeparation: lerpDouble(a.minThumbSeparation, b.minThumbSeparation, t),
      thumbSelector: t < 0.5 ? a.thumbSelector : b.thumbSelector,
    );
  }

  @override
  int get hashCode {
    return hashList(<Object>[
      trackHeight,
      activeTrackColor,
      inactiveTrackColor,
      disabledActiveTrackColor,
      disabledInactiveTrackColor,
      activeTickMarkColor,
      inactiveTickMarkColor,
      disabledActiveTickMarkColor,
      disabledInactiveTickMarkColor,
      thumbColor,
      overlappingShapeStrokeColor,
      disabledThumbColor,
      overlayColor,
      valueIndicatorColor,
      overlayShape,
      tickMarkShape,
      thumbShape,
      trackShape,
      valueIndicatorShape,
      rangeTickMarkShape,
      rangeThumbShape,
      rangeTrackShape,
      rangeValueIndicatorShape,
      showValueIndicator,
      valueIndicatorTextStyle,
      minThumbSeparation,
      thumbSelector,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    final SliderThemeData otherData = other;
    return otherData.trackHeight == trackHeight
      && otherData.activeTrackColor == activeTrackColor
      && otherData.inactiveTrackColor == inactiveTrackColor
      && otherData.disabledActiveTrackColor == disabledActiveTrackColor
      && otherData.disabledInactiveTrackColor == disabledInactiveTrackColor
      && otherData.activeTickMarkColor == activeTickMarkColor
      && otherData.inactiveTickMarkColor == inactiveTickMarkColor
      && otherData.disabledActiveTickMarkColor == disabledActiveTickMarkColor
      && otherData.disabledInactiveTickMarkColor == disabledInactiveTickMarkColor
      && otherData.thumbColor == thumbColor
      && otherData.overlappingShapeStrokeColor == overlappingShapeStrokeColor
      && otherData.disabledThumbColor == disabledThumbColor
      && otherData.overlayColor == overlayColor
      && otherData.valueIndicatorColor == valueIndicatorColor
      && otherData.overlayShape == overlayShape
      && otherData.tickMarkShape == tickMarkShape
      && otherData.thumbShape == thumbShape
      && otherData.trackShape == trackShape
      && otherData.valueIndicatorShape == valueIndicatorShape
      && otherData.rangeTickMarkShape == rangeTickMarkShape
      && otherData.rangeThumbShape == rangeThumbShape
      && otherData.rangeTrackShape == rangeTrackShape
      && otherData.rangeValueIndicatorShape == rangeValueIndicatorShape
      && otherData.showValueIndicator == showValueIndicator
      && otherData.valueIndicatorTextStyle == valueIndicatorTextStyle
      && otherData.minThumbSeparation == minThumbSeparation
      && otherData.thumbSelector == thumbSelector;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    const SliderThemeData defaultData = SliderThemeData();
    properties.add(DoubleProperty('trackHeight', trackHeight, defaultValue: defaultData.trackHeight));
    properties.add(ColorProperty('activeTrackColor', activeTrackColor, defaultValue: defaultData.activeTrackColor));
    properties.add(ColorProperty('inactiveTrackColor', inactiveTrackColor, defaultValue: defaultData.inactiveTrackColor));
    properties.add(ColorProperty('disabledActiveTrackColor', disabledActiveTrackColor, defaultValue: defaultData.disabledActiveTrackColor));
    properties.add(ColorProperty('disabledInactiveTrackColor', disabledInactiveTrackColor, defaultValue: defaultData.disabledInactiveTrackColor));
    properties.add(ColorProperty('activeTickMarkColor', activeTickMarkColor, defaultValue: defaultData.activeTickMarkColor));
    properties.add(ColorProperty('inactiveTickMarkColor', inactiveTickMarkColor, defaultValue: defaultData.inactiveTickMarkColor));
    properties.add(ColorProperty('disabledActiveTickMarkColor', disabledActiveTickMarkColor, defaultValue: defaultData.disabledActiveTickMarkColor));
    properties.add(ColorProperty('disabledInactiveTickMarkColor', disabledInactiveTickMarkColor, defaultValue: defaultData.disabledInactiveTickMarkColor));
    properties.add(ColorProperty('thumbColor', thumbColor, defaultValue: defaultData.thumbColor));
    properties.add(ColorProperty('overlappingShapeStrokeColor', overlappingShapeStrokeColor, defaultValue: defaultData.overlappingShapeStrokeColor));
    properties.add(ColorProperty('disabledThumbColor', disabledThumbColor, defaultValue: defaultData.disabledThumbColor));
    properties.add(ColorProperty('overlayColor', overlayColor, defaultValue: defaultData.overlayColor));
    properties.add(ColorProperty('valueIndicatorColor', valueIndicatorColor, defaultValue: defaultData.valueIndicatorColor));
    properties.add(DiagnosticsProperty<SliderComponentShape>('overlayShape', overlayShape, defaultValue: defaultData.overlayShape));
    properties.add(DiagnosticsProperty<SliderTickMarkShape>('tickMarkShape', tickMarkShape, defaultValue: defaultData.tickMarkShape));
    properties.add(DiagnosticsProperty<SliderComponentShape>('thumbShape', thumbShape, defaultValue: defaultData.thumbShape));
    properties.add(DiagnosticsProperty<SliderTrackShape>('trackShape', trackShape, defaultValue: defaultData.trackShape));
    properties.add(DiagnosticsProperty<SliderComponentShape>('valueIndicatorShape', valueIndicatorShape, defaultValue: defaultData.valueIndicatorShape));
    properties.add(DiagnosticsProperty<RangeSliderTickMarkShape>('rangeTickMarkShape', rangeTickMarkShape, defaultValue: defaultData.rangeTickMarkShape));
    properties.add(DiagnosticsProperty<RangeSliderThumbShape>('rangeThumbShape', rangeThumbShape, defaultValue: defaultData.rangeThumbShape));
    properties.add(DiagnosticsProperty<RangeSliderTrackShape>('rangeTrackShape', rangeTrackShape, defaultValue: defaultData.rangeTrackShape));
    properties.add(DiagnosticsProperty<RangeSliderValueIndicatorShape>('rangeValueIndicatorShape', rangeValueIndicatorShape, defaultValue: defaultData.rangeValueIndicatorShape));
    properties.add(EnumProperty<ShowValueIndicator>('showValueIndicator', showValueIndicator, defaultValue: defaultData.showValueIndicator));
    properties.add(DiagnosticsProperty<TextStyle>('valueIndicatorTextStyle', valueIndicatorTextStyle, defaultValue: defaultData.valueIndicatorTextStyle));
    properties.add(DoubleProperty('minThumbSeparation', minThumbSeparation, defaultValue: defaultData.minThumbSeparation));
    properties.add(DiagnosticsProperty<RangeThumbSelector>('thumbSelector', thumbSelector, defaultValue: defaultData.thumbSelector));
  }
}

/// {@template flutter.material.slider.shape.center}
/// [center] is the offset for where this shape's center should be painted.
/// This offset is relative to the origin of the [context] canvas.
/// {@endtemplate}
///
/// {@template flutter.material.slider.shape.context}
/// [context] is the same as the one that includes the [Slider]'s render box.
/// {@endtemplate}
///
/// {@template flutter.material.slider.shape.enableAnimation}
/// [enableAnimation] is an animation triggered when the [Slider] is enabled,
/// and it reverses when the slider is disabled. Enabled is the
/// [Slider.isInteractive] state. Use this to paint intermediate frames for
/// this shape when the slider changes enabled state.
/// {@endtemplate}
///
/// {@template flutter.material.slider.shape.isDiscrete}
/// [isDiscrete] is true if [Slider.divisions] is non-null. If true, the
/// slider will render tick marks on top of the track.
/// {@endtemplate}
///
/// {@template flutter.material.slider.shape.isEnabled}
/// [isEnabled] has the same value as [Slider.isInteractive]. If true, the
/// slider will respond to input.
/// {@endtemplate}
///
/// {@template flutter.material.slider.shape.parentBox}
/// [parentBox] is the [RenderBox] of the [Slider]. Its attributes, such as
/// size, can be used to assist in painting this shape.
/// {@endtemplate}
//
/// {@template flutter.material.slider.shape.sliderTheme}
/// [sliderTheme] is the theme assigned to the [Slider] that this shape
/// belongs to.
/// {@endtemplate}
///
/// {@template flutter.material.rangeSlider.shape.activationAnimation}
/// [activationAnimation] is an animation triggered when the user begins
/// to interact with the [RangeSlider]. It reverses when the user stops
/// interacting with the slider.
/// {@endtemplate}
///
/// {@template flutter.material.rangeSlider.shape.context}
/// [context] is the same as the one that includes the [RangeSlider]'s render
/// box.
/// {@endtemplate}
///
/// {@template flutter.material.rangeSlider.shape.enableAnimation}
/// [enableAnimation] is an animation triggered when the [RangeSlider] is
/// enabled, and it reverses when the slider is disabled. Enabled is the
/// [RangeSlider.isEnabled] state. Use this to paint intermediate frames for
/// this shape when the slider changes enabled state.
/// {@endtemplate}
///
/// {@template flutter.material.rangeSlider.shape.isDiscrete}
/// [isDiscrete] is true if [RangeSlider.divisions] is non-null. If true, the
/// slider will render tick marks on top of the track.
/// {@endtemplate}
///
/// {@template flutter.material.rangeSlider.shape.isEnabled}
/// [isEnabled] has the same value as [RangeSlider.isEnabled]. If true, the
/// slider will respond to input.
/// {@endtemplate}
///
/// {@template flutter.material.rangeSlider.shape.parentBox}
/// [parentBox] is the [RenderBox] of the [RangeSlider]. Its attributes, such as
/// size, can be used to assist in painting this shape.
/// {@endtemplate}
///
/// {@template flutter.material.rangeSlider.shape.sliderTheme}
/// [sliderTheme] is the theme assigned to the [RangeSlider] that this shape
/// belongs to.
/// {@endtemplate}
///
/// {@template flutter.material.rangeSlider.shape.thumb}
/// [thumb] Is the specifier for which of the two thumbs this method should
/// paint, start or end.
/// {@endtemplate}

/// Base class for slider thumb, thumb overlay, and value indicator shapes.
///
/// Create a subclass of this if you would like a custom shape.
///
/// All shapes are painted to the same canvas and ordering is important.
/// The overlay is painted first, then the value indicator, then the thumb.
///
/// The thumb painting can be skipped by specifying [noThumb] for
/// [SliderThemeData.thumbShape].
///
/// The overlay painting can be skipped by specifying [noOverlay] for
/// [SliderThemeData.overlayShape].
///
/// See also:
///
/// {@macro flutter.material.slider.seeAlso.roundSliderThumbShape}
/// {@macro flutter.material.slider.seeAlso.roundSliderOverlayShape}
/// {@macro flutter.material.slider.seeAlso.paddleSliderValueIndicatorShape}
abstract class SliderComponentShape {
  /// This abstract const constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SliderComponentShape();

  /// Returns the preferred size of the shape, based on the given conditions.
  Size getPreferredSize(bool isEnabled, bool isDiscrete);

  /// Paints the shape, taking into account the state passed to it.
  ///
  /// {@macro flutter.material.slider.shape.context}
  ///
  /// {@macro flutter.material.slider.shape.center}
  ///
  /// [activationAnimation] is an animation triggered when the user begins
  /// to interact with the slider. It reverses when the user stops interacting
  /// with the slider.
  ///
  /// {@macro flutter.material.slider.shape.enableAnimation}
  ///
  /// {@macro flutter.material.slider.shape.isDiscrete}
  ///
  /// If [labelPainter] is non-null, then [labelPainter.paint] should be
  /// called with the location that the label should appear. If the labelPainter
  /// parameter is null, then no label was supplied to the [Slider].
  ///
  /// {@macro flutter.material.slider.shape.parentBox}
  ///
  /// {@macro flutter.material.slider.shape.sliderTheme}
  ///
  /// [textDirection] can be used to determine how any extra text or graphics,
  /// besides the text painted by the [labelPainter] should be positioned. The
  /// [labelPainter] already has the [textDirection] set.
  ///
  /// [value] is the current parametric value (from 0.0 to 1.0) of the slider.
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  });

  /// Special instance of [SliderComponentShape] to skip the thumb drawing.
  ///
  /// See also:
  ///
  ///  * [SliderThemeData.thumbShape], which is the shape that the [Slider]
  ///    uses when painting the thumb.
  static final SliderComponentShape noThumb = _EmptySliderComponentShape();

  /// Special instance of [SliderComponentShape] to skip the overlay drawing.
  ///
  /// See also:
  ///
  ///  * [SliderThemeData.overlayShape], which is the shape that the [Slider]
  ///    uses when painting the overlay.
  static final SliderComponentShape noOverlay = _EmptySliderComponentShape();
}

/// Base class for [Slider] tick mark shapes.
///
/// Create a subclass of this if you would like a custom slider tick mark shape.
///
/// The tick mark painting can be skipped by specifying [noTickMark] for
/// [SliderThemeData.tickMarkShape].
///
/// See also:
///
/// {@macro flutter.material.slider.seeAlso.roundSliderTickMarkShape}
/// {@macro flutter.material.slider.seeAlso.sliderTrackShape}
/// {@macro flutter.material.slider.seeAlso.sliderComponentShape}
abstract class SliderTickMarkShape {
  /// This abstract const constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SliderTickMarkShape();

  /// Returns the preferred size of the shape.
  ///
  /// It is used to help position the tick marks within the slider.
  ///
  /// {@macro flutter.material.slider.shape.sliderTheme}
  ///
  /// {@macro flutter.material.slider.shape.isEnabled}
  Size getPreferredSize({
    SliderThemeData sliderTheme,
    bool isEnabled,
  });

  /// Paints the slider track.
  ///
  /// {@macro flutter.material.slider.shape.context}
  ///
  /// {@macro flutter.material.slider.shape.center}
  ///
  /// {@macro flutter.material.slider.shape.parentBox}
  ///
  /// {@macro flutter.material.slider.shape.sliderTheme}
  ///
  /// {@macro flutter.material.slider.shape.enableAnimation}
  ///
  /// {@macro flutter.material.slider.shape.isEnabled}
  ///
  /// [textDirection] can be used to determine how the tick marks are painting
  /// depending on whether they are on an active track segment or not. The track
  /// segment between the start of the slider and the thumb is the active track
  /// segment. The track segment between the thumb and the end of the slider is
  /// the inactive track segment. In LTR text direction, the start of the slider
  /// is on the left, and in RTL text direction, the start of the slider is on
  /// the right.
  void paint(
    PaintingContext context,
    Offset center, {
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    Animation<double> enableAnimation,
    Offset thumbCenter,
    bool isEnabled,
    TextDirection textDirection,
  });

  /// Special instance of [SliderTickMarkShape] to skip the tick mark painting.
  ///
  /// See also:
  ///
  ///  * [SliderThemeData.tickMarkShape], which is the shape that the [Slider]
  ///    uses when painting tick marks.
  static final SliderTickMarkShape noTickMark = _EmptySliderTickMarkShape();
}

/// Base class for slider track shapes.
///
/// The slider's thumb moves along the track. A discrete slider's tick marks
/// are drawn after the track, but before the thumb, and are aligned with the
/// track.
///
/// The [getPreferredRect] helps position the slider thumb and tick marks
/// relative to the track.
///
/// See also:
///
/// {@macro flutter.material.slider.seeAlso.roundedRectSliderTrackShape}
/// {@macro flutter.material.slider.seeAlso.sliderTickMarkShape}
/// {@macro flutter.material.slider.seeAlso.sliderComponentShape}
abstract class SliderTrackShape {
  /// This abstract const constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SliderTrackShape();

  /// Returns the preferred bounds of the shape.
  ///
  /// It is used to provide horizontal boundaries for the thumb's position, and
  /// to help position the slider thumb and tick marks relative to the track.
  ///
  /// The [parentBox] argument can be used to help determine the preferredRect relative to
  /// attributes of the render box of the slider itself, such as size.
  ///
  /// The [offset] argument is relative to the caller's bounding box. It can be used to
  /// convert gesture coordinates from global to slider-relative coordinates.
  ///
  /// {@macro flutter.material.slider.shape.sliderTheme}
  ///
  /// {@macro flutter.material.slider.shape.isEnabled}
  ///
  /// {@macro flutter.material.slider.shape.isDiscrete}
  Rect getPreferredRect({
    RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData sliderTheme,
    bool isEnabled,
    bool isDiscrete,
  });

  /// Paints the track shape based on the state passed to it.
  ///
  /// {@macro flutter.material.slider.shape.context}
  ///
  /// [offset] is the offset of the origin of the [parentBox] to the origin of
  /// its [context] canvas. This shape must be painted relative to this
  /// offset. See [PaintingContextCallback].
  ///
  /// {@macro flutter.material.slider.shape.parentBox}
  ///
  /// {@macro flutter.material.slider.shape.sliderTheme}
  ///
  /// {@macro flutter.material.slider.shape.enableAnimation}
  ///
  /// The [thumbCenter] argument is the offset of the center of the thumb relative to the
  /// origin of the [PaintingContext.canvas]. It can be used as the point that
  /// divides the track into 2 segments.
  ///
  /// {@macro flutter.material.slider.shape.isEnabled}
  ///
  /// {@macro flutter.material.slider.shape.isDiscrete}
  ///
  /// The [textDirection] argument can be used to determine how the track segments are
  /// painted depending on whether they are active or not.
  /// {@macro flutter.material.slider.trackSegment}
  void paint(
    PaintingContext context,
    Offset offset, {
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    Animation<double> enableAnimation,
    Offset thumbCenter,
    bool isEnabled,
    bool isDiscrete,
    TextDirection textDirection,
  });
}

/// Base class for [RangeSlider] thumb shapes.
///
/// See also:
///
/// {@macro flutter.material.slider.seeAlso.roundRangeSliderThumbShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderTickMarkShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderTrackShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderValueIndicatorShape}
/// {@macro flutter.material.slider.seeAlso.sliderComponentShape}
abstract class RangeSliderThumbShape {
  /// This abstract const constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const RangeSliderThumbShape();

  /// Returns the preferred size of the shape, based on the given conditions.
  ///
  /// {@macro flutter.material.rangeSlider.shape.isDiscrete}
  ///
  /// {@macro flutter.material.rangeSlider.shape.isEnabled}
  Size getPreferredSize(bool isEnabled, bool isDiscrete);

  /// Paints the thumb shape based on the state passed to it.
  ///
  /// {@macro flutter.material.rangeSlider.shape.context}
  ///
  /// {@macro flutter.material.slider.shape.center}
  ///
  /// {@macro flutter.material.rangeSlider.shape.activationAnimation}
  ///
  /// {@macro flutter.material.rangeSlider.shape.enableAnimation}
  ///
  /// {@macro flutter.material.rangeSlider.shape.isDiscrete}
  ///
  /// {@macro flutter.material.rangeSlider.shape.isEnabled}
  ///
  /// If [isOnTop] is true this thumb is painted on top of the other slider
  /// thumb because this thumb is the one that was most recently selected.
  ///
  /// {@macro flutter.material.rangeSlider.shape.sliderTheme}
  ///
  /// [textDirection] can be used to determine how the orientation of either
  /// slider thumb should be changed, such as drawing different shapes for the
  /// left and right thumb.
  ///
  /// {@macro flutter.material.rangeSlider.shape.thumb}
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    bool isEnabled,
    bool isOnTop,
    TextDirection textDirection,
    SliderThemeData sliderTheme,
    Thumb thumb,
  });
}

/// Base class for [RangeSlider] value indicator shapes.
///
/// See also:
///
/// {@macro flutter.material.slider.seeAlso.paddleRangeSliderValueIndicatorShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderTickMarkShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderThumbShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderTrackShape}
/// {@macro flutter.material.slider.seeAlso.sliderComponentShape}
abstract class RangeSliderValueIndicatorShape {
  /// This abstract const constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const RangeSliderValueIndicatorShape();

  /// Returns the preferred size of the shape, based on the given conditions.
  ///
  /// {@macro flutter.material.rangeSlider.shape.isEnabled}
  ///
  /// {@macro flutter.material.rangeSlider.shape.isDiscrete}
  ///
  /// [labelPainter] helps determine the width of the shape. It is variable
  /// width because it is derived from a formatted string.
  Size getPreferredSize(bool isEnabled, bool isDiscrete, { TextPainter labelPainter });

  /// Paints the value indicator shape based on the state passed to it.
  ///
  /// {@macro flutter.material.rangeSlider.shape.context}
  ///
  /// {@macro flutter.material.slider.shape.center}
  ///
  /// {@macro flutter.material.rangeSlider.shape.activationAnimation}
  ///
  /// {@macro flutter.material.rangeSlider.shape.enableAnimation}
  ///
  /// {@macro flutter.material.rangeSlider.shape.isDiscrete}
  ///
  /// The [isOnTop] argument is the top-most value indicator between the two value
  /// indicators, which is always the indicator for the most recently selected thumb. In
  /// the default case, this is used to paint a stroke around the top indicator
  /// for better visibility between the two indicators.
  ///
  /// {@macro flutter.material.rangeSlider.shape.sliderTheme}
  ///
  /// [textDirection] can be used to determine how any extra text or graphics,
  /// besides the text painted by the [labelPainter] should be positioned. The
  /// [labelPainter] already has the [textDirection] set.
  ///
  /// [value] is the current parametric value (from 0.0 to 1.0) of the slider.
  ///
  /// {@macro flutter.material.rangeSlider.shape.thumb}
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    bool isOnTop,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
    Thumb thumb,
  });
}

/// Base class for [RangeSlider] tick mark shapes.
///
/// This is a simplified version of [SliderComponentShape] with a
/// [SliderThemeData] passed when getting the preferred size.
///
/// See also:
///
/// {@macro flutter.material.slider.seeAlso.roundRangeSliderTickMarkShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderThumbShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderTrackShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderValueIndicatorShape}
/// {@macro flutter.material.slider.seeAlso.sliderComponentShape}
abstract class RangeSliderTickMarkShape {
  /// This abstract const constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const RangeSliderTickMarkShape();

  /// Returns the preferred size of the shape.
  ///
  /// It is used to help position the tick marks within the slider.
  ///
  /// {@macro flutter.material.rangeSlider.shape.sliderTheme}
  ///
  /// {@macro flutter.material.rangeSlider.shape.isEnabled}
  Size getPreferredSize({
    SliderThemeData sliderTheme,
    bool isEnabled,
  });

  /// Paints the slider track.
  ///
  /// {@macro flutter.material.rangeSlider.shape.context}
  ///
  /// {@macro flutter.material.slider.shape.center}
  ///
  /// {@macro flutter.material.rangeSlider.shape.parentBox}
  ///
  /// {@macro flutter.material.rangeSlider.shape.sliderTheme}
  ///
  /// {@macro flutter.material.rangeSlider.shape.enableAnimation}
  ///
  /// {@macro flutter.material.rangeSlider.shape.isEnabled}
  ///
  /// The [textDirection] argument can be used to determine how the tick marks are painted
  /// depending on whether they are on an active track segment or not.
  /// {@macro flutter.material.rangeSlider.trackSegment}
  void paint(
    PaintingContext context,
    Offset center, {
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    Animation<double> enableAnimation,
    Offset startThumbCenter,
    Offset endThumbCenter,
    bool isEnabled,
    TextDirection textDirection,
  });
}

/// Base class for [RangeSlider] track shapes.
///
/// The slider's thumbs move along the track. A discrete slider's tick marks
/// are drawn after the track, but before the thumb, and are aligned with the
/// track.
///
/// The [getPreferredRect] helps position the slider thumbs and tick marks
/// relative to the track.
///
/// See also:
///
/// {@macro flutter.material.slider.seeAlso.roundedRectRangeSliderTrackShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderTickMarkShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderThumbShape}
/// {@macro flutter.material.slider.seeAlso.rangeSliderValueIndicatorShape}
/// {@macro flutter.material.slider.seeAlso.sliderComponentShape}
abstract class RangeSliderTrackShape {
  /// This abstract const constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const RangeSliderTrackShape();

  /// Returns the preferred bounds of the shape.
  ///
  /// It is used to provide horizontal boundaries for the position of the
  /// thumbs, and to help position the slider thumbs and tick marks relative to
  /// the track.
  ///
  /// The [parentBox] argument can be used to help determine the preferredRect relative to
  /// attributes of the render box of the slider itself, such as size.
  ///
  /// The [offset] argument is relative to the caller's bounding box. It can be used to
  /// convert gesture coordinates from global to slider-relative coordinates.
  ///
  /// {@macro flutter.material.rangeSlider.shape.sliderTheme}
  ///
  /// {@macro flutter.material.rangeSlider.shape.isEnabled}
  ///
  /// {@macro flutter.material.rangeSlider.shape.isDiscrete}
  Rect getPreferredRect({
    RenderBox parentBox,
    Offset offset = Offset.zero,
    SliderThemeData sliderTheme,
    bool isEnabled,
    bool isDiscrete,
  });

  /// Paints the track shape based on the state passed to it.
  ///
  /// {@macro flutter.material.slider.shape.context}
  ///
  /// [offset] is the offset of the origin of the [parentBox] to the origin of
  /// its [context] canvas. This shape must be painted relative to this
  /// offset. See [PaintingContextCallback].
  ///
  /// {@macro flutter.material.rangeSlider.shape.parentBox}
  ///
  /// {@macro flutter.material.rangeSlider.shape.sliderTheme}
  ///
  /// {@macro flutter.material.rangeSlider.shape.enableAnimation}
  ///
  /// [startThumbCenter] is the offset of the center of the start thumb relative
  /// to the origin of the [PaintingContext.canvas]. It can be used as one point
  /// that divides the track between inactive and active.
  ///
  /// [endThumbCenter] is the offset of the center of the end thumb relative
  /// to the origin of the [PaintingContext.canvas]. It can be used as one point
  /// that divides the track between inactive and active.
  ///
  /// {@macro flutter.material.rangeSlider.shape.isEnabled}
  ///
  /// {@macro flutter.material.rangeSlider.shape.isDiscrete}
  ///
  /// [textDirection] can be used to determine how the track segments are
  /// painted depending on whether they are on an active track segment or not.
  /// {@macro flutter.material.rangeSlider.trackSegment}
  void paint(
    PaintingContext context,
    Offset offset, {
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    Animation<double> enableAnimation,
    Offset startThumbCenter,
    Offset endThumbCenter,
    bool isEnabled,
    bool isDiscrete,
    TextDirection textDirection,
  });
}

/// Base track shape that provides an implementation of [getPreferredRect] for
/// default sizing.
///
/// See also:
///
///  * [RectangularSliderTrackShape], which is a track shape with sharp
///    rectangular edges
///  * [RoundedRectSliderTrackShape], which is a track shape with round
///    stadium-like edges.
///
/// The height is set from [SliderThemeData.trackHeight] and the width of the
/// parent box less the larger of the widths of [SliderThemeData.thumbShape] and
/// [SliderThemeData.overlayShape].
abstract class BaseSliderTrackShape {
  /// Returns a rect that represents the track bounds that fits within the
  /// [Slider].
  ///
  /// The width is the width of the [Slider] or [RangeSlider], but padded by
  /// the max  of the overlay and thumb radius. The height is defined by the
  /// [SliderThemeData.trackHeight].
  ///
  /// The [Rect] is centered both horizontally and vertically within the slider
  /// bounds.
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    assert(isEnabled != null);
    assert(isDiscrete != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    final double thumbWidth = sliderTheme.thumbShape.getPreferredSize(isEnabled, isDiscrete).width;
    final double overlayWidth = sliderTheme.overlayShape.getPreferredSize(isEnabled, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= overlayWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + overlayWidth / 2;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - math.max(thumbWidth, overlayWidth);
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

/// A [Slider] track that's a simple rectangle.
///
/// It paints a solid colored rectangle, vertically centered in the
/// [parentBox]. The track rectangle extends to the bounds of the [parentBox],
/// but is padded by the [RoundSliderOverlayShape] radius. The height is defined
/// by the [SliderThemeData.trackHeight]. The color is determined by the
/// [Slider]'s enabled state and the track segments's active state which are
/// defined by:
///   [SliderThemeData.activeTrackColor],
///   [SliderThemeData.inactiveTrackColor],
///   [SliderThemeData.disabledActiveTrackColor],
///   [SliderThemeData.disabledInactiveTrackColor].
///
/// {@macro flutter.material.slider.trackSegment}
///
/// See also:
///
///  * [Slider], for the component that is meant to display this shape.
///  * [SliderThemeData], where an instance of this class is set to inform the
///    slider of the visual details of the its track.
/// {@macro flutter.material.slider.seeAlso.sliderTrackShape}
///  * [RoundedRectSliderTrackShape], for a similar track with rounded edges.
class RectangularSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  /// Creates a slider track that draws 2 rectangles.
  const RectangularSliderTrackShape({ this.disabledThumbGapWidth = 2.0 });

  /// Horizontal spacing, or gap, between the disabled thumb and the track.
  ///
  /// This is only used when the slider is disabled. There is no gap around
  /// the thumb and any part of the track when the slider is enabled. The
  /// Material spec defaults this gap width 2, which is half of the disabled
  /// thumb radius.
  final double disabledThumbGapWidth;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required TextDirection textDirection,
    @required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    assert(isEnabled != null);
    assert(isDiscrete != null);
    // If the slider track height is less than or equal to 0, then it makes no
    // difference whether the track is painted or not, therefore the painting
    // can be a no-op.
    if (sliderTheme.trackHeight <= 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor , end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(begin: sliderTheme.disabledInactiveTrackColor , end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation);
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Size thumbSize = sliderTheme.thumbShape.getPreferredSize(isEnabled, isDiscrete);
    final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left + trackRect.height / 2, trackRect.top, thumbCenter.dx - thumbSize.width / 2, trackRect.bottom);
    if (!leftTrackSegment.isEmpty)
      context.canvas.drawRect(leftTrackSegment, leftTrackPaint);
    final Rect rightTrackSegment = Rect.fromLTRB(thumbCenter.dx + thumbSize.width / 2, trackRect.top, trackRect.right, trackRect.bottom);
    if (!rightTrackSegment.isEmpty)
      context.canvas.drawRect(rightTrackSegment, rightTrackPaint);
  }
}

/// The default shape of a [Slider]'s track.
///
/// It paints a solid colored rectangle with rounded edges, vertically centered
/// in the [parentBox]. The track rectangle extends to the bounds of the
/// [parentBox], but is padded by the larger of [RoundSliderOverlayShape]'s
/// radius and [RoundSliderThumbShape]'s radius. The height is defined by the
/// [SliderThemeData.trackHeight]. The color is determined by the [Slider]'s
/// enabled state and the track segment's active state which are defined by:
///   [SliderThemeData.activeTrackColor],
///   [SliderThemeData.inactiveTrackColor],
///   [SliderThemeData.disabledActiveTrackColor],
///   [SliderThemeData.disabledInactiveTrackColor].
///
/// {@macro flutter.material.slider.trackSegment}
///
/// See also:
///
///  * [Slider], for the component that is meant to display this shape.
///  * [SliderThemeData], where an instance of this class is set to inform the
///    slider of the visual details of the its track.
/// {@macro flutter.material.slider.seeAlso.sliderTrackShape}
///  * [RectangularSliderTrackShape], for a similar track with sharp edges.
class RoundedRectSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  /// Create a slider track that draws two rectangles with rounded outer edges.
  const RoundedRectSliderTrackShape();

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
      @required RenderBox parentBox,
      @required SliderThemeData sliderTheme,
      @required Animation<double> enableAnimation,
      @required TextDirection textDirection,
      @required Offset thumbCenter,
      bool isDiscrete = false,
      bool isEnabled = false,
    }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    // If the slider track height is less than or equal to 0, then it makes no
    // difference whether the track is painted or not, therefore the painting
    // can be a no-op.
    if (sliderTheme.trackHeight <= 0) {
      return;
    }

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation);
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    switch (textDirection) {
      case TextDirection.ltr:
        leftTrackPaint = activePaint;
        rightTrackPaint = inactivePaint;
        break;
      case TextDirection.rtl:
        leftTrackPaint = inactivePaint;
        rightTrackPaint = activePaint;
        break;
    }

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // The arc rects create a semi-circle with radius equal to track height.
    final Rect leftTrackArcRect = Rect.fromLTWH(trackRect.left, trackRect.top, trackRect.height, trackRect.height);
    if (!leftTrackArcRect.isEmpty)
      context.canvas.drawArc(leftTrackArcRect, math.pi / 2, math.pi, false, leftTrackPaint);
    final Rect rightTrackArcRect = Rect.fromLTWH(trackRect.right - trackRect.height / 2, trackRect.top, trackRect.height, trackRect.height);
    if (!rightTrackArcRect.isEmpty)
      context.canvas.drawArc(rightTrackArcRect, -math.pi / 2, math.pi, false, rightTrackPaint);

    final Size thumbSize = sliderTheme.thumbShape.getPreferredSize(isEnabled, isDiscrete);
    final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left + trackRect.height / 2, trackRect.top, thumbCenter.dx - thumbSize.width / 2, trackRect.bottom);
    if (!leftTrackSegment.isEmpty)
      context.canvas.drawRect(leftTrackSegment, leftTrackPaint);
    final Rect rightTrackSegment = Rect.fromLTRB(thumbCenter.dx + thumbSize.width / 2, trackRect.top, trackRect.right, trackRect.bottom);
    if (!rightTrackSegment.isEmpty)
      context.canvas.drawRect(rightTrackSegment, rightTrackPaint);
  }
}

/// A [RangeSlider] track that's a simple rectangle.
///
/// It paints a solid colored rectangle, vertically centered in the
/// [parentBox]. The track rectangle extends to the bounds of the [parentBox],
/// but is padded by the [RoundSliderOverlayShape] radius. The height is
/// defined by the [SliderThemeData.trackHeight]. The color is determined by the
/// [Slider]'s enabled state and the track segments's active state which are
/// defined by:
///   [SliderThemeData.activeTrackColor],
///   [SliderThemeData.inactiveTrackColor],
///   [SliderThemeData.disabledActiveTrackColor],
///   [SliderThemeData.disabledInactiveTrackColor].
///
/// {@macro flutter.material.rangeSlider.trackSegment}
///
/// See also:
///
///  * [RangeSlider], for the component that is meant to display this shape.
///  * [SliderThemeData], where an instance of this class is set to inform the
///    slider of the visual details of the its track.
/// {@macro flutter.material.slider.seeAlso.rangeSliderTrackShape}
///  * [RoundedRectRangeSliderTrackShape], for a similar track with rounded
///    edges.
class RectangularRangeSliderTrackShape extends RangeSliderTrackShape {
  /// Create a slider track with rectangular outer edges.
  ///
  /// The middle track segment is the selected range and is active, and the two
  /// outer track segments are inactive.
  const RectangularRangeSliderTrackShape();

  @override
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    assert(parentBox != null);
    assert(offset != null);
    assert(sliderTheme != null);
    assert(sliderTheme.overlayShape != null);
    assert(isEnabled != null);
    assert(isDiscrete != null);
    final double overlayWidth = sliderTheme.overlayShape.getPreferredSize(isEnabled, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= overlayWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + overlayWidth / 2;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - overlayWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required Offset startThumbCenter,
    @required Offset endThumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    @required TextDirection textDirection,
  }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.rangeThumbShape != null);
    assert(enableAnimation != null);
    assert(startThumbCenter != null);
    assert(endThumbCenter != null);
    assert(isEnabled != null);
    assert(isDiscrete != null);
    assert(textDirection != null);
    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor , end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(begin: sliderTheme.disabledInactiveTrackColor , end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation);

    Offset leftThumbOffset;
    Offset rightThumbOffset;
    switch (textDirection) {
      case TextDirection.ltr:
        leftThumbOffset = startThumbCenter;
        rightThumbOffset = endThumbCenter;
        break;
      case TextDirection.rtl:
        leftThumbOffset = endThumbCenter;
        rightThumbOffset = startThumbCenter;
        break;
    }
    final Size thumbSize = sliderTheme.rangeThumbShape.getPreferredSize(isEnabled, isDiscrete);
    final double thumbRadius = thumbSize.width / 2;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left, trackRect.top, leftThumbOffset.dx - thumbRadius, trackRect.bottom);
    if (!leftTrackSegment.isEmpty)
      context.canvas.drawRect(leftTrackSegment, inactivePaint);
    final Rect middleTrackSegment = Rect.fromLTRB(leftThumbOffset.dx + thumbRadius, trackRect.top, rightThumbOffset.dx - thumbRadius, trackRect.bottom);
    if (!middleTrackSegment.isEmpty)
      context.canvas.drawRect(middleTrackSegment, activePaint);
    final Rect rightTrackSegment = Rect.fromLTRB(rightThumbOffset.dx + thumbRadius, trackRect.top, trackRect.right, trackRect.bottom);
    if (!rightTrackSegment.isEmpty)
      context.canvas.drawRect(rightTrackSegment, inactivePaint);
  }
}

/// The default shape of a [RangeSlider]'s track.
///
/// It paints a solid colored rectangle with rounded edges, vertically centered
/// in the [parentBox]. The track rectangle extends to the bounds of the
/// [parentBox], but is padded by the larger of [RoundSliderOverlayShape]'s
/// radius and [RoundRangeSliderThumbShape]'s radius. The height is defined by
/// the [SliderThemeData.trackHeight]. The color is determined by the
/// [RangeSlider]'s enabled state and the track segment's active state which are
/// defined by:
///   [SliderThemeData.activeTrackColor],
///   [SliderThemeData.inactiveTrackColor],
///   [SliderThemeData.disabledActiveTrackColor],
///   [SliderThemeData.disabledInactiveTrackColor].
///
/// {@macro flutter.material.rangeSlider.trackSegment}
///
/// See also:
///
///  * [RangeSlider], for the component that is meant to display this shape.
///  * [SliderThemeData], where an instance of this class is set to inform the
///    slider of the visual details of the its track.
/// {@macro flutter.material.slider.seeAlso.rangeSliderTrackShape}
///  * [RectangularRangeSliderTrackShape], for a similar track with sharp edges.
class RoundedRectRangeSliderTrackShape extends RangeSliderTrackShape {
  /// Create a slider track with rounded outer edges.
  ///
  /// The middle track segment is the selected range and is active, and the two
  /// outer track segments are inactive.
  const RoundedRectRangeSliderTrackShape();

  @override
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    assert(parentBox != null);
    assert(offset != null);
    assert(sliderTheme != null);
    assert(sliderTheme.overlayShape != null);
    assert(sliderTheme.trackHeight != null);
    assert(isEnabled != null);
    assert(isDiscrete != null);
    final double overlayWidth = sliderTheme.overlayShape.getPreferredSize(isEnabled, isDiscrete).width;
    final double trackHeight = sliderTheme.trackHeight;
    assert(overlayWidth >= 0);
    assert(trackHeight >= 0);
    assert(parentBox.size.width >= overlayWidth);
    assert(parentBox.size.height >= trackHeight);

    final double trackLeft = offset.dx + overlayWidth / 2;
    final double trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - overlayWidth;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required Offset startThumbCenter,
    @required Offset endThumbCenter,
    bool isEnabled = false,
    bool isDiscrete = false,
    @required TextDirection textDirection,
  }) {
    assert(context != null);
    assert(offset != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.rangeThumbShape != null);
    assert(enableAnimation != null);
    assert(startThumbCenter != null);
    assert(endThumbCenter != null);
    assert(isEnabled != null);
    assert(isDiscrete != null);
    assert(textDirection != null);
    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor , end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(begin: sliderTheme.disabledInactiveTrackColor , end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation);

    Offset leftThumbOffset;
    Offset rightThumbOffset;
    switch (textDirection) {
      case TextDirection.ltr:
        leftThumbOffset = startThumbCenter;
        rightThumbOffset = endThumbCenter;
        break;
      case TextDirection.rtl:
        leftThumbOffset = endThumbCenter;
        rightThumbOffset = startThumbCenter;
        break;
    }
    final Size thumbSize = sliderTheme.rangeThumbShape.getPreferredSize(isEnabled, isDiscrete);
    final double thumbRadius = thumbSize.width / 2;
    assert(thumbRadius > 0);

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final double trackRadius = trackRect.height / 2;

    final Rect leftTrackArcRect = Rect.fromLTWH(trackRect.left, trackRect.top, trackRect.height, trackRect.height);
    if (!leftTrackArcRect.isEmpty)
      context.canvas.drawArc(leftTrackArcRect, math.pi / 2, math.pi, false, inactivePaint);

    final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left + trackRadius, trackRect.top, leftThumbOffset.dx - thumbRadius, trackRect.bottom);
    if (!leftTrackSegment.isEmpty)
      context.canvas.drawRect(leftTrackSegment, inactivePaint);
    final Rect middleTrackSegment = Rect.fromLTRB(leftThumbOffset.dx + thumbRadius, trackRect.top, rightThumbOffset.dx - thumbRadius, trackRect.bottom);
    if (!middleTrackSegment.isEmpty)
      context.canvas.drawRect(middleTrackSegment, activePaint);
    final Rect rightTrackSegment = Rect.fromLTRB(rightThumbOffset.dx + thumbRadius, trackRect.top, trackRect.right - trackRadius, trackRect.bottom);
    if (!rightTrackSegment.isEmpty)
      context.canvas.drawRect(rightTrackSegment, inactivePaint);

    final Rect rightTrackArcRect = Rect.fromLTWH(trackRect.right - trackRect.height, trackRect.top, trackRect.height, trackRect.height);
    if (!rightTrackArcRect.isEmpty)
      context.canvas.drawArc(rightTrackArcRect, -math.pi / 2, math.pi, false, inactivePaint);
  }
}

/// The default shape of each [Slider] tick mark.
///
/// Tick marks are only displayed if the slider is discrete, which can be done
/// by setting the [Slider.divisions] to an integer value.
///
/// It paints a solid circle, centered in the on the track.
/// The color is determined by the [Slider]'s enabled state and track's active
/// states. These colors are defined in:
///   [SliderThemeData.activeTrackColor],
///   [SliderThemeData.inactiveTrackColor],
///   [SliderThemeData.disabledActiveTrackColor],
///   [SliderThemeData.disabledInactiveTrackColor].
///
/// See also:
///
///  * [Slider], which includes tick marks defined by this shape.
///  * [SliderTheme], which can be used to configure the tick mark shape of all
///    sliders in a widget subtree.
class RoundSliderTickMarkShape extends SliderTickMarkShape {
  /// Create a slider tick mark that draws a circle.
  const RoundSliderTickMarkShape({ this.tickMarkRadius });

  /// The preferred radius of the round tick mark.
  ///
  /// If it is not provided, then half of the track height is used.
  final double tickMarkRadius;

  @override
  Size getPreferredSize({
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
  }) {
    assert(sliderTheme != null);
    assert(sliderTheme.trackHeight != null);
    assert(isEnabled != null);
    // The tick marks are tiny circles. If no radius is provided, then they are
    // defaulted to be the same height as the track.
    return Size.fromRadius(tickMarkRadius ?? sliderTheme.trackHeight / 2);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required TextDirection textDirection,
    @required Offset thumbCenter,
    bool isEnabled = false,
  }) {
    assert(context != null);
    assert(center != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTickMarkColor != null);
    assert(sliderTheme.disabledInactiveTickMarkColor != null);
    assert(sliderTheme.activeTickMarkColor != null);
    assert(sliderTheme.inactiveTickMarkColor != null);
    assert(enableAnimation != null);
    assert(textDirection != null);
    assert(thumbCenter != null);
    assert(isEnabled != null);
    // The paint color of the tick mark depends on its position relative
    // to the thumb and the text direction.
    Color begin;
    Color end;
    switch (textDirection) {
      case TextDirection.ltr:
        final bool isTickMarkRightOfThumb = center.dx > thumbCenter.dx;
        begin = isTickMarkRightOfThumb ? sliderTheme.disabledInactiveTickMarkColor : sliderTheme.disabledActiveTickMarkColor;
        end = isTickMarkRightOfThumb ? sliderTheme.inactiveTickMarkColor : sliderTheme.activeTickMarkColor;
        break;
      case TextDirection.rtl:
        final bool isTickMarkLeftOfThumb = center.dx < thumbCenter.dx;
        begin = isTickMarkLeftOfThumb ? sliderTheme.disabledInactiveTickMarkColor : sliderTheme.disabledActiveTickMarkColor;
        end = isTickMarkLeftOfThumb ? sliderTheme.inactiveTickMarkColor : sliderTheme.activeTickMarkColor;
        break;
    }
    final Paint paint = Paint()..color = ColorTween(begin: begin, end: end).evaluate(enableAnimation);

    // The tick marks are tiny circles that are the same height as the track.
    final double tickMarkRadius = getPreferredSize(
      isEnabled: isEnabled,
      sliderTheme: sliderTheme,
    ).width / 2;
    if (tickMarkRadius > 0) {
      context.canvas.drawCircle(center, tickMarkRadius, paint);
    }
  }
}

/// The default shape of each [RangeSlider] tick mark.
///
/// Tick marks are only displayed if the slider is discrete, which can be done
/// by setting the [RangeSlider.divisions] to an integer value.
///
/// It paints a solid circle, centered on the track.
/// The color is determined by the [Slider]'s enabled state and track's active
/// states. These colors are defined in:
///   [SliderThemeData.activeTrackColor],
///   [SliderThemeData.inactiveTrackColor],
///   [SliderThemeData.disabledActiveTrackColor],
///   [SliderThemeData.disabledInactiveTrackColor].
///
/// See also:
///
///  * [RangeSlider], which includes tick marks defined by this shape.
///  * [SliderTheme], which can be used to configure the tick mark shape of all
///    sliders in a widget subtree.
class RoundRangeSliderTickMarkShape extends RangeSliderTickMarkShape {
  /// Create a range slider tick mark that draws a circle.
  const RoundRangeSliderTickMarkShape({ this.tickMarkRadius });

  /// The preferred radius of the round tick mark.
  ///
  /// If it is not provided, then half of the track height is used.
  final double tickMarkRadius;

  @override
  Size getPreferredSize({
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
  }) {
    assert(sliderTheme != null);
    assert(sliderTheme.trackHeight != null);
    assert(isEnabled != null);
    return Size.fromRadius(tickMarkRadius ?? sliderTheme.trackHeight / 2);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required Animation<double> enableAnimation,
    @required Offset startThumbCenter,
    @required Offset endThumbCenter,
    bool isEnabled = false,
    @required TextDirection textDirection,
  }) {
    assert(context != null);
    assert(center != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledActiveTickMarkColor != null);
    assert(sliderTheme.disabledInactiveTickMarkColor != null);
    assert(sliderTheme.activeTickMarkColor != null);
    assert(sliderTheme.inactiveTickMarkColor != null);
    assert(enableAnimation != null);
    assert(startThumbCenter != null);
    assert(endThumbCenter != null);
    assert(isEnabled != null);
    assert(textDirection != null);

    bool isBetweenThumbs;
    switch (textDirection) {
      case TextDirection.ltr:
        isBetweenThumbs = startThumbCenter.dx < center.dx && center.dx < endThumbCenter.dx;
        break;
      case TextDirection.rtl:
        isBetweenThumbs = endThumbCenter.dx < center.dx && center.dx < startThumbCenter.dx;
        break;
    }
    final Color begin = isBetweenThumbs ? sliderTheme.disabledActiveTickMarkColor : sliderTheme.disabledInactiveTickMarkColor;
    final Color end = isBetweenThumbs ? sliderTheme.activeTickMarkColor : sliderTheme.inactiveTickMarkColor;
    final Paint paint = Paint()..color = ColorTween(begin: begin, end: end).evaluate(enableAnimation);

    // The tick marks are tiny circles that are the same height as the track.
    final double tickMarkRadius = getPreferredSize(
      isEnabled: isEnabled,
      sliderTheme: sliderTheme,
    ).width / 2;
    if (tickMarkRadius > 0) {
      context.canvas.drawCircle(center, tickMarkRadius, paint);
    }
  }
}

/// A special version of [SliderTickMarkShape] that has a zero size and paints
/// nothing.
///
/// This class is used to create a special instance of a [SliderTickMarkShape]
/// that will not paint any tick mark shape. A static reference is stored in
/// [SliderTickMarkShape.noTickMark]. When this value is specified for
/// [SliderThemeData.tickMarkShape], the tick mark painting is skipped.
class _EmptySliderTickMarkShape extends SliderTickMarkShape {
  @override
  Size getPreferredSize({
    SliderThemeData sliderTheme,
    bool isEnabled,
  }) {
    return Size.zero;
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    Animation<double> enableAnimation,
    Offset thumbCenter,
    bool isEnabled,
    TextDirection textDirection,
  }) {
    // no-op.
  }
}

/// A special version of [SliderComponentShape] that has a zero size and paints
/// nothing.
///
/// This class is used to create a special instance of a [SliderComponentShape]
/// that will not paint any component shape. A static reference is stored in
/// [SliderTickMarkShape.noThumb] and [SliderTickMarkShape.noOverlay]. When this value
/// is specified for [SliderThemeData.thumbShape], the thumb painting is
/// skipped.  When this value is specified for [SliderThemeData.overlaySHape],
/// the overlay painting is skipped.
class _EmptySliderComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    // no-op.
  }
}

/// The default shape of a [Slider]'s thumb.
///
/// See also:
///
///  * [Slider], which includes a thumb defined by this shape.
///  * [SliderTheme], which can be used to configure the thumb shape of all
///    sliders in a widget subtree.
class RoundSliderThumbShape extends SliderComponentShape {
  /// Create a slider thumb that draws a circle.
  const RoundSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
  });

  /// The preferred radius of the round thumb shape when the slider is enabled.
  ///
  /// If it is not provided, then the material default of 10 is used.
  final double enabledThumbRadius;

  /// The preferred radius of the round thumb shape when the slider is disabled.
  ///
  /// If no disabledRadius is provided, then it is equal to the
  /// [enabledThumbRadius]
  final double disabledThumbRadius;
  double get _disabledThumbRadius =>  disabledThumbRadius ?? enabledThumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    @required Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    assert(context != null);
    assert(center != null);
    assert(enableAnimation != null);
    assert(sliderTheme != null);
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    canvas.drawCircle(
      center,
      radiusTween.evaluate(enableAnimation),
      Paint()..color = colorTween.evaluate(enableAnimation),
    );
  }
}

/// The default shape of a [RangeSlider]'s thumbs.
///
/// See also:
///
///  * [RangeSlider], which includes thumbs defined by this shape.
///  * [SliderTheme], which can be used to configure the thumb shapes of all
///    range sliders in a widget subtree.
class RoundRangeSliderThumbShape extends RangeSliderThumbShape {
  /// Create a slider thumb that draws a circle.
  const RoundRangeSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
  }) : assert(enabledThumbRadius != null);

  /// The preferred radius of the round thumb shape when the slider is enabled.
  ///
  /// If it is not provided, then the material default of 10 is used.
  final double enabledThumbRadius;

  /// The preferred radius of the round thumb shape when the slider is disabled.
  ///
  /// If no disabledRadius is provided, then it is equal to the
  /// [enabledThumbRadius].
  final double disabledThumbRadius;
  double get _disabledThumbRadius =>  disabledThumbRadius ?? enabledThumbRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    @required Animation<double> activationAnimation,
    @required Animation<double> enableAnimation,
    bool isDiscrete = false,
    bool isEnabled = false,
    bool isOnTop,
    @required SliderThemeData sliderTheme,
    TextDirection textDirection,
    Thumb thumb,
  }) {
    assert(context != null);
    assert(center != null);
    assert(activationAnimation != null);
    assert(sliderTheme != null);
    assert(sliderTheme.showValueIndicator != null);
    assert(sliderTheme.overlappingShapeStrokeColor != null);
    assert(enableAnimation != null);
    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );
    final double radius = radiusTween.evaluate(enableAnimation);

    // Add a stroke of 1dp around the circle if this thumb would overlap
    // the other thumb.
    if (isOnTop == true) {
      bool showValueIndicator;
      switch (sliderTheme.showValueIndicator) {
        case ShowValueIndicator.onlyForDiscrete:
          showValueIndicator = isDiscrete;
          break;
        case ShowValueIndicator.onlyForContinuous:
          showValueIndicator = !isDiscrete;
          break;
        case ShowValueIndicator.always:
          showValueIndicator = true;
          break;
        case ShowValueIndicator.never:
          showValueIndicator = false;
          break;
      }

      final Paint strokePaint = Paint()
        ..color = sliderTheme.overlappingShapeStrokeColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      if (showValueIndicator && activationAnimation.value > 0) {
        // If there is a value indicator, then it is already stroked and a gap
        // needs to be left on the thumb where the value indicator intersects
        // the thumb.
        const double startAngle = -math.pi / 2 + 0.2;
        const double sweepAngle = math.pi * 2 - 0.4;
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, strokePaint);
      } else {
        canvas.drawCircle(center, radius, strokePaint);
      }
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = colorTween.evaluate(enableAnimation),
    );
  }
}

/// The default shape of a [Slider]'s thumb overlay.
///
/// The shape of the overlay is a circle with the same center as the thumb, but
/// with a larger radius. It animates to full size when the thumb is pressed,
/// and animates back down to size 0 when it is released. It is painted behind
/// the thumb, and is expected to extend beyond the bounds of the thumb so that
/// it is visible.
///
/// The overlay color is defined by [SliderThemeData.overlayColor].
///
/// See also:
///
///  * [Slider], which includes an overlay defined by this shape.
///  * [SliderTheme], which can be used to configure the overlay shape of all
///    sliders in a widget subtree.
class RoundSliderOverlayShape extends SliderComponentShape {
  /// Create a slider thumb overlay that draws a circle.
  const RoundSliderOverlayShape({ this.overlayRadius = 24.0 });

  /// The preferred radius of the round thumb shape when enabled.
  ///
  /// If it is not provided, then half of the track height is used.
  final double overlayRadius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(overlayRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    @required Animation<double> activationAnimation,
    @required Animation<double> enableAnimation,
    bool isDiscrete = false,
    @required TextPainter labelPainter,
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    @required TextDirection textDirection,
    @required double value,
  }) {
    assert(context != null);
    assert(center != null);
    assert(activationAnimation != null);
    assert(enableAnimation != null);
    assert(labelPainter != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    assert(textDirection != null);
    assert(value != null);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: 0.0,
      end: overlayRadius,
    );

    canvas.drawCircle(
      center,
      radiusTween.evaluate(activationAnimation),
      Paint()..color = sliderTheme.overlayColor,
    );
  }
}

/// The default shape of a [Slider]'s value indicator.
///
/// See also:
///
///  * [Slider], which includes a value indicator defined by this shape.
///  * [SliderTheme], which can be used to configure the slider value indicator
///    of all sliders in a widget subtree.
class PaddleSliderValueIndicatorShape extends SliderComponentShape {
  /// Create a slider value indicator in the shape of an upside-down pear.
  const PaddleSliderValueIndicatorShape();

  static const _PaddleSliderTrackShapePathPainter _pathPainter = _PaddleSliderTrackShapePathPainter();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete, { @required TextPainter labelPainter }) {
    assert(labelPainter != null);
    return _pathPainter.getPreferredSize(isEnabled, isDiscrete, labelPainter);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    @required Animation<double> activationAnimation,
    @required Animation<double> enableAnimation,
    bool isDiscrete,
    @required TextPainter labelPainter,
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
  }) {
    assert(context != null);
    assert(center != null);
    assert(activationAnimation != null);
    assert(enableAnimation != null);
    assert(labelPainter != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    final ColorTween enableColor = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.valueIndicatorColor,
    );
    _pathPainter.drawValueIndicator(
      parentBox,
      context.canvas,
      center,
      Paint()..color = enableColor.evaluate(enableAnimation),
      activationAnimation.value,
      labelPainter,
      null,
    );
  }
}

/// The default shape of a [RangeSlider]'s value indicators.
///
/// See also:
///
///  * [RangeSlider], which includes value indicators defined by this shape.
///  * [SliderTheme], which can be used to configure the range slider value
///    indicator of all sliders in a widget subtree.
class PaddleRangeSliderValueIndicatorShape extends RangeSliderValueIndicatorShape {
  /// Create a slider value indicator in the shape of an upside-down pear.
  const PaddleRangeSliderValueIndicatorShape();

  static const _PaddleSliderTrackShapePathPainter _pathPainter = _PaddleSliderTrackShapePathPainter();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete, { @required TextPainter labelPainter }) {
    assert(labelPainter != null);
    return _pathPainter.getPreferredSize(isEnabled, isDiscrete, labelPainter);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    @required Animation<double> activationAnimation,
    @required Animation<double> enableAnimation,
    bool isDiscrete,
    bool isOnTop = false,
    @required TextPainter labelPainter,
    @required RenderBox parentBox,
    @required SliderThemeData sliderTheme,
    TextDirection textDirection,
    Thumb thumb,
    double value,
  }) {
    assert(context != null);
    assert(center != null);
    assert(activationAnimation != null);
    assert(enableAnimation != null);
    assert(labelPainter != null);
    assert(parentBox != null);
    assert(sliderTheme != null);
    final ColorTween enableColor = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.valueIndicatorColor,
    );
    // Add a stroke of 1dp around the top paddle.
    _pathPainter.drawValueIndicator(
      parentBox,
      context.canvas,
      center,
      Paint()..color = enableColor.evaluate(enableAnimation),
      activationAnimation.value,
      labelPainter,
      isOnTop ? sliderTheme.overlappingShapeStrokeColor : null,
    );
  }
}

class _PaddleSliderTrackShapePathPainter {
  const _PaddleSliderTrackShapePathPainter();

  // These constants define the shape of the default value indicator.
  // The value indicator changes shape based on the size of
  // the label: The top lobe spreads horizontally, and the
  // top arc on the neck moves down to keep it merging smoothly
  // with the top lobe as it expands.

  // Radius of the top lobe of the value indicator.
  static const double _topLobeRadius = 16.0;
  // Designed size of the label text. This is the size that the value indicator
  // was designed to contain. We scale it from here to fit other sizes.
  static const double _labelTextDesignSize = 14.0;
  // Radius of the bottom lobe of the value indicator.
  static const double _bottomLobeRadius = 6.0;
  // The starting angle for the bottom lobe. Picked to get the desired
  // thickness for the neck.
  static const double _bottomLobeStartAngle = -1.1 * math.pi / 4.0;
  // The ending angle for the bottom lobe. Picked to get the desired
  // thickness for the neck.
  static const double _bottomLobeEndAngle = 1.1 * 5 * math.pi / 4.0;
  // The padding on either side of the label.
  static const double _labelPadding = 8.0;
  static const double _distanceBetweenTopBottomCenters = 40.0;
  static const Offset _topLobeCenter = Offset(0.0, -_distanceBetweenTopBottomCenters);
  static const double _topNeckRadius = 14.0;
  // The length of the hypotenuse of the triangle formed by the center
  // of the left top lobe arc and the center of the top left neck arc.
  // Used to calculate the position of the center of the arc.
  static const double _neckTriangleHypotenuse = _topLobeRadius + _topNeckRadius;
  // Some convenience values to help readability.
  static const double _twoSeventyDegrees = 3.0 * math.pi / 2.0;
  static const double _ninetyDegrees = math.pi / 2.0;
  static const double _thirtyDegrees = math.pi / 6.0;
  static const double _preferredHeight = _distanceBetweenTopBottomCenters + _topLobeRadius + _bottomLobeRadius;
  // Set to true if you want a rectangle to be drawn around the label bubble.
  // This helps with building tests that check that the label draws in the right
  // place (because it prints the rect in the failed test output). It should not
  // be checked in while set to "true".
  static const bool _debuggingLabelLocation = false;

  static Path _bottomLobePath; // Initialized by _generateBottomLobe
  static Offset _bottomLobeEnd; // Initialized by _generateBottomLobe

  Size getPreferredSize(
    bool isEnabled,
    bool isDiscrete,
    TextPainter labelPainter,
  ) {
    assert(labelPainter != null);
    final double labelHalfWidth = labelPainter.width / 2.0;
    return Size((labelHalfWidth + _topLobeRadius) * 2, _preferredHeight);
  }

  // Adds an arc to the path that has the attributes passed in. This is
  // a convenience to make adding arcs have less boilerplate.
  static void _addArc(Path path, Offset center, double radius, double startAngle, double endAngle) {
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
    path.arcTo(arcRect, startAngle, endAngle - startAngle, false);
  }

  // Generates the bottom lobe path, which is the same for all instances of
  // the value indicator, so we reuse it for each one.
  static void _generateBottomLobe() {
    const double bottomNeckRadius = 4.5;
    const double bottomNeckStartAngle = _bottomLobeEndAngle - math.pi;
    const double bottomNeckEndAngle = 0.0;

    final Path path = Path();
    final Offset bottomKnobStart = Offset(
      _bottomLobeRadius * math.cos(_bottomLobeStartAngle),
      _bottomLobeRadius * math.sin(_bottomLobeStartAngle) - 2,
    );
    final Offset bottomNeckRightCenter = bottomKnobStart +
        Offset(
          bottomNeckRadius * math.cos(bottomNeckStartAngle),
          -bottomNeckRadius * math.sin(bottomNeckStartAngle),
        );
    final Offset bottomNeckLeftCenter = Offset(
      -bottomNeckRightCenter.dx,
      bottomNeckRightCenter.dy,
    );
    final Offset bottomNeckStartRight = Offset(
      bottomNeckRightCenter.dx - bottomNeckRadius,
      bottomNeckRightCenter.dy,
    );
    path.moveTo(bottomNeckStartRight.dx, bottomNeckStartRight.dy);
    _addArc(
      path,
      bottomNeckRightCenter,
      bottomNeckRadius,
      math.pi - bottomNeckEndAngle,
      math.pi - bottomNeckStartAngle,
    );
    _addArc(
      path,
      Offset.zero,
      _bottomLobeRadius,
      _bottomLobeStartAngle,
      _bottomLobeEndAngle,
    );
    _addArc(
      path,
      bottomNeckLeftCenter,
      bottomNeckRadius,
      bottomNeckStartAngle,
      bottomNeckEndAngle,
    );

    _bottomLobeEnd = Offset(
      -bottomNeckStartRight.dx,
      bottomNeckStartRight.dy,
    );
    _bottomLobePath = path;
  }

  Offset _addBottomLobe(Path path) {
    if (_bottomLobePath == null || _bottomLobeEnd == null) {
      // Generate this lazily so as to not slow down app startup.
      _generateBottomLobe();
    }
    path.extendWithPath(_bottomLobePath, Offset.zero);
    return _bottomLobeEnd;
  }

  // Determines the "best" offset to keep the bubble on the screen. The calling
  // code will bound that with the available movement in the paddle shape.
  double _getIdealOffset(
    RenderBox parentBox,
    double halfWidthNeeded,
    double scale,
    Offset center,
  ) {
    const double edgeMargin = 4.0;
    final Rect topLobeRect = Rect.fromLTWH(
      -_topLobeRadius - halfWidthNeeded,
      -_topLobeRadius - _distanceBetweenTopBottomCenters,
      2.0 * (_topLobeRadius + halfWidthNeeded),
      2.0 * _topLobeRadius,
    );
    // We can just multiply by scale instead of a transform, since we're scaling
    // around (0, 0).
    final Offset topLeft = (topLobeRect.topLeft * scale) + center;
    final Offset bottomRight = (topLobeRect.bottomRight * scale) + center;
    double shift = 0.0;
    if (topLeft.dx < edgeMargin) {
      shift = edgeMargin - topLeft.dx;
    }
    if (bottomRight.dx > parentBox.size.width - edgeMargin) {
      shift = parentBox.size.width - bottomRight.dx - edgeMargin;
    }
    shift = scale == 0.0 ? 0.0 : shift / scale;
    return shift;
  }

  void drawValueIndicator(
    RenderBox parentBox,
    Canvas canvas,
    Offset center,
    Paint paint,
    double scale,
    TextPainter labelPainter,
    Color strokePaintColor,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // The entire value indicator should scale with the size of the label,
    // to keep it large enough to encompass the label text.
    final double textScaleFactor = labelPainter.height / _labelTextDesignSize;
    final double overallScale = scale * textScaleFactor;
    canvas.scale(overallScale, overallScale);
    final double inverseTextScale = textScaleFactor != 0 ? 1.0 / textScaleFactor : 0.0;
    final double labelHalfWidth = labelPainter.width / 2.0;

    // This is the needed extra width for the label.  It is only positive when
    // the label exceeds the minimum size contained by the round top lobe.
    final double halfWidthNeeded = math.max(
      0.0,
      inverseTextScale * labelHalfWidth - (_topLobeRadius - _labelPadding),
    );

    double shift = _getIdealOffset(parentBox, halfWidthNeeded, overallScale, center);
    double leftWidthNeeded;
    double rightWidthNeeded;
    if (shift < 0.0) {
      // shifting to the left
      shift = math.max(shift, -halfWidthNeeded);
    } else {
      // shifting to the right
      shift = math.min(shift, halfWidthNeeded);
    }
    rightWidthNeeded = halfWidthNeeded + shift;
    leftWidthNeeded = halfWidthNeeded - shift;

    final Path path = Path();
    final Offset bottomLobeEnd = _addBottomLobe(path);

    // The base of the triangle between the top lobe center and the centers of
    // the two top neck arcs.
    final double neckTriangleBase = _topNeckRadius - bottomLobeEnd.dx;
    // The parameter that describes how far along the transition from round to
    // stretched we are.
    final double leftAmount = math.max(0.0, math.min(1.0, leftWidthNeeded / neckTriangleBase));
    final double rightAmount = math.max(0.0, math.min(1.0, rightWidthNeeded / neckTriangleBase));
    // The angle between the top neck arc's center and the top lobe's center
    // and vertical.
    final double leftTheta = (1.0 - leftAmount) * _thirtyDegrees;
    final double rightTheta = (1.0 - rightAmount) * _thirtyDegrees;
    // The center of the top left neck arc.
    final Offset neckLeftCenter = Offset(
      -neckTriangleBase,
      _topLobeCenter.dy + math.cos(leftTheta) * _neckTriangleHypotenuse,
    );
    final Offset neckRightCenter = Offset(
      neckTriangleBase,
      _topLobeCenter.dy + math.cos(rightTheta) * _neckTriangleHypotenuse,
    );
    final double leftNeckArcAngle = _ninetyDegrees - leftTheta;
    final double rightNeckArcAngle = math.pi + _ninetyDegrees - rightTheta;
    // The distance between the end of the bottom neck arc and the beginning of
    // the top neck arc. We use this to shrink/expand it based on the scale
    // factor of the value indicator.
    final double neckStretchBaseline = math.max(0.0, bottomLobeEnd.dy - math.max(neckLeftCenter.dy, neckRightCenter.dy));
    final double t = math.pow(inverseTextScale, 3.0);
    final double stretch = (neckStretchBaseline * t).clamp(0.0, 10.0 * neckStretchBaseline);
    final Offset neckStretch = Offset(0.0, neckStretchBaseline - stretch);

    assert(!_debuggingLabelLocation ||
        () {
          final Offset leftCenter = _topLobeCenter - Offset(leftWidthNeeded, 0.0) + neckStretch;
          final Offset rightCenter = _topLobeCenter + Offset(rightWidthNeeded, 0.0) + neckStretch;
          final Rect valueRect = Rect.fromLTRB(
            leftCenter.dx - _topLobeRadius,
            leftCenter.dy - _topLobeRadius,
            rightCenter.dx + _topLobeRadius,
            rightCenter.dy + _topLobeRadius,
          );
          final Paint outlinePaint = Paint()
            ..color = const Color(0xffff0000)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;
          canvas.drawRect(valueRect, outlinePaint);
          return true;
        }());

    _addArc(
      path,
      neckLeftCenter + neckStretch,
      _topNeckRadius,
      0.0,
      -leftNeckArcAngle,
    );
    _addArc(
      path,
      _topLobeCenter - Offset(leftWidthNeeded, 0.0) + neckStretch,
      _topLobeRadius,
      _ninetyDegrees + leftTheta,
      _twoSeventyDegrees,
    );
    _addArc(
      path,
      _topLobeCenter + Offset(rightWidthNeeded, 0.0) + neckStretch,
      _topLobeRadius,
      _twoSeventyDegrees,
      _twoSeventyDegrees + math.pi - rightTheta,
    );
    _addArc(
      path,
      neckRightCenter + neckStretch,
      _topNeckRadius,
      rightNeckArcAngle,
      math.pi,
    );

    if (strokePaintColor != null) {
      final Paint strokePaint = Paint()
        ..color = strokePaintColor
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, strokePaint);
    }

    canvas.drawPath(path, paint);

    // Draw the label.
    canvas.save();
    canvas.translate(shift, -_distanceBetweenTopBottomCenters + neckStretch.dy);
    canvas.scale(inverseTextScale, inverseTextScale);
    labelPainter.paint(canvas, Offset.zero - Offset(labelHalfWidth, labelPainter.height / 2.0));
    canvas.restore();
    canvas.restore();
  }
}

/// A callback that formats the numeric values from a [RangeSlider] widget.
///
/// See also:
///
///  * [RangeSlider.semanticFormatterCallback], which shows an example use case.
typedef RangeSemanticFormatterCallback = String Function(RangeValues values);

/// Decides which thumbs (if any) should be selected.
///
/// The default finds the closest thumb, but if the thumbs are close to each
/// other, it waits for movement defined by [dx] to determine the selected
/// thumb.
///
/// Override [RangeSlider.thumbSelector] for custom thumb selection.
typedef RangeThumbSelector = Thumb Function(
    TextDirection textDirection,
    RangeValues values,
    double tapValue,
    Size thumbSize,
    Size trackSize,
    double dx
    );

/// Object for representing range slider thumb values.
///
/// This object is passed into [RangeSlider.values] to set its values, and it
/// is emitted in [RangeSlider.onChange], [RangeSlider.onChangeStart], and
/// [RangeSlider.onChangeEnd] when the values change.
class RangeValues {
  /// Creates pair of start and end values.
  const RangeValues(this.start, this.end);

  /// The value of the start thumb.
  ///
  /// For LTR text direction, the start is the left thumb, and for RTL text
  /// direction, the start is the right thumb.
  final double start;

  /// The value of the end thumb.
  ///
  /// For LTR text direction, the end is the right thumb, and for RTL text
  /// direction, the end is the left thumb.
  final double end;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    final RangeValues typedOther = other;
    return typedOther.start == start
        && typedOther.end == end;
  }

  @override
  int get hashCode => hashValues(start, end);

  @override
  String toString() {
    return '$runtimeType($start, $end)';
  }
}

/// Object for setting range slider label values that appear in the value
/// indicator for each thumb.
///
/// Used in combination with [RangeSlider.showValueIndicator] to display
/// labels above the thumbs.
class RangeLabels {
  /// Creates pair of start and end labels.
  const RangeLabels(this.start, this.end);

  /// The label of the start thumb.
  ///
  /// For LTR text direction, the start is the left thumb, and for RTL text
  /// direction, the start is the right thumb.
  final String start;

  /// The label of the end thumb.
  ///
  /// For LTR text direction, the end is the right thumb, and for RTL text
  /// direction, the end is the left thumb.
  final String end;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType)
      return false;
    final RangeLabels typedOther = other;
    return typedOther.start == start
        && typedOther.end == end;
  }

  @override
  int get hashCode => hashValues(start, end);

  @override
  String toString() {
    return '$runtimeType($start, $end)';
  }
}

