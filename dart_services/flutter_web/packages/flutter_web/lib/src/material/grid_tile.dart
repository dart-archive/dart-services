// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/widgets.dart';

/// A tile in a material design grid list.
///
/// A grid list is a [GridView] of tiles in a vertical and horizontal
/// array. Each tile typically contains some visually rich content (e.g., an
/// image) together with a [GridTileBar] in either a [header] or a [footer].
///
/// See also:
///
///  * [GridView], which is a scrollable grid of tiles.
///  * [GridTileBar], which is typically used in either the [header] or
///    [footer].
///  * <https://material.google.com/components/grid-lists.html>
class GridTile extends StatelessWidget {
  /// Creates a grid tile.
  ///
  /// Must have a child. Does not typically have both a header and a footer.
  const GridTile({
    Key key,
    this.header,
    this.footer,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  /// The widget to show over the top of this grid tile.
  ///
  /// Typically a [GridTileBar].
  final Widget header;

  /// The widget to show over the bottom of this grid tile.
  ///
  /// Typically a [GridTileBar].
  final Widget footer;

  /// The widget that fills the tile.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (header == null && footer == null) return child;

    final List<Widget> children = <Widget>[
      Positioned.fill(
        child: child,
      ),
    ];
    if (header != null) {
      children.add(Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        child: header,
      ));
    }
    if (footer != null) {
      children.add(Positioned(
        left: 0.0,
        bottom: 0.0,
        right: 0.0,
        child: footer,
      ));
    }
    return Stack(children: children);
  }
}
