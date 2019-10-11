// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of engine;

/// When `true` prints statistics about what happened to the surface tree when
/// it was composited.
///
/// Also paints an on-screen overlay with the numbers visualized as a timeline.
const bool _debugExplainSurfaceStats = false;

/// When `true` shows an overlay that contains stats about canvas reuse.
///
/// The overlay also includes a button to reset the stats.
const bool _debugShowCanvasReuseStats = false;

/// When `true` renders the outlines of clip layers on the screen instead of
/// clipping the contents.
///
/// This is useful when visually debugging clipping behavior.
bool debugShowClipLayers = false;

/// The threshold for the canvas pixel count to screen pixel count ratio, beyond
/// which in debug mode a warning is issued to the console.
///
/// As we improve canvas utilization we should decrease this number. It is
/// unlikely that we will hit 1.0, but something around 3.0 should be
/// reasonable.
const double _kScreenPixelRatioWarningThreshold = 6.0;

/// A monotonically increasing frame number being rendered.
///
/// Used for debugging only.
int _debugFrameNumber = 1;

List<FrameReference<dynamic>> _frameReferences = <FrameReference<dynamic>>[];

/// A temporary reference to a value of type [V].
///
/// The value automatically gets set to null after the current frame is
/// rendered.
///
/// It is useful to think of this as a weak reference that's scoped to a
/// single frame.
class FrameReference<V> {
  /// Creates a frame reference to a value.
  FrameReference([this.value]) {
    _frameReferences.add(this);
  }

  /// The current value of this reference.
  V value;
}

/// Performs any outstanding painting work enqueued by [PersistedPicture]s.
void commitScene(PersistedScene scene) {
  if (_paintQueue.isNotEmpty) {
    if (_paintQueue.length > 1) {
      // Sort paint requests in decreasing canvas size order. Paint requests
      // attempt to reuse canvases. For efficiency we want the biggest pictures
      // to find canvases before the smaller ones claim them.
      _paintQueue.sort((_PaintRequest a, _PaintRequest b) {
        final double aSize = a.canvasSize.height * a.canvasSize.width;
        final double bSize = b.canvasSize.height * b.canvasSize.width;
        return bSize.compareTo(aSize);
      });
    }

    for (_PaintRequest request in _paintQueue) {
      request.paintCallback();
    }
    _paintQueue = <_PaintRequest>[];
  }

  // After the update the retained surfaces are back to active.
  if (_retainedSurfaces.isNotEmpty) {
    for (int i = 0; i < _retainedSurfaces.length; i++) {
      final PersistedSurface retainedSurface = _retainedSurfaces[i];
      assert(retainedSurface.isPendingRetention);
      retainedSurface.state = PersistedSurfaceState.active;
    }
    _retainedSurfaces = <PersistedSurface>[];
  }
  if (_debugExplainSurfaceStats) {
    _debugPrintSurfaceStats(scene, _debugFrameNumber);
    _debugRepaintSurfaceStatsOverlay(scene);
  }
  assert(() {
    final List<String> validationErrors = <String>[];
    scene.debugValidate(validationErrors);
    if (validationErrors.isNotEmpty) {
      print('ENGINE LAYER TREE INCONSISTENT:\n'
          '${validationErrors.map((String e) => '  - $e\n').join()}');
    }
    return true;
  }());

  for (int i = 0; i < _frameReferences.length; i++) {
    _frameReferences[i].value = null;
  }
  _frameReferences = <FrameReference<dynamic>>[];

  if (_debugExplainSurfaceStats) {
    _surfaceStats = <PersistedSurface, _DebugSurfaceStats>{};
  }
  assert(() {
    _debugFrameNumber++;
    return true;
  }());
}

/// Discards information about previously rendered frames, including DOM
/// elements and cached canvases.
///
/// After calling this function new canvases will be created for the
/// subsequent scene. This is useful when tests need predictable canvas
/// sizes. If the cache is not cleared, then canvases allocated in one test
/// may be reused in another test.
void debugForgetFrameScene() {
  _clipIdCounter = 0;
  _recycledCanvases.clear();
}

/// Surfaces that were retained this frame.
///
/// Surfaces should be added to this list directly. Instead, if a surface needs
/// to be retained call [_retainSurface].
List<PersistedSurface> get debugRetainedSurfaces => _retainedSurfaces;
List<PersistedSurface> _retainedSurfaces = <PersistedSurface>[];

/// Maps every surface currently active on the screen to debug statistics.
Map<PersistedSurface, _DebugSurfaceStats> _surfaceStats =
    <PersistedSurface, _DebugSurfaceStats>{};

List<Map<PersistedSurface, _DebugSurfaceStats>> _surfaceStatsTimeline =
    <Map<PersistedSurface, _DebugSurfaceStats>>[];

/// Returns debug statistics for the given [surface].
_DebugSurfaceStats _surfaceStatsFor(PersistedSurface surface) {
  if (!_debugExplainSurfaceStats) {
    throw Exception(
        '_surfaceStatsFor is only available when _debugExplainSurfaceStats is set to true.');
  }
  return _surfaceStats.putIfAbsent(surface, () => _DebugSurfaceStats(surface));
}

/// Compositor information collected for one frame useful for assessing the
/// efficiency of constructing the frame.
///
/// This information is only available in debug mode.
///
/// For stats pertaining to a single surface the numeric counter fields are
/// typically either 0 or 1. For aggregated stats, the numbers can be >1.
class _DebugSurfaceStats {
  _DebugSurfaceStats(this.surface);

  /// The surface these stats are for, or `null` if these are aggregated stats.
  final PersistedSurface surface;

  /// How many times a surface was retained from a previously rendered frame.
  int retainSurfaceCount = 0;

  /// How many times a surface reused an HTML element from a previously rendered
  /// surface.
  int reuseElementCount = 0;

  /// If a surface is a [PersistedPicture], how many times it painted.
  int paintCount = 0;

  /// If a surface is a [PersistedPicture], how many pixels it painted.
  int paintPixelCount = 0;

  /// If a surface is a [PersistedPicture], how many times it reused a
  /// previously allocated `<canvas>` element when it painted.
  int reuseCanvasCount = 0;

