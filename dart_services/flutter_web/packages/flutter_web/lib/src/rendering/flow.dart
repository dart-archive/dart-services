// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-05-30T14:20:56.492056.

import 'package:flutter_web/foundation.dart';

import 'package:vector_math/vector_math_64.dart';

import 'box.dart';
import 'object.dart';

/// A context in which a [FlowDelegate] paints.
///
/// Provides information about the current size of the container and the
/// children and a mechanism for painting children.
///
/// See also:
///
///  * [FlowDelegate]
///  * [Flow]
///  * [RenderFlow]
abstract class FlowPaintingContext {
  /// The size of the container in which the children can be painted.
  Size get size;

  /// The number of children available to paint.
  int get childCount;

  /// The size of the [i]th child.
  ///
  /// If [i] is negative or exceeds [childCount], returns null.
  Size getChildSize(int i);

  /// Paint the [i]th child using the given transform.
  ///
  /// The child will be painted in a coordinate system that concatenates the
  /// container's coordinate system with the given transform. The origin of the
  /// parent's coordinate system is the upper left corner of the parent, with
  /// x increasing rightward and y increasing downward.
  ///
  /// The container will clip the children to its bounds.
  void paintChild(int i, { Matrix4 transform, double opacity = 1.0 });
}

/// A delegate that controls the appearance of a flow layout.
///
/// Flow layouts are optimized for moving children around the screen using
/// transformation matrices. For optimal performance, construct the
/// [FlowDelegate] with an [Animation] that ticks whenever the delegate wishes
/// to change the transformation matrices for the children and avoid rebuilding
/// the [Flow] widget itself every animation frame.
///
/// See also:
///
///  * [Flow]
///  * [RenderFlow]
abstract class FlowDelegate {
  /// The flow will repaint whenever [repaint] notifies its listeners.
  const FlowDelegate({ Listenable repaint }) : _repaint = repaint;

  final Listenable _repaint;

  /// Override to control the size of the container for the children.
  ///
  /// By default, the flow will be as large as possible. If this function
  /// returns a size that does not respect the given constraints, the size will
  /// be adjusted to be as close to the returned size as possible while still
  /// respecting the constraints.
  ///
  /// If this function depends on information other than the given constraints,
  /// override [shouldRelayout] to indicate when when the container should
  /// relayout.
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  /// Override to control the layout constraints given to each child.
  ///
  /// By default, the children will receive the given constraints, which are the
  /// constraints used to size the container. The children need
  /// not respect the given constraints, but they are required to respect the
  /// returned constraints. For example, the incoming constraints might require
  /// the container to have a width of exactly 100.0 and a height of exactly
  /// 100.0, but this function might give the children looser constraints that
  /// let them be larger or smaller than 100.0 by 100.0.
  ///
  /// If this function depends on information other than the given constraints,
  /// override [shouldRelayout] to indicate when when the container should
  /// relayout.
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) => constraints;

  /// Override to paint the children of the flow.
  ///
  /// Children can be painted in any order, but each child can be painted at
  /// most once. Although the container clips the children to its own bounds, it
  /// is more efficient to skip painting a child altogether rather than having
  /// it paint entirely outside the container's clip.
  ///
  /// To paint a child, call [FlowPaintingContext.paintChild] on the given
  /// [FlowPaintingContext] (the `context` argument). The given context is valid
  /// only within the scope of this function call and contains information (such
  /// as the size of the container) that is useful for picking transformation
  /// matrices for the children.
  ///
  /// If this function depends on information other than the given context,
  /// override [shouldRepaint] to indicate when when the container should
  /// relayout.
  void paintChildren(FlowPaintingContext context);

  /// Override this method to return true when the children need to be laid out.
  /// This should compare the fields of the current delegate and the given
  /// oldDelegate and return true if the fields are such that the layout would
  /// be different.
  bool shouldRelayout(covariant FlowDelegate oldDelegate) => false;

  /// Override this method to return true when the children need to be
  /// repainted. This should compare the fields of the current delegate and the
  /// given oldDelegate and return true if the fields are such that
  /// paintChildren would act differently.
  ///
  /// The delegate can also trigger a repaint if the delegate provides the
  /// repaint animation argument to this object's constructor and that animation
  /// ticks. Triggering a repaint using this animation-based mechanism is more
  /// efficient than rebuilding the [Flow] widget to change its delegate.
  ///
  /// The flow container might repaint even if this function returns false, for
  /// example if layout triggers painting (e.g., if [shouldRelayout] returns
  /// true).
  bool shouldRepaint(covariant FlowDelegate oldDelegate);

  /// Override this method to include additional information in the
  /// debugging data printed by [debugDumpRenderTree] and friends.
  ///
  /// By default, returns the [runtimeType] of the class.
  @override
  String toString() => '$runtimeType';
}

