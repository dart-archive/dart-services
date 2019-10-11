// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/painting.dart';

import 'object.dart';

export 'package:flutter_web/foundation.dart' show debugPrint;

// Any changes to this file should be reflected in the debugAssertAllRenderVarsUnset()
// function below.

const HSVColor _kDebugDefaultRepaintColor = HSVColor.fromAHSV(0.4, 60.0, 1.0, 1.0);

/// Causes each RenderBox to paint a box around its bounds, and some extra
/// boxes, such as [RenderPadding], to draw construction lines.
///
/// The edges of the boxes are painted as a one-pixel-thick `const Color(0xFF00FFFF)` outline.
///
/// Spacing is painted as a solid `const Color(0x90909090)` area.
///
/// Padding is filled in solid `const Color(0x900090FF)`, with the inner edge
/// outlined in `const Color(0xFF0090FF)`, using [debugPaintPadding].
bool debugPaintSizeEnabled = false;

/// Causes each RenderBox to paint a line at each of its baselines.
bool debugPaintBaselinesEnabled = false;

/// Causes each Layer to paint a box around its bounds.
bool debugPaintLayerBordersEnabled = false;

/// Causes objects like [RenderPointerListener] to flash while they are being
/// tapped. This can be useful to see how large the hit box is, e.g. when
/// debugging buttons that are harder to hit than expected.
///
/// For details on how to support this in your [RenderBox] subclass, see
/// [RenderBox.debugHandleEvent].
bool debugPaintPointersEnabled = false;

/// Overlay a rotating set of colors when repainting layers in checked mode.
///
/// See also:
///
///  * [RepaintBoundary], which can be used to contain repaints when unchanged
///    areas are being excessively repainted.
bool debugRepaintRainbowEnabled = false;

/// Overlay a rotating set of colors when repainting text in checked mode.
bool debugRepaintTextRainbowEnabled = false;

/// Causes [PhysicalModelLayer]s to paint a red rectangle around themselves if
/// they are overlapping and painted out of order with regard to their elevation.
///
/// Android and iOS will show the last painted layer on top, whereas Fuchsia
/// will show the layer with the highest elevation on top.
///
/// For example, a rectangular elevation at 3.0 that is painted before an
/// overlapping rectangular elevation at 2.0 would render this way on Android
/// and iOS (with fake shadows):
/// ```
/// ┌───────────────────┐
/// │                   │
/// │      3.0          │
/// │            ┌───────────────────┐
/// │            │                   │
/// └────────────│                   │
///              │        2.0        │
///              │                   │
///              └───────────────────┘
/// ```
///
/// But this way on Fuchsia (with real shadows):
/// ```
/// ┌───────────────────┐
/// │                   │
/// │      3.0          │
/// │                   │────────────┐
/// │                   │            │
/// └───────────────────┘            │
///              │         2.0       │
///              │                   │
///              └───────────────────┘
/// ```
///
/// This check helps developers that want a consistent look and feel detect
/// where this inconsistency would occur.
bool debugCheckElevationsEnabled = false;

/// The current color to overlay when repainting a layer.
///
/// This is used by painting debug code that implements
/// [debugRepaintRainbowEnabled] or [debugRepaintTextRainbowEnabled].
///
/// The value is incremented by [RenderView.compositeFrame] if either of those
/// flags is enabled.
HSVColor debugCurrentRepaintColor = _kDebugDefaultRepaintColor;

/// Log the call stacks that mark render objects as needing layout.
///
/// For sanity, this only logs the stack traces of cases where an object is
/// added to the list of nodes needing layout. This avoids printing multiple
/// redundant stack traces as a single [RenderObject.markNeedsLayout] call walks
/// up the tree.
bool debugPrintMarkNeedsLayoutStacks = false;

/// Log the call stacks that mark render objects as needing paint.
bool debugPrintMarkNeedsPaintStacks = false;

/// Log the dirty render objects that are laid out each frame.
///
/// Combined with [debugPrintBeginFrameBanner], this allows you to distinguish
/// layouts triggered by the initial mounting of a render tree (e.g. in a call
/// to [runApp]) from the regular layouts triggered by the pipeline.
///
/// Combined with [debugPrintMarkNeedsLayoutStacks], this lets you watch a
/// render object's dirty/clean lifecycle.
///
/// See also:
///
///  * [debugProfilePaintsEnabled], which does something similar for
///    painting but using the timeline view.
///  * [debugPrintRebuildDirtyWidgets], which does something similar for widgets
///    being rebuilt.
///  * The discussion at [RendererBinding.drawFrame].
bool debugPrintLayouts = false;

/// Check the intrinsic sizes of each [RenderBox] during layout.
///
/// By default this is turned off since these checks are expensive, but it is
/// enabled by the test framework.
bool debugCheckIntrinsicSizes = false;

