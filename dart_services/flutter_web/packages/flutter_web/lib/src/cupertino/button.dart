// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-08-12T13:26:26.189487.

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/widgets.dart';

import 'theme.dart';

const Color _kDisabledBackground = Color(0xFFA9A9A9);
// Measured against iOS 12 in Xcode.
const Color _kDisabledForeground = Color(0xFFD1D1D1);

const EdgeInsets _kButtonPadding = EdgeInsets.all(16.0);
const EdgeInsets _kBackgroundButtonPadding = EdgeInsets.symmetric(
  vertical: 14.0,
  horizontal: 64.0,
);

/// An iOS-style button.
///
/// Takes in a text or an icon that fades out and in on touch. May optionally have a
/// background.
///
/// See also:
///
///  * <https://developer.apple.com/ios/human-interface-guidelines/controls/buttons/>
class CupertinoButton extends StatefulWidget {
  /// Creates an iOS-style button.
  const CupertinoButton({
    Key key,
    @required this.child,
    this.padding,
    this.color,
    this.disabledColor,
    this.minSize = 44.0,
    this.pressedOpacity = 0.1,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    @required this.onPressed,
  }) : assert(pressedOpacity == null || (pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
       _filled = false,
       super(key: key);

  /// Creates an iOS-style button with a filled background.
  ///
  /// The background color is derived from the [CupertinoTheme]'s `primaryColor`.
  ///
  /// To specify a custom background color, use the [color] argument of the
  /// default constructor.
  const CupertinoButton.filled({
    Key key,
    @required this.child,
    this.padding,
    this.disabledColor,
    this.minSize = 44.0,
    this.pressedOpacity = 0.1,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    @required this.onPressed,
  }) : assert(pressedOpacity == null || (pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
       color = null,
       _filled = true,
       super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  /// The amount of space to surround the child inside the bounds of the button.
  ///
  /// Defaults to 16.0 pixels.
  final EdgeInsetsGeometry padding;

  /// The color of the button's background.
  ///
  /// Defaults to null which produces a button with no background or border.
  ///
  /// Defaults to the [CupertinoTheme]'s `primaryColor` when the
  /// [CupertinoButton.filled] constructor is used.
  final Color color;

  /// The color of the button's background when the button is disabled.
  ///
  /// Ignored if the [CupertinoButton] doesn't also have a [color].
  ///
  /// Defaults to a standard iOS disabled color when [color] is specified and
  /// [disabledColor] is null.
  final Color disabledColor;

  /// The callback that is called when the button is tapped or otherwise activated.
  ///
  /// If this is set to null, the button will be disabled.
  final VoidCallback onPressed;

  /// Minimum size of the button.
  ///
  /// Defaults to 44.0 which the iOS Human Interface Guideline recommends as the
  /// minimum tappable area
  ///
  /// See also:
  ///
  ///  * <https://developer.apple.com/ios/human-interface-guidelines/visual-design/adaptivity-and-layout/>
  final double minSize;

  /// The opacity that the button will fade to when it is pressed.
  /// The button will have an opacity of 1.0 when it is not pressed.
  ///
  /// This defaults to 0.1. If null, opacity will not change on pressed if using
  /// your own custom effects is desired.
  final double pressedOpacity;

  /// The radius of the button's corners when it has a background color.
  ///
  /// Defaults to round corners of 8 logical pixels.
  final BorderRadius borderRadius;

  final bool _filled;

  /// Whether the button is enabled or disabled. Buttons are disabled by default. To
  /// enable a button, set its [onPressed] property to a non-null value.
  bool get enabled => onPressed != null;

  @override
  _CupertinoButtonState createState() => _CupertinoButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'));
  }
}

class _CupertinoButtonState extends State<CupertinoButton> with SingleTickerProviderStateMixin {
  // Eyeballed values. Feel free to tweak.
  static const Duration kFadeOutDuration = Duration(milliseconds: 10);
  static const Duration kFadeInDuration = Duration(milliseconds: 100);
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  AnimationController _animationController;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _opacityAnimation = _animationController
      .drive(CurveTween(curve: Curves.decelerate))
      .drive(_opacityTween);
    _setTween();
  }

  @override
  void didUpdateWidget(CupertinoButton old) {
    super.didUpdateWidget(old);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity ?? 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationController = null;
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController.isAnimating)
      return;
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _animationController.animateTo(1.0, duration: kFadeOutDuration)
        : _animationController.animateTo(0.0, duration: kFadeInDuration);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown)
        _animate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.enabled;
    final Color primaryColor = CupertinoTheme.of(context).primaryColor;
    final Color backgroundColor = widget.color ?? (widget._filled ? primaryColor : null);
    final Color foregroundColor = backgroundColor != null
        ? CupertinoTheme.of(context).primaryContrastingColor
        : enabled
            ? primaryColor
            : _kDisabledForeground;
    final TextStyle textStyle =
        CupertinoTheme.of(context).textTheme.textStyle.copyWith(color: foregroundColor);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: Semantics(
        button: true,
        child: ConstrainedBox(
          constraints: widget.minSize == null
            ? const BoxConstraints()
            : BoxConstraints(
              minWidth: widget.minSize,
              minHeight: widget.minSize,
            ),
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                color: backgroundColor != null && !enabled
                  ? widget.disabledColor ?? _kDisabledBackground
                  : backgroundColor,
              ),
              child: Padding(
                padding: widget.padding ?? (backgroundColor != null
                  ? _kBackgroundButtonPadding
                  : _kButtonPadding),
                child: Center(
                  widthFactor: 1.0,
                  heightFactor: 1.0,
                  child: DefaultTextStyle(
                    style: textStyle,
                    child: IconTheme(
                      data: IconThemeData(color: foregroundColor),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