  /// If a surface is a [PersistedPicture], how many times it allocated a new
  /// bitmap canvas.
  int allocateBitmapCanvasCount = 0;

  /// If a surface is a [PersistedPicture], how many pixels it allocated for
  /// the bitmap.
  ///
  /// For aggregated stats, this is the total sum of all pixels across all
  /// canvases.
  int allocatedBitmapSizeInPixels = 0;

  /// The number of HTML DOM nodes a surface allocated.
  ///
  /// For aggregated stats, this is the total sum of all DOM nodes across all
  /// surfaces.
  int allocatedDomNodeCount = 0;

  /// Adds all counters of [oneSurfaceStats] into this object.
  void aggregate(_DebugSurfaceStats oneSurfaceStats) {
    retainSurfaceCount += oneSurfaceStats.retainSurfaceCount;
    reuseElementCount += oneSurfaceStats.reuseElementCount;
    paintCount += oneSurfaceStats.paintCount;
    paintPixelCount += oneSurfaceStats.paintPixelCount;
    reuseCanvasCount += oneSurfaceStats.reuseCanvasCount;
    allocateBitmapCanvasCount += oneSurfaceStats.allocateBitmapCanvasCount;
    allocatedBitmapSizeInPixels += oneSurfaceStats.allocatedBitmapSizeInPixels;
    allocatedDomNodeCount += oneSurfaceStats.allocatedDomNodeCount;
  }
}

html.CanvasRenderingContext2D _debugSurfaceStatsOverlayCtx;

void _debugRepaintSurfaceStatsOverlay(PersistedScene scene) {
  final int overlayWidth = html.window.innerWidth;
  const int rowHeight = 30;
  const int rowCount = 4;
  const int overlayHeight = rowHeight * rowCount;
  const int strokeWidth = 2;

  _surfaceStatsTimeline.add(_surfaceStats);

  while (_surfaceStatsTimeline.length > (overlayWidth / strokeWidth)) {
    _surfaceStatsTimeline.removeAt(0);
  }

  if (_debugSurfaceStatsOverlayCtx == null) {
    final html.CanvasElement _debugSurfaceStatsOverlay = html.CanvasElement(
      width: overlayWidth,
      height: overlayHeight,
    );
    _debugSurfaceStatsOverlay.style
      ..position = 'fixed'
      ..left = '0'
      ..top = '0'
      ..zIndex = '1000'
      ..opacity = '0.8';
    _debugSurfaceStatsOverlayCtx = _debugSurfaceStatsOverlay.context2D;
    html.document.body.append(_debugSurfaceStatsOverlay);
  }

  _debugSurfaceStatsOverlayCtx
    ..fillStyle = 'black'
    ..beginPath()
    ..rect(0, 0, overlayWidth, overlayHeight)
    ..fill();

  final double physicalScreenWidth =
      html.window.innerWidth * html.window.devicePixelRatio;
  final double physicalScreenHeight =
      html.window.innerHeight * html.window.devicePixelRatio;
  final double physicsScreenPixelCount =
      physicalScreenWidth * physicalScreenHeight;

  final int totalDomNodeCount = scene.rootElement.querySelectorAll('*').length;

  for (int i = 0; i < _surfaceStatsTimeline.length; i++) {
    final Map<PersistedSurface, _DebugSurfaceStats> statsMap =
        _surfaceStatsTimeline[i];
    final _DebugSurfaceStats totals = _DebugSurfaceStats(null);
    int pixelCount = 0;
    for (_DebugSurfaceStats oneSurfaceStats in statsMap.values) {
      totals.aggregate(oneSurfaceStats);
      if (oneSurfaceStats.surface is PersistedPicture) {
        final PersistedPicture picture = oneSurfaceStats.surface;
        pixelCount += picture.bitmapPixelCount;
      }
    }

    final double repaintRate = totals.paintPixelCount / pixelCount;
    final double domAllocationRate =
        totals.allocatedDomNodeCount / totalDomNodeCount;
    final double bitmapAllocationRate =
        totals.allocatedBitmapSizeInPixels / physicsScreenPixelCount;
    final double surfaceRetainRate =
        totals.retainSurfaceCount / _surfaceStatsTimeline[i].length;

    // Repaints
    _debugSurfaceStatsOverlayCtx
      ..lineWidth = strokeWidth
      ..strokeStyle = 'red'
      ..beginPath()
      ..moveTo(strokeWidth * i, rowHeight)
      ..lineTo(strokeWidth * i, rowHeight * (1 - repaintRate))
      ..stroke();

    // DOM allocations
    _debugSurfaceStatsOverlayCtx
      ..lineWidth = strokeWidth
      ..strokeStyle = 'red'
      ..beginPath()
      ..moveTo(strokeWidth * i, 2 * rowHeight)
      ..lineTo(strokeWidth * i, rowHeight * (2 - domAllocationRate))
      ..stroke();

    // Bitmap allocations
    _debugSurfaceStatsOverlayCtx
      ..lineWidth = strokeWidth
      ..strokeStyle = 'red'
      ..beginPath()
      ..moveTo(strokeWidth * i, 3 * rowHeight)
      ..lineTo(strokeWidth * i, rowHeight * (3 - bitmapAllocationRate))
      ..stroke();

    // Surface retentions
    _debugSurfaceStatsOverlayCtx
      ..lineWidth = strokeWidth
      ..strokeStyle = 'green'
      ..beginPath()
      ..moveTo(strokeWidth * i, 4 * rowHeight)
      ..lineTo(strokeWidth * i, rowHeight * (4 - surfaceRetainRate))
      ..stroke();
  }

  _debugSurfaceStatsOverlayCtx
    ..font = 'normal normal 14px sans-serif'
    ..fillStyle = 'white'
    ..fillText('Repaint rate', 5, rowHeight - 5)
    ..fillText('DOM alloc rate', 5, 2 * rowHeight - 5)
    ..fillText('Bitmap alloc rate', 5, 3 * rowHeight - 5)
    ..fillText('Retain rate', 5, 4 * rowHeight - 5);

  for (int i = 1; i <= rowCount; i++) {
    _debugSurfaceStatsOverlayCtx
      ..lineWidth = 1
      ..strokeStyle = 'blue'
      ..beginPath()
      ..moveTo(0, overlayHeight - rowHeight * i)
      ..lineTo(overlayWidth, overlayHeight - rowHeight * i)
      ..stroke();
  }
}

