// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-05-30T14:20:56.783382.

import 'dart:math' as math;

import 'package:flutter_web/gestures.dart' show DragStartBehavior;
import 'package:flutter_web/rendering.dart';

import 'basic.dart';
import 'framework.dart';
import 'primary_scroll_controller.dart';
import 'scroll_controller.dart';
import 'scroll_physics.dart';
import 'scrollable.dart';

/// A box in which a single widget can be scrolled.
///
/// This widget is useful when you have a single box that will normally be
/// entirely visible, for example a clock face in a time picker, but you need to
/// make sure it can be scrolled if the container gets too small in one axis
/// (the scroll direction).
///
/// It is also useful if you need to shrink-wrap in both axes (the main
/// scrolling direction as well as the cross axis), as one might see in a dialog
/// or pop-up menu. In that case, you might pair the [SingleChildScrollView]
/// with a [ListBody] child.
///
/// When you have a list of children and do not require cross-axis
/// shrink-wrapping behavior, for example a scrolling list that is always the
/// width of the screen, consider [ListView], which is vastly more efficient
/// that a [SingleChildScrollView] containing a [ListBody] or [Column] with
/// many children.
///
/// ## Sample code: Using [SingleChildScrollView] with a [Column]
///
/// Sometimes a layout is designed around the flexible properties of a
/// [Column], but there is the concern that in some cases, there might not
/// be enough room to see the entire contents. This could be because some
/// devices have unusually small screens, or because the application can
/// be used in landscape mode where the aspect ratio isn't what was
/// originally envisioned, or because the application is being shown in a
/// small window in split-screen mode. In any case, as a result, it might
/// make sense to wrap the layout in a [SingleChildScrollView].
///
/// Simply doing so, however, usually results in a conflict between the [Column],
/// which typically tries to grow as big as it can, and the [SingleChildScrollView],
/// which provides its children with an infinite amount of space.
///
/// To resolve this apparent conflict, there are a couple of techniques, as
/// discussed below. These techniques should only be used when the content is
/// normally expected to fit on the screen, so that the lazy instantiation of
/// a sliver-based [ListView] or [CustomScrollView] is not expected to provide
/// any performance benefit. If the viewport is expected to usually contain
/// content beyond the dimensions of the screen, then [SingleChildScrollView]
/// would be very expensive.
///
/// ### Centering, spacing, or aligning fixed-height content
///
/// If the content has fixed (or intrinsic) dimensions but needs to be spaced out,
/// centered, or otherwise positioned using the [Flex] layout model of a [Column],
/// the following technique can be used to provide the [Column] with a minimum
/// dimension while allowing it to shrink-wrap the contents when there isn't enough
/// room to apply these spacing or alignment needs.
///
/// A [LayoutBuilder] is used to obtain the size of the viewport (implicitly via
/// the constraints that the [SingleChildScrollView] sees, since viewports
/// typically grow to fit their maximum height constraint). Then, inside the
/// scroll view, a [ConstrainedBox] is used to set the minimum height of the
/// [Column].
///
/// The [Column] has no [Expanded] children, so rather than take on the infinite
/// height from its [BoxConstraints.maxHeight], (the viewport provides no maximum height
/// constraint), it automatically tries to shrink to fit its children. It cannot
/// be smaller than its [BoxConstraints.minHeight], though, and It therefore
/// becomes the bigger of the minimum height provided by the
/// [ConstrainedBox] and the sum of the heights of the children.
///
/// If the children aren't enough to fit that minimum size, the [Column] ends up
/// with some remaining space to allocate as specified by its
/// [Column.mainAxisAlignment] argument.
///
/// {@tool snippet --template=stateless_widget}
/// In this example, the children are spaced out equally, unless there's no more
/// room, in which case they stack vertically and scroll.
///
/// When using this technique, [Expanded] and [Flexible] are not useful, because
/// in both cases the "available space" is infinite (since this is in a viewport).
/// The next section describes a technique for providing a maximum height constraint.
///
/// ```dart
/// Widget build(BuildContext context) {
///   return LayoutBuilder(
///     builder: (BuildContext context, BoxConstraints viewportConstraints) {
///       return SingleChildScrollView(
///         child: ConstrainedBox(
///           constraints: BoxConstraints(
///             minHeight: viewportConstraints.maxHeight,
///           ),
///           child: Column(
///             mainAxisSize: MainAxisSize.min,
///             mainAxisAlignment: MainAxisAlignment.spaceAround,
///             children: <Widget>[
///               Container(
///                 // A fixed-height child.
///                 color: const Color(0xff808000), // Yellow
///                 height: 120.0,
///               ),
///               Container(
///                 // Another fixed-height child.
///                 color: const Color(0xff008000), // Green
///                 height: 120.0,
///               ),
///             ],
///           ),
///         ),
///       );
///     },
///   );
/// }
/// ```
/// {@end-tool}
///
/// ### Expanding content to fit the viewport
///
/// The following example builds on the previous one. In addition to providing a
/// minimum dimension for the child [Column], an [IntrinsicHeight] widget is used
/// to force the column to be exactly as big as its contents. This constraint
/// combines with the [ConstrainedBox] constraints discussed previously to ensure
/// that the column becomes either as big as viewport, or as big as the contents,
/// whichever is biggest.
///
/// Both constraints must be used to get the desired effect. If only the
/// [IntrinsicHeight] was specified, then the column would not grow to fit the
/// entire viewport when its children were smaller than the whole screen. If only
/// the size of the viewport was used, then the [Column] would overflow if the
/// children were bigger than the viewport.
///
/// The widget that is to grow to fit the remaining space so provided is wrapped
/// in an [Expanded] widget.
///
/// This technique is quite expensive, as it more or less requires that the contents
/// of the viewport be laid out twice (once to find their intrinsic dimensions, and
/// once to actually lay them out). The number of widgets within the column should
/// therefore be kept small. Alternatively, subsets of the children that have known
/// dimensions can be wrapped in a [SizedBox] that has tight vertical constraints,
/// so that the intrinsic sizing algorithm can short-circuit the computation when it
/// reaches those parts of the subtree.
///
/// {@tool snippet --template=stateless_widget}
/// In this example, the column becomes either as big as viewport, or as big as
/// the contents, whichever is biggest.
///
/// ```dart
/// Widget build(BuildContext context) {
///   return LayoutBuilder(
///     builder: (BuildContext context, BoxConstraints viewportConstraints) {
///       return SingleChildScrollView(
///         child: ConstrainedBox(
///           constraints: BoxConstraints(
///             minHeight: viewportConstraints.maxHeight,
///           ),
///           child: IntrinsicHeight(
///             child: Column(
///               children: <Widget>[
///                 Container(
///                   // A fixed-height child.
///                   color: const Color(0xff808000), // Yellow
///                   height: 120.0,
///                 ),
///                 Expanded(
///                   // A flexible child that will grow to fit the viewport but
///                   // still be at least as big as necessary to fit its contents.
///                   child: Container(
///                     color: const Color(0xff800000), // Red
///                     height: 120.0,
///                   ),
///                 ),
///               ],
///             ),
///           ),
///         ),
///       );
///     },
///   );
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [ListView], which handles multiple children in a scrolling list.
///  * [GridView], which handles multiple children in a scrolling grid.
///  * [PageView], for a scrollable that works page by page.
///  * [Scrollable], which handles arbitrary scrolling effects.
class SingleChildScrollView extends StatelessWidget {
  /// Creates a box in which a single widget can be scrolled.
  const SingleChildScrollView({
    Key key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    bool primary,
    this.physics,
    this.controller,
    this.child,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : assert(scrollDirection != null),
       assert(dragStartBehavior != null),
       assert(!(controller != null && primary == true),
          'Primary ScrollViews obtain their ScrollController via inheritance from a PrimaryScrollController widget. '
          'You cannot both set primary to true and pass an explicit controller.'
       ),
       primary = primary ?? controller == null && identical(scrollDirection, Axis.vertical),
       super(key: key);

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// The amount of space by which to inset the child.
  final EdgeInsetsGeometry padding;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is vertical and [controller] is
  /// not specified.
  final bool primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  /// The widget that scrolls.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  AxisDirection _getDirection(BuildContext context) {
    return getAxisDirectionFromAxisReverseAndDirectionality(context, scrollDirection, reverse);
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    Widget contents = child;
    if (padding != null)
      contents = Padding(padding: padding, child: contents);
    final ScrollController scrollController = primary
        ? PrimaryScrollController.of(context)
        : controller;
    final Scrollable scrollable = Scrollable(
      dragStartBehavior: dragStartBehavior,
      axisDirection: axisDirection,
      controller: scrollController,
      physics: physics,
      viewportBuilder: (BuildContext context, ViewportOffset offset) {
        return _SingleChildViewport(
          axisDirection: axisDirection,
          offset: offset,
          child: contents,
        );
      },
    );
    return primary && scrollController != null
      ? PrimaryScrollController.none(child: scrollable)
      : scrollable;
  }
}

class _SingleChildViewport extends SingleChildRenderObjectWidget {
  const _SingleChildViewport({
    Key key,
    this.axisDirection = AxisDirection.down,
    this.offset,
    Widget child,
  }) : assert(axisDirection != null),
       super(key: key, child: child);

