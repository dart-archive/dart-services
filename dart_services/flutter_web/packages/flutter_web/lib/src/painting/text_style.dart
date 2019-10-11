// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-05-30T14:20:56.440946.

import 'package:flutter_web_ui/ui.dart' as ui show ParagraphStyle, TextStyle, StrutStyle, lerpDouble, Shadow;

import 'package:flutter_web/foundation.dart';

import 'basic_types.dart';
import 'strut_style.dart';

const String _kDefaultDebugLabel = 'unknown';

const String _kColorForegroundWarning = 'Cannot provide both a color and a foreground\n'
    'The color argument is just a shorthand for "foreground: new Paint()..color = color".';

const String _kColorBackgroundWarning = 'Cannot provide both a backgroundColor and a background\n'
    'The backgroundColor argument is just a shorthand for "background: new Paint()..color = color".';

// Examples can assume:
// BuildContext context;

/// An immutable style in which paint text.
///
/// ### Bold
///
/// {@tool sample}
/// Here, a single line of text in a [Text] widget is given a specific style
/// override. The style is mixed with the ambient [DefaultTextStyle] by the
/// [Text] widget.
///
/// ```dart
/// Text(
///   'No, we need bold strokes. We need this plan.',
///   style: TextStyle(fontWeight: FontWeight.bold),
/// )
/// ```
/// {@end-tool}
///
/// ### Italics
///
/// {@tool sample}
/// As in the previous example, the [Text] widget is given a specific style
/// override which is implicitly mixed with the ambient [DefaultTextStyle].
///
/// ```dart
/// Text(
///   'Welcome to the present, we\'re running a real nation.',
///   style: TextStyle(fontStyle: FontStyle.italic),
/// )
/// ```
/// {@end-tool}
///
/// ### Opacity and Color
///
/// Each line here is progressively more opaque. The base color is
/// [material.Colors.black], and [Color.withOpacity] is used to create a
/// derivative color with the desired opacity. The root [TextSpan] for this
/// [RichText] widget is explicitly given the ambient [DefaultTextStyle], since
/// [RichText] does not do that automatically. The inner [TextStyle] objects are
/// implicitly mixed with the parent [TextSpan]'s [TextSpan.style].
///
/// If [color] is specified, [foreground] must be null and vice versa. [color] is
/// treated as a shorthand for `Paint()..color = color`.
///
/// If [backgroundColor] is specified, [background] must be null and vice versa.
/// The [backgroundColor] is treated as a shorthand for
/// `background: Paint()..color = backgroundColor`.
///
/// ```dart
/// RichText(
///   text: TextSpan(
///     style: DefaultTextStyle.of(context).style,
///     children: <TextSpan>[
///       TextSpan(
///         text: 'You don\'t have the votes.\n',
///         style: TextStyle(color: Colors.black.withOpacity(0.6)),
///       ),
///       TextSpan(
///         text: 'You don\'t have the votes!\n',
///         style: TextStyle(color: Colors.black.withOpacity(0.8)),
///       ),
///       TextSpan(
///         text: 'You\'re gonna need congressional approval and you don\'t have the votes!\n',
///         style: TextStyle(color: Colors.black.withOpacity(1.0)),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### Size
///
/// {@tool sample}
/// In this example, the ambient [DefaultTextStyle] is explicitly manipulated to
/// obtain a [TextStyle] that doubles the default font size.
///
/// ```dart
/// Text(
///   'These are wise words, enterprising men quote \'em.',
///   style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
/// )
/// ```
/// {@end-tool}
///
/// ### Line height
///
/// {@tool sample}
/// The [height] property can be used to change the line height. Here, the line
/// height is set to 5 times the font size, so that the text is very spaced out.
///
/// ```dart
/// Text(
///   'Don\'t act surprised, you guys, cuz I wrote \'em!',
///   style: TextStyle(height: 5.0),
/// )
/// ```
/// {@end-tool}
///
/// ### Wavy red underline with black text
///
/// {@tool sample}
/// Styles can be combined. In this example, the misspelt word is drawn in black
/// text and underlined with a wavy red line to indicate a spelling error. (The
/// remainder is styled according to the Flutter default text styles, not the
/// ambient [DefaultTextStyle], since no explicit style is given and [RichText]
/// does not automatically use the ambient [DefaultTextStyle].)
///
/// ```dart
/// RichText(
///   text: TextSpan(
///     text: 'Don\'t tax the South ',
///     children: <TextSpan>[
///       TextSpan(
///         text: 'cuz',
///         style: TextStyle(
///           color: Colors.black,
///           decoration: TextDecoration.underline,
///           decorationColor: Colors.red,
///           decorationStyle: TextDecorationStyle.wavy,
///         ),
///       ),
///       TextSpan(
///         text: ' we got it made in the shade',
///       ),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// ### Custom Fonts
///
/// Custom fonts can be declared in the `pubspec.yaml` file as shown below:
///
/// ```yaml
/// flutter:
///   fonts:
///     - family: Raleway
///       fonts:
///         - asset: fonts/Raleway-Regular.ttf
///         - asset: fonts/Raleway-Medium.ttf
///           weight: 500
///         - asset: assets/fonts/Raleway-SemiBold.ttf
///           weight: 600
///      - family: Schyler
///        fonts:
///          - asset: fonts/Schyler-Regular.ttf
///          - asset: fonts/Schyler-Italic.ttf
///            style: italic
/// ```
///
/// The `family` property determines the name of the font, which you can use in
/// the [fontFamily] argument. The `asset` property is a path to the font file,
/// relative to the `pubspec.yaml` file. The `weight` property specifies the
/// weight of the glyph outlines in the file as an integer multiple of 100
/// between 100 and 900. This corresponds to the [FontWeight] class and can be
/// used in the [fontWeight] argument. The `style` property specifies whether the
/// outlines in the file are `italic` or `normal`. These values correspond to
/// the [FontStyle] class and can be used in the [fontStyle] argument.
///
/// To select a custom font, create [TextStyle] using the [fontFamily]
/// argument as shown in the example below:
///
/// {@tool sample}
/// ```dart
/// const TextStyle(fontFamily: 'Raleway')
/// ```
/// {@end-tool}
///
/// To use a font family defined in a package, the [package] argument must be
/// provided. For instance, suppose the font declaration above is in the
/// `pubspec.yaml` of a package named `my_package` which the app depends on.
/// Then creating the TextStyle is done as follows:
///
/// ```dart
/// const TextStyle(fontFamily: 'Raleway', package: 'my_package')
/// ```
///
/// If the package internally uses the font it defines, it should still specify
/// the `package` argument when creating the text style as in the example above.
///
/// A package can also provide font files without declaring a font in its
/// `pubspec.yaml`. These files should then be in the `lib/` folder of the
/// package. The font files will not automatically be bundled in the app, instead
/// the app can use these selectively when declaring a font. Suppose a package
/// named `my_package` has:
///
/// ```
/// lib/fonts/Raleway-Medium.ttf
/// ```
///
/// Then the app can declare a font like in the example below:
///
/// ```yaml
/// flutter:
///   fonts:
///     - family: Raleway
///       fonts:
///         - asset: assets/fonts/Raleway-Regular.ttf
///         - asset: packages/my_package/fonts/Raleway-Medium.ttf
///           weight: 500
/// ```
///
/// The `lib/` is implied, so it should not be included in the asset path.
///
/// In this case, since the app locally defines the font, the TextStyle is
/// created without the `package` argument:
///
/// {@tool sample}
/// ```dart
/// const TextStyle(fontFamily: 'Raleway')
/// ```
/// {@end-tool}
///
/// ### Custom Font Fallback
///
/// A custom [fontFamilyFallback] list can be provided. The list should be an
/// ordered list of strings of font family names in the order they will be attempted.
///
/// The fonts in [fontFamilyFallback] will be used only if the requested glyph is
/// not present in the [fontFamily].
///
/// The fallback order is:
///
///  * [fontFamily]
///  * [fontFamilyFallback] in order of first to last.
///
/// The glyph used will always be the first matching version in fallback order.
///
/// The [fontFamilyFallback] property is commonly used to specify different font
/// families for multilingual text spans as well as separate fonts for glyphs such
/// as emojis.
///
/// {@tool sample}
/// In the following example, any glyphs not present in the font `Raleway` will be attempted
/// to be resolved with `Noto Sans CJK SC`, and then with `Noto Color Emoji`:
///
/// ```dart
/// const TextStyle(
///   fontFamily: 'Raleway',
///   fontFamilyFallback: <String>[
///     'Noto Sans CJK SC',
///     'Noto Color Emoji',
///   ],
/// )
/// ```
/// {@end-tool}
///
/// If all custom fallback font families are exhausted and no match was found
/// or no custom fallback was provided, the platform font fallback will be used.
///
/// ### Inconsistent platform fonts
///
/// Since Flutter's font discovery for default fonts depends on the fonts present
/// on the device, it is not safe to assume all default fonts will be available or
/// consistent across devices.
///
/// A known example of this is that Samsung devices ship with a CJK font that has
/// smaller line spacing than the Android default. This results in Samsung devices
/// displaying more tightly spaced text than on other Android devices when no
/// custom font is specified.
///
/// To avoid this, a custom font should be specified if absolute font consistency
/// is required for your application.
///
/// See also:
///
///  * [Text], the widget for showing text in a single style.
///  * [DefaultTextStyle], the widget that specifies the default text styles for
///    [Text] widgets, configured using a [TextStyle].
///  * [RichText], the widget for showing a paragraph of mix-style text.
///  * [TextSpan], the class that wraps a [TextStyle] for the purposes of
///    passing it to a [RichText].
///  * [TextStyle](https://api.flutter.dev/flutter/dart-ui/TextStyle-class.html), the class in the [dart:ui] library.
///
@immutable
class TextStyle extends Diagnosticable {
  /// Creates a text style.
  ///
  /// The `package` argument must be non-null if the font family is defined in a
  /// package. It is combined with the `fontFamily` argument to set the
  /// [fontFamily] property.
  const TextStyle({
    this.inherit = true,
    this.color,
    this.backgroundColor,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.textBaseline,
    this.height,
    this.locale,
    this.foreground,
    this.background,
    this.shadows,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
    this.debugLabel,
    String fontFamily,
    List<String> fontFamilyFallback,
    String package,
  }) : fontFamily = package == null ? fontFamily : 'packages/$package/$fontFamily',
       _fontFamilyFallback = fontFamilyFallback,
       _package = package,
       assert(inherit != null),
       assert(color == null || foreground == null, _kColorForegroundWarning),
       assert(backgroundColor == null || background == null, _kColorBackgroundWarning);


