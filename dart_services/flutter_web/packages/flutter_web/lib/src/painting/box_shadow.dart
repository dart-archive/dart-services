// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-08-02T12:40:49.876160.

import 'dart:math' as math;
import 'package:flutter_web_ui/ui.dart' as ui show Shadow, lerpDouble;

import 'package:flutter_web/foundation.dart';

import 'basic_types.dart';
import 'debug.dart';

/// A shadow cast by a box.
///
/// Inherits from [Shadow]
///
/// [BoxShadow] can cast non-rectangular shadows if the box is non-rectangular
/// (e.g., has a border radius or a circular shape).
///
/// This class is similar to CSS box-shadow.
///
/// See also:
///
///  * [Canvas.drawShadow], which is a more efficient way to draw shadows.
///  * [Shadow], which is the parent class that lacks [spreadRadius].
@immutable
class BoxShadow extends ui.Shadow {
  /// Creates a box shadow.
  ///
  /// By default, the shadow is solid black with zero [offset], [blurRadius],
  /// and [spreadRadius].
  const BoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    this.spreadRadius = 0.0,
  }) : super(color: color, offset: offset, blurRadius: blurRadius);

  /// The amount the box should be inflated prior to applying the blur.
  final double spreadRadius;

  /// Create the [Paint] object that corresponds to this shadow description.
  ///
  /// The [offset] and [spreadRadius] are not represented in the [Paint] object.
  /// To honor those as well, the shape should be inflated by [spreadRadius] pixels
  /// in every direction and then translated by [offset] before being filled using
  /// this [Paint].
  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    assert(() {
      if (debugDisableShadows)
        result.maskFilter = null;
      return true;
    }());
    return result;
  }

  /// Returns a new box shadow with its offset, blurRadius, and spreadRadius scaled by the given factor.
  @override
  BoxShadow scale(double factor) {
    return BoxShadow(
      color: color,
      offset: offset * factor,
      blurRadius: blurRadius * factor,
      spreadRadius: spreadRadius * factor,
    );
  }

  /// Linearly interpolate between two box shadows.
  ///
  /// If either box shadow is null, this function linearly interpolates from a
  /// a box shadow that matches the other box shadow in color but has a zero
  /// offset and a zero blurRadius.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static BoxShadow lerp(BoxShadow a, BoxShadow b, double t) {
    assert(t != null);
    if (a == null && b == null)
      return null;
    if (a == null)
      return b.scale(t);
    if (b == null)
      return a.scale(1.0 - t);
    return BoxShadow(
      color: Color.lerp(a.color, b.color, t),
      offset: Offset.lerp(a.offset, b.offset, t),
      blurRadius: ui.lerpDouble(a.blurRadius, b.blurRadius, t),
      spreadRadius: ui.lerpDouble(a.spreadRadius, b.spreadRadius, t),
    );
  }

  /// Linearly interpolate between two lists of box shadows.
  ///
  /// If the lists differ in length, excess items are lerped with null.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static List<BoxShadow> lerpList(List<BoxShadow> a, List<BoxShadow> b, double t) {
    assert(t != null);
    if (a == null && b == null)
      return null;
    a ??= <BoxShadow>[];
    b ??= <BoxShadow>[];
    final List<BoxShadow> result = <BoxShadow>[];
    final int commonLength = math.min(a.length, b.length);
    for (int i = 0; i < commonLength; i += 1)
      result.add(BoxShadow.lerp(a[i], b[i], t));
    for (int i = commonLength; i < a.length; i += 1)
      result.add(a[i].scale(1.0 - t));
    for (int i = commonLength; i < b.length; i += 1)
      result.add(b[i].scale(t));
    return result;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other))
      return true;
    if (runtimeType != other.runtimeType)
      return false;
    final BoxShadow typedOther = other;
    return color == typedOther.color &&
           offset == typedOther.offset &&
           blurRadius == typedOther.blurRadius &&
           spreadRadius == typedOther.spreadRadius;
  }

  @override
  int get hashCode => hashValues(color, offset, blurRadius, spreadRadius);

  @override
  String toString() => 'BoxShadow($color, $offset, ${debugFormatDouble(blurRadius)}, ${debugFormatDouble(spreadRadius)})';
}