/// Prints debug statistics for the current frame to the console.
void _debugPrintSurfaceStats(PersistedScene scene, int frameNumber) {
  int pictureCount = 0;
  int paintCount = 0;

  int bitmapCanvasCount = 0;
  int bitmapReuseCount = 0;
  int bitmapAllocationCount = 0;
  int bitmapPaintCount = 0;
  int bitmapPixelsAllocated = 0;

  int domCanvasCount = 0;
  int domPaintCount = 0;

  int surfaceRetainCount = 0;
  int elementReuseCount = 0;

  int totalAllocatedDomNodeCount = 0;

  void countReusesRecursively(PersistedSurface surface) {
    final _DebugSurfaceStats stats = _surfaceStatsFor(surface);
    assert(stats != null);

    surfaceRetainCount += stats.retainSurfaceCount;
    elementReuseCount += stats.reuseElementCount;
    totalAllocatedDomNodeCount += stats.allocatedDomNodeCount;

    if (surface is PersistedStandardPicture) {
      pictureCount += 1;
      paintCount += stats.paintCount;

      if (surface._canvas is DomCanvas) {
        domCanvasCount++;
        domPaintCount += stats.paintCount;
      }

      if (surface._canvas is BitmapCanvas) {
        bitmapCanvasCount++;
        bitmapPaintCount += stats.paintCount;
      }

      bitmapReuseCount += stats.reuseCanvasCount;
      bitmapAllocationCount += stats.allocateBitmapCanvasCount;
      bitmapPixelsAllocated += stats.allocatedBitmapSizeInPixels;
    }

    surface.visitChildren(countReusesRecursively);
  }

  scene.visitChildren(countReusesRecursively);

  final StringBuffer buf = StringBuffer();
  buf
    ..writeln(
        '---------------------- FRAME #$frameNumber -------------------------')
    ..writeln('Surfaces retained: $surfaceRetainCount')
    ..writeln('Elements reused: $elementReuseCount')
    ..writeln('Elements allocated: $totalAllocatedDomNodeCount')
    ..writeln('Pictures: $pictureCount')
    ..writeln('  Painted: $paintCount')
    ..writeln('  Skipped painting: ${pictureCount - paintCount}')
    ..writeln('DOM canvases:')
    ..writeln('  Painted: $domPaintCount')
    ..writeln('  Skipped painting: ${domCanvasCount - domPaintCount}')
    ..writeln('Bitmap canvases: $bitmapCanvasCount')
    ..writeln('  Painted: $bitmapPaintCount')
    ..writeln('  Skipped painting: ${bitmapCanvasCount - bitmapPaintCount}')
    ..writeln('  Reused: $bitmapReuseCount')
    ..writeln('  Allocated: $bitmapAllocationCount')
    ..writeln('  Allocated pixels: $bitmapPixelsAllocated')
    ..writeln('  Available for reuse: ${_recycledCanvases.length}');

  // A microtask will fire after the DOM is flushed, letting us probe into
  // actual <canvas> tags.
  scheduleMicrotask(() {
    final List<html.Element> canvasElements =
        html.document.querySelectorAll('canvas');
    final StringBuffer canvasInfo = StringBuffer();
    final int pixelCount = canvasElements
        .cast<html.CanvasElement>()
        .map<int>((html.CanvasElement e) {
      final int pixels = e.width * e.height;
      canvasInfo.writeln('    - ${e.width} x ${e.height} = $pixels pixels');
      return pixels;
    }).fold(0, (int total, int pixels) => total + pixels);
    final double physicalScreenWidth =
        html.window.innerWidth * html.window.devicePixelRatio;
    final double physicalScreenHeight =
        html.window.innerHeight * html.window.devicePixelRatio;
    final double physicsScreenPixelCount =
        physicalScreenWidth * physicalScreenHeight;
    final double screenPixelRatio = pixelCount / physicsScreenPixelCount;
    final String screenDescription =
        '1 screen is $physicalScreenWidth x $physicalScreenHeight = $physicsScreenPixelCount pixels';
    final String canvasPixelDescription =
        '$pixelCount (${screenPixelRatio.toStringAsFixed(2)} x screens';
    buf
      ..writeln('  Elements: ${canvasElements.length}')
      ..writeln(canvasInfo)
      ..writeln('  Pixels: $canvasPixelDescription; $screenDescription)')
      ..writeln('-----------------------------------------------------------');
    final bool screenPixelRatioTooHigh =
        screenPixelRatio > _kScreenPixelRatioWarningThreshold;
    if (screenPixelRatioTooHigh) {
      print(
          'WARNING: pixel/screen ratio too high (${screenPixelRatio.toStringAsFixed(2)}x)');
    }
    print(buf);
  });
}

/// Signature of a function that receives a [PersistedSurface].
///
/// This is used to traverse surfaces using [PersistedSurface.visitChildren].
typedef PersistedSurfaceVisitor = void Function(PersistedSurface);

/// Controls the algorithm used to reuse a previously rendered surface.
enum PersistedSurfaceState {
  /// A new or revived surface that does not have a
  /// [PersistedSurface.rootElement].
  ///
  /// Surfaces in this state acquire an element either by creating a new element
  /// or by adopting an element from an [active] surface.
  created,

  /// The surface has DOM resources that are attached to the live DOM tree.
  ///
  /// During update surfaces in this state come from the previous frame. This is
  /// also the state that all surfaces that are attached to the new frame's
  /// scene acquire at the end of the frame.
  ///
  /// In this state the surface has a non-null [PersistedSurface.rootElement].
  /// The element may be adopted by a new surface by matching to it during
  /// update (see [PersistedSurface.matchForUpdate]).
  active,

  /// The surface object will be reused along with all its descendants.
  ///
  /// This strategy relies on Flutter's retained-mode layer system (see
  /// [EngineLayer]).
  pendingRetention,

