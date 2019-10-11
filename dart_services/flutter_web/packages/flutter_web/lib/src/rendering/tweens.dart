// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/animation.dart';
import 'package:flutter_web/painting.dart';

/// An interpolation between two fractional offsets.
///
/// This class specializes the interpolation of [Tween<FractionalOffset>] to be
/// appropriate for fractional offsets.
///
/// See [Tween] for a discussion on how to use interpolation objects.
///
/// See also:
///
///  * [AlignmentTween], which interpolates between to [Alignment] objects.
class FractionalOffsetTween extends Tween<FractionalOffset> {
  /// Creates a fractional offset tween.
  ///
  /// The [begin] and [end] properties may be null; the null value
  /// is treated as meaning the center.
  FractionalOffsetTween({FractionalOffset begin, FractionalOffset end})
      : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  FractionalOffset lerp(double t) => FractionalOffset.lerp(begin, end, t);
}

/// An interpolation between two alignments.
///
/// This class specializes the interpolation of [Tween<Alignment>] to be
/// appropriate for alignments.
///
/// See [Tween] for a discussion on how to use interpolation objects.
///
/// See also:
///
///  * [AlignmentGeometryTween], which interpolates between two
///    [AlignmentGeometry] objects.
class AlignmentTween extends Tween<Alignment> {
  /// Creates a fractional offset tween.
  ///
  /// The [begin] and [end] properties may be null; the null value
  /// is treated as meaning the center.
  AlignmentTween({Alignment begin, Alignment end})
      : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  Alignment lerp(double t) => Alignment.lerp(begin, end, t);
}

/// An interpolation between two [AlignmentGeometry].
///
/// This class specializes the interpolation of [Tween<AlignmentGeometry>]
/// to be appropriate for alignments.
///
/// See [Tween] for a discussion on how to use interpolation objects.
///
/// See also:
///
///  * [AlignmentTween], which interpolates between two [Alignment] objects.
class AlignmentGeometryTween extends Tween<AlignmentGeometry> {
  /// Creates a fractional offset geometry tween.
  ///
  /// The [begin] and [end] properties may be null; the null value
  /// is treated as meaning the center.
  AlignmentGeometryTween({
    AlignmentGeometry begin,
    AlignmentGeometry end,
  }) : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  AlignmentGeometry lerp(double t) => AlignmentGeometry.lerp(begin, end, t);
}
