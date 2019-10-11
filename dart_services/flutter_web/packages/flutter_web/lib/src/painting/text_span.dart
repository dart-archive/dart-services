// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced. * Contains Web DELTA *

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/gestures.dart';
import 'package:flutter_web/services.dart';
import 'package:flutter_web_ui/ui.dart' as ui show ParagraphBuilder;

import 'basic_types.dart';
import 'inline_span.dart';
import 'text_painter.dart';
import 'text_style.dart';

/// An immutable span of text.
///
/// A [TextSpan] object can be styled using its [style] property.
/// The style will be applied to the [text] and the [children].
///
/// A [TextSpan] object can just have plain text, or it can have
/// children [TextSpan] objects with their own styles that (possibly
/// only partially) override the [style] of this object. If a
/// [TextSpan] has both [text] and [children], then the [text] is
/// treated as if it was an unstyled [TextSpan] at the start of the
/// [children] list. Leaving the [TextSpan.text] field null results
/// in the [TextSpan] acting as an empty node in the [InlineSpan]
/// tree with a list of children.
///
/// To paint a [TextSpan] on a [Canvas], use a [TextPainter]. To display a text
/// span in a widget, use a [RichText]. For text with a single style, consider
/// using the [Text] widget.
///
/// {@tool sample}
///
/// The text "Hello world!", in black:
///
/// ```dart
/// TextSpan(
///   text: 'Hello world!',
///   style: TextStyle(color: Colors.black),
/// )
/// ```
/// {@end-tool}
///
/// _There is some more detailed sample code in the documentation for the
/// [recognizer] property._
///
/// The [TextSpan.text] will be used as the semantics label unless overriden
/// by the [TextSpan.semanticsLabel] property. Any [PlaceholderSpan]s in the
/// [TextSpan.children] list will separate the text before and after it into
/// two semantics nodes.
///
/// See also:
///
///  * [WidgetSpan], a leaf node that represents an embedded inline widget
///    in an [InlineSpan] tree. Specify a widget within the [children]
///    list by wrapping the widget with a [WidgetSpan]. The widget will be
///    laid out inline within the paragraph.
///  * [Text], a widget for showing uniformly-styled text.
///  * [RichText], a widget for finer control of text rendering.
///  * [TextPainter], a class for painting [TextSpan] objects on a [Canvas].
@immutable
class TextSpan extends InlineSpan {
  /// Creates a [TextSpan] with the given values.
  ///
  /// For the object to be useful, at least one of [text] or
  /// [children] should be set.
  const TextSpan({
    this.text,
    this.children,
    TextStyle style,
    this.recognizer,
    this.semanticsLabel,
  }) : super(style: style,);

  /// The text contained in this span.
  ///
  /// If both [text] and [children] are non-null, the text will precede the
  /// children.
  ///
  /// This getter does not include the contents of its children.
  @override
  final String text;


  /// Additional spans to include as children.
  ///
  /// If both [text] and [children] are non-null, the text will precede the
  /// children.
  ///
  /// Modifying the list after the [TextSpan] has been created is not
  /// supported and may have unexpected results.
  ///
  /// The list must not contain any nulls.
  @override
  final List<InlineSpan> children;

