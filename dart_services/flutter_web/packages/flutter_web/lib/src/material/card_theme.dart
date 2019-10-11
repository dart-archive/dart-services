// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-08-02T12:40:49.799139.

import 'package:flutter_web_ui/ui.dart';

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/widgets.dart';

import 'theme.dart';

/// Defines default property values for descendant [Card] widgets.
///
/// Descendant widgets obtain the current [CardTheme] object using
/// `CardTheme.of(context)`. Instances of [CardTheme] can be
/// customized with [CardTheme.copyWith].
///
/// Typically a [CardTheme] is specified as part of the overall [Theme]
/// with [ThemeData.cardTheme].
///
/// All [CardTheme] properties are `null` by default. When null, the [Card]
/// will use the values from [ThemeData] if they exist, otherwise it will
/// provide its own defaults.
///
/// See also:
///
///  * [ThemeData], which describes the overall theme information for the
///    application.
class CardTheme extends Diagnosticable {

  /// Creates a theme that can be used for [ThemeData.cardTheme].
  ///
  /// The [elevation] must be null or non-negative.
  const CardTheme({
    this.clipBehavior,
    this.color,
    this.elevation,
    this.margin,
    this.shape,
  }) : assert(elevation == null || elevation >= 0.0);

  /// Default value for [Card.clipBehavior].
  ///
  /// If null, [Card] uses [Clip.none].
  final Clip clipBehavior;

  /// Default value for [Card.color].
  ///
  /// If null, [Card] uses [ThemeData.cardColor].
  final Color color;

  /// Default value for [Card.elevation].
  ///
  /// If null, [Card] uses a default of 1.0.
  final double elevation;

  /// Default value for [Card.margin].
  ///
  /// If null, [Card] uses a default margin of 4.0 logical pixels on all sides:
  /// `EdgeInsets.all(4.0)`.
  final EdgeInsetsGeometry margin;

  /// Default value for [Card.shape].
  ///
  /// If null, [Card] then uses a [RoundedRectangleBorder] with a circular
  /// corner radius of 4.0.
  final ShapeBorder shape;

  /// Creates a copy of this object with the given fields replaced with the
  /// new values.
  CardTheme copyWith({
    Clip clipBehavior,
    Color color,
    double elevation,
    EdgeInsetsGeometry margin,
    ShapeBorder shape,
  }) {
    return CardTheme(
      clipBehavior: clipBehavior ?? this.clipBehavior,
      color: color ?? this.color,
      elevation: elevation ?? this.elevation,
      margin: margin ?? this.margin,
      shape: shape ?? this.shape,
    );
  }

  /// The [ThemeData.cardTheme] property of the ambient [Theme].
  static CardTheme of(BuildContext context) {
    return Theme.of(context).cardTheme;
  }

  /// Linearly interpolate between two Card themes.
  ///
  /// The argument `t` must not be null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static CardTheme lerp(CardTheme a, CardTheme b, double t) {
    assert(t != null);
    return CardTheme(
      clipBehavior: t < 0.5 ? a?.clipBehavior : b?.clipBehavior,
      color: Color.lerp(a?.color, b?.color, t),
      elevation: lerpDouble(a?.elevation, b?.elevation, t),
      margin: EdgeInsetsGeometry.lerp(a?.margin, b?.margin, t),
      shape: ShapeBorder.lerp(a?.shape, b?.shape, t),
    );
  }

  @override
  int get hashCode {
    return hashValues(
      clipBehavior,
      color,
      elevation,
      margin,
      shape,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    final CardTheme typedOther = other;
    return typedOther.clipBehavior == clipBehavior
        && typedOther.color == color
        && typedOther.elevation == elevation
        && typedOther.margin == margin
        && typedOther.shape == shape;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Clip>('clipBehavior', clipBehavior, defaultValue: null));
    properties.add(ColorProperty('color', color, defaultValue: null));
    properties.add(DiagnosticsProperty<double>('elevation', elevation, defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin, defaultValue: null));
    properties.add(DiagnosticsProperty<ShapeBorder>('shape', shape, defaultValue: null));
  }
}
