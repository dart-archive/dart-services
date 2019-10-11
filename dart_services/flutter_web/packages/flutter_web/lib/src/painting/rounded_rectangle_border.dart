// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'package:flutter_web_ui/ui.dart';
import 'package:flutter_web_ui/ui.dart' as ui;
import 'package:flutter_web/painting.dart';

import '../util.dart';
import 'borders.dart';
import 'border_radius.dart';
import 'circle_border.dart';

/// A rectangular border with rounded corners.
///
/// Typically used with [ShapeDecoration] to draw a box with a rounded
/// rectangle.
///
/// This shape can interpolate to and from [CircleBorder].
///
/// See also:
///
///  * [BorderSide], which is used to describe each side of the box.
///  * [Border], which, when used with [BoxDecoration], can also
///    describe a rounded rectangle.
class RoundedRectangleBorder extends ShapeBorder {
  /// Creates a rounded rectangle border.
  ///
  /// The arguments must not be null.
  const RoundedRectangleBorder({
    this.side = BorderSide.none,
    this.borderRadius = BorderRadius.zero,
  })  : assert(side != null),
        assert(borderRadius != null);

  /// The style of this border.
  final BorderSide side;

  /// The radii for each corner.
  final BorderRadiusGeometry borderRadius;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(side.width);
  }

  @override
  ShapeBorder scale(double t) {
    return RoundedRectangleBorder(
      side: side.scale(t),
      borderRadius: borderRadius * t,
    );
  }

  @override
  ShapeBorder lerpFrom(ShapeBorder a, double t) {
    assert(t != null);
    if (a is RoundedRectangleBorder) {
      return RoundedRectangleBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius:
            BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t),
      );
    }
    if (a is CircleBorder) {
      return _RoundedRectangleToCircleBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: borderRadius,
        circleness: 1.0 - t,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder lerpTo(ShapeBorder b, double t) {
    assert(t != null);
    if (b is RoundedRectangleBorder) {
      return RoundedRectangleBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius:
            BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t),
      );
    }
    if (b is CircleBorder) {
      return _RoundedRectangleToCircleBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: borderRadius,
        circleness: t,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..addRRect(borderRadius
          .resolve(textDirection)
          .toRRect(rect)
          .deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final double width = side.width;
        if (width == 0.0) {
          canvas.drawRRect(borderRadius.resolve(textDirection).toRRect(rect),
              side.toPaint());
        } else {
          final RRect outer = borderRadius.resolve(textDirection).toRRect(rect);
          final RRect inner = outer.deflate(width);
          final Paint paint = Paint()..color = side.color;
          canvas.drawDRRect(outer, inner, paint);
        }
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    final RoundedRectangleBorder typedOther = other;
    return side == typedOther.side && borderRadius == typedOther.borderRadius;
  }

  @override
  int get hashCode => hashValues(side, borderRadius);

  @override
  String toString() {
    return '$runtimeType($side, $borderRadius)';
  }
}

class _RoundedRectangleToCircleBorder extends ShapeBorder {
  const _RoundedRectangleToCircleBorder({
    this.side = BorderSide.none,
    this.borderRadius = BorderRadius.zero,
    @required this.circleness,
  })  : assert(side != null),
        assert(borderRadius != null),
        assert(circleness != null);

  final BorderSide side;

  final BorderRadiusGeometry borderRadius;

  final double circleness;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(side.width);
  }

  @override
  ShapeBorder scale(double t) {
    return _RoundedRectangleToCircleBorder(
      side: side.scale(t),
      borderRadius: borderRadius * t,
      circleness: t,
    );
  }

  @override
  ShapeBorder lerpFrom(ShapeBorder a, double t) {
    assert(t != null);
    if (a is RoundedRectangleBorder) {
      return _RoundedRectangleToCircleBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius:
            BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t),
        circleness: circleness * t,
      );
    }
    if (a is CircleBorder) {
      return _RoundedRectangleToCircleBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: borderRadius,
        circleness: circleness + (1.0 - circleness) * (1.0 - t),
      );
    }
    if (a is _RoundedRectangleToCircleBorder) {
      return _RoundedRectangleToCircleBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius:
            BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t),
        circleness: ui.lerpDouble(a.circleness, circleness, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder lerpTo(ShapeBorder b, double t) {
    if (b is RoundedRectangleBorder) {
      return _RoundedRectangleToCircleBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius:
            BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t),
        circleness: circleness * (1.0 - t),
      );
    }
    if (b is CircleBorder) {
      return _RoundedRectangleToCircleBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: borderRadius,
        circleness: circleness + (1.0 - circleness) * t,
      );
    }
    if (b is _RoundedRectangleToCircleBorder) {
      return _RoundedRectangleToCircleBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius:
            BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t),
        circleness: ui.lerpDouble(circleness, b.circleness, t),
      );
    }
    return super.lerpTo(b, t);
  }

  Rect _adjustRect(Rect rect) {
    if (circleness == 0.0 || rect.width == rect.height) return rect;
    if (rect.width < rect.height) {
      final double delta = circleness * (rect.height - rect.width) / 2.0;
      return Rect.fromLTRB(
        rect.left,
        rect.top + delta,
        rect.right,
        rect.bottom - delta,
      );
    } else {
      final double delta = circleness * (rect.width - rect.height) / 2.0;
      return Rect.fromLTRB(
        rect.left + delta,
        rect.top,
        rect.right - delta,
        rect.bottom,
      );
    }
  }

  BorderRadius _adjustBorderRadius(Rect rect, TextDirection textDirection) {
    final BorderRadius resolvedRadius = borderRadius.resolve(textDirection);
    if (circleness == 0.0) return resolvedRadius;
    return BorderRadius.lerp(resolvedRadius,
        BorderRadius.circular(rect.shortestSide / 2.0), circleness);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..addRRect(_adjustBorderRadius(rect, textDirection)
          .toRRect(_adjustRect(rect))
          .deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..addRRect(
          _adjustBorderRadius(rect, textDirection).toRRect(_adjustRect(rect)));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final double width = side.width;
        if (width == 0.0) {
          canvas.drawRRect(
              _adjustBorderRadius(rect, textDirection)
                  .toRRect(_adjustRect(rect)),
              side.toPaint());
        } else {
          final RRect outer = _adjustBorderRadius(rect, textDirection)
              .toRRect(_adjustRect(rect));
          final RRect inner = outer.deflate(width);
          final Paint paint = Paint()..color = side.color;
          canvas.drawDRRect(outer, inner, paint);
        }
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (runtimeType != other.runtimeType) return false;
    final _RoundedRectangleToCircleBorder typedOther = other;
    return side == typedOther.side &&
        borderRadius == typedOther.borderRadius &&
        circleness == typedOther.circleness;
  }

  @override
  int get hashCode => hashValues(side, borderRadius, circleness);

  @override
  String toString() {
    if (assertionsEnabled) {
      return 'RoundedRectangleBorder($side, $borderRadius, ${(circleness * 100).toStringAsFixed(1)}% of the way to being a CircleBorder)';
    } else {
      return super.toString();
    }
  }
}