  /// Whether null values are replaced with their value in an ancestor text
  /// style (e.g., in a [TextSpan] tree).
  ///
  /// If this is false, properties that don't have explicit values will revert
  /// to the defaults: white in color, a font size of 10 pixels, in a sans-serif
  /// font face.
  final bool inherit;

  /// The color to use when painting the text.
  ///
  /// If [foreground] is specified, this value must be null. The [color] property
  /// is shorthand for `Paint()..color = color`.
  ///
  /// In [merge], [apply], and [lerp], conflicts between [color] and [foreground]
  /// specification are resolved in [foreground]'s favor - i.e. if [foreground] is
  /// specified in one place, it will dominate [color] in another.
  final Color color;

  /// The color to use as the background for the text.
  ///
  /// If [background] is specified, this value must be null. The
  /// [backgroundColor] property is shorthand for
  /// `background: Paint()..color = backgroundColor`.
  ///
  /// In [merge], [apply], and [lerp], conflicts between [backgroundColor] and [background]
  /// specification are resolved in [background]'s favor - i.e. if [background] is
  /// specified in one place, it will dominate [color] in another.
  final Color backgroundColor;

  /// The name of the font to use when painting the text (e.g., Roboto). If the
  /// font is defined in a package, this will be prefixed with
  /// 'packages/package_name/' (e.g. 'packages/cool_fonts/Roboto'). The
  /// prefixing is done by the constructor when the `package` argument is
  /// provided.
  ///
  /// The value provided in [fontFamily] will act as the preferred/first font
  /// family that glyphs are looked for in, followed in order by the font families
  /// in [fontFamilyFallback]. When [fontFamily] is null or not provided, the
  /// first value in [fontFamilyFallback] acts as the preferred/first font
  /// family. When neither is provided, then the default platform font will
  /// be used.
  final String fontFamily;

