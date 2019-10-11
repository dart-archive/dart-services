// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_ui/ui.dart' as ui show Image;

import 'box.dart';
import 'object.dart';

export 'package:flutter_web/painting.dart' show BoxFit, ImageRepeat;

/// An image in the render tree.
///
/// The render image attempts to find a size for itself that fits in the given
/// constraints and preserves the image's intrinsic aspect ratio.
///
/// The image is painted using [paintImage], which describes the meanings of the
/// various fields on this class in more detail.
class RenderImage extends RenderBox {
  /// Creates a render box that displays an image.
  ///
  /// The [scale], [alignment], [repeat], [matchTextDirection] and [filterQuality] arguments
  /// must not be null. The [textDirection] argument must not be null if
  /// [alignment] will need resolving or if [matchTextDirection] is true.
  RenderImage(
      {ui.Image image,
      double width,
      double height,
      double scale = 1.0,
      Color color,
      BlendMode colorBlendMode,
      BoxFit fit,
      AlignmentGeometry alignment = Alignment.center,
      ImageRepeat repeat = ImageRepeat.noRepeat,
      Rect centerSlice,
      bool matchTextDirection = false,
      TextDirection textDirection,
      bool invertColors = false,
      FilterQuality filterQuality = FilterQuality.low})
      : assert(scale != null),
        assert(repeat != null),
        assert(alignment != null),
        assert(filterQuality != null),
        assert(matchTextDirection != null),
        _image = image,
        _width = width,
        _height = height,
        _scale = scale,
        _color = color,
        _colorBlendMode = colorBlendMode,
        _fit = fit,
        _alignment = alignment,
        _repeat = repeat,
        _centerSlice = centerSlice,
        _matchTextDirection = matchTextDirection,
        _invertColors = invertColors,
        _textDirection = textDirection,
        _filterQuality = filterQuality {
    _updateColorFilter();
  }

  Alignment _resolvedAlignment;
  bool _flipHorizontally;

  void _resolve() {
    if (_resolvedAlignment != null) return;
    _resolvedAlignment = alignment.resolve(textDirection);
    _flipHorizontally =
        matchTextDirection && textDirection == TextDirection.rtl;
  }

  void _markNeedResolution() {
    _resolvedAlignment = null;
    _flipHorizontally = null;
    markNeedsPaint();
  }

  /// The image to display.
  ui.Image get image => _image;
  ui.Image _image;
  set image(ui.Image value) {
    if (value == _image) return;
    _image = value;
    markNeedsPaint();
    if (_width == null || _height == null) markNeedsLayout();
  }

  /// If non-null, requires the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  double get width => _width;
  double _width;
  set width(double value) {
    if (value == _width) return;
    _width = value;
    markNeedsLayout();
  }

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio.
  double get height => _height;
  double _height;
  set height(double value) {
    if (value == _height) return;
    _height = value;
    markNeedsLayout();
  }

  /// Specifies the image's scale.
  ///
  /// Used when determining the best display size for the image.
  double get scale => _scale;
  double _scale;
  set scale(double value) {
    assert(value != null);
    if (value == _scale) return;
    _scale = value;
    markNeedsLayout();
  }

  ColorFilter _colorFilter;