  final AxisDirection axisDirection;
  final ViewportOffset offset;

  @override
  _RenderSingleChildViewport createRenderObject(BuildContext context) {
    return _RenderSingleChildViewport(
      axisDirection: axisDirection,
      offset: offset,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderSingleChildViewport renderObject) {
    // Order dependency: The offset setter reads the axis direction.
    renderObject
      ..axisDirection = axisDirection
      ..offset = offset;
  }
}

class _RenderSingleChildViewport extends RenderBox with RenderObjectWithChildMixin<RenderBox> implements RenderAbstractViewport {
  _RenderSingleChildViewport({
    AxisDirection axisDirection = AxisDirection.down,
    @required ViewportOffset offset,
    double cacheExtent = RenderAbstractViewport.defaultCacheExtent,
    RenderBox child,
  }) : assert(axisDirection != null),
       assert(offset != null),
       assert(cacheExtent != null),
       _axisDirection = axisDirection,
       _offset = offset,
       _cacheExtent = cacheExtent {
    this.child = child;
  }

  AxisDirection get axisDirection => _axisDirection;
  AxisDirection _axisDirection;
  set axisDirection(AxisDirection value) {
    assert(value != null);
    if (value == _axisDirection)
      return;
    _axisDirection = value;
    markNeedsLayout();
  }