  /// The surface's DOM elements will be reused and updated.
  ///
  /// The surface in this state must have been rendered in a previous frame, it
  /// must have non-null [PersistedSurface.rootElement], and there must be a new
  /// surface that points to this surface via
  /// [PersistedContainerSurface.oldLayer]. The new surface will adopt this
  /// surface's DOM elements and update them.
  pendingUpdate,

  /// This state indicates that all DOM resources of this surface have been
  /// released and cannot be reused anymore.
  ///
  /// There are two ways a surface may be released:
  ///
  /// - When the surface is updated its DOM elements are adopted by a new
  ///   surface. This can happen either via [PersistedContainerSurface.oldLayer]
  ///   or by matching.
  /// - When the surface is removed from the tree because it is no longer in the
  ///   scene, nor its elements are reused by another surface.
  ///
  /// A surface may be revived from this state back into [created] state via
  /// [PersistedSurface.revive].
  released,
}

/// A node in the tree built by [SceneBuilder] that contains information used to
/// compute the fewest amount of mutations necessary to update the browser DOM.
abstract class PersistedSurface implements ui.EngineLayer {
  /// Creates a persisted surface.
  PersistedSurface();

  /// Controls the algorithm that reuses the DOM resources owned by this
  /// surface.
  PersistedSurfaceState get state => _state;
  set state(PersistedSurfaceState newState) {
    assert(newState != null);
    assert(newState != _state,
        'Attempted to set state that the surface is already in. This likely indicates a bug in the compositor.');
    assert(_debugValidateStateTransition(newState));
    _state = newState;
  }

  PersistedSurfaceState _state = PersistedSurfaceState.created;

  bool _debugValidateStateTransition(PersistedSurfaceState newState) {
    if (newState == PersistedSurfaceState.created) {
      assert(isReleased, 'Only released surfaces may be revived.');
    } else {
      assert(!isReleased,
          'Released surfaces may only be revived, but caught attempt to set $newState.');
    }
    if (newState == PersistedSurfaceState.active) {
      assert(
        isCreated || isPendingRetention || isPendingUpdate,
        'Surface is $state. Only created, pending retention, and pending update surfaces may be activated.',
      );
    }
    if (newState == PersistedSurfaceState.pendingRetention) {
      assert(isActive,
          'Surface is not active. Only active surfaces may be retained.');
    }
    if (newState == PersistedSurfaceState.pendingUpdate) {
      assert(isActive,
          'Surface is not active. Only active surfaces may be updated.');
    }
    if (newState == PersistedSurfaceState.released) {
      assert(isActive || isPendingUpdate,
          'A surface may only be released if it is currently active or pending update, but it is in $state.');
    }
    return true;
  }

  /// Attempts to retain this surface along with its descendants.
  ///
  /// If the surface is currently active this surface is retained. If the
  /// surface is released, it means that the surface's DOM resources have been
  /// reused before the request to retain it came in. In this case, the surface
  /// is [revive]d and rebuilt from scratch.
  void tryRetain() {
    assert(isActive || isReleased);
    // Request that the layer is retained, but only if it's still active. It
    // could have been released.
    if (isActive) {
      state = PersistedSurfaceState.pendingRetention;
    } else {
      // The surface is released. This means that by the time addRetained was
      // called this surface's DOM elements have been reused for something else.
      // In this case, we reset the surface back to "created" state.
      revive();
    }
  }

  /// Turns a previously released surface and all its descendants into a
  /// [PersistedSurfaceState.created] one.
  ///
  /// This is used to rebuild surfaces that were released before a request to
  /// retain came in.
  @mustCallSuper
  @visibleForTesting
  @protected
  void revive() {
    assert(isReleased);
    state = PersistedSurfaceState.created;
  }

  /// The surface is in the [PersistedSurfaceState.created] state;
  bool get isCreated => _state == PersistedSurfaceState.created;

  /// The surface is in the [PersistedSurfaceState.active] state;
  bool get isActive => _state == PersistedSurfaceState.active;

  /// The surface is in the [PersistedSurfaceState.pendingRetention] state;
  bool get isPendingRetention =>
      _state == PersistedSurfaceState.pendingRetention;

  /// The surface is in the [PersistedSurfaceState.pendingUpdate] state;
  bool get isPendingUpdate => _state == PersistedSurfaceState.pendingUpdate;

  /// The surface is in the [PersistedSurfaceState.released] state;
  bool get isReleased => _state == PersistedSurfaceState.released;

  /// The root element that renders this surface to the DOM.
  ///
  /// This element can be reused across frames. See also, [childContainer],
  /// which is the element used to manage child nodes.
  html.Element rootElement;

  /// Whether this surface can update an existing [oldSurface].
  bool canUpdateAsMatch(PersistedSurface oldSurface) {
    return oldSurface.isActive && runtimeType == oldSurface.runtimeType;
  }

  /// The element that contains child surface elements.
  ///
  /// By default this is the same as the [rootElement]. However, specialized
  /// surface implementations may choose to override this and provide a
  /// different element for nesting children.
  html.Element get childContainer => rootElement;

  /// This surface's immediate parent.
  PersistedContainerSurface parent;

  /// Visits immediate children.
  ///
  /// Does not recurse.
  void visitChildren(PersistedSurfaceVisitor visitor);

  /// Computes how expensive it would be to update an [existingSurface]'s DOM
  /// resources using this surface's data.
  ///
  /// The returned value is a score between 0.0 and 1.0, inclusive. 0.0 is the
  /// perfect score, meaning that the update is free. 1.0 is the worst score,
  /// indicating that the DOM resources cannot be reused, and if an update is
  /// performed, will result in reallocation.
  ///
  /// Values that fall strictly between 0.0 and 1.0 are used to communicate
  /// the efficiency of updates, with lower scores having better efficiency
  /// compared to higher scores. For example, when matching a picture with a
  /// bitmap canvas the score is higher for a canvas that's bigger in size than
  /// a smaller canvas that also fits the picture.
  double matchForUpdate(covariant PersistedSurface existingSurface);

