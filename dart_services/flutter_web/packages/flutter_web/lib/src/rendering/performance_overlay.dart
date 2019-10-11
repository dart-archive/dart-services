// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'box.dart';
import 'layer.dart';
import 'object.dart';

/// The options that control whether the performance overlay displays certain
/// aspects of the compositor.
enum PerformanceOverlayOption {
  // these must be in the order needed for their index values to match the
  // constants in //engine/src/sky/compositor/performance_overlay_layer.h

  /// Display the frame time and FPS of the last frame rendered. This field is
  /// updated every frame.
  ///
  /// This is the time spent by the rasterizer as it tries
  /// to convert the layer tree obtained from the widgets into OpenGL commands
  /// and tries to flush them onto the screen. When the total time taken by this
  /// step exceeds the frame slice, a frame is lost.
  displayRasterizerStatistics,

  /// Display the rasterizer frame times as they change over a set period of
  /// time in the form of a graph. The y axis of the graph denotes the total
  /// time spent by the rasterizer as a fraction of the total frame slice. When
  /// the bar turns red, a frame is lost.
  visualizeRasterizerStatistics,

  /// Display the frame time and FPS at which the interface can construct a
  /// layer tree for the rasterizer (whose behavior is described above) to
  /// consume.
  ///
  /// This involves all layout, animations, etc. When the total time taken by
  /// this step exceeds the frame slice, a frame is lost.
  displayEngineStatistics,

  /// Display the engine frame times as they change over a set period of time
  /// in the form of a graph. The y axis of the graph denotes the total time
  /// spent by the engine as a fraction of the total frame slice. When the bar
  /// turns red, a frame is lost.
  visualizeEngineStatistics,
}

/// Displays performance statistics.
///
/// The overlay shows two time series. The first shows how much time was
/// required on this thread to produce each frame. The second shows how much
/// time was required on the GPU thread to produce each frame. Ideally, both
/// these values would be less than the total frame budget for the hardware on
/// which the app is running. For example, if the hardware has a screen that
/// updates at 60 Hz, each thread should ideally spend less than 16ms producing
/// each frame. This ideal condition is indicated by a green vertical line for
/// each thread. Otherwise, the performance overlay shows a red vertical line.
///
/// The simplest way to show the performance overlay is to set
/// [MaterialApp.showPerformanceOverlay] or [WidgetsApp.showPerformanceOverlay]
/// to true.
class RenderPerformanceOverlay extends RenderBox {
  /// Creates a performance overlay render object.
  ///
  /// The [optionsMask], [rasterizerThreshold], [checkerboardRasterCacheImages],
  /// and [checkerboardOffscreenLayers] arguments must not be null.
  RenderPerformanceOverlay({
    int optionsMask = 0,
    int rasterizerThreshold = 0,
    bool checkerboardRasterCacheImages = false,
    bool checkerboardOffscreenLayers = false,
  })  : assert(optionsMask != null),
        assert(rasterizerThreshold != null),
        assert(checkerboardRasterCacheImages != null),
        assert(checkerboardOffscreenLayers != null),
        _optionsMask = optionsMask,
        _rasterizerThreshold = rasterizerThreshold,
        _checkerboardRasterCacheImages = checkerboardRasterCacheImages,
        _checkerboardOffscreenLayers = checkerboardOffscreenLayers;

  /// The mask is created by shifting 1 by the index of the specific
  /// [PerformanceOverlayOption] to enable.
  int get optionsMask => _optionsMask;
  int _optionsMask;
  set optionsMask(int value) {
    assert(value != null);
    if (value == _optionsMask) return;
    _optionsMask = value;
    markNeedsPaint();
  }

  /// The rasterizer threshold is an integer specifying the number of frame
  /// intervals that the rasterizer must miss before it decides that the frame
  /// is suitable for capturing an SkPicture trace for further analysis.
  int get rasterizerThreshold => _rasterizerThreshold;
  int _rasterizerThreshold;
  set rasterizerThreshold(int value) {
    assert(value != null);
    if (value == _rasterizerThreshold) return;
    _rasterizerThreshold = value;
    markNeedsPaint();
  }

  /// Whether the raster cache should checkerboard cached entries.
  bool get checkerboardRasterCacheImages => _checkerboardRasterCacheImages;
  bool _checkerboardRasterCacheImages;
  set checkerboardRasterCacheImages(bool value) {
    assert(value != null);
    if (value == _checkerboardRasterCacheImages) return;
    _checkerboardRasterCacheImages = value;
    markNeedsPaint();
  }

  /// Whether the compositor should checkerboard layers rendered to offscreen bitmaps.
  bool get checkerboardOffscreenLayers => _checkerboardOffscreenLayers;
  bool _checkerboardOffscreenLayers;
  set checkerboardOffscreenLayers(bool value) {
    assert(value != null);
    if (value == _checkerboardOffscreenLayers) return;
    _checkerboardOffscreenLayers = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  double computeMinIntrinsicWidth(double height) {
    return 0.0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return 0.0;
  }

  double get _intrinsicHeight {
    const double kDefaultGraphHeight = 80.0;
    double result = 0.0;
    if ((optionsMask |
                (1 <<
                    PerformanceOverlayOption
                        .displayRasterizerStatistics.index) >
            0) ||
        (optionsMask |
                (1 <<
                    PerformanceOverlayOption
                        .visualizeRasterizerStatistics.index) >
            0)) result += kDefaultGraphHeight;
    if ((optionsMask |
                (1 << PerformanceOverlayOption.displayEngineStatistics.index) >
            0) ||
        (optionsMask |
                (1 <<
                    PerformanceOverlayOption.visualizeEngineStatistics.index) >
            0)) result += kDefaultGraphHeight;
    return result;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _intrinsicHeight;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _intrinsicHeight;
  }

  @override
  void performResize() {
    size = constraints.constrain(Size(double.infinity, _intrinsicHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(needsCompositing);
    context.addLayer(PerformanceOverlayLayer(
      overlayRect: Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      optionsMask: optionsMask,
      rasterizerThreshold: rasterizerThreshold,
      checkerboardRasterCacheImages: checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: checkerboardOffscreenLayers,
    ));
  }
}
