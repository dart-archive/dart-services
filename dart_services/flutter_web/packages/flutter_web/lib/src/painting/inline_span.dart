// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced. * Contains Web DELTA *

import 'package:flutter_web_ui/ui.dart' as ui show ParagraphBuilder;

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/gestures.dart';

import 'basic_types.dart';
import 'text_painter.dart';
import 'text_span.dart';
import 'text_style.dart';

/// Mutable wrapper of an integer that can be passed by reference to track a
/// value across a recursive stack.
class Accumulator {
  /// [Accumulator] may be initialized with a specified value, otherwise, it will
  /// initialize to zero.
  Accumulator([this._value = 0]);

  /// The integer stored in this [Accumulator].
  int get value => _value;
  int _value;

  /// Increases the [value] by the `addend`.
  void increment(int addend) {
    assert(addend >= 0);
    _value += addend;
  }
}
/// Called on each span as [InlineSpan.visitChildren] walks the [InlineSpan] tree.
///
/// Returns true when the walk should continue, and false to stop visiting further
/// [InlineSpan]s.
typedef InlineSpanVisitor = bool Function(InlineSpan span);

/// The textual and semantic label information for an [InlineSpan].
///
/// For [PlaceholderSpan]s, [InlineSpanSemanticsInformation.placeholder] is used by default.
///
/// See also:
///   * [InlineSpan.getSemanticsInformation]
@immutable
class InlineSpanSemanticsInformation {
  /// Constructs an object that holds the text and sematnics label values of an
  /// [InlineSpan].
  ///
  /// The text parameter must not be null.
  ///
  /// Use [InlineSpanSemanticsInformation.placeholder] instead of directly setting
  /// [isPlaceholder].
  const InlineSpanSemanticsInformation(
    this.text, {
    this.isPlaceholder = false,
    this.semanticsLabel,
    this.recognizer
  }) : assert(text != null),
       assert(isPlaceholder != null),
       assert(isPlaceholder == false || (text == '\uFFFC' && semanticsLabel == null && recognizer == null)),
       requiresOwnNode = isPlaceholder || recognizer != null;

  /// The text info for a [PlaceholderSpan].
  static const InlineSpanSemanticsInformation placeholder = InlineSpanSemanticsInformation('\uFFFC', isPlaceholder: true);

  /// The text value, if any.  For [PlaceholderSpan]s, this will be the unicode
  /// placeholder value.
  final String text;

  /// The semanticsLabel, if any.
  final String semanticsLabel;

  /// The gesture recognizer, if any, for this span.
  final GestureRecognizer recognizer;

  /// Whether this is for a placeholder span.
  final bool isPlaceholder;

  /// True if this configuration should get its own semantics node.
  ///
  /// This will be the case of the [recognizer] is not null, of if
  /// [isPlaceholder] is true.
  final bool requiresOwnNode;

  @override
  bool operator ==(dynamic other) {
    if (other is! InlineSpanSemanticsInformation) {
      return false;
    }
    return other.text == text && other.semanticsLabel == semanticsLabel && other.recognizer == recognizer && other.isPlaceholder == isPlaceholder;
  }

  @override
  int get hashCode => hashValues(text, semanticsLabel, recognizer, isPlaceholder);

  @override
  String toString() => '$runtimeType{text: $text, semanticsLabel: $semanticsLabel, recognizer: $recognizer}';
}

/// An immutable span of inline content which forms part of a paragraph.
///
///  * The subclass [TextSpan] specifies text and may contain child [InlineSpan]s.
///  * The subclass [PlaceholderSpan] represents a placeholder that may be
///    filled with non-text content. [PlaceholderSpan] itself defines a
///    [ui.PlaceholderAlignemnt] and a [TextBaseline]. To be useful,
///    [PlaceholderSpan] must be extended to define content. An instance of
///    this is the [WidgetSpan] class in the widgets library.
///  * The subclass [WidgetSpan] specifies embedded inline widgets.
///
/// {@tool sample}
///
/// This example shows a tree of [InlineSpan]s that make a query asking for a
/// name with a [TextField] embedded inline.
///
/// ```dart
/// Text.rich(
///   TextSpan(
///     text: 'My name is ',
///     style: TextStyle(color: Colors.black),
///     children: <InlineSpan>[
///       WidgetSpan(
///         alignment: PlaceholderAlignment.baseline,
///         baseline: TextBaseline.alphabetic,
///         child: ConstrainedBox(
///           constraints: BoxConstraints(maxWidth: 100),
///           child: TextField(),
///         )
///       ),
///       TextSpan(
///         text: '.',
///       ),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Text], a widget for showing uniformly-styled text.
///  * [RichText], a widget for finer control of text rendering.
///  * [TextPainter], a class for painting [InlineSpan] objects on a [Canvas].
@immutable
abstract class InlineSpan extends DiagnosticableTree {
  /// Creates an [InlineSpan] with the given values.
  const InlineSpan({
    this.style,
  });

