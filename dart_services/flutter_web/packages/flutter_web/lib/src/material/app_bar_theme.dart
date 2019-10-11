// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_ui/ui.dart' show lerpDouble;

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/widgets.dart';

import 'text_theme.dart';
import 'theme.dart';

/// Defines default property values for descendant [AppBar] widgets.
///
/// Descendant widgets obtain the current [AppBarTheme] object using
/// `AppBarTheme.of(context)`. Instances of [AppBarTheme] can be customized
/// with [AppBarTheme.copyWith].
///
/// Typically an [AppBarTheme] is specified as part of the overall [Theme] with
/// [ThemeData.appBarTheme].
///
/// All [AppBarTheme] properties are `null` by default. When null, the [AppBar]
/// will use the values from [ThemeData] if they exist, otherwise it will
/// provide its own defaults.
///
/// See also:
///
///  * [ThemeData], which describes the overall theme information for the
///    application.
class AppBarTheme extends Diagnosticable {
  /// Creates a theme that can be used for [ThemeData.AppBarTheme].
  const AppBarTheme({
    this.brightness,
    this.color,
    this.elevation,
    this.iconTheme,
    this.textTheme,
  });

  /// Default value for [AppBar.brightness].
  ///
  /// If null, [AppBar] uses [ThemeData.primaryColorBrightness].
  final Brightness brightness;

  /// Default value for [AppBar.color].
  ///
  /// If null, [AppBar] uses [ThemeData.primaryColor].
  final Color color;

  /// Default value for [AppBar.elevation].
  ///
  /// If null, [AppBar] uses a default value of 4.0.
  final double elevation;

  /// Default value for [AppBar.iconTheme].
  ///
  /// If null, [AppBar] uses [ThemeData.primaryIconTheme].
  final IconThemeData iconTheme;

  /// Default value for [AppBar.textTheme].
  ///
  /// If null, [AppBar] uses [ThemeData.primaryTextTheme].
  final TextTheme textTheme;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  AppBarTheme copyWith({
    Brightness brightness,
    Color color,
    double elevation,
    IconThemeData iconTheme,
    TextTheme textTheme,
  }) {
    return AppBarTheme(
      brightness: brightness ?? this.brightness,
      color: color ?? this.color,
      elevation: elevation ?? this.elevation,
      iconTheme: iconTheme ?? this.iconTheme,
      textTheme: textTheme ?? this.textTheme,
    );
  }

  /// The [ThemeData.appBarTheme] property of the ambient [Theme].
  static AppBarTheme of(BuildContext context) {
    return Theme.of(context).appBarTheme;
  }

  /// Linearly interpolate between two AppBar themes.
  ///
  /// The argument `t` must not be null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static AppBarTheme lerp(AppBarTheme a, AppBarTheme b, double t) {
    assert(t != null);
    return AppBarTheme(
      brightness: t < 0.5 ? a?.brightness : b?.brightness,
      color: Color.lerp(a?.color, b?.color, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      iconTheme: IconThemeData.lerp(a?.iconTheme, b?.iconTheme, t),
      textTheme: TextTheme.lerp(a?.textTheme, b?.textTheme, t),
    );
  }

  @override
  int get hashCode {
    return hashValues(
      brightness,
      color,
      elevation,
      iconTheme,
      textTheme,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final AppBarTheme typedOther = other;
    return typedOther.brightness == brightness &&
        typedOther.color == color &&
        typedOther.elevation == elevation &&
        typedOther.iconTheme == iconTheme &&
        typedOther.textTheme == textTheme;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Brightness>('brightness', brightness,
        defaultValue: null));
    properties
        .add(DiagnosticsProperty<Color>('color', color, defaultValue: null));
    properties.add(DiagnosticsProperty<double>('elevation', elevation,
        defaultValue: null));
    properties.add(DiagnosticsProperty<IconThemeData>('iconTheme', iconTheme,
        defaultValue: null));
    properties.add(DiagnosticsProperty<TextTheme>('textTheme', textTheme,
        defaultValue: null));
  }
}