  /// Creates a new element and sets the necessary HTML and CSS attributes.
  ///
  /// This is called when we failed to locate an existing DOM element to reuse,
  /// such as on the very first frame.
  @protected
  @mustCallSuper
  void build() {
    assert(rootElement == null);
    assert(isCreated);
    rootElement = createElement();
    if (_debugExplainSurfaceStats) {
      _surfaceStatsFor(this).allocatedDomNodeCount++;
    }
    apply();
    state = PersistedSurfaceState.active;
  }

  /// Instructs this surface to adopt HTML DOM elements of another surface.
  ///
  /// This is done for efficiency. Instead of creating new DOM elements on every
  /// frame, we reuse old ones as much as possible. This method should only be
  /// called when [isTotalMatchFor] returns true for the [oldSurface]. Otherwise
  /// adopting the [oldSurface]'s elements could lead to correctness issues.
  @protected
  @mustCallSuper
  void adoptElements(covariant PersistedSurface oldSurface) {
    assert(oldSurface.rootElement != null);
    assert(oldSurface.isActive || oldSurface.isPendingUpdate);
    assert(() {
      if (oldSurface.isPendingUpdate) {
        final PersistedContainerSurface self = this;
        assert(identical(self.oldLayer, oldSurface));
      }
      return true;
    }());
    rootElement = oldSurface.rootElement;
    if (_debugExplainSurfaceStats) {
      _surfaceStatsFor(this).reuseElementCount++;
    }

    // We took ownership of the old element.
    oldSurface.rootElement = null;
    // Make sure the old surface object is no longer usable.
    oldSurface.state = PersistedSurfaceState.released;
  }

  /// Updates the attributes of this surface's element.
  ///
  /// Attempts to reuse [oldSurface]'s DOM element, if possible. Otherwise,
  /// creates a new element by calling [build].
  @protected
  @mustCallSuper
  void update(covariant PersistedSurface oldSurface) {
    assert(oldSurface != null);
    assert(!identical(oldSurface, this));
    assert(isCreated && (oldSurface.isPendingUpdate || oldSurface.isActive));

    adoptElements(oldSurface);

    if (assertionsEnabled) {
      rootElement.setAttribute('flt-layer-state', 'updated');
    }
    state = PersistedSurfaceState.active;
    assert(rootElement != null);
  }

  /// Reuses a [PersistedSurface] rendered in the previous frame.
  ///
  /// This is different from [update], which reuses another surface's elements,
  /// i.e. it was not requested to be retained by the framework.
  ///
  /// This is also different from [build], which constructs a brand new surface
  /// sub-tree.
  @protected
  @mustCallSuper
  void retain() {
    assert(rootElement != null);
    if (isPendingRetention) {
      // Adding to the list of retained surfaces so that at the end of the frame
      // it is set to active state. We do not set the state to active
      // immediately. Otherwise, another surface could match on it and steal
      // this surface's DOM elements.
      _retainedSurfaces.add(this);
    }
    if (assertionsEnabled) {
      rootElement.setAttribute('flt-layer-state', 'retained');
    }
    if (_debugExplainSurfaceStats) {
      _surfaceStatsFor(this).retainSurfaceCount++;
    }
  }

  /// Removes the [element] of this surface from the tree and makes this
  /// surface released.
  ///
  /// This method may be overridden by concrete implementations, for example, to
  /// recycle the resources owned by this surface.
  @protected
  @mustCallSuper
  void discard() {
    assert(isActive);
    assert(rootElement != null);
    // TODO(yjbanov): it may be wasteful to recursively disassemble the DOM tree
    //                node by node. It should be sufficient to detach the root
    //                of the tree and let the browser handle the rest. Note,
    //                element.isConnected might be a poor choice to drive this
    //                decision because it is sensitive to the timing of when a
    //                scene's element is attached to the document. We might want
    //                to use a custom tracking mechanism, such as pass a boolean
    //                to `discard`, which would be `true` for the root, and
    //                `false` for children. Or, which might be cleaner, we could
    //                split this method into two methods. One method will detach
    //                the DOM, and the second method will disassociate the
    //                surface from the the DOM and release it irrespective of
    //                whether the DOM itself gets detached or not.
    rootElement.remove();
    rootElement = null;
    state = PersistedSurfaceState.released;
  }

  @protected
  @mustCallSuper
  void debugValidate(List<String> validationErrors) {
    if (rootElement == null) {
      validationErrors.add('${debugIdentify(this)} has null rootElement.');
    }
    if (!isActive) {
      validationErrors.add('${debugIdentify(this)} is in the wrong state.\n'
          'It is in the live DOM tree expectec to be in ${PersistedSurfaceState.active}.\n'
          'However, it is currently in $state.');
    }
  }

  /// Creates a DOM element for this surface.
  html.Element createElement();

  /// Creates a DOM element for this surface preconfigured with common
  /// attributes, such as absolute positioning and debug information.
  html.Element defaultCreateElement(String tagName) {
    final html.Element element = html.Element.tag(tagName);
    element.style.position = 'absolute';
    if (assertionsEnabled) {
      element.setAttribute('flt-layer-state', 'new');
    }
    return element;
  }

  /// Sets the HTML and CSS properties appropriate for this surface's
  /// implementation.
  ///
  /// For example, [PersistedTransform] sets the "transform" CSS attribute.
  void apply();

  /// The effective transform at this surface level.
  ///
  /// This value is computed by concatenating transforms of all ancestor
  /// transforms as well as this layer's transform (if any).
  ///
  /// The value is update by [recomputeTransformAndClip].
  Matrix4 get transform => _transform;
  Matrix4 _transform;

  /// The intersection at this surface level.
  ///
  /// This value is the intersection of clips in the ancestor chain, including
  /// the clip added by this layer (if any).
  ///
  /// The value is update by [recomputeTransformAndClip].
  ui.Rect _projectedClip;

  /// Bounds of clipping performed by this layer.
  ui.Rect _localClipBounds;
  // Cached inverse of transform on this node. Unlike transform, this
  // Matrix only contains local transform (not chain multiplied since root).
  Matrix4 _localTransformInverse;

  Matrix4 get localTransformInverse;