  /// The [TextStyle] to apply to this span.
  ///
  /// The [style] is also applied to any child spans when this is an instance
  /// of [TextSpan].
  final TextStyle style;

  // TODO(garyq): Remove the deprecated visitTextSpan, text, and children.
  /// Returns the text associated with this span if this is an instance of [TextSpan],
  /// otherwise returns null.
  @Deprecated('InlineSpan does not innately have text. Use TextSpan.text instead.')
  String get text => null;

  // TODO(garyq): Remove the deprecated visitTextSpan, text, and children.
  /// Returns the [InlineSpan] children list associated with this span if this is an
  /// instance of [TextSpan], otherwise returns null.
  @Deprecated('InlineSpan does not innately have children. Use TextSpan.children instead.')
  List<InlineSpan> get children => null;

  /// Returns the [GestureRecognizer] associated with this span if this is an
  /// instance of [TextSpan], otherwise returns null.
  @Deprecated('InlineSpan does not innately have a recognizer. Use TextSpan.recognizer instead.')
  GestureRecognizer get recognizer => null;

  /// Apply the properties of this object to the given [ParagraphBuilder], from
  /// which a [Paragraph] can be obtained.
  ///
  /// The `textScaleFactor` parameter specifies a scale that the text and
  /// placeholders will be scaled by. The scaling is performed before layout,
  /// so the text will be laid out with the scaled glyphs and placeholders.
  ///
  /// The `dimensions` parameter specifies the sizes of the placeholders.
  /// Each [PlaceholderSpan] must be paired with a [PlaceholderDimensions]
  /// in the same order as defined in the [InlineSpan] tree.
  ///
  /// [Paragraph] objects can be drawn on [Canvas] objects.
  void build(ui.ParagraphBuilder builder, { double textScaleFactor = 1.0, List<PlaceholderDimensions> dimensions });

  // TODO(garyq): Remove the deprecated visitTextSpan, text, and children.
  /// Walks this [TextSpan] and any descendants in pre-order and calls `visitor`
  /// for each span that has content.
  ///
  /// When `visitor` returns true, the walk will continue. When `visitor` returns
  /// false, then the walk will end.
  @Deprecated('Use visitChildren instead')
  bool visitTextSpan(bool visitor(TextSpan span));

  /// Walks this [InlineSpan] and any descendants in pre-order and calls `visitor`
  /// for each span that has content.
  ///
  /// When `visitor` returns true, the walk will continue. When `visitor` returns
  /// false, then the walk will end.
  bool visitChildren(InlineSpanVisitor visitor);

  /// Returns the [InlineSpan] that contains the given position in the text.
  InlineSpan getSpanForPosition(TextPosition position) {
    assert(debugAssertIsValid());
    final Accumulator offset = Accumulator();
    InlineSpan result;
    visitChildren((InlineSpan span) {
      result = span.getSpanForPositionVisitor(position, offset);
      return result == null;
    });
    return result;
  }

  /// Performs the check at each [InlineSpan] for if the `position` falls within the range
  /// of the span and returns the span if it does.
  ///
  /// The `offset` parameter tracks the current index offset in the text buffer formed
  /// if the contents of the [InlineSpan] tree were concatenated together starting
  /// from the root [InlineSpan].
  ///
  /// This method should not be directly called. Use [getSpanForPosition] instead.
  @protected
  InlineSpan getSpanForPositionVisitor(TextPosition position, Accumulator offset);

