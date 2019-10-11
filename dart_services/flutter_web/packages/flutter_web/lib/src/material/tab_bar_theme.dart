// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';

import 'tabs.dart';
import 'theme.dart';

/// Defines a theme for [TabBar] widgets.
///
/// A tab bar theme describes the color of the tab label and the size/shape of
/// the [TabBar.indicator].
///
/// Descendant widgets obtain the current theme's [TabBarTheme] object using
/// `TabBarTheme.of(context)`. Instances of [TabBarTheme] can be customized with
/// [TabBarTheme.copyWith].
///
/// See also:
///
///  * [TabBar], a widget that displays a horizontal row of tabs.
///  * [ThemeData], which describes the overall theme information for the
///    application.
class TabBarTheme extends Diagnosticable {
  /// Creates a tab bar theme that can be used with [ThemeData.tabBarTheme].
  const TabBarTheme({
    this.indicator,
    this.indicatorSize,
    this.labelColor,
    this.labelStyle,
    this.unselectedLabelColor,
    this.unselectedLabelStyle,
  });

  /// Default value for [TabBar.indicator].
  final Decoration indicator;

  /// Default value for [TabBar.indicatorSize].
  final TabBarIndicatorSize indicatorSize;

  /// Default value for [TabBar.labelColor].
  final Color labelColor;

  /// Default value for [TabBar.labelStyle].
  final TextStyle labelStyle;

  /// Default value for [TabBar.unselectedLabelColor].
  final Color unselectedLabelColor;

  /// Default value for [TabBar.unselectedLabelStyle].
  final TextStyle unselectedLabelStyle;

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  TabBarTheme copyWith({
    Decoration indicator,
    TabBarIndicatorSize indicatorSize,
    Color labelColor,
    TextStyle labelStyle,
    Color unselectedLabelColor,
    TextStyle unselectedLabelStyle,
  }) {
    return TabBarTheme(
      indicator: indicator ?? this.indicator,
      indicatorSize: indicatorSize ?? this.indicatorSize,
      labelColor: labelColor ?? this.labelColor,
      labelStyle: labelStyle ?? this.labelStyle,
      unselectedLabelColor: unselectedLabelColor ?? this.unselectedLabelColor,
      unselectedLabelStyle: unselectedLabelStyle ?? this.unselectedLabelStyle,
    );
  }

  /// The data from the closest [TabBarTheme] instance given the build context.
  static TabBarTheme of(BuildContext context) {
    return Theme.of(context).tabBarTheme;
  }

  /// Linearly interpolate between two tab bar themes.
  ///
  /// The arguments must not be null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static TabBarTheme lerp(TabBarTheme a, TabBarTheme b, double t) {
    assert(a != null);
    assert(b != null);
    assert(t != null);
    return TabBarTheme(
      indicator: Decoration.lerp(a.indicator, b.indicator, t),
      indicatorSize: t < 0.5 ? a.indicatorSize : b.indicatorSize,
      labelColor: Color.lerp(a.labelColor, b.labelColor, t),
      labelStyle: TextStyle.lerp(a.labelStyle, b.labelStyle, t),
      unselectedLabelColor:
          Color.lerp(a.unselectedLabelColor, b.unselectedLabelColor, t),
      unselectedLabelStyle:
          TextStyle.lerp(a.unselectedLabelStyle, b.unselectedLabelStyle, t),
    );
  }

  @override
  int get hashCode {
    return hashValues(
      indicator,
      indicatorSize,
      labelColor,
      labelStyle,
      unselectedLabelColor,
      unselectedLabelStyle,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final TabBarTheme typedOther = other;
    return typedOther.indicator == indicator &&
        typedOther.indicatorSize == indicatorSize &&
        typedOther.labelColor == labelColor &&
        typedOther.labelStyle == labelStyle &&
        typedOther.unselectedLabelColor == unselectedLabelColor &&
        typedOther.unselectedLabelStyle == unselectedLabelStyle;
  }
}