  Axis get axis => axisDirectionToAxis(axisDirection);

  ViewportOffset get offset => _offset;
  ViewportOffset _offset;
  set offset(ViewportOffset value) {
    assert(value != null);
    if (value == _offset)
      return;
    if (attached)
      _offset.removeListener(_hasScrolled);
    _offset = value;
    if (attached)
      _offset.addListener(_hasScrolled);
    markNeedsLayout();
  }

  /// {@macro flutter.rendering.viewport.cacheExtent}
  double get cacheExtent => _cacheExtent;
  double _cacheExtent;
  set cacheExtent(double value) {
    assert(value != null);
    if (value == _cacheExtent)
      return;
    _cacheExtent = value;
    markNeedsLayout();
  }

  void _hasScrolled() {
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void setupParentData(RenderObject child) {
    // We don't actually use the offset argument in BoxParentData, so let's
    // avoid allocating it at all.
    if (child.parentData is! ParentData)
      child.parentData = ParentData();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(_hasScrolled);
  }

  @override
  void detach() {
    _offset.removeListener(_hasScrolled);
    super.detach();
  }

  @override
  bool get isRepaintBoundary => true;

  double get _viewportExtent {
    assert(hasSize);
    switch (axis) {
      case Axis.horizontal:
        return size.width;
      case Axis.vertical:
        return size.height;
    }
    return null;
  }

  double get _minScrollExtent {
    assert(hasSize);
    return 0.0;
  }

  double get _maxScrollExtent {
    assert(hasSize);
    if (child == null)
      return 0.0;
    switch (axis) {
      case Axis.horizontal:
        return math.max(0.0, child.size.width - size.width);
      case Axis.vertical:
        return math.max(0.0, child.size.height - size.height);
    }
    return null;
  }

  BoxConstraints _getInnerConstraints(BoxConstraints constraints) {
    switch (axis) {
      case Axis.horizontal:
        return constraints.heightConstraints();
      case Axis.vertical:
        return constraints.widthConstraints();
    }
    return null;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (child != null)
      return child.getMinIntrinsicWidth(height);
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (child != null)
      return child.getMaxIntrinsicWidth(height);
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (child != null)
      return child.getMinIntrinsicHeight(width);
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (child != null)
      return child.getMaxIntrinsicHeight(width);
    return 0.0;
  }

  // We don't override computeDistanceToActualBaseline(), because we
  // want the default behavior (returning null). Otherwise, as you
  // scroll, it would shift in its parent if the parent was baseline-aligned,
  // which makes no sense.

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
    } else {
      child.layout(_getInnerConstraints(constraints), parentUsesSize: true);
      size = constraints.constrain(child.size);
    }

    offset.applyViewportDimension(_viewportExtent);
    offset.applyContentDimensions(_minScrollExtent, _maxScrollExtent);
  }