  /// The ordered list of font families to fall back on when a glyph cannot be
  /// found in a higher priority font family.
  ///
  /// The value provided in [fontFamily] will act as the preferred/first font
  /// family that glyphs are looked for in, followed in order by the font families
  /// in [fontFamilyFallback]. If all font families are exhausted and no match
  /// was found, the default platform font family will be used instead.
  ///
  /// When [fontFamily] is null or not provided, the first value in [fontFamilyFallback]
  /// acts as the preferred/first font family. When neither is provided, then
  /// the default platform font will be used. Providing and empty list or null
  /// for this property is the same as omitting it.
  ///
  /// For example, if a glyph is not found in [fontFamily], then each font family
  /// in [fontFamilyFallback] will be searched in order until it is found. If it
  /// is not found, then a box will be drawn in its place.
  ///
  /// If the font is defined in a package, each font family in the list will be
  /// prefixed with 'packages/package_name/' (e.g. 'packages/cool_fonts/Roboto').
  /// The package name should be provided by the `package` argument in the
  /// constructor.
  List<String> get fontFamilyFallback => _package != null && _fontFamilyFallback != null ? _fontFamilyFallback.map((String str) => 'packages/$_package/$str').toList() : _fontFamilyFallback;
  final List<String> _fontFamilyFallback;

  // This is stored in order to prefix the fontFamilies in _fontFamilyFallback
  // in the [fontFamilyFallback] getter.
  final String _package;

  /// The size of glyphs (in logical pixels) to use when painting the text.
  ///
  /// During painting, the [fontSize] is multiplied by the current
  /// `textScaleFactor` to let users make it easier to read text by increasing
  /// its size.
  ///
  /// [getParagraphStyle] will default to 14 logical pixels if the font size
  /// isn't specified here.
  final double fontSize;

  // The default font size if none is specified.
  static const double _defaultFontSize = 14.0;

  /// The typeface thickness to use when painting the text (e.g., bold).
  final FontWeight fontWeight;

  /// The typeface variant to use when drawing the letters (e.g., italics).
  final FontStyle fontStyle;

  /// The amount of space (in logical pixels) to add between each letter.
  /// A negative value can be used to bring the letters closer.
  final double letterSpacing;

  /// The amount of space (in logical pixels) to add at each sequence of
  /// white-space (i.e. between each word). A negative value can be used to
  /// bring the words closer.
  final double wordSpacing;

  /// The common baseline that should be aligned between this text span and its
  /// parent text span, or, for the root text spans, with the line box.
  final TextBaseline textBaseline;

  /// The height of this text span, as a multiple of the font size.
  ///
  /// If applied to the root [TextSpan], this value sets the line height, which
  /// is the minimum distance between subsequent text baselines, as multiple of
  /// the font size.
  final double height;

  /// The locale used to select region-specific glyphs.
  ///
  /// This property is rarely set. Typically the locale used to select
  /// region-specific glyphs is defined by the text widget's [BuildContext]
  /// using `Localizations.localeOf(context)`. For example [RichText] defines
  /// its locale this way. However, a rich text widget's [TextSpan]s could
  /// specify text styles with different explicit locales in order to select
  /// different region-specific glyphs for each text span.
  final Locale locale;

  /// The paint drawn as a foreground for the text.
  ///
  /// The value should ideally be cached and reused each time if multiple text
  /// styles are created with the same paint settings. Otherwise, each time it
  /// will appear like the style changed, which will result in unnecessary
  /// updates all the way through the framework.
  ///
  /// If [color] is specified, this value must be null. The [color] property
  /// is shorthand for `Paint()..color = color`.
  ///
  /// In [merge], [apply], and [lerp], conflicts between [color] and [foreground]
  /// specification are resolved in [foreground]'s favor - i.e. if [foreground] is
  /// specified in one place, it will dominate [color] in another.
  final Paint foreground;