  /// A gesture recognizer that will receive events that hit this span.
  ///
  /// [InlineSpan] itself does not implement hit testing or event dispatch. The
  /// object that manages the [InlineSpan] painting is also responsible for
  /// dispatching events. In the rendering library, that is the
  /// [RenderParagraph] object, which corresponds to the [RichText] widget in
  /// the widgets layer; these objects do not bubble events in [InlineSpan]s, so a
  /// [recognizer] is only effective for events that directly hit the [text] of
  /// that [InlineSpan], not any of its [children].
  ///
  /// [InlineSpan] also does not manage the lifetime of the gesture recognizer.
  /// The code that owns the [GestureRecognizer] object must call
  /// [GestureRecognizer.dispose] when the [InlineSpan] object is no longer used.
  ///
  /// {@tool sample}
  ///
  /// This example shows how to manage the lifetime of a gesture recognizer
  /// provided to an [InlineSpan] object. It defines a `BuzzingText` widget which
  /// uses the [HapticFeedback] class to vibrate the device when the user
  /// long-presses the "find the" span, which is underlined in wavy green. The
  /// hit-testing is handled by the [RichText] widget.
  ///
  /// ```dart
  /// class BuzzingText extends StatefulWidget {
  ///   @override
  ///   _BuzzingTextState createState() => _BuzzingTextState();
  /// }
  ///
  /// class _BuzzingTextState extends State<BuzzingText> {
  ///   LongPressGestureRecognizer _longPressRecognizer;
  ///
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     _longPressRecognizer = LongPressGestureRecognizer()
  ///       ..onLongPress = _handlePress;
  ///   }
  ///
  ///   @override
  ///   void dispose() {
  ///     _longPressRecognizer.dispose();
  ///     super.dispose();
  ///   }
  ///
  ///   void _handlePress() {
  ///     HapticFeedback.vibrate();
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Text.rich(
  ///       TextSpan(
  ///         text: 'Can you ',
  ///         style: TextStyle(color: Colors.black),
  ///         children: <InlineSpan>[
  ///           TextSpan(
  ///             text: 'find the',
  ///             style: TextStyle(
  ///               color: Colors.green,
  ///               decoration: TextDecoration.underline,
  ///               decorationStyle: TextDecorationStyle.wavy,
  ///             ),
  ///             recognizer: _longPressRecognizer,
  ///           ),
  ///           TextSpan(
  ///             text: ' secret?',
  ///           ),
  ///         ],
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  @override
  final GestureRecognizer recognizer;

  /// An alternative semantics label for this [TextSpan].
  ///
  /// If present, the semantics of this span will contain this value instead
  /// of the actual text.
  ///
  /// This is useful for replacing abbreviations or shorthands with the full
  /// text value:
  ///
  /// ```dart
  /// TextSpan(text: r'$$', semanticsLabel: 'Double dollars')
  /// ```
  final String semanticsLabel;

  /// Apply the [style], [text], and [children] of this object to the
  /// given [ParagraphBuilder], from which a [Paragraph] can be obtained.
  /// [Paragraph] objects can be drawn on [Canvas] objects.
  ///
  /// Rather than using this directly, it's simpler to use the
  /// [TextPainter] class to paint [TextSpan] objects onto [Canvas]
  /// objects.
  @override
  void build(ui.ParagraphBuilder builder, { double textScaleFactor = 1.0, List<PlaceholderDimensions> dimensions }) {
    assert(debugAssertIsValid());
    final bool hasStyle = style != null;
    if (hasStyle)
      builder.pushStyle(style.getTextStyle(textScaleFactor: textScaleFactor));
    if (text != null)
      builder.addText(text);
    if (children != null) {
      for (InlineSpan child in children) {
        assert(child != null);
        child.build(builder, textScaleFactor: textScaleFactor, dimensions: dimensions);
      }
    }
    if (hasStyle)
      builder.pop();
  }

  /// Walks this [TextSpan] and its descendants in pre-order and calls [visitor]
  /// for each span that has text.
  ///
  /// When `visitor` returns true, the walk will continue. When `visitor` returns
  /// false, then the walk will end.
  @override
  bool visitChildren(InlineSpanVisitor visitor) {
    if (text != null) {
      if (!visitor(this))
        return false;
    }
    if (children != null) {
      for (InlineSpan child in children) {
        if (!child.visitChildren(visitor))
          return false;
      }
    }
    return true;
  }

  // TODO(garyq): Remove this after next stable release.
  /// Walks this [TextSpan] and any descendants in pre-order and calls `visitor`
  /// for each span that has content.
  ///
  /// When `visitor` returns true, the walk will continue. When `visitor` returns
  /// false, then the walk will end.
  @override
  @Deprecated('Use to visitChildren instead')
  bool visitTextSpan(bool visitor(TextSpan span)) {
    if (text != null) {
      if (!visitor(this))
        return false;
    }
    if (children != null) {
      for (InlineSpan child in children) {
        assert(child is TextSpan, 'visitTextSpan is deprecated. Use visitChildren to support InlineSpans');
        final TextSpan textSpanChild = child;
        if (!textSpanChild.visitTextSpan(visitor))
          return false;
      }
    }
    return true;
  }

  /// Returns the text span that contains the given position in the text.
  @override
  InlineSpan getSpanForPositionVisitor(TextPosition position, Accumulator offset) {
    if (text == null) {
      return null;
    }
    final TextAffinity affinity = position.affinity;
    final int targetOffset = position.offset;
    final int endOffset = offset.value + text.length;
    if (offset.value == targetOffset && affinity == TextAffinity.downstream ||
        offset.value < targetOffset && targetOffset < endOffset ||
        endOffset == targetOffset && affinity == TextAffinity.upstream) {
      return this;
    }
    offset.increment(text.length);
    return null;
  }

  @override
  void computeToPlainText(StringBuffer buffer, {bool includeSemanticsLabels = true, bool includePlaceholders = true}) {
    assert(debugAssertIsValid());
    if (semanticsLabel != null && includeSemanticsLabels) {
      buffer.write(semanticsLabel);
    } else if (text != null) {
      buffer.write(text);
    }
    if (children != null) {
      for (InlineSpan child in children) {
        child.computeToPlainText(buffer,
          includeSemanticsLabels: includeSemanticsLabels,
          includePlaceholders: includePlaceholders,
        );
      }
    }
  }

  @override
  void computeSemanticsInformation(List<InlineSpanSemanticsInformation> collector) {
    assert(debugAssertIsValid());
    if (text != null || semanticsLabel != null) {
      collector.add(InlineSpanSemanticsInformation(
        text,
        semanticsLabel: semanticsLabel,
        recognizer: recognizer,
      ));
    }
    if (children != null) {
      for (InlineSpan child in children) {
        child.computeSemanticsInformation(collector);
      }
    }
  }

  @override
  int codeUnitAtVisitor(int index, Accumulator offset) {
    if (text == null) {
      return null;
    }
    if (index - offset.value < text.length) {
      return text.codeUnitAt(index - offset.value);
    }
    offset.increment(text.length);
    return null;
  }

  @override
  void describeSemantics(Accumulator offset, List<int> semanticsOffsets, List<dynamic> semanticsElements) {
    if (recognizer != null && (recognizer is TapGestureRecognizer || recognizer is LongPressGestureRecognizer)) {
      final int length = semanticsLabel?.length ?? text.length;
      semanticsOffsets.add(offset.value);
      semanticsOffsets.add(offset.value + length);
      semanticsElements.add(recognizer);
    }
    offset.increment(text != null ? text.length : 0);
  }

  /// In checked mode, throws an exception if the object is not in a
  /// valid configuration. Otherwise, returns true.
  ///
  /// This is intended to be used as follows:
  ///
  /// ```dart
  /// assert(myTextSpan.debugAssertIsValid());
  /// ```
  @override
  bool debugAssertIsValid() {
    assert(() {
      if (children != null) {
        for (InlineSpan child in children) {
          assert(child != null,
            'TextSpan contains a null child.\n...'
            'A TextSpan object with a non-null child list should not have any nulls in its child list.\n'
            'The full text in question was:\n'
            '${toStringDeep(prefixLineOne: '  ')}'
          );
          assert(child.debugAssertIsValid());
        }
      }
      return true;
    }());
    return super.debugAssertIsValid();
  }

  @override
  RenderComparison compareTo(InlineSpan other) {
    if (identical(this, other))
      return RenderComparison.identical;
    if (other.runtimeType != runtimeType)
      return RenderComparison.layout;
    final TextSpan textSpan = other;
    if (textSpan.text != text ||
        children?.length != textSpan.children?.length ||
        (style == null) != (textSpan.style == null))
      return RenderComparison.layout;
    RenderComparison result = recognizer == textSpan.recognizer ? RenderComparison.identical : RenderComparison.metadata;
    if (style != null) {
      final RenderComparison candidate = style.compareTo(textSpan.style);
      if (candidate.index > result.index)
        result = candidate;
      if (result == RenderComparison.layout)
        return result;
    }
    if (children != null) {
      for (int index = 0; index < children.length; index += 1) {
        final RenderComparison candidate = children[index].compareTo(textSpan.children[index]);
        if (candidate.index > result.index)
          result = candidate;
        if (result == RenderComparison.layout)
          return result;
      }
    }
    return result;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    if (!super.equals(other))
      return false;
    final TextSpan typedOther = other;
    return typedOther.text == text
        && typedOther.recognizer == recognizer
        && typedOther.semanticsLabel == semanticsLabel
        && listEquals<InlineSpan>(typedOther.children, children);
  }

  @override
  int get hashCode => hashValues(super.hashCode, text, recognizer, semanticsLabel, hashList(children));

  @override
  String toStringShort() => '$runtimeType';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('text', text, showName: false, defaultValue: null));
    if (style == null && text == null && children == null)
      properties.add(DiagnosticsNode.message('(empty)'));

    properties.add(DiagnosticsProperty<GestureRecognizer>(
      'recognizer', recognizer,
      description: recognizer?.runtimeType?.toString(),
      defaultValue: null,
    ));

    if (semanticsLabel != null) {
      properties.add(StringProperty('semanticsLabel', semanticsLabel));
    }
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    if (children == null)
      return const <DiagnosticsNode>[];
    return children.map<DiagnosticsNode>((InlineSpan child) {
      if (child != null) {
        return child.toDiagnosticsNode();
      } else {
        return DiagnosticsNode.message('<null child>');
      }
    }).toList();
  }
}