  void _updateColorFilter() {
    if (_color == null)
      _colorFilter = null;
    else
      _colorFilter =
          ColorFilter.mode(_color, _colorBlendMode ?? BlendMode.srcIn);
  }

  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) return;
    _color = value;
    _updateColorFilter();
    markNeedsPaint();
  }

  /// Used to set the filterQuality of the image
  /// Use the [FilterQuality.low] quality setting to scale the image, which corresponds to
  /// bilinear interpolation, rather than the default [FilterQuality.none] which corresponds
  /// to nearest-neighbor.
  FilterQuality get filterQuality => _filterQuality;
  FilterQuality _filterQuality;
  set filterQuality(FilterQuality value) {
    assert(value != null);
    if (value == _filterQuality) return;
    _filterQuality = value;
    markNeedsPaint();
  }

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each blend mode.
  BlendMode get colorBlendMode => _colorBlendMode;
  BlendMode _colorBlendMode;
  set colorBlendMode(BlendMode value) {
    if (value == _colorBlendMode) return;
    _colorBlendMode = value;
    _updateColorFilter();
    markNeedsPaint();
  }

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  BoxFit get fit => _fit;
  BoxFit _fit;
  set fit(BoxFit value) {
    if (value == _fit) return;
    _fit = value;
    markNeedsPaint();
  }

  /// How to align the image within its bounds.
  ///
  /// If this is set to a text-direction-dependent value, [textDirection] must
  /// not be null.
  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;
  set alignment(AlignmentGeometry value) {
    assert(value != null);
    if (value == _alignment) return;
    _alignment = value;
    _markNeedResolution();
  }

  /// How to repeat this image if it doesn't fill its layout bounds.
  ImageRepeat get repeat => _repeat;
  ImageRepeat _repeat;
  set repeat(ImageRepeat value) {
    assert(value != null);
    if (value == _repeat) return;
    _repeat = value;
    markNeedsPaint();
  }

  /// The center slice for a nine-patch image.
  ///
  /// The region of the image inside the center slice will be stretched both
  /// horizontally and vertically to fit the image into its destination. The
  /// region of the image above and below the center slice will be stretched
  /// only horizontally and the region of the image to the left and right of
  /// the center slice will be stretched only vertically.
  Rect get centerSlice => _centerSlice;
  Rect _centerSlice;
  set centerSlice(Rect value) {
    if (value == _centerSlice) return;
    _centerSlice = value;
    markNeedsPaint();
  }

  /// Whether to invert the colors of the image.
  ///
  /// inverting the colors of an image applies a new color filter to the paint.
  /// If there is another specified color filter, the invert will be applied
  /// after it. This is primarily used for implementing smart invert on iOS.
  bool get invertColors => _invertColors;
  bool _invertColors;
  set invertColors(bool value) {
    if (value == _invertColors) return;
    _invertColors = value;
    markNeedsPaint();
  }

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// images); and in [TextDirection.rtl] contexts, the image will be drawn with
  /// a scaling factor of -1 in the horizontal direction so that the origin is
  /// in the top right.
  ///
  /// This is occasionally used with images in right-to-left environments, for
  /// images that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip images with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is set to true, [textDirection] must not be null.
  bool get matchTextDirection => _matchTextDirection;
  bool _matchTextDirection;
  set matchTextDirection(bool value) {
    assert(value != null);
    if (value == _matchTextDirection) return;
    _matchTextDirection = value;
    _markNeedResolution();
  }

  /// The text direction with which to resolve [alignment].
  ///
  /// This may be changed to null, but only after the [alignment] and
  /// [matchTextDirection] properties have been changed to values that do not
  /// depend on the direction.
  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _markNeedResolution();
  }

  /// Find a size for the render image within the given constraints.
  ///
  ///  - The dimensions of the RenderImage must fit within the constraints.
  ///  - The aspect ratio of the RenderImage matches the intrinsic aspect
  ///    ratio of the image.
  ///  - The RenderImage's dimension are maximal subject to being smaller than
  ///    the intrinsic size of the image.
  Size _sizeForConstraints(BoxConstraints constraints) {
    // Folds the given |width| and |height| into |constraints| so they can all
    // be treated uniformly.
    constraints = BoxConstraints.tightFor(width: _width, height: _height)
        .enforce(constraints);

    if (_image == null) return constraints.smallest;

    return constraints.constrainSizeAndAttemptToPreserveAspectRatio(Size(
        _image.width.toDouble() / _scale, _image.height.toDouble() / _scale));
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    assert(height >= 0.0);
    if (_width == null && _height == null) return 0.0;
    return _sizeForConstraints(BoxConstraints.tightForFinite(height: height))
        .width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    assert(height >= 0.0);
    return _sizeForConstraints(BoxConstraints.tightForFinite(height: height))
        .width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    assert(width >= 0.0);
    if (_width == null && _height == null) return 0.0;
    return _sizeForConstraints(BoxConstraints.tightForFinite(width: width))
        .height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    assert(width >= 0.0);
    return _sizeForConstraints(BoxConstraints.tightForFinite(width: width))
        .height;
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void performLayout() {
    size = _sizeForConstraints(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_image == null) return;
    _resolve();
    assert(_resolvedAlignment != null);
    assert(_flipHorizontally != null);
    paintImage(
        canvas: context.canvas,
        rect: offset & size,
        image: _image,
        scale: _scale,
        colorFilter: _colorFilter,
        fit: _fit,
        alignment: _resolvedAlignment,
        centerSlice: _centerSlice,
        repeat: _repeat,
        flipHorizontally: _flipHorizontally,
        invertColors: invertColors,
        filterQuality: _filterQuality);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ui.Image>('image', image));
    properties.add(DoubleProperty('width', width, defaultValue: null));
    properties.add(DoubleProperty('height', height, defaultValue: null));
    properties.add(DoubleProperty('scale', scale, defaultValue: 1.0));
    properties
        .add(DiagnosticsProperty<Color>('color', color, defaultValue: null));
    properties.add(EnumProperty<BlendMode>('colorBlendMode', colorBlendMode,
        defaultValue: null));
    properties.add(EnumProperty<BoxFit>('fit', fit, defaultValue: null));
    properties.add(DiagnosticsProperty<AlignmentGeometry>(
        'alignment', alignment,
        defaultValue: null));
    properties.add(EnumProperty<ImageRepeat>('repeat', repeat,
        defaultValue: ImageRepeat.noRepeat));
    properties.add(DiagnosticsProperty<Rect>('centerSlice', centerSlice,
        defaultValue: null));
    properties.add(FlagProperty('matchTextDirection',
        value: matchTextDirection, ifTrue: 'match text direction'));
    properties.add(EnumProperty<TextDirection>('textDirection', textDirection,
        defaultValue: null));
    properties.add(DiagnosticsProperty<bool>('invertColors', invertColors));
    properties.add(EnumProperty<FilterQuality>('filterQuality', filterQuality));
  }
}
