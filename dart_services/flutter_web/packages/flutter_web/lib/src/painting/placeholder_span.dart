// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-08-07T09:50:31.285679.

import 'package:flutter_web_ui/ui.dart' as ui show PlaceholderAlignment;

import 'package:flutter_web/foundation.dart';

import 'basic_types.dart';
import 'inline_span.dart';
import 'text_painter.dart';
import 'text_span.dart';
import 'text_style.dart';

/// An immutable placeholder that is embedded inline within text.
///
/// [PlaceholderSpan] represents a placeholder that acts as a stand-in for other
/// content. A [PlaceholderSpan] by itself does not contain useful
/// information to change a [TextSpan]. Instead, this class must be extended
/// to define contents.
///
/// [WidgetSpan] from the widgets library extends [PlaceholderSpan] and may be
/// used instead to specify a widget as the contents of the placeholder.
///
/// See also:
///
///  * [WidgetSpan], a leaf node that represents an embedded inline widget.
///  * [TextSpan], a node that represents text in a [TextSpan] tree.
///  * [Text], a widget for showing uniformly-styled text.
///  * [RichText], a widget for finer control of text rendering.
///  * [TextPainter], a class for painting [TextSpan] objects on a [Canvas].
abstract class PlaceholderSpan extends InlineSpan {
  /// Creates a [PlaceholderSpan] with the given values.
  ///
  /// A [TextStyle] may be provided with the [style] property, but only the
  /// decoration, foreground, background, and spacing options will be used.
  const PlaceholderSpan({
    this.alignment = ui.PlaceholderAlignment.bottom,
    this.baseline,
    TextStyle style,
  }) : super(style: style,);

  /// How the placeholder aligns vertically with the text.
  ///
  /// See [ui.PlaceholderAlignment] for details on each mode.
  final ui.PlaceholderAlignment alignment;

  /// The [TextBaseline] to align against when using [ui.PlaceholderAlignment.baseline],
  /// [ui.PlaceholderAlignment.aboveBaseline], and [ui.PlaceholderAlignment.belowBaseline].
  ///
  /// This is ignored when using other alignment modes.
  final TextBaseline baseline;

  /// [PlaceholderSpan]s are flattened to a `0xFFFC` object replacement character in the
  /// plain text representation when `includePlaceholders` is true.
  @override
  void computeToPlainText(StringBuffer buffer, {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
    if (includePlaceholders) {
      buffer.write('\uFFFC');
    }
  }

  @override
  void computeSemanticsInformation(List<InlineSpanSemanticsInformation> collector) {
    collector.add(InlineSpanSemanticsInformation.placeholder);
  }

  // TODO(garyq): Remove this after next stable release.
  /// The [visitTextSpan] method is invalid on [PlaceholderSpan]s
  @override
  @Deprecated('Use to visitChildren instead')
  bool visitTextSpan(bool visitor(TextSpan span)) {
    assert(false, 'visitTextSpan is deprecated. Use visitChildren to support InlineSpans');
    return false;
  }

  /// Populates the `semanticsOffsets` and `semanticsElements` with the appropriate data
  /// to be able to construct a [SemanticsNode].
  ///
  /// [PlaceholderSpan]s have a text length of 1, which corresponds to the object
  /// replacement character (0xFFFC) that is inserted to represent it.
  ///
  /// Null is added to `semanticsElements` for [PlaceholderSpan]s.
  @override
  void describeSemantics(Accumulator offset, List<int> semanticsOffsets, List<dynamic> semanticsElements) {
    semanticsOffsets.add(offset.value);
    semanticsOffsets.add(offset.value + 1);
    semanticsElements.add(null); // null indicates this is a placeholder.
    offset.increment(1);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(EnumProperty<ui.PlaceholderAlignment>('alignment', alignment, defaultValue: null));
    properties.add(EnumProperty<TextBaseline>('baseline', baseline, defaultValue: null));
  }
}