  /// The paint drawn as a background for the text.
  ///
  /// The value should ideally be cached and reused each time if multiple text
  /// styles are created with the same paint settings. Otherwise, each time it
  /// will appear like the style changed, which will result in unnecessary
  /// updates all the way through the framework.
  ///
  /// If [backgroundColor] is specified, this value must be null. The
  /// [backgroundColor] property is shorthand for
  /// `background: Paint()..color = backgroundColor`.
  ///
  /// In [merge], [apply], and [lerp], conflicts between [backgroundColor] and
  /// [background] specification are resolved in [background]'s favor - i.e. if
  /// [background] is specified in one place, it will dominate [backgroundColor]
  /// in another.
  final Paint background;

  /// The decorations to paint near the text (e.g., an underline).
  ///
  /// Multiple decorations can be applied using [TextDecoration.combine].
  final TextDecoration decoration;

  /// The color in which to paint the text decorations.
  final Color decorationColor;

  /// The style in which to paint the text decorations (e.g., dashed).
  final TextDecorationStyle decorationStyle;

  /// The thickness of the decoration stroke as a muliplier of the thickness
  /// defined by the font.
  ///
  /// The font provides a base stroke width for [decoration]s which scales off
  /// of the [fontSize]. This property may be used to achieve a thinner or
  /// thicker decoration stroke, without changing the [fontSize]. For example,
  /// a [decorationThickness] of 2.0 will draw a decoration twice as thick as
  /// the font defined decoration thickness.
  ///
  /// {@tool sample}
  /// To achieve a bolded strike-through, we can apply a thicker stroke for the
  /// decoration.
  ///
  /// ```dart
  /// Text(
  ///   'This has a very BOLD strike through!',
  ///   style: TextStyle(
  ///     decoration: TextDecoration.lineThrough,
  ///     decorationThickness: 2.85,
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// {@tool sample}
  /// We can apply a very thin and subtle wavy underline (perhaps, when words
  /// are misspelled) by using a [decorationThickness] < 1.0.
  ///
  /// ```dart
  /// Text(
  ///   'oopsIforgottousespaces!',
  ///   style: TextStyle(
  ///     decoration: TextDecoration.underline,
  ///     decorationStyle: TextDecorationStyle.wavy,
  ///     decorationColor: Colors.red,
  ///     decorationThickness: 0.5,
  ///   ),
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// The default [decorationThickness] is 1.0, which will use the font's base
  /// stroke thickness/width.
  final double decorationThickness;

  /// A human-readable description of this text style.
  ///
  /// This property is maintained only in debug builds.
  ///
  /// When merging ([merge]), copying ([copyWith]), modifying using [apply], or
  /// interpolating ([lerp]), the label of the resulting style is marked with
  /// the debug labels of the original styles. This helps figuring out where a
  /// particular text style came from.
  ///
  /// This property is not considered when comparing text styles using `==` or
  /// [compareTo], and it does not affect [hashCode].
  final String debugLabel;

  /// A list of [Shadow]s that will be painted underneath the text.
  ///
  /// Multiple shadows are supported to replicate lighting from multiple light
  /// sources.
  ///
  /// Shadows must be in the same order for [TextStyle] to be considered as
  /// equivalent as order produces differing transparency.
  final List<ui.Shadow> shadows;

  /// Creates a copy of this text style but with the given fields replaced with
  /// the new values.
  ///
  /// One of [color] or [foreground] must be null, and if this has [foreground]
  /// specified it will be given preference over any color parameter.
  ///
  /// One of [backgroundColor] or [background] must be null, and if this has
  /// [background] specified it will be given preference over any
  /// backgroundColor parameter.
  TextStyle copyWith({
    bool inherit,
    Color color,
    Color backgroundColor,
    String fontFamily,
    List<String> fontFamilyFallback,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double letterSpacing,
    double wordSpacing,
    TextBaseline textBaseline,
    double height,
    Locale locale,
    Paint foreground,
    Paint background,
    List<ui.Shadow> shadows,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    double decorationThickness,
    String debugLabel,
  }) {
    assert(color == null || foreground == null, _kColorForegroundWarning);
    assert(backgroundColor == null || background == null, _kColorBackgroundWarning);
    String newDebugLabel;
    assert(() {
      if (this.debugLabel != null)
        newDebugLabel = debugLabel ?? '(${this.debugLabel}).copyWith';
      return true;
    }());
    return TextStyle(
      inherit: inherit ?? this.inherit,
      color: this.foreground == null && foreground == null ? color ?? this.color : null,
      backgroundColor: this.background == null && background == null ? backgroundColor ?? this.backgroundColor : null,
      fontFamily: fontFamily ?? this.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      textBaseline: textBaseline ?? this.textBaseline,
      height: height ?? this.height,
      locale: locale ?? this.locale,
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
      shadows: shadows ?? this.shadows,
      decoration: decoration ?? this.decoration,
      decorationColor: decorationColor ?? this.decorationColor,
      decorationStyle: decorationStyle ?? this.decorationStyle,
      decorationThickness: decorationThickness ?? this.decorationThickness,
      debugLabel: newDebugLabel,
    );
  }

