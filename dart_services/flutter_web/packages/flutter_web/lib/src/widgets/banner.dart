// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/painting.dart';

import 'basic.dart';
import 'debug.dart';
import 'framework.dart';

const double _kOffset =
    40.0; // distance to bottom of banner, at a 45 degree angle inwards
const double _kHeight = 12.0; // height of banner
const double _kBottomOffset =
    _kOffset + 0.707 * _kHeight; // offset plus sqrt(2)/2 * banner height
final Rect _kRect =
    Rect.fromLTWH(-_kOffset, _kOffset - _kHeight, _kOffset * 2.0, _kHeight);

const Color _kColor = Color(0xA0B71C1C);
const TextStyle _kTextStyle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: _kHeight * 0.85,
    fontWeight: FontWeight.w900,
    height: 1.0);

/// Where to show a [Banner].
///
/// The start and end locations are relative to the ambient [Directionality]
/// (which can be overridden by [Banner.layoutDirection]).
enum BannerLocation {
  /// Show the banner in the top-right corner when the ambient [Directionality]
  /// (or [Banner.layoutDirection]) is [TextDirection.rtl] and in the top-left
  /// corner when the ambient [Directionality] is [TextDirection.ltr].
  topStart,

  /// Show the banner in the top-left corner when the ambient [Directionality]
  /// (or [Banner.layoutDirection]) is [TextDirection.rtl] and in the top-right
  /// corner when the ambient [Directionality] is [TextDirection.ltr].
  topEnd,

  /// Show the banner in the bottom-right corner when the ambient
  /// [Directionality] (or [Banner.layoutDirection]) is [TextDirection.rtl] and
  /// in the bottom-left corner when the ambient [Directionality] is
  /// [TextDirection.ltr].
  bottomStart,

  /// Show the banner in the bottom-left corner when the ambient
  /// [Directionality] (or [Banner.layoutDirection]) is [TextDirection.rtl] and
  /// in the bottom-right corner when the ambient [Directionality] is
  /// [TextDirection.ltr].
  bottomEnd,
}

/// Paints a [Banner].
class BannerPainter extends CustomPainter {
  /// Creates a banner painter.
  ///
  /// The [message], [textDirection], [location], and [layoutDirection]
  /// arguments must not be null.
  BannerPainter({
    @required this.message,
    @required this.textDirection,
    @required this.location,
    @required this.layoutDirection,
    this.color = _kColor,
    this.textStyle = _kTextStyle,
  })  : assert(message != null),
        assert(textDirection != null),
        assert(location != null),
        assert(color != null),
        assert(textStyle != null);

  /// The message to show in the banner.
  final String message;

  /// The directionality of the text.
  ///
  /// This value is used to disambiguate how to render bidirectional text. For
  /// example, if the message is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// See also [layoutDirection], which controls the interpretation of values in
  /// [location].
  final TextDirection textDirection;

  /// Where to show the banner (e.g., the upper right corner).
  final BannerLocation location;

  /// The directionality of the layout.
  ///
  /// This value is used to interpret the [location] of the banner.
  ///
  /// See also [textDirection], which controls the reading direction of the
  /// [message].
  final TextDirection layoutDirection;

  /// The color to paint behind the [message].
  ///
  /// Defaults to a dark red.
  final Color color;

  /// The text style to use for the [message].
  ///
  /// Defaults to bold, white text.
  final TextStyle textStyle;

  static const BoxShadow _shadow = BoxShadow(
    color: Color(0x7F000000),
    blurRadius: 6.0,
  );

  bool _prepared = false;
  TextPainter _textPainter;
  Paint _paintShadow;
  Paint _paintBanner;

