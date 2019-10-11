// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-05-30T14:20:56.768929.

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/services.dart';

import 'basic.dart';
import 'focus_scope.dart';
import 'focus_manager.dart';
import 'framework.dart';

export 'package:flutter_web/services.dart' show RawKeyEvent;

/// A widget that calls a callback whenever the user presses or releases a key
/// on a keyboard.
///
/// A [RawKeyboardListener] is useful for listening to raw key events and
/// hardware buttons that are represented as keys. Typically used by games and
/// other apps that use keyboards for purposes other than text entry.
///
/// For text entry, consider using a [EditableText], which integrates with
/// on-screen keyboards and input method editors (IMEs).
///
/// See also:
///
///  * [EditableText], which should be used instead of this widget for text
///    entry.
class RawKeyboardListener extends StatefulWidget {
  /// Creates a widget that receives raw keyboard events.
  ///
  /// For text entry, consider using a [EditableText], which integrates with
  /// on-screen keyboards and input method editors (IMEs).
  const RawKeyboardListener({
    Key key,
    @required this.focusNode,
    @required this.onKey,
    @required this.child,
  }) : assert(focusNode != null),
       assert(child != null),
       super(key: key);

  /// Controls whether this widget has keyboard focus.
  final FocusNode focusNode;

  /// Called whenever this widget receives a raw keyboard event.
  final ValueChanged<RawKeyEvent> onKey;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  _RawKeyboardListenerState createState() => _RawKeyboardListenerState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode));
  }
}

class _RawKeyboardListenerState extends State<RawKeyboardListener> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(RawKeyboardListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      widget.focusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChanged);
    _detachKeyboardIfAttached();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (widget.focusNode.hasFocus)
      _attachKeyboardIfDetached();
    else
      _detachKeyboardIfAttached();
  }

  bool _listening = false;

  void _attachKeyboardIfDetached() {
    if (_listening)
      return;
    RawKeyboard.instance.addListener(_handleRawKeyEvent);
    _listening = true;
  }

  void _detachKeyboardIfAttached() {
    if (!_listening)
      return;
    RawKeyboard.instance.removeListener(_handleRawKeyEvent);
    _listening = false;
  }

  void _handleRawKeyEvent(RawKeyEvent event) {
    if (widget.onKey != null)
      widget.onKey(event);
  }

  @override
  Widget build(BuildContext context) => Focus(focusNode: widget.focusNode, child: widget.child);
}