  /// Creates a copy of this text style replacing or altering the specified
  /// properties.
  ///
  /// The non-numeric properties [color], [fontFamily], [decoration],
  /// [decorationColor] and [decorationStyle] are replaced with the new values.
  ///
  /// [foreground] will be given preference over [color] if it is not null and
  /// [background] will be given preference over [backgroundColor] if it is not
  /// null.
  ///
  /// The numeric properties are multiplied by the given factors and then
  /// incremented by the given deltas.
  ///
  /// For example, `style.apply(fontSizeFactor: 2.0, fontSizeDelta: 1.0)` would
  /// return a [TextStyle] whose [fontSize] is `style.fontSize * 2.0 + 1.0`.
  ///
  /// For the [fontWeight], the delta is applied to the [FontWeight] enum index
  /// values, so that for instance `style.apply(fontWeightDelta: -2)` when
  /// applied to a `style` whose [fontWeight] is [FontWeight.w500] will return a
  /// [TextStyle] with a [FontWeight.w300].
  ///
  /// The numeric arguments must not be null.
  ///
  /// If the underlying values are null, then the corresponding factors and/or
  /// deltas must not be specified.
  ///
  /// If [foreground] is specified on this object, then applying [color] here
  /// will have no effect and if [background] is specified on this object, then
  /// applying [backgroundColor] here will have no effect either.
  TextStyle apply({
    Color color,
    Color backgroundColor,
    TextDecoration decoration,
    Color decorationColor,
    TextDecorationStyle decorationStyle,
    double decorationThicknessFactor = 1.0,
    double decorationThicknessDelta = 0.0,
    String fontFamily,
    List<String> fontFamilyFallback,
    double fontSizeFactor = 1.0,
    double fontSizeDelta = 0.0,
    int fontWeightDelta = 0,
    double letterSpacingFactor = 1.0,
    double letterSpacingDelta = 0.0,
    double wordSpacingFactor = 1.0,
    double wordSpacingDelta = 0.0,
    double heightFactor = 1.0,
    double heightDelta = 0.0,
  }) {
    assert(fontSizeFactor != null);
    assert(fontSizeDelta != null);
    assert(fontSize != null || (fontSizeFactor == 1.0 && fontSizeDelta == 0.0));
    assert(fontWeightDelta != null);
    assert(fontWeight != null || fontWeightDelta == 0.0);
    assert(letterSpacingFactor != null);
    assert(letterSpacingDelta != null);
    assert(letterSpacing != null || (letterSpacingFactor == 1.0 && letterSpacingDelta == 0.0));
    assert(wordSpacingFactor != null);
    assert(wordSpacingDelta != null);
    assert(wordSpacing != null || (wordSpacingFactor == 1.0 && wordSpacingDelta == 0.0));
    assert(heightFactor != null);
    assert(heightDelta != null);
    assert(heightFactor != null || (heightFactor == 1.0 && heightDelta == 0.0));
    assert(decorationThicknessFactor != null);
    assert(decorationThicknessDelta != null);
    assert(decorationThickness != null || (decorationThicknessFactor == 1.0 && decorationThicknessDelta == 0.0));

    String modifiedDebugLabel;
    assert(() {
      if (debugLabel != null)
        modifiedDebugLabel = '($debugLabel).apply';
      return true;
    }());

    return TextStyle(
      inherit: inherit,
      color: foreground == null ? color ?? this.color : null,
      backgroundColor: background == null ? backgroundColor ?? this.backgroundColor : null,
      fontFamily: fontFamily ?? this.fontFamily,
      fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
      fontSize: fontSize == null ? null : fontSize * fontSizeFactor + fontSizeDelta,
      fontWeight: fontWeight == null ? null : FontWeight.values[(fontWeight.index + fontWeightDelta).clamp(0, FontWeight.values.length - 1)],
      fontStyle: fontStyle,
      letterSpacing: letterSpacing == null ? null : letterSpacing * letterSpacingFactor + letterSpacingDelta,
      wordSpacing: wordSpacing == null ? null : wordSpacing * wordSpacingFactor + wordSpacingDelta,
      textBaseline: textBaseline,
      height: height == null ? null : height * heightFactor + heightDelta,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      decoration: decoration ?? this.decoration,
      decorationColor: decorationColor ?? this.decorationColor,
      decorationStyle: decorationStyle ?? this.decorationStyle,
      decorationThickness: decorationThickness == null ? null : decorationThickness * decorationThicknessFactor + decorationThicknessDelta,
      debugLabel: modifiedDebugLabel,
    );
  }