  /// Recomputes [transform] and [globalClip] fields.
  ///
  /// The default implementation inherits the values from the parent. Concrete
  /// surface implementations may override this with their custom transform and
  /// clip behaviors.
  ///
  /// This method is called by the [preroll] method.
  @protected
  void recomputeTransformAndClip() {
    _transform = parent._transform;
    _localClipBounds = null;
    _localTransformInverse = null;
    _projectedClip = null;
  }

  /// Performs computations before [build], [update], or [retain] are called.
  ///
  /// The computations prepare data needed for efficient scene diffing. For
  /// example, as part of a preroll we compute transforms and cull rects, which
  /// are used to find the best matching canvases.
  ///
  /// This method recursively walks the surface tree calling `preroll` on all
  /// descendants.
  void preroll() {
    recomputeTransformAndClip();
  }

  /// Prints this surface into a [buffer] in a human-readable format.
  void debugPrint(StringBuffer buffer, int indent) {
    if (rootElement != null) {
      buffer.write('${'  ' * indent}<${rootElement.tagName.toLowerCase()} ');
    } else {
      buffer.write('${'  ' * indent}<$runtimeType recycled ');
    }
    debugPrintAttributes(buffer);
    buffer.writeln('>');
    debugPrintChildren(buffer, indent);
    if (rootElement != null) {
      buffer.writeln('${'  ' * indent}</${rootElement.tagName.toLowerCase()}>');
    } else {
      buffer.writeln('${'  ' * indent}</$runtimeType>');
    }
  }

  @protected
  @mustCallSuper
  void debugPrintAttributes(StringBuffer buffer) {
    if (rootElement != null) {
      buffer.write('@${rootElement.hashCode} ');
    }
  }

  @protected
  @mustCallSuper
  void debugPrintChildren(StringBuffer buffer, int indent) {}

  @override
  String toString() {
    if (assertionsEnabled) {
      final StringBuffer log = StringBuffer();
      debugPrint(log, 0);
      return log.toString();
    } else {
      return super.toString();
    }
  }
}

/// A surface that doesn't have child surfaces.
abstract class PersistedLeafSurface extends PersistedSurface {
  PersistedLeafSurface();

  @override
  void visitChildren(PersistedSurfaceVisitor visitor) {
    // Does not have children.
  }
}

/// A surface that has a flat list of child surfaces.
abstract class PersistedContainerSurface extends PersistedSurface {
  /// Creates a container surface.
  ///
  /// `oldLayer` points to the surface rendered in the previous frame that's
  /// being updated by this layer.
  PersistedContainerSurface(PersistedSurface oldLayer)
      : _oldLayer = FrameReference<PersistedSurface>(
            oldLayer != null && oldLayer.isActive ? oldLayer : null) {
    assert(oldLayer == null || runtimeType == oldLayer.runtimeType);
  }

  /// The surface that is being updated using this surface.
  ///
  /// If not null this surface will reuse the old surface's HTML [element].
  ///
  /// This value is set to null at the end of the frame.
  PersistedSurface get oldLayer => _oldLayer.value;
  final FrameReference<PersistedSurface> _oldLayer;

  final List<PersistedSurface> _children = <PersistedSurface>[];

  @override
  void visitChildren(PersistedSurfaceVisitor visitor) {
    _children.forEach(visitor);
  }

  /// Adds a child to this container.
  void appendChild(PersistedSurface child) {
    assert(child.isCreated || child.isPendingRetention || child.isPendingUpdate,
        'Child is in incorrect state ${child.state}');
    _children.add(child);
    child.parent = this;
  }

  @override
  void preroll() {
    super.preroll();
    final int length = _children.length;
    for (int i = 0; i < length; i += 1) {
      _children[i].preroll();
    }
  }

  @override
  void recomputeTransformAndClip() {
    _transform = parent._transform;
    _localClipBounds = null;
    _localTransformInverse = null;
    _projectedClip = null;
  }

  @override
  void build() {
    super.build();
    // Memoize length for efficiency.
    final int len = _children.length;
    // Memoize container element for efficiency. [childContainer] is polymorphic
    final html.Element containerElement = childContainer;
    for (int i = 0; i < len; i++) {
      final PersistedSurface child = _children[i];
      if (child.isPendingRetention) {
        assert(child.rootElement != null);
        child.retain();
      } else if (child is PersistedContainerSurface && child.oldLayer != null) {
        final PersistedSurface oldLayer = child.oldLayer;
        assert(oldLayer.rootElement != null);
        assert(oldLayer.isPendingUpdate);
        child.update(child.oldLayer);
      } else {
        assert(child.isCreated);
        assert(child.rootElement == null);
        child.build();
      }
      containerElement.append(child.rootElement);
    }
  }

  @override
  double matchForUpdate(PersistedContainerSurface existingSurface) {
    assert(existingSurface.runtimeType == runtimeType);
    // Intermediate container nodes don't have many resources worth comparing,
    // so we always return 1.0 to signal that it doesn't matter which one to
    // choose.
    // TODO(yjbanov): while the container doesn't have own resources, imperfect
    //                matching can lead to unnecessary reparenting of DOM
    //                subtrees. One trick we could try is to look at children's
    //                oldLayer values and see if we can use those to match
    //                intermediate surfaces better.
    return 1.0;
  }

  @override
  void update(PersistedContainerSurface oldSurface) {
    assert(oldSurface.isActive || oldSurface.isPendingUpdate);
    assert(runtimeType == oldSurface.runtimeType);
    super.update(oldSurface);
    assert(oldSurface.isReleased);

    if (oldSurface._children.isEmpty) {
      _updateZeroToMany(oldSurface);
    } else if (_children.length == 1) {
      _updateManyToOne(oldSurface);
    } else if (_children.isEmpty) {
      _discardActiveChildren(oldSurface);
    } else {
      _updateManyToMany(oldSurface);
    }

    if (assertionsEnabled) {
      _debugValidateContainerUpdate(oldSurface);
    }
  }