  Offset get _paintOffset => _paintOffsetForPosition(offset.pixels);

  Offset _paintOffsetForPosition(double position) {
    assert(axisDirection != null);
    switch (axisDirection) {
      case AxisDirection.up:
        return Offset(0.0, position - child.size.height + size.height);
      case AxisDirection.down:
        return Offset(0.0, -position);
      case AxisDirection.left:
        return Offset(position - child.size.width + size.width, 0.0);
      case AxisDirection.right:
        return Offset(-position, 0.0);
    }
    return null;
  }

  bool _shouldClipAtPaintOffset(Offset paintOffset) {
    assert(child != null);
    return paintOffset < Offset.zero || !(Offset.zero & size).contains((paintOffset & child.size).bottomRight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final Offset paintOffset = _paintOffset;

      void paintContents(PaintingContext context, Offset offset) {
        context.paintChild(child, offset + paintOffset);
      }

      if (_shouldClipAtPaintOffset(paintOffset)) {
        context.pushClipRect(needsCompositing, offset, Offset.zero & size, paintContents);
      } else {
        paintContents(context, offset);
      }
    }
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final Offset paintOffset = _paintOffset;
    transform.translate(paintOffset.dx, paintOffset.dy);
  }

  @override
  Rect describeApproximatePaintClip(RenderObject child) {
    if (child != null && _shouldClipAtPaintOffset(_paintOffset))
      return Offset.zero & size;
    return null;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { Offset position }) {
    if (child != null) {
      return result.addWithPaintOffset(
        offset: _paintOffset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position + -_paintOffset);
          return child.hitTest(result, position: transformed);
        },
      );
    }
    return false;
  }

  @override
  RevealedOffset getOffsetToReveal(RenderObject target, double alignment, { Rect rect }) {
    rect ??= target.paintBounds;
    if (target is! RenderBox)
      return RevealedOffset(offset: offset.pixels, rect: rect);

    final RenderBox targetBox = target;
    final Matrix4 transform = targetBox.getTransformTo(this);
    final Rect bounds = MatrixUtils.transformRect(transform, rect);
    final Size contentSize = child.size;

    double leadingScrollOffset;
    double targetMainAxisExtent;
    double mainAxisExtent;

    assert(axisDirection != null);
    switch (axisDirection) {
      case AxisDirection.up:
        mainAxisExtent = size.height;
        leadingScrollOffset = contentSize.height - bounds.bottom;
        targetMainAxisExtent = bounds.height;
        break;
      case AxisDirection.right:
        mainAxisExtent = size.width;
        leadingScrollOffset = bounds.left;
        targetMainAxisExtent = bounds.width;
        break;
      case AxisDirection.down:
        mainAxisExtent = size.height;
        leadingScrollOffset = bounds.top;
        targetMainAxisExtent = bounds.height;
        break;
      case AxisDirection.left:
        mainAxisExtent = size.width;
        leadingScrollOffset = contentSize.width - bounds.right;
        targetMainAxisExtent = bounds.width;
        break;
    }

    final double targetOffset = leadingScrollOffset - (mainAxisExtent - targetMainAxisExtent) * alignment;
    final Rect targetRect = bounds.shift(_paintOffsetForPosition(targetOffset));
    return RevealedOffset(offset: targetOffset, rect: targetRect);
  }

  @override
  void showOnScreen({
    RenderObject descendant,
    Rect rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    if (!offset.allowImplicitScrolling) {
      return super.showOnScreen(
        descendant: descendant,
        rect: rect,
        duration: duration,
        curve: curve,
      );
    }

    final Rect newRect = RenderViewportBase.showInViewport(
      descendant: descendant,
      viewport: this,
      offset: offset,
      rect: rect,
      duration: duration,
      curve: curve,
    );
    super.showOnScreen(
      rect: newRect,
      duration: duration,
      curve: curve,
    );
  }

  @override
  Rect describeSemanticsClip(RenderObject child) {
    assert(axis != null);
    switch (axis) {
      case Axis.vertical:
        return Rect.fromLTRB(
          semanticBounds.left,
          semanticBounds.top - cacheExtent,
          semanticBounds.right,
          semanticBounds.bottom + cacheExtent,
        );
      case Axis.horizontal:
        return Rect.fromLTRB(
          semanticBounds.left - cacheExtent,
          semanticBounds.top,
          semanticBounds.right + cacheExtent,
          semanticBounds.bottom,
        );
    }
    return null;
  }
}