  /// Returns a new text style that is a combination of this style and the given
  /// [other] style.
  ///
  /// If the given [other] text style has its [TextStyle.inherit] set to true,
  /// its null properties are replaced with the non-null properties of this text
  /// style. The [other] style _inherits_ the properties of this style. Another
  /// way to think of it is that the "missing" properties of the [other] style
  /// are _filled_ by the properties of this style.
  ///
  /// If the given [other] text style has its [TextStyle.inherit] set to false,
  /// returns the given [other] style unchanged. The [other] style does not
  /// inherit properties of this style.
  ///
  /// If the given text style is null, returns this text style.
  ///
  /// One of [color] or [foreground] must be null, and if this or `other` has
  /// [foreground] specified it will be given preference over any color parameter.
  ///
  /// Similarly, One of [backgroundColor] or [background] must be null, and if
  /// this or `other` has [background] specified it will be given preference
  /// over any backgroundColor parameter.
  TextStyle merge(TextStyle other) {
    if (other == null)
      return this;
    if (!other.inherit)
      return other;

    String mergedDebugLabel;
    assert(() {
      if (other.debugLabel != null || debugLabel != null)
        mergedDebugLabel = '(${debugLabel ?? _kDefaultDebugLabel}).merge(${other.debugLabel ?? _kDefaultDebugLabel})';
      return true;
    }());

    return copyWith(
      color: other.color,
      backgroundColor: other.backgroundColor,
      fontFamily: other.fontFamily,
      fontFamilyFallback: other.fontFamilyFallback,
      fontSize: other.fontSize,
      fontWeight: other.fontWeight,
      fontStyle: other.fontStyle,
      letterSpacing: other.letterSpacing,
      wordSpacing: other.wordSpacing,
      textBaseline: other.textBaseline,
      height: other.height,
      locale: other.locale,
      foreground: other.foreground,
      background: other.background,
      shadows: other.shadows,
      decoration: other.decoration,
      decorationColor: other.decorationColor,
      decorationStyle: other.decorationStyle,
      decorationThickness: other.decorationThickness,
      debugLabel: mergedDebugLabel,
    );
  }

  /// Interpolate between two text styles.
  ///
  /// This will not work well if the styles don't set the same fields.
  ///
  /// {@macro dart.ui.shadow.lerp}
  ///
  /// If [foreground] is specified on either of `a` or `b`, both will be treated
  /// as if they have a [foreground] paint (creating a new [Paint] if necessary
  /// based on the [color] property).
  ///
  /// If [background] is specified on either of `a` or `b`, both will be treated
  /// as if they have a [background] paint (creating a new [Paint] if necessary
  /// based on the [backgroundColor] property).
  static TextStyle lerp(TextStyle a, TextStyle b, double t) {
    assert(t != null);
    assert(a == null || b == null || a.inherit == b.inherit);
    if (a == null && b == null) {
      return null;
    }

    String lerpDebugLabel;
    assert(() {
      lerpDebugLabel = 'lerp(${a?.debugLabel ?? _kDefaultDebugLabel} ⎯${t.toStringAsFixed(1)}→ ${b?.debugLabel ?? _kDefaultDebugLabel})';
      return true;
    }());

    if (a == null) {
      return TextStyle(
        inherit: b.inherit,
        color: Color.lerp(null, b.color, t),
        backgroundColor: Color.lerp(null, b.backgroundColor, t),
        fontFamily: t < 0.5 ? null : b.fontFamily,
        fontFamilyFallback: t < 0.5 ? null : b.fontFamilyFallback,
        fontSize: t < 0.5 ? null : b.fontSize,
        fontWeight: FontWeight.lerp(null, b.fontWeight, t),
        fontStyle: t < 0.5 ? null : b.fontStyle,
        letterSpacing: t < 0.5 ? null : b.letterSpacing,
        wordSpacing: t < 0.5 ? null : b.wordSpacing,
        textBaseline: t < 0.5 ? null : b.textBaseline,
        height: t < 0.5 ? null : b.height,
        locale: t < 0.5 ? null : b.locale,
        foreground: t < 0.5 ? null : b.foreground,
        background: t < 0.5 ? null : b.background,
        decoration: t < 0.5 ? null : b.decoration,
        shadows: t < 0.5 ? null : b.shadows,
        decorationColor: Color.lerp(null, b.decorationColor, t),
        decorationStyle: t < 0.5 ? null : b.decorationStyle,
        decorationThickness: t < 0.5 ? null : b.decorationThickness,
        debugLabel: lerpDebugLabel,
      );
    }

    if (b == null) {
      return TextStyle(
        inherit: a.inherit,
        color: Color.lerp(a.color, null, t),
        backgroundColor: Color.lerp(null, a.backgroundColor, t),
        fontFamily: t < 0.5 ? a.fontFamily : null,
        fontFamilyFallback: t < 0.5 ? a.fontFamilyFallback : null,
        fontSize: t < 0.5 ? a.fontSize : null,
        fontWeight: FontWeight.lerp(a.fontWeight, null, t),
        fontStyle: t < 0.5 ? a.fontStyle : null,
        letterSpacing: t < 0.5 ? a.letterSpacing : null,
        wordSpacing: t < 0.5 ? a.wordSpacing : null,
        textBaseline: t < 0.5 ? a.textBaseline : null,
        height: t < 0.5 ? a.height : null,
        locale: t < 0.5 ? a.locale : null,
        foreground: t < 0.5 ? a.foreground : null,
        background: t < 0.5 ? a.background : null,
        shadows: t < 0.5 ? a.shadows : null,
        decoration: t < 0.5 ? a.decoration : null,
        decorationColor: Color.lerp(a.decorationColor, null, t),
        decorationStyle: t < 0.5 ? a.decorationStyle : null,
        decorationThickness: t < 0.5 ? a.decorationThickness : null,
        debugLabel: lerpDebugLabel,
      );
    }

    return TextStyle(
      inherit: b.inherit,
      color: a.foreground == null && b.foreground == null ? Color.lerp(a.color, b.color, t) : null,
      backgroundColor: a.background == null && b.background == null ? Color.lerp(a.backgroundColor, b.backgroundColor, t) : null,
      fontFamily: t < 0.5 ? a.fontFamily : b.fontFamily,
      fontFamilyFallback: t < 0.5 ? a.fontFamilyFallback : b.fontFamilyFallback,
      fontSize: ui.lerpDouble(a.fontSize ?? b.fontSize, b.fontSize ?? a.fontSize, t),
      fontWeight: FontWeight.lerp(a.fontWeight, b.fontWeight, t),
      fontStyle: t < 0.5 ? a.fontStyle : b.fontStyle,
      letterSpacing: ui.lerpDouble(a.letterSpacing ?? b.letterSpacing, b.letterSpacing ?? a.letterSpacing, t),
      wordSpacing: ui.lerpDouble(a.wordSpacing ?? b.wordSpacing, b.wordSpacing ?? a.wordSpacing, t),
      textBaseline: t < 0.5 ? a.textBaseline : b.textBaseline,
      height: ui.lerpDouble(a.height ?? b.height, b.height ?? a.height, t),
      locale: t < 0.5 ? a.locale : b.locale,
      foreground: (a.foreground != null || b.foreground != null)
        ? t < 0.5
          ? a.foreground ?? (Paint()..color = a.color)
          : b.foreground ?? (Paint()..color = b.color)
        : null,
      background: (a.background != null || b.background != null)
        ? t < 0.5
          ? a.background ?? (Paint()..color = a.backgroundColor)
          : b.background ?? (Paint()..color = b.backgroundColor)
        : null,
      shadows: t < 0.5 ? a.shadows : b.shadows,
      decoration: t < 0.5 ? a.decoration : b.decoration,
      decorationColor: Color.lerp(a.decorationColor, b.decorationColor, t),
      decorationStyle: t < 0.5 ? a.decorationStyle : b.decorationStyle,
      decorationThickness: ui.lerpDouble(a.decorationThickness ?? b.decorationThickness, b.decorationThickness ?? a.decorationThickness, t),
      debugLabel: lerpDebugLabel,
    );
  }

