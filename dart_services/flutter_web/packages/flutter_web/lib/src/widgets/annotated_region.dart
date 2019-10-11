// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/rendering.dart';

import 'framework.dart';

/// Annotates a region of the layer tree with a value.
///
/// See also:
///
///   * [Layer.find], for an example of how this value is retrieved.
///   * [AnnotatedRegionLayer], the layer pushed into the layer tree.
class AnnotatedRegion<T> extends SingleChildRenderObjectWidget {
  /// Creates a new annotated region to insert [value] into the layer tree.
  ///
  /// Neither [child] nor [value] may be null.
  ///
  /// [sized] defaults to true and controls whether the annotated region will
  /// clip its child.
  const AnnotatedRegion({
    Key key,
    @required Widget child,
    @required this.value,
    this.sized = true,
  })  : assert(value != null),
        assert(child != null),
        super(key: key, child: child);

  /// A value which can be retrieved using [Layer.find].
  final T value;

  /// If false, the layer pushed into the tree will not be provided with a size.
  ///
  /// An [AnnotatedRegionLayer] with a size checks that the offset provided in
  /// [Layer.find] is within the bounds, returning null otherwise.
  ///
  /// See also:
  ///
  ///   * [AnnotatedRegionLayer], for a description of this behavior.
  final bool sized;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAnnotatedRegion<T>(value: value, sized: sized);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderAnnotatedRegion<T> renderObject) {
    renderObject
      ..value = value
      ..sized = sized;
  }
}