  void _prepare() {
    _paintShadow = _shadow.toPaint();
    _paintBanner = Paint()..color = color;
    _textPainter = TextPainter(
      text: TextSpan(style: textStyle, text: message),
      textAlign: TextAlign.center,
      textDirection: textDirection,
    );
    _prepared = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!_prepared) _prepare();
    canvas
      ..translate(_translationX(size.width), _translationY(size.height))
      ..rotate(_rotation)
      ..drawRect(_kRect, _paintShadow)
      ..drawRect(_kRect, _paintBanner);
    const double width = _kOffset * 2.0;
    _textPainter.layout(minWidth: width, maxWidth: width);
    _textPainter.paint(
        canvas,
        _kRect.topLeft +
            Offset(0.0, (_kRect.height - _textPainter.height) / 2.0));
  }

  @override
  bool shouldRepaint(BannerPainter oldDelegate) {
    return message != oldDelegate.message ||
        location != oldDelegate.location ||
        color != oldDelegate.color ||
        textStyle != oldDelegate.textStyle;
  }

  @override
  bool hitTest(Offset position) => false;

  double _translationX(double width) {
    assert(location != null);
    assert(layoutDirection != null);
    switch (layoutDirection) {
      case TextDirection.rtl:
        switch (location) {
          case BannerLocation.bottomEnd:
            return _kBottomOffset;
          case BannerLocation.topEnd:
            return 0.0;
          case BannerLocation.bottomStart:
            return width - _kBottomOffset;
          case BannerLocation.topStart:
            return width;
        }
        break;
      case TextDirection.ltr:
        switch (location) {
          case BannerLocation.bottomEnd:
            return width - _kBottomOffset;
          case BannerLocation.topEnd:
            return width;
          case BannerLocation.bottomStart:
            return _kBottomOffset;
          case BannerLocation.topStart:
            return 0.0;
        }
        break;
    }
    return null;
  }

  double _translationY(double height) {
    assert(location != null);
    switch (location) {
      case BannerLocation.bottomStart:
      case BannerLocation.bottomEnd:
        return height - _kBottomOffset;
      case BannerLocation.topStart:
      case BannerLocation.topEnd:
        return 0.0;
    }
    return null;
  }

  double get _rotation {
    assert(location != null);
    assert(layoutDirection != null);
    switch (layoutDirection) {
      case TextDirection.rtl:
        switch (location) {
          case BannerLocation.bottomStart:
          case BannerLocation.topEnd:
            return -math.pi / 4.0;
          case BannerLocation.bottomEnd:
          case BannerLocation.topStart:
            return math.pi / 4.0;
        }
        break;
      case TextDirection.ltr:
        switch (location) {
          case BannerLocation.bottomStart:
          case BannerLocation.topEnd:
            return math.pi / 4.0;
          case BannerLocation.bottomEnd:
          case BannerLocation.topStart:
            return -math.pi / 4.0;
        }
        break;
    }
    return null;
  }
}

/// Displays a diagonal message above the corner of another widget.
///
/// Useful for showing the execution mode of an app (e.g., that asserts are
/// enabled.)
///
/// See also:
///
///  * [CheckedModeBanner], which the [WidgetsApp] widget includes by default in
///    debug mode, to show a banner that says "DEBUG".
class Banner extends StatelessWidget {
  /// Creates a banner.
  ///
  /// The [message] and [location] arguments must not be null.
  const Banner({
    Key key,
    this.child,
    @required this.message,
    this.textDirection,
    @required this.location,
    this.layoutDirection,
    this.color = _kColor,
    this.textStyle = _kTextStyle,
  })  : assert(message != null),
        assert(location != null),
        assert(color != null),
        assert(textStyle != null),
        super(key: key);

  /// The widget to show behind the banner.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The message to show in the banner.
  final String message;

  /// The directionality of the text.
  ///
  /// This is used to disambiguate how to render bidirectional text. For
  /// example, if the message is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any.
  ///
  /// See also [layoutDirection], which controls the interpretation of the
  /// [location].
  final TextDirection textDirection;

  /// Where to show the banner (e.g., the upper right corner).
  final BannerLocation location;

  /// The directionality of the layout.
  ///
  /// This is used to resolve the [location] values.
  ///
  /// Defaults to the ambient [Directionality], if any.
  ///
  /// See also [textDirection], which controls the reading direction of the
  /// [message].
  final TextDirection layoutDirection;

  /// The color of the banner.
  final Color color;

  /// The style of the text shown on the banner.
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    assert((textDirection != null && layoutDirection != null) ||
        debugCheckHasDirectionality(context));
    return CustomPaint(
      foregroundPainter: BannerPainter(
        message: message,
        textDirection: textDirection ?? Directionality.of(context),
        location: location,
        layoutDirection: layoutDirection ?? Directionality.of(context),
        color: color,
        textStyle: textStyle,
      ),
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('message', message, showName: false));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(EnumProperty<BannerLocation>('location', location));
    properties.add(EnumProperty<TextDirection>(
        'layoutDirection', layoutDirection,
        defaultValue: null));
    properties.add(DiagnosticsProperty<Color>('color', color, showName: false));
    textStyle?.debugFillProperties(properties, prefix: 'text ');
  }
}

/// Displays a [Banner] saying "DEBUG" when running in checked mode.
/// [MaterialApp] builds one of these by default.
/// Does nothing in release mode.
class CheckedModeBanner extends StatelessWidget {
  /// Creates a checked mode banner.
  const CheckedModeBanner({Key key, @required this.child}) : super(key: key);

  /// The widget to show behind the banner.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget result = child;
    assert(() {
      result = Banner(
        child: result,
        message: 'DEBUG',
        textDirection: TextDirection.ltr,
        location: BannerLocation.topEnd,
      );
      return true;
    }());
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    String message = 'disabled';
    assert(() {
      message = '"DEBUG"';
      return true;
    }());
    properties.add(DiagnosticsNode.message(message));
  }
}