  /// The style information for text runs, encoded for use by `dart:ui`.
  ui.TextStyle getTextStyle({ double textScaleFactor = 1.0 }) {
    return ui.TextStyle(
      color: color,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      textBaseline: textBaseline,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      fontSize: fontSize == null ? null : fontSize * textScaleFactor,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background ?? (backgroundColor != null
        ? (Paint()..color = backgroundColor)
        : null
      ),
      shadows: shadows,
    );
  }

  /// The style information for paragraphs, encoded for use by `dart:ui`.
  ///
  /// The `textScaleFactor` argument must not be null. If omitted, it defaults
  /// to 1.0. The other arguments may be null. The `maxLines` argument, if
  /// specified and non-null, must be greater than zero.
  ///
  /// If the font size on this style isn't set, it will default to 14 logical
  /// pixels.
  ui.ParagraphStyle getParagraphStyle({
    TextAlign textAlign,
    TextDirection textDirection,
    double textScaleFactor = 1.0,
    String ellipsis,
    int maxLines,
    Locale locale,
    String fontFamily,
    double fontSize,
    FontWeight fontWeight,
    FontStyle fontStyle,
    double height,
    StrutStyle strutStyle,
  }) {
    assert(textScaleFactor != null);
    assert(maxLines == null || maxLines > 0);
    return ui.ParagraphStyle(
      textAlign: textAlign,
      textDirection: textDirection,
      // Here, we stablish the contents of this TextStyle as the paragraph's default font
      // unless an override is passed in.
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: (fontSize ?? this.fontSize ?? _defaultFontSize) * textScaleFactor,
      height: height ?? this.height,
      strutStyle: strutStyle == null ? null : ui.StrutStyle(
        fontFamily: strutStyle.fontFamily,
        fontFamilyFallback: strutStyle.fontFamilyFallback,
        fontSize: strutStyle.fontSize,
        height: strutStyle.height,
        leading: strutStyle.leading,
        fontWeight: strutStyle.fontWeight,
        fontStyle: strutStyle.fontStyle,
        forceStrutHeight: strutStyle.forceStrutHeight,
      ),
      maxLines: maxLines,
      ellipsis: ellipsis,
      locale: locale,
    );
  }

  /// Describe the difference between this style and another, in terms of how
  /// much damage it will make to the rendering.
  ///
  /// See also:
  ///
  ///  * [TextSpan.compareTo], which does the same thing for entire [TextSpan]s.
  RenderComparison compareTo(TextStyle other) {
    if (identical(this, other))
      return RenderComparison.identical;
    if (inherit != other.inherit ||
        fontFamily != other.fontFamily ||
        fontSize != other.fontSize ||
        fontWeight != other.fontWeight ||
        fontStyle != other.fontStyle ||
        letterSpacing != other.letterSpacing ||
        wordSpacing != other.wordSpacing ||
        textBaseline != other.textBaseline ||
        height != other.height ||
        locale != other.locale ||
        foreground != other.foreground ||
        background != other.background ||
        !listEquals(shadows, other.shadows) ||
        !listEquals(fontFamilyFallback, other.fontFamilyFallback))
      return RenderComparison.layout;
    if (color != other.color ||
        backgroundColor != other.backgroundColor ||
        decoration != other.decoration ||
        decorationColor != other.decorationColor ||
        decorationStyle != other.decorationStyle ||
        decorationThickness != other.decorationThickness)
      return RenderComparison.paint;
    return RenderComparison.identical;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    final TextStyle typedOther = other;
    return inherit == typedOther.inherit &&
           color == typedOther.color &&
           backgroundColor == typedOther.backgroundColor &&
           fontFamily == typedOther.fontFamily &&
           fontSize == typedOther.fontSize &&
           fontWeight == typedOther.fontWeight &&
           fontStyle == typedOther.fontStyle &&
           letterSpacing == typedOther.letterSpacing &&
           wordSpacing == typedOther.wordSpacing &&
           textBaseline == typedOther.textBaseline &&
           height == typedOther.height &&
           locale == typedOther.locale &&
           foreground == typedOther.foreground &&
           background == typedOther.background &&
           decoration == typedOther.decoration &&
           decorationColor == typedOther.decorationColor &&
           decorationStyle == typedOther.decorationStyle &&
           decorationThickness == typedOther.decorationThickness &&
           listEquals(shadows, typedOther.shadows) &&
           listEquals(fontFamilyFallback, typedOther.fontFamilyFallback);
  }