  /// Flattens the [InlineSpan] tree into a single string.
  ///
  /// Styles are not honored in this process. If `includeSemanticsLabels` is
  /// true, then the text returned will include the [TextSpan.semanticsLabel]s
  /// instead of the text contents for [TextSpan]s.
  ///
  /// When `includePlaceholders` is true, [PlaceholderSpan]s in the tree will be
  /// represented as a 0xFFFC 'object replacement character'.
  String toPlainText({bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
    final StringBuffer buffer = StringBuffer();
    computeToPlainText(buffer, includeSemanticsLabels: includeSemanticsLabels, includePlaceholders: includePlaceholders);
    return buffer.toString();
  }

  /// Flattens the [InlineSpan] tree to a list of
  /// [InlineSpanSemanticsInformation] objects.
  ///
  /// [PlaceholderSpan]s in the tree will be represented with a
  /// [InlineSpanSemanticsInformation.placeholder] value.
  List<InlineSpanSemanticsInformation> getSemanticsInformation() {
    final List<InlineSpanSemanticsInformation> collector = <InlineSpanSemanticsInformation>[];
    computeSemanticsInformation(collector);
    return collector;
  }

  /// Walks the [InlineSpan] tree and accumulates a list of
  /// [InlineSpanSemanticsInformation] objects.
  ///
  /// This method should not be directly called.  Use
  /// [getSemanticsInformation] instead.
  ///
  /// [PlaceholderSpan]s in the tree will be represented with a
  /// [InlineSpanSemanticsInformation.placeholder] value.
  @protected
  void computeSemanticsInformation(List<InlineSpanSemanticsInformation> collector);

  /// Walks the [InlineSpan] tree and writes the plain text representation to `buffer`.
  ///
  /// This method should not be directly called. Use [toPlainText] instead.
  ///
  /// Styles are not honored in this process. If `includeSemanticsLabels` is
  /// true, then the text returned will include the [TextSpan.semanticsLabel]s
  /// instead of the text contents for [TextSpan]s.
  ///
  /// When `includePlaceholders` is true, [PlaceholderSpan]s in the tree will be
  /// represented as a 0xFFFC 'object replacement character'.
  ///
  /// The plain-text representation of this [InlineSpan] is written into the `buffer`.
  /// This method will then recursively call [computeToPlainText] on its childen
  /// [InlineSpan]s if available.
  @protected
  void computeToPlainText(StringBuffer buffer, {bool includeSemanticsLabels = true, bool includePlaceholders = true});

  /// Returns the UTF-16 code unit at the given `index` in the flattened string.
  ///
  /// This only accounts for the [TextSpan.text] values and ignores [PlaceholderSpans].
  ///
  /// Returns null if the `index` is out of bounds.
  int codeUnitAt(int index) {
    if (index < 0)
      return null;
    final Accumulator offset = Accumulator();
    int result;
    visitChildren((InlineSpan span) {
      result = span.codeUnitAtVisitor(index, offset);
      return result == null;
    });
    return result;
  }

  /// Performs the check at each [InlineSpan] for if the `index` falls within the range
  /// of the span and returns the corresponding code unit. Returns null otherwise.
  ///
  /// The `offset` parameter tracks the current index offset in the text buffer formed
  /// if the contents of the [InlineSpan] tree were concatenated together starting
  /// from the root [InlineSpan].
  ///
  /// This method should not be directly called. Use [codeUnitAt] instead.
  @protected
  int codeUnitAtVisitor(int index, Accumulator offset);

  /// Populates the `semanticsOffsets` and `semanticsElements` with the appropriate data
  /// to be able to construct a [SemanticsNode].
  ///
  /// If applicable, the beginning and end text offset are added to [semanticsOffsets].
  /// [PlaceholderSpan]s have a text length of 1, which corresponds to the object
  /// replacement character (0xFFFC) that is inserted to represent it.
  ///
  /// Any [GestureRecognizer]s are added to `semanticsElements`. Null is added to
  /// `semanticsElements` for [PlaceholderSpan]s.
  @Deprecated('Implement computeSemanticsInformation instead.')
  void describeSemantics(Accumulator offset, List<int> semanticsOffsets, List<dynamic> semanticsElements);

  /// In checked mode, throws an exception if the object is not in a
  /// valid configuration. Otherwise, returns true.
  ///
  /// This is intended to be used as follows:
  ///
  /// ```dart
  /// assert(myInlineSpan.debugAssertIsValid());
  /// ```
  bool debugAssertIsValid() => true;

  /// Describe the difference between this span and another, in terms of
  /// how much damage it will make to the rendering. The comparison is deep.
  ///
  /// Comparing [InlineSpan] objects of different types, for example, comparing
  /// a [TextSpan] to a [WidgetSpan], always results in [RenderComparison.layout].
  ///
  /// See also:
  ///
  ///  * [TextStyle.compareTo], which does the same thing for [TextStyle]s.
  RenderComparison compareTo(InlineSpan other);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    final InlineSpan typedOther = other;
    return typedOther.style == style;
  }

  // TODO(flutter_web): Remove this once super!=other bug in TextSpan is fixed.
  bool equals(dynamic other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    final InlineSpan typedOther = other;
    return typedOther.style == style;
  }

  @override
  int get hashCode => style.hashCode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.defaultDiagnosticsTreeStyle = DiagnosticsTreeStyle.whitespace;

    if (style != null) {
      style.debugFillProperties(properties);
    }
  }
}