int _getAlphaFromOpacity(double opacity) => (opacity * 255).round();

/// Parent data for use with [RenderFlow].
///
/// The [offset] property is ignored by [RenderFlow] and is always set to
/// [Offset.zero]. Children of a [RenderFlow] are positioned using a
/// transformation matrix, which is private to the [RenderFlow]. To set the
/// matrix, use the [FlowPaintingContext.paintChild] function from an override
/// of the [FlowDelegate.paintChildren] function.
class FlowParentData extends ContainerBoxParentData<RenderBox> {
  Matrix4 _transform;
}

/// Implements the flow layout algorithm.
///
/// Flow layouts are optimized for repositioning children using transformation
/// matrices.
///
/// The flow container is sized independently from the children by the
/// [FlowDelegate.getSize] function of the delegate. The children are then sized
/// independently given the constraints from the
/// [FlowDelegate.getConstraintsForChild] function.
///
/// Rather than positioning the children during layout, the children are
/// positioned using transformation matrices during the paint phase using the
/// matrices from the [FlowDelegate.paintChildren] function. The children can be
/// repositioned efficiently by simply repainting the flow.
///
/// The most efficient way to trigger a repaint of the flow is to supply a
/// repaint argument to the constructor of the [FlowDelegate]. The flow will
/// listen to this animation and repaint whenever the animation ticks, avoiding
/// both the build and layout phases of the pipeline.
///
/// See also:
///
///  * [FlowDelegate]
///  * [RenderStack]
class RenderFlow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, FlowParentData>,
         RenderBoxContainerDefaultsMixin<RenderBox, FlowParentData>
    implements FlowPaintingContext {
  /// Creates a render object for a flow layout.
  ///
  /// For optimal performance, consider using children that return true from
  /// [isRepaintBoundary].
  RenderFlow({
    List<RenderBox> children,
    @required FlowDelegate delegate,
  }) : assert(delegate != null),
       _delegate = delegate {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    final ParentData childParentData = child.parentData;
    if (childParentData is FlowParentData)
      childParentData._transform = null;
    else
      child.parentData = FlowParentData();
  }

  /// The delegate that controls the transformation matrices of the children.
  FlowDelegate get delegate => _delegate;
  FlowDelegate _delegate;
  /// When the delegate is changed to a new delegate with the same runtimeType
  /// as the old delegate, this object will call the delegate's
  /// [FlowDelegate.shouldRelayout] and [FlowDelegate.shouldRepaint] functions
  /// to determine whether the new delegate requires this object to update its
  /// layout or painting.
  set delegate(FlowDelegate newDelegate) {
    assert(newDelegate != null);
    if (_delegate == newDelegate)
      return;
    final FlowDelegate oldDelegate = _delegate;
    _delegate = newDelegate;

    if (newDelegate.runtimeType != oldDelegate.runtimeType || newDelegate.shouldRelayout(oldDelegate))
      markNeedsLayout();
    else if (newDelegate.shouldRepaint(oldDelegate))
      markNeedsPaint();

    if (attached) {
      oldDelegate._repaint?.removeListener(markNeedsPaint);
      newDelegate._repaint?.addListener(markNeedsPaint);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _delegate._repaint?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _delegate._repaint?.removeListener(markNeedsPaint);
    super.detach();
  }

  Size _getSize(BoxConstraints constraints) {
    assert(constraints.debugAssertIsValid());
    return constraints.constrain(_delegate.getSize(constraints));
  }

  @override
  bool get isRepaintBoundary => true;

  // TODO(ianh): It's a bit dubious to be using the getSize function from the delegate to
  // figure out the intrinsic dimensions. We really should either not support intrinsics,
  // or we should expose intrinsic delegate callbacks and throw if they're not implemented.

  @override
  double computeMinIntrinsicWidth(double height) {
    final double width = _getSize(BoxConstraints.tightForFinite(height: height)).width;
    if (width.isFinite)
      return width;
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final double width = _getSize(BoxConstraints.tightForFinite(height: height)).width;
    if (width.isFinite)
      return width;
    return 0.0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final double height = _getSize(BoxConstraints.tightForFinite(width: width)).height;
    if (height.isFinite)
      return height;
    return 0.0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final double height = _getSize(BoxConstraints.tightForFinite(width: width)).height;
    if (height.isFinite)
      return height;
    return 0.0;
  }

  @override
  void performLayout() {
    size = _getSize(constraints);
    int i = 0;
    _randomAccessChildren.clear();
    RenderBox child = firstChild;
    while (child != null) {
      _randomAccessChildren.add(child);
      final BoxConstraints innerConstraints = _delegate.getConstraintsForChild(i, constraints);
      child.layout(innerConstraints, parentUsesSize: true);
      final FlowParentData childParentData = child.parentData;
      childParentData.offset = Offset.zero;
      child = childParentData.nextSibling;
      i += 1;
    }
  }

  // Updated during layout. Only valid if layout is not dirty.
  final List<RenderBox> _randomAccessChildren = <RenderBox>[];

  // Updated during paint.
  final List<int> _lastPaintOrder = <int>[];

  // Only valid during paint.
  PaintingContext _paintingContext;
  Offset _paintingOffset;

  @override
  Size getChildSize(int i) {
    if (i < 0 || i >= _randomAccessChildren.length)
      return null;
    return _randomAccessChildren[i].size;
  }

  @override
  void paintChild(int i, { Matrix4 transform, double opacity = 1.0 }) {
    transform ??= Matrix4.identity();
    final RenderBox child = _randomAccessChildren[i];
    final FlowParentData childParentData = child.parentData;
    assert(() {
      if (childParentData._transform != null) {
        throw FlutterError(
          'Cannot call paintChild twice for the same child.\n'
          'The flow delegate of type ${_delegate.runtimeType} attempted to '
          'paint child $i multiple times, which is not permitted.'
        );
      }
      return true;
    }());
    _lastPaintOrder.add(i);
    childParentData._transform = transform;

    // We return after assigning _transform so that the transparent child can
    // still be hit tested at the correct location.
    if (opacity == 0.0)
      return;

    void painter(PaintingContext context, Offset offset) {
      context.paintChild(child, offset);
    }
    if (opacity == 1.0) {
      _paintingContext.pushTransform(needsCompositing, _paintingOffset, transform, painter);
    } else {
      _paintingContext.pushOpacity(_paintingOffset, _getAlphaFromOpacity(opacity), (PaintingContext context, Offset offset) {
        context.pushTransform(needsCompositing, offset, transform, painter);
      });
    }
  }

  void _paintWithDelegate(PaintingContext context, Offset offset) {
    _lastPaintOrder.clear();
    _paintingContext = context;
    _paintingOffset = offset;
    for (RenderBox child in _randomAccessChildren) {
      final FlowParentData childParentData = child.parentData;
      childParentData._transform = null;
    }
    try {
      _delegate.paintChildren(this);
    } finally {
      _paintingContext = null;
      _paintingOffset = null;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.pushClipRect(needsCompositing, offset, Offset.zero & size, _paintWithDelegate);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { Offset position }) {
    final List<RenderBox> children = getChildrenAsList();
    for (int i = _lastPaintOrder.length - 1; i >= 0; --i) {
      final int childIndex = _lastPaintOrder[i];
      if (childIndex >= children.length)
        continue;
      final RenderBox child = children[childIndex];
      final FlowParentData childParentData = child.parentData;
      final Matrix4 transform = childParentData._transform;
      if (transform == null)
        continue;
      final bool absorbed = result.addWithPaintTransform(
        transform: transform,
        position: position,
        hitTest: (BoxHitTestResult result, Offset position) {
          return child.hitTest(result, position: position);
        },
      );
      if (absorbed)
        return true;
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final FlowParentData childParentData = child.parentData;
    if (childParentData._transform != null)
      transform.multiply(childParentData._transform);
    super.applyPaintTransform(child, transform);
  }
}
