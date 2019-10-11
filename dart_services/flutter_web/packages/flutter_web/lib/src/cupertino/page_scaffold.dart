// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-08-12T13:26:26.223829.

import 'package:flutter_web/widgets.dart';

import 'theme.dart';

/// Implements a single iOS application page's layout.
///
/// The scaffold lays out the navigation bar on top and the content between or
/// behind the navigation bar.
///
/// See also:
///
///  * [CupertinoTabScaffold], a similar widget for tabbed applications.
///  * [CupertinoPageRoute], a modal page route that typically hosts a
///    [CupertinoPageScaffold] with support for iOS-style page transitions.
class CupertinoPageScaffold extends StatefulWidget {
  /// Creates a layout for pages with a navigation bar at the top.
  const CupertinoPageScaffold({
    Key key,
    this.navigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    @required this.child,
  }) : assert(child != null),
       assert(resizeToAvoidBottomInset != null),
       super(key: key);

  /// The [navigationBar], typically a [CupertinoNavigationBar], is drawn at the
  /// top of the screen.
  ///
  /// If translucent, the main content may slide behind it.
  /// Otherwise, the main content's top margin will be offset by its height.
  ///
  /// The scaffold assumes the navigation bar will account for the [MediaQuery] top padding,
  /// also consume it if the navigation bar is opaque.
  // TODO(xster): document its page transition animation when ready
  final ObstructingPreferredSizeWidget navigationBar;

  /// Widget to show in the main content area.
  ///
  /// Content can slide under the [navigationBar] when they're translucent.
  /// In that case, the child's [BuildContext]'s [MediaQuery] will have a
  /// top padding indicating the area of obstructing overlap from the
  /// [navigationBar].
  final Widget child;

  /// The color of the widget that underlies the entire scaffold.
  ///
  /// By default uses [CupertinoTheme]'s `scaffoldBackgroundColor` when null.
  final Color backgroundColor;

  /// Whether the [child] should size itself to avoid the window's bottom inset.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// scaffold, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true and cannot be null.
  final bool resizeToAvoidBottomInset;

  @override
  _CupertinoPageScaffoldState createState() => _CupertinoPageScaffoldState();
}

class _CupertinoPageScaffoldState extends State<CupertinoPageScaffold> {
  final ScrollController _primaryScrollController = ScrollController();

  void _handleStatusBarTap() {
    // Only act on the scroll controller if it has any attached scroll positions.
    if (_primaryScrollController.hasClients) {
      _primaryScrollController.animateTo(
        0.0,
        // Eyeballed from iOS.
        duration: const Duration(milliseconds: 500),
        curve: Curves.linearToEaseOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> stacked = <Widget>[];

    Widget paddedContent = widget.child;

    final MediaQueryData existingMediaQuery = MediaQuery.of(context);
    if (widget.navigationBar != null) {
      // TODO(xster): Use real size after partial layout instead of preferred size.
      // https://github.com/flutter/flutter/issues/12912
      final double topPadding =
          widget.navigationBar.preferredSize.height + existingMediaQuery.padding.top;

      // Propagate bottom padding and include viewInsets if appropriate
      final double bottomPadding = widget.resizeToAvoidBottomInset
          ? existingMediaQuery.viewInsets.bottom
          : 0.0;

      final EdgeInsets newViewInsets = widget.resizeToAvoidBottomInset
          // The insets are consumed by the scaffolds and no longer exposed to
          // the descendant subtree.
          ? existingMediaQuery.viewInsets.copyWith(bottom: 0.0)
          : existingMediaQuery.viewInsets;

      final bool fullObstruction =
        widget.navigationBar.fullObstruction ?? CupertinoTheme.of(context).barBackgroundColor.alpha == 0xFF;

      // If navigation bar is opaquely obstructing, directly shift the main content
      // down. If translucent, let main content draw behind navigation bar but hint the
      // obstructed area.
      if (fullObstruction) {
        paddedContent = MediaQuery(
          data: existingMediaQuery
          // If the navigation bar is opaque, the top media query padding is fully consumed by the navigation bar.
          .removePadding(removeTop: true)
          .copyWith(
            viewInsets: newViewInsets,
          ),
          child: Padding(
            padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
            child: paddedContent,
          ),
        );
      } else {
        paddedContent = MediaQuery(
          data: existingMediaQuery.copyWith(
            padding: existingMediaQuery.padding.copyWith(
              top: topPadding,
            ),
            viewInsets: newViewInsets,
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: paddedContent,
          ),
        );
      }
    }

    // The main content being at the bottom is added to the stack first.
    stacked.add(PrimaryScrollController(
      controller: _primaryScrollController,
      child: paddedContent,
    ));

    if (widget.navigationBar != null) {
      stacked.add(Positioned(
        top: 0.0,
        left: 0.0,
        right: 0.0,
        child: widget.navigationBar,
      ));
    }

    // Add a touch handler the size of the status bar on top of all contents
    // to handle scroll to top by status bar taps.
    stacked.add(Positioned(
      top: 0.0,
      left: 0.0,
      right: 0.0,
      height: existingMediaQuery.padding.top,
      child: GestureDetector(
          excludeFromSemantics: true,
          onTap: _handleStatusBarTap,
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? CupertinoTheme.of(context).scaffoldBackgroundColor,
      ),
      child: Stack(
        children: stacked,
      ),
    );
  }
}

/// Widget that has a preferred size and reports whether it fully obstructs
/// widgets behind it.
///
/// Used by [CupertinoPageScaffold] to either shift away fully obstructed content
/// or provide a padding guide to partially obstructed content.
abstract class ObstructingPreferredSizeWidget extends PreferredSizeWidget {
  /// If true, this widget fully obstructs widgets behind it by the specified
  /// size.
  ///
  /// If false, this widget partially obstructs.
  bool get fullObstruction;
}
