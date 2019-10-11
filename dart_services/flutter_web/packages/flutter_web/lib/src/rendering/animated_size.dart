// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-05-31T15:14:36.731896.

import 'package:flutter_web/animation.dart';
import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/scheduler.dart';

import 'box.dart';
import 'object.dart';
import 'shifted_box.dart';

/// A [RenderAnimatedSize] can be in exactly one of these states.
@visibleForTesting
enum RenderAnimatedSizeState {
  /// The initial state, when we do not yet know what the starting and target
  /// sizes are to animate.
  ///
  /// The next state is [stable].
  start,

  /// At this state the child's size is assumed to be stable and we are either
  /// animating, or waiting for the child's size to change.
  ///
  /// If the child's size changes, the state will become [changed]. Otherwise,
  /// it remains [stable].
  stable,

  /// At this state we know that the child has changed once after being assumed
  /// [stable].
  ///
  /// The next state will be one of:
  ///
  /// * [stable] if the child's size stabilized immediately. This is a signal
  ///   for the render object to begin animating the size towards the child's new
  ///   size.
  ///
  /// * [unstable] if the child's size continues to change.
  changed,

  /// At this state the child's size is assumed to be unstable (changing each
  /// frame).
  ///
  /// Instead of chasing the child's size in this state, the render object
  /// tightly tracks the child's size until it stabilizes.
  ///
  /// The render object remains in this state until a frame where the child's
  /// size remains the same as the previous frame. At that time, the next state
  /// is [stable].
  unstable,
}