/// Adds [dart:developer.Timeline] events for every [RenderObject] painted.
///
/// This is only enabled in debug builds. The timing information this exposes is
/// not representative of actual paints. However, it can expose unexpected
/// painting in the timeline.
///
/// For details on how to use [dart:developer.Timeline] events in the Dart
/// Observatory to optimize your app, see:
/// <https://fuchsia.googlesource.com/topaz/+/master/shell/docs/performance.md>
///
/// See also:
///
///  * [debugPrintLayouts], which does something similar for layout but using
///    console output.
///  * [debugProfileBuildsEnabled], which does something similar for widgets
///    being rebuilt, and [debugPrintRebuildDirtyWidgets], its console
///    equivalent.
///  * The discussion at [RendererBinding.drawFrame].
///  * [RepaintBoundary], which can be used to contain repaints when unchanged
///    areas are being excessively repainted.
bool debugProfilePaintsEnabled = false;

/// Signature for [debugOnProfilePaint] implementations.
typedef ProfilePaintCallback = void Function(RenderObject renderObject);

/// Callback invoked for every [RenderObject] painted each frame.
///
/// This callback is only invoked in debug builds.
///
/// See also:
///
///  * [debugProfilePaintsEnabled], which does something similar but adds
///    [dart:developer.Timeline] events instead of invoking a callback.
///  * [debugOnRebuildDirtyWidget], which does something similar for widgets
///    being built.
///  * [WidgetInspectorService], which uses the [debugOnProfilePaint]
///    callback to generate aggregate profile statistics describing what paints
///    occurred when the `ext.flutter.inspector.trackRepaintWidgets` service
///    extension is enabled.
ProfilePaintCallback debugOnProfilePaint;

/// Setting to true will cause all clipping effects from the layer tree to be
/// ignored.
///
/// Can be used to debug whether objects being clipped are painting excessively
/// in clipped areas. Can also be used to check whether excessive use of
/// clipping is affecting performance.
///
/// This will not reduce the number of [Layer] objects created; the compositing
/// strategy is unaffected. It merely causes the clipping layers to be skipped
/// when building the scene.
bool debugDisableClipLayers = false;

/// Setting to true will cause all physical modeling effects from the layer
/// tree, such as shadows from elevations, to be ignored.
///
/// Can be used to check whether excessive use of physical models is affecting
/// performance.
///
/// This will not reduce the number of [Layer] objects created; the compositing
/// strategy is unaffected. It merely causes the physical shape layers to be
/// skipped when building the scene.
bool debugDisablePhysicalShapeLayers = false;

/// Setting to true will cause all opacity effects from the layer tree to be
/// ignored.
///
/// An optimization to not paint the child at all when opacity is 0 will still
/// remain.
///
/// Can be used to check whether excessive use of opacity effects is affecting
/// performance.
///
/// This will not reduce the number of [Layer] objects created; the compositing
/// strategy is unaffected. It merely causes the opacity layers to be skipped
/// when building the scene.
bool debugDisableOpacityLayers = false;

void _debugDrawDoubleRect(Canvas canvas, Rect outerRect, Rect innerRect, Color color) {
  final Path path = Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(outerRect)
    ..addRect(innerRect);
  final Paint paint = Paint()
    ..color = color;
  canvas.drawPath(path, paint);
}

/// Paint a diagram showing the given area as padding.
///
/// Called by [RenderPadding.debugPaintSize] when [debugPaintSizeEnabled] is
/// true.
void debugPaintPadding(Canvas canvas, Rect outerRect, Rect innerRect, { double outlineWidth = 2.0 }) {
  assert(() {
    if (innerRect != null && !innerRect.isEmpty) {
      _debugDrawDoubleRect(canvas, outerRect, innerRect, const Color(0x900090FF));
      _debugDrawDoubleRect(canvas, innerRect.inflate(outlineWidth).intersect(outerRect), innerRect, const Color(0xFF0090FF));
    } else {
      final Paint paint = Paint()
        ..color = const Color(0x90909090);
      canvas.drawRect(outerRect, paint);
    }
    return true;
  }());
}

/// Returns true if none of the rendering library debug variables have been changed.
///
/// This function is used by the test framework to ensure that debug variables
/// haven't been inadvertently changed.
///
/// See [the rendering library](rendering/rendering-library.html) for a complete
/// list.
///
/// The `debugCheckIntrinsicSizesOverride` argument can be provided to override
/// the expected value for [debugCheckIntrinsicSizes]. (This exists because the
/// test framework itself overrides this value in some cases.)
bool debugAssertAllRenderVarsUnset(String reason, { bool debugCheckIntrinsicSizesOverride = false }) {
  assert(() {
    if (debugPaintSizeEnabled ||
        debugPaintBaselinesEnabled ||
        debugPaintLayerBordersEnabled ||
        debugPaintPointersEnabled ||
        debugRepaintRainbowEnabled ||
        debugRepaintTextRainbowEnabled ||
        debugCurrentRepaintColor != _kDebugDefaultRepaintColor ||
        debugPrintMarkNeedsLayoutStacks ||
        debugPrintMarkNeedsPaintStacks ||
        debugPrintLayouts ||
        debugCheckIntrinsicSizes != debugCheckIntrinsicSizesOverride ||
        debugProfilePaintsEnabled ||
        debugOnProfilePaint != null) {
      throw FlutterError(reason);
    }
    return true;
  }());
  return true;
}