  void _debugValidateContainerUpdate(PersistedContainerSurface oldSurface) {
    // At the end of this all children should have an element each, and it
    // should be attached to this container's element.
    assert(() {
      for (int i = 0; i < oldSurface._children.length; i++) {
        final PersistedSurface oldChild = oldSurface._children[i];
        assert(!oldChild.isActive && !oldChild.isCreated,
            'Old child is in incorrect state ${oldChild.state}');
        if (oldChild.isReleased) {
          assert(oldChild.rootElement == null);
          assert(oldChild.childContainer == null);
        }
      }
      for (int i = 0; i < _children.length; i++) {
        final PersistedSurface newChild = _children[i];
        assert(newChild.isActive || newChild.isPendingRetention,
            'New child is in incorrect state ${newChild.state}');
        assert(newChild.rootElement != null);
        assert(newChild.rootElement.parent == childContainer);
      }
      return true;
    }());
  }

  /// This is a fast path update for the case when an empty container is being
  /// populated with children.
  ///
  /// This method does not do any matching.
  void _updateZeroToMany(PersistedContainerSurface oldSurface) {
    assert(oldSurface._children.isEmpty);

    // Memoizing variables for efficiency.
    final html.Element containerElement = childContainer;
    final int length = _children.length;

    for (int i = 0; i < length; i++) {
      final PersistedSurface newChild = _children[i];
      if (newChild.isPendingRetention) {
        newChild.retain();
        assert(newChild.isPendingRetention);
      } else if (newChild is PersistedContainerSurface &&
          newChild.oldLayer != null) {
        final PersistedContainerSurface oldLayer = newChild.oldLayer;
        assert(oldLayer.isPendingUpdate);
        newChild.update(oldLayer);
        assert(oldLayer.isReleased);
        assert(newChild.isActive);
      } else {
        newChild.build();
        assert(newChild.isActive);
      }
      assert(newChild.rootElement != null);
      containerElement.append(newChild.rootElement);
    }
  }

  /// Called to release children that were not reused this frame.
  static void _discardActiveChildren(PersistedContainerSurface surface) {
    final int length = surface._children.length;
    for (int i = 0; i < length; i += 1) {
      final PersistedSurface child = surface._children[i];
      // Only release active children that are currently active (i.e. they are
      // not pending retention or update).
      if (child.isActive) {
        child.discard();
      }
      assert(!child.isCreated && !child.isActive);
    }
  }

  /// This is a fast path update for the common case when there's only one child
  /// active in this frame.
  void _updateManyToOne(PersistedContainerSurface oldSurface) {
    assert(_children.length == 1);
    final PersistedSurface newChild = _children[0];

    // Retained child is moved to the correct location in the tree; all others
    // are released.
    if (newChild.isPendingRetention) {
      assert(newChild.rootElement != null);

      // Move the HTML node if necessary.
      if (newChild.rootElement.parent != childContainer) {
        childContainer.append(newChild.rootElement);
      }

      newChild.retain();

      _discardActiveChildren(oldSurface);
      assert(newChild.isPendingRetention);
      return;
    }

    // Updated child is moved to the correct location in the tree; all others
    // are released.
    if (newChild is PersistedContainerSurface && newChild.oldLayer != null) {
      assert(newChild.oldLayer.isPendingUpdate);
      assert(newChild.rootElement == null);
      assert(newChild.oldLayer.rootElement != null);

      final PersistedContainerSurface oldLayer = newChild.oldLayer;

      // Move the HTML node if necessary.
      if (oldLayer.rootElement.parent != childContainer) {
        childContainer.append(oldLayer.rootElement);
      }

      newChild.update(oldLayer);
      _discardActiveChildren(oldSurface);
      assert(oldLayer.isReleased);
      assert(newChild.isActive);
      return;
    }

    assert(newChild.isCreated);

    PersistedSurface bestMatch;
    double bestScore = 2.0;
    for (int i = 0; i < oldSurface._children.length; i++) {
      final PersistedSurface candidate = oldSurface._children[i];
      if (!newChild.canUpdateAsMatch(candidate)) {
        continue;
      }
      final double score = newChild.matchForUpdate(candidate);
      if (score < bestScore) {
        bestMatch = candidate;
        bestScore = score;
      }
    }

    if (bestMatch != null) {
      assert(bestMatch.isActive);
      newChild.update(bestMatch);

      // Move the HTML node if necessary.
      if (newChild.rootElement.parent != childContainer) {
        childContainer.append(newChild.rootElement);
      }

      assert(bestMatch.isReleased);
    } else {
      newChild.build();
      childContainer.append(newChild.rootElement);
      assert(newChild.isActive);
    }

    // Child nodes that were not used this frame that are still active and not
    // explicitly retained or updated are discarded.
    for (int i = 0; i < oldSurface._children.length; i++) {
      final PersistedSurface oldChild = oldSurface._children[i];
      if (!identical(oldChild, bestMatch) && oldChild.isActive) {
        oldChild.discard();
      }
      assert(!oldChild.isCreated && !oldChild.isActive);
    }
  }