  @override
  int get hashCode {
    return hashValues(
      inherit,
      color,
      backgroundColor,
      fontFamily,
      fontFamilyFallback,
      fontSize,
      fontWeight,
      fontStyle,
      letterSpacing,
      wordSpacing,
      textBaseline,
      height,
      locale,
      foreground,
      background,
      decoration,
      decorationColor,
      decorationStyle,
      shadows,
    );
  }

  @override
  String toStringShort() => '$runtimeType';

  /// Adds all properties prefixing property names with the optional `prefix`.
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties, { String prefix = '' }) {
    super.debugFillProperties(properties);
    if (debugLabel != null)
      properties.add(MessageProperty('${prefix}debugLabel', debugLabel));
    final List<DiagnosticsNode> styles = <DiagnosticsNode>[];
    styles.add(DiagnosticsProperty<Color>('${prefix}color', color, defaultValue: null));
    styles.add(DiagnosticsProperty<Color>('${prefix}backgroundColor', backgroundColor, defaultValue: null));
    styles.add(StringProperty('${prefix}family', fontFamily, defaultValue: null, quoted: false));
    styles.add(IterableProperty<String>('${prefix}familyFallback', fontFamilyFallback, defaultValue: null));
    styles.add(DoubleProperty('${prefix}size', fontSize, defaultValue: null));
    String weightDescription;
    if (fontWeight != null) {
      weightDescription = '${fontWeight.index + 1}00';
    }
    // TODO(jacobr): switch this to use enumProperty which will either cause the
    // weight description to change to w600 from 600 or require existing
    // enumProperty to handle this special case.
    styles.add(DiagnosticsProperty<FontWeight>(
      '${prefix}weight',
      fontWeight,
      description: weightDescription,
      defaultValue: null,
    ));
    styles.add(EnumProperty<FontStyle>('${prefix}style', fontStyle, defaultValue: null));
    styles.add(DoubleProperty('${prefix}letterSpacing', letterSpacing, defaultValue: null));
    styles.add(DoubleProperty('${prefix}wordSpacing', wordSpacing, defaultValue: null));
    styles.add(EnumProperty<TextBaseline>('${prefix}baseline', textBaseline, defaultValue: null));
    styles.add(DoubleProperty('${prefix}height', height, unit: 'x', defaultValue: null));
    styles.add(DiagnosticsProperty<Locale>('${prefix}locale', locale, defaultValue: null));
    styles.add(DiagnosticsProperty<Paint>('${prefix}foreground', foreground, defaultValue: null));
    styles.add(DiagnosticsProperty<Paint>('${prefix}background', background, defaultValue: null));
    if (decoration != null || decorationColor != null || decorationStyle != null || decorationThickness != null) {
      final List<String> decorationDescription = <String>[];
      if (decorationStyle != null)
        decorationDescription.add(describeEnum(decorationStyle));

      // Hide decorationColor from the default text view as it is shown in the
      // terse decoration summary as well.
      styles.add(DiagnosticsProperty<Color>('${prefix}decorationColor', decorationColor, defaultValue: null, level: DiagnosticLevel.fine));

      if (decorationColor != null)
        decorationDescription.add('$decorationColor');

      // Intentionally collide with the property 'decoration' added below.
      // Tools that show hidden properties could choose the first property
      // matching the name to disambiguate.
      styles.add(DiagnosticsProperty<TextDecoration>('${prefix}decoration', decoration, defaultValue: null, level: DiagnosticLevel.hidden));
      if (decoration != null)
        decorationDescription.add('$decoration');
      assert(decorationDescription.isNotEmpty);
      styles.add(MessageProperty('${prefix}decoration', decorationDescription.join(' ')));
      styles.add(DoubleProperty('${prefix}decorationThickness', decorationThickness, unit: 'x', defaultValue: null));
    }

    final bool styleSpecified = styles.any((DiagnosticsNode n) => !n.isFiltered(DiagnosticLevel.info));
    properties.add(DiagnosticsProperty<bool>('${prefix}inherit', inherit, level: (!styleSpecified && inherit) ? DiagnosticLevel.fine : DiagnosticLevel.info));
    styles.forEach(properties.add);

    if (!styleSpecified)
      properties.add(FlagProperty('inherit', value: inherit, ifTrue: '$prefix<all styles inherited>', ifFalse: '$prefix<no style specified>'));
  }
}
