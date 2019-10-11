// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-08-15T10:04:31.534305.

import 'package:flutter_web_ui/ui.dart' show lerpDouble;

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/widgets.dart';

import 'theme.dart';

/// Defines the visual properties of the routes used to display popup menus
/// as well as [PopupMenuItem] and [PopupMenuDivider] widgets.
///
/// Descendant widgets obtain the current [PopupMenuThemeData] object
/// using `PopupMenuTheme.of(context)`. Instances of
/// [PopupMenuThemeData] can be customized with
/// [PopupMenuThemeData.copyWith].
///
/// Typically, a [PopupMenuThemeData] is specified as part of the
/// overall [Theme] with [ThemeData.popupMenuTheme]. Otherwise,
/// [PopupMenuTheme] can be used to configure its own widget subtree.
///
/// All [PopupMenuThemeData] properties are `null` by default.
/// If any of these properties are null, the popup menu will provide its
/// own defaults.
///
/// See also:
///
///  * [ThemeData], which describes the overall theme information for the
///    application.
class PopupMenuThemeData extends Diagnosticable {
  /// Creates the set of properties used to configure [PopupMenuTheme].
  const PopupMenuThemeData({
    this.color,
    this.shape,
    this.elevation,
    this.textStyle,
  });

  /// The background color of the popup menu.
  final Color color;

  /// The shape of the popup menu.
  final ShapeBorder shape;

  /// The elevation of the popup menu.
  final double elevation;

  /// The text style of items in the popup menu.
  final TextStyle textStyle;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  PopupMenuThemeData copyWith({
    Color color,
    ShapeBorder shape,
    double elevation,
    TextStyle textStyle,
  }) {
    return PopupMenuThemeData(
      color: color ?? this.color,
      shape: shape ?? this.shape,
      elevation: elevation ?? this.elevation,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  /// Linearly interpolate between two popup menu themes.
  ///
  /// If both arguments are null, then null is returned.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static PopupMenuThemeData lerp(PopupMenuThemeData a, PopupMenuThemeData b, double t) {
    assert(t != null);
    if (a == null && b == null)
      return null;
    return PopupMenuThemeData(
      color: Color.lerp(a?.color, b?.color, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      textStyle: TextStyle.lerp(a?.textStyle, b?.textStyle, t),
    );
  }

  @override
  int get hashCode {
    return hashValues(
      color,
      shape,
      elevation,
      textStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    final PopupMenuThemeData typedOther = other;
    return typedOther.elevation == elevation
        && typedOther.color == color
        && typedOther.shape == shape
        && typedOther.textStyle == textStyle;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(DiagnosticsProperty<ShapeBorder>('shape', shape, defaultValue: null));
    properties.add(DoubleProperty('elevation', elevation, defaultValue: null));
    properties.add(DiagnosticsProperty<TextStyle>('text style', textStyle, defaultValue: null));
  }
}

/// An inherited widget that defines the configuration for
/// popup menus in this widget's subtree.
///
/// Values specified here are used for popup menu properties that are not
/// given an explicit non-null value.
class PopupMenuTheme extends InheritedWidget {
  /// Creates a popup menu theme that controls the configurations for
  /// popup menus in its widget subtree.
  PopupMenuTheme({
    Key key,
    Color color,
    ShapeBorder shape,
    double elevation,
    TextStyle textStyle,
    Widget child,
  }) : data = PopupMenuThemeData(
         color: color,
         shape: shape,
         elevation: elevation,
         textStyle: textStyle,
       ),
       super(key: key, child: child);

  /// The properties for descendant popup menu widgets.
  final PopupMenuThemeData data;

  /// The closest instance of this class's [data] value that encloses the given
  /// context. If there is no ancestor, it returns [ThemeData.popupMenuTheme].
  /// Applications can assume that the returned value will not be null.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// PopupMenuThemeData theme = PopupMenuTheme.of(context);
  /// ```
  static PopupMenuThemeData of(BuildContext context) {
    final PopupMenuTheme popupMenuTheme = context.inheritFromWidgetOfExactType(PopupMenuTheme);
    return popupMenuTheme?.data ?? Theme.of(context).popupMenuTheme;
  }

  @override
  bool updateShouldNotify(PopupMenuTheme oldWidget) => data != oldWidget.data;
}
