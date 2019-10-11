// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-08-05T10:24:57.062679.

import 'package:flutter_web_ui/ui.dart' show lerpDouble;

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/widgets.dart';

import 'theme.dart';

/// Defines a theme for [Dialog] widgets.
///
/// Descendant widgets obtain the current [DialogTheme] object using
/// `DialogTheme.of(context)`. Instances of [DialogTheme] can be customized with
/// [DialogTheme.copyWith].
///
/// When Shape is `null`, the dialog defaults to a [RoundedRectangleBorder] with
/// a border radius of 2.0 on all corners.
///
/// [titleTextStyle] and [contentTextStyle] are used in [AlertDialogs].
/// If null, they default to [ThemeData.textTheme.title] and [ThemeData.textTheme.subhead],
/// respectively.
///
/// See also:
///
///  * [Dialog], a material dialog that can be customized using this [DialogTheme].
///  * [ThemeData], which describes the overall theme information for the
///    application.
class DialogTheme extends Diagnosticable {
  /// Creates a dialog theme that can be used for [ThemeData.dialogTheme].
  const DialogTheme({
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.titleTextStyle,
    this.contentTextStyle,
  });

  /// Default value for [Dialog.backgroundColor].
  ///
  /// If null, [ThemeData.dialogBackgroundColor] is used, if that's null,
  /// defaults to [Colors.white].
  final Color backgroundColor;

  /// Default value for [Dialog.elevation].
  ///
  /// If null, the [Dialog] elevation defaults to `24.0`.
  final double elevation;

  /// Default value for [Dialog.shape].
  final ShapeBorder shape;

  /// Used to configure the [DefaultTextStyle] for the [AlertDialog.title] widget.
  ///
  /// If null, defaults to [ThemeData.textTheme.title].
  final TextStyle titleTextStyle;

  /// Used to configure the [DefaultTextStyle] for the [AlertDialog.content] widget.
  ///
  /// If null, defaults to [ThemeData.textTheme.subhead].
  final TextStyle contentTextStyle;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  DialogTheme copyWith({
    Color backgroundColor,
    double elevation,
    ShapeBorder shape,
    TextStyle titleTextStyle,
    TextStyle contentTextStyle,
  }) {
    return DialogTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      contentTextStyle: contentTextStyle ?? this.contentTextStyle,
    );
  }

  /// The data from the closest [DialogTheme] instance given the build context.
  static DialogTheme of(BuildContext context) {
    return Theme.of(context).dialogTheme;
  }

  /// Linearly interpolate between two dialog themes.
  ///
  /// The arguments must not be null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static DialogTheme lerp(DialogTheme a, DialogTheme b, double t) {
    assert(t != null);
    return DialogTheme(
      backgroundColor: Color.lerp(a?.backgroundColor, b?.backgroundColor, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
      titleTextStyle: TextStyle.lerp(a?.titleTextStyle, b?.titleTextStyle, t),
      contentTextStyle: TextStyle.lerp(a?.contentTextStyle, b?.contentTextStyle, t),
    );
  }

  @override
  int get hashCode => shape.hashCode;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    final DialogTheme typedOther = other;
    return typedOther.backgroundColor == backgroundColor
        && typedOther.elevation == elevation
        && typedOther.shape == shape
        && typedOther.titleTextStyle == titleTextStyle
        && typedOther.contentTextStyle == contentTextStyle;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(DiagnosticsProperty<ShapeBorder>('shape', shape, defaultValue: null));
    properties.add(DoubleProperty('elevation', elevation));
    properties.add(DiagnosticsProperty<TextStyle>('titleTextStyle', titleTextStyle, defaultValue: null));
    properties.add(DiagnosticsProperty<TextStyle>('contentTextStyle', contentTextStyle, defaultValue: null));
  }
}