  /// This is the general case when multiple children are matched against
  /// multiple children.
  void _updateManyToMany(PersistedContainerSurface oldSurface) {
    assert(_children.isNotEmpty && oldSurface._children.isNotEmpty);

    // Memoize container element for efficiency. [childContainer] is polymorphic
    final html.Element containerElement = childContainer;

    PersistedSurface nextSibling;

    // Inserts the DOM node of the child before the DOM node of the next sibling
    // if it has moved as a result of the update. Does nothing if the new child
    // is already in the right location in the DOM tree.
    void insertDomNodeIfMoved(PersistedSurface newChild) {
      assert(newChild.rootElement != null);
      assert(newChild.parent == this);
      final bool reparented = newChild.rootElement.parent != containerElement;
      // Do not check for sibling if reparented. It's obvious that we moved.
      final bool moved = reparented ||
          newChild.rootElement.nextElementSibling != nextSibling?.rootElement;
      if (moved) {
        if (nextSibling == null) {
          // We're at the end of the list.
          containerElement.append(newChild.rootElement);
        } else {
          // We're in the middle of the list.
          containerElement.insertBefore(
              newChild.rootElement, nextSibling.rootElement);
        }
      }
    }

    final Map<PersistedSurface, PersistedSurface> matches =
        _matchChildren(oldSurface);

    for (int bottomInNew = _children.length - 1;
        bottomInNew >= 0;
        bottomInNew--) {
      final PersistedSurface newChild = _children[bottomInNew];
      if (newChild.isPendingRetention) {
        newChild.retain();
        assert(newChild.isPendingRetention);
      } else if (newChild is PersistedContainerSurface &&
          newChild.oldLayer != null) {
        final PersistedContainerSurface oldLayer = newChild.oldLayer;
        assert(oldLayer.isPendingUpdate);
        newChild.update(oldLayer);
        assert(oldLayer.isReleased);
        assert(newChild.isActive);
      } else {
        final PersistedSurface matchedOldChild = matches[newChild];
        if (matchedOldChild != null) {
          assert(matchedOldChild.isActive);
          newChild.update(matchedOldChild);
          assert(matchedOldChild.isReleased);
          assert(newChild.isActive);
        } else {
          newChild.build();
          assert(newChild.isActive);
        }
      }
      insertDomNodeIfMoved(newChild);
      assert(newChild.rootElement != null);
      assert(newChild.isActive || newChild.isPendingRetention);
      nextSibling = newChild;
    }

    // Remove elements that were not reused this frame.
    _discardActiveChildren(oldSurface);
  }

  Map<PersistedSurface, PersistedSurface> _matchChildren(
      PersistedContainerSurface oldSurface) {
    final int newUnfilteredChildCount = _children.length;
    final int oldUnfilteredChildCount = oldSurface._children.length;

    // Extract new nodes that need to be matched.
    final List<PersistedSurface> newChildren = <PersistedSurface>[];
    for (int i = 0; i < newUnfilteredChildCount; i++) {
      final PersistedSurface child = _children[i];
      if (child.isCreated) {
        newChildren.add(child);
      }
    }

    // Extract old nodes that can be matched against.
    final List<PersistedSurface> oldChildren = <PersistedSurface>[];
    for (int i = 0; i < oldUnfilteredChildCount; i++) {
      final PersistedSurface child = oldSurface._children[i];
      if (child.isActive) {
        oldChildren.add(child);
      }
    }

    final int newChildCount = newChildren.length;
    final int oldChildCount = oldChildren.length;

    if (newChildCount == 0 || oldChildCount == 0) {
      // Nothing to match.
      return const <PersistedSurface, PersistedSurface>{};
    }

    final List<_PersistedSurfaceMatch> allMatches = <_PersistedSurfaceMatch>[];

    // This is worst-case O(N*M) but it only happens when:
    // - most of the children are newly created (N)
    // - the old container is not empty (M)
    //
    // The choice here is between recreating all DOM nodes from scratch, or try
    // finding matches and reusing their elements.
    for (int indexInNew = 0; indexInNew < newChildCount; indexInNew += 1) {
      final PersistedSurface newChild = newChildren[indexInNew];
      for (int indexInOld = 0; indexInOld < oldChildCount; indexInOld += 1) {
        final PersistedSurface oldChild = oldChildren[indexInOld];
        final bool childAlreadyClaimed = oldChild == null;
        if (childAlreadyClaimed || !newChild.canUpdateAsMatch(oldChild)) {
          continue;
        }
        allMatches.add(_PersistedSurfaceMatch(
          matchQuality: newChild.matchForUpdate(oldChild),
          newChild: newChild,
          oldChildIndex: indexInOld,
        ));
      }
    }

    allMatches.sort((_PersistedSurfaceMatch m1, _PersistedSurfaceMatch m2) {
      return m1.matchQuality.compareTo(m2.matchQuality);
    });

    final Map<PersistedSurface, PersistedSurface> result =
        <PersistedSurface, PersistedSurface>{};
    for (int i = 0; i < allMatches.length; i += 1) {
      final _PersistedSurfaceMatch match = allMatches[i];
      // This may be null if it has been claimed.
      final PersistedSurface matchedChild = oldChildren[match.oldChildIndex];
      if (matchedChild != null) {
        oldChildren[match.oldChildIndex] = null;
        result[match.newChild] = matchedChild; // claim it
      }
    }

    assert(result.length == Set<PersistedSurface>.from(result.values).length);
    return result;
  }

  @override
  void retain() {
    super.retain();
    final int len = _children.length;
    for (int i = 0; i < len; i++) {
      _children[i].retain();
    }
  }

  @override
  void revive() {
    super.revive();
    final int len = _children.length;
    for (int i = 0; i < len; i++) {
      _children[i].revive();
    }
  }

  @override
  void discard() {
    super.discard();
    _discardActiveChildren(this);
  }

  @override
  @protected
  @mustCallSuper
  void debugValidate(List<String> validationErrors) {
    super.debugValidate(validationErrors);
    for (int i = 0; i < _children.length; i++) {
      final PersistedSurface child = _children[i];
      if (child.parent != this) {
        validationErrors.add(
            '${debugIdentify(child)} parent is ${debugIdentify(child.parent)} but expected the parent to be ${debugIdentify(this)}');
      }
    }
    for (int i = 0; i < _children.length; i++) {
      _children[i].debugValidate(validationErrors);
    }
  }

  @override
  void debugPrintChildren(StringBuffer buffer, int indent) {
    super.debugPrintChildren(buffer, indent);
    for (int i = 0; i < _children.length; i++) {
      _children[i].debugPrint(buffer, indent + 1);
    }
  }
}

/// A custom class used by [PersistedContainerSurface._matchChildren].
class _PersistedSurfaceMatch {
  _PersistedSurfaceMatch({
    this.newChild,
    this.oldChildIndex,
    this.matchQuality,
  });

  /// The child in the new scene who we are trying to match to an existing
  /// child.
  final PersistedSurface newChild;

  /// The index pointing at the old child that matched [newChild] in the old
  /// child list.
  ///
  /// The indirection is intentional because when matches are traversed old
  /// children are claimed and nulled out in the array.
  final int oldChildIndex;

  /// The score of how well [newChild] matched the old child as computed by
  /// [PersistedSurface.matchForUpdate].
  final double matchQuality;
}