/// A render object that animates its size to its child's size over a given
/// [duration] and with a given [curve]. If the child's size itself animates
/// (i.e. if it changes size two frames in a row, as opposed to abruptly
/// changing size in one frame then remaining that size in subsequent frames),
/// this render object sizes itself to fit the child instead of animating
/// itself.
///
/// When the child overflows the current animated size of this render object, it
/// is clipped.
class RenderAnimatedSize extends RenderAligningShiftedBox {
  /// Creates a render object that animates its size to match its child.
  /// The [duration] and [curve] arguments define the animation.
  ///
  /// The [alignment] argument is used to align the child when the parent is not
  /// (yet) the same size as the child.
  ///
  /// The [duration] is required.
  ///
  /// The [vsync] should specify a [TickerProvider] for the animation
  /// controller.
  ///
  /// The arguments [duration], [curve], [alignment], and [vsync] must
  /// not be null.
  RenderAnimatedSize({
    @required TickerProvider vsync,
    @required Duration duration,
    Duration reverseDuration,
    Curve curve = Curves.linear,
    AlignmentGeometry alignment = Alignment.center,
    TextDirection textDirection,
    RenderBox child,
  }) : assert(vsync != null),
       assert(duration != null),
       assert(curve != null),
       _vsync = vsync,
       super(child: child, alignment: alignment, textDirection: textDirection) {
    _controller = AnimationController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
    )..addListener(() {
      if (_controller.value != _lastValue)
        markNeedsLayout();
    });
    _animation = CurvedAnimation(
      parent: _controller,
      curve: curve,
    );
  }

  AnimationController _controller;
  CurvedAnimation _animation;
  final SizeTween _sizeTween = SizeTween();
  bool _hasVisualOverflow;
  double _lastValue;

  /// The state this size animation is in.
  ///
  /// See [RenderAnimatedSizeState] for possible states.
  @visibleForTesting
  RenderAnimatedSizeState get state => _state;
  RenderAnimatedSizeState _state = RenderAnimatedSizeState.start;

  /// The duration of the animation.
  Duration get duration => _controller.duration;
  set duration(Duration value) {
    assert(value != null);
    if (value == _controller.duration)
      return;
    _controller.duration = value;
  }

  /// The duration of the animation when running in reverse.
  Duration get reverseDuration => _controller.reverseDuration;
  set reverseDuration(Duration value) {
    if (value == _controller.reverseDuration)
      return;
    _controller.reverseDuration = value;
  }

  /// The curve of the animation.
  Curve get curve => _animation.curve;
  set curve(Curve value) {
    assert(value != null);
    if (value == _animation.curve)
      return;
    _animation.curve = value;
  }

  /// Whether the size is being currently animated towards the child's size.
  ///
  /// See [RenderAnimatedSizeState] for situations when we may not be animating
  /// the size.
  bool get isAnimating => _controller.isAnimating;

  /// The [TickerProvider] for the [AnimationController] that runs the animation.
  TickerProvider get vsync => _vsync;
  TickerProvider _vsync;
  set vsync(TickerProvider value) {
    assert(value != null);
    if (value == _vsync)
      return;
    _vsync = value;
    _controller.resync(vsync);
  }

  @override
  void detach() {
    _controller.stop();
    super.detach();
  }

  Size get _animatedSize {
    return _sizeTween.evaluate(_animation);
  }

  @override
  void performLayout() {
    _lastValue = _controller.value;
    _hasVisualOverflow = false;

    if (child == null || constraints.isTight) {
      _controller.stop();
      size = _sizeTween.begin = _sizeTween.end = constraints.smallest;
      _state = RenderAnimatedSizeState.start;
      child?.layout(constraints);
      return;
    }

    child.layout(constraints, parentUsesSize: true);

    assert(_state != null);
    switch (_state) {
      case RenderAnimatedSizeState.start:
        _layoutStart();
        break;
      case RenderAnimatedSizeState.stable:
        _layoutStable();
        break;
      case RenderAnimatedSizeState.changed:
        _layoutChanged();
        break;
      case RenderAnimatedSizeState.unstable:
        _layoutUnstable();
        break;
    }

    size = constraints.constrain(_animatedSize);
    alignChild();

    if (size.width < _sizeTween.end.width ||
        size.height < _sizeTween.end.height)
      _hasVisualOverflow = true;
  }

  void _restartAnimation() {
    _lastValue = 0.0;
    _controller.forward(from: 0.0);
  }

  /// Laying out the child for the first time.
  ///
  /// We have the initial size to animate from, but we do not have the target
  /// size to animate to, so we set both ends to child's size.
  void _layoutStart() {
    _sizeTween.begin = _sizeTween.end = debugAdoptSize(child.size);
    _state = RenderAnimatedSizeState.stable;
  }

  /// At this state we're assuming the child size is stable and letting the
  /// animation run its course.
  ///
  /// If during animation the size of the child changes we restart the
  /// animation.
  void _layoutStable() {
    if (_sizeTween.end != child.size) {
      _sizeTween.begin = size;
      _sizeTween.end = debugAdoptSize(child.size);
      _restartAnimation();
      _state = RenderAnimatedSizeState.changed;
    } else if (_controller.value == _controller.upperBound) {
      // Animation finished. Reset target sizes.
      _sizeTween.begin = _sizeTween.end = debugAdoptSize(child.size);
    } else if (!_controller.isAnimating) {
      _controller.forward(); // resume the animation after being detached
    }
  }

  /// This state indicates that the size of the child changed once after being
  /// considered stable.
  ///
  /// If the child stabilizes immediately, we go back to stable state. If it
  /// changes again, we match the child's size, restart animation and go to
  /// unstable state.
  void _layoutChanged() {
    if (_sizeTween.end != child.size) {
      // Child size changed again. Match the child's size and restart animation.
      _sizeTween.begin = _sizeTween.end = debugAdoptSize(child.size);
      _restartAnimation();
      _state = RenderAnimatedSizeState.unstable;
    } else {
      // Child size stabilized.
      _state = RenderAnimatedSizeState.stable;
      if (!_controller.isAnimating)
        _controller.forward(); // resume the animation after being detached
    }
  }

  /// The child's size is not stable.
  ///
  /// Continue tracking the child's size until is stabilizes.
  void _layoutUnstable() {
    if (_sizeTween.end != child.size) {
      // Still unstable. Continue tracking the child.
      _sizeTween.begin = _sizeTween.end = debugAdoptSize(child.size);
      _restartAnimation();
    } else {
      // Child size stabilized.
      _controller.stop();
      _state = RenderAnimatedSizeState.stable;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && _hasVisualOverflow) {
      final Rect rect = Offset.zero & size;
      context.pushClipRect(needsCompositing, offset, rect, super.paint);
    } else {
      super.paint(context, offset);
    }
  }
}
