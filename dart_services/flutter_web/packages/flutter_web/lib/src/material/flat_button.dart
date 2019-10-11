// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-05-30T14:20:56.277572.

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web_ui/ui.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';

import 'material_button.dart';
import 'button.dart';
import 'button_theme.dart';
import 'theme.dart';
import 'theme_data.dart';

/// A material design "flat button".
///
/// A flat button is a text label displayed on a (zero elevation) [Material]
/// widget that reacts to touches by filling with color.
///
/// Use flat buttons on toolbars, in dialogs, or inline with other content but
/// offset from that content with padding so that the button's presence is
/// obvious. Flat buttons intentionally do not have visible borders and must
/// therefore rely on their position relative to other content for context. In
/// dialogs and cards, they should be grouped together in one of the bottom
/// corners. Avoid using flat buttons where they would blend in with other
/// content, for example in the middle of lists.
///
/// Material design flat buttons have an all-caps label, some internal padding,
/// and some defined dimensions. To have a part of your application be
/// interactive, with ink splashes, without also committing to these stylistic
/// choices, consider using [InkWell] instead.
///
/// If the [onPressed] callback is null, then the button will be disabled,
/// will not react to touch, and will be colored as specified by
/// the [disabledColor] property instead of the [color] property. If you are
/// trying to change the button's [color] and it is not having any effect, check
/// that you are passing a non-null [onPressed] handler.
///
/// Flat buttons have a minimum size of 88.0 by 36.0 which can be overridden
/// with [ButtonTheme].
///
/// The [clipBehavior] argument must not be null.
///
/// {@tool sample}
///
/// This example shows a simple [FlatButton].
///
/// ```dart
/// FlatButton(
///   onPressed: () {
///     /*...*/
///   },
///   child: Text(
///     "Flat Button",
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@tool sample}
///
/// This example shows a [FlatButton] that is normally white-on-blue,
/// with splashes rendered in a different shade of blue.
/// It turns black-on-grey when disabled.
/// The button has 8px of padding on each side, and the text is 20px high.
///
/// ```dart
/// FlatButton(
///   color: Colors.blue,
///   textColor: Colors.white,
///   disabledColor: Colors.grey,
///   disabledTextColor: Colors.black,
///   padding: EdgeInsets.all(8.0),
///   splashColor: Colors.blueAccent,
///   onPressed: () {
///     /*...*/
///   },
///   child: Text(
///     "Flat Button",
///     style: TextStyle(fontSize: 20.0),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [RaisedButton], a filled button whose material elevates when pressed.
///  * [DropdownButton], which offers the user a choice of a number of options.
///  * [SimpleDialogOption], which is used in [SimpleDialog]s.
///  * [IconButton], to create buttons that just contain icons.
///  * [InkWell], which implements the ink splash part of a flat button.
///  * [RawMaterialButton], the widget this widget is based on.
///  * <https://material.io/design/components/buttons.html>
class FlatButton extends MaterialButton {
  /// Create a simple text button.
  const FlatButton({
    Key key,
    @required VoidCallback onPressed,
    ValueChanged<bool> onHighlightChanged,
    ButtonTextTheme textTheme,
    Color textColor,
    Color disabledTextColor,
    Color color,
    Color disabledColor,
    Color focusColor,
    Color hoverColor,
    Color highlightColor,
    Color splashColor,
    Brightness colorBrightness,
    EdgeInsetsGeometry padding,
    ShapeBorder shape,
    Clip clipBehavior,
    FocusNode focusNode,
    MaterialTapTargetSize materialTapTargetSize,
    @required Widget child,
  }) : super(
         key: key,
         onPressed: onPressed,
         onHighlightChanged: onHighlightChanged,
         textTheme: textTheme,
         textColor: textColor,
         disabledTextColor: disabledTextColor,
         color: color,
         disabledColor: disabledColor,
         focusColor: focusColor,
         hoverColor: hoverColor,
         highlightColor: highlightColor,
         splashColor: splashColor,
         colorBrightness: colorBrightness,
         padding: padding,
         shape: shape,
         clipBehavior: clipBehavior,
         focusNode: focusNode,
         materialTapTargetSize: materialTapTargetSize,
         child: child,
      );

  /// Create a text button from a pair of widgets that serve as the button's
  /// [icon] and [label].
  ///
  /// The icon and label are arranged in a row and padded by 12 logical pixels
  /// at the start, and 16 at the end, with an 8 pixel gap in between.
  ///
  /// The [icon], [label], and [clipBehavior] arguments must not be null.
  factory FlatButton.icon({
    Key key,
    @required VoidCallback onPressed,
    ValueChanged<bool> onHighlightChanged,
    ButtonTextTheme textTheme,
    Color textColor,
    Color disabledTextColor,
    Color color,
    Color disabledColor,
    Color focusColor,
    Color hoverColor,
    Color highlightColor,
    Color splashColor,
    Brightness colorBrightness,
    EdgeInsetsGeometry padding,
    ShapeBorder shape,
    Clip clipBehavior,
    FocusNode focusNode,
    MaterialTapTargetSize materialTapTargetSize,
    @required Widget icon,
    @required Widget label,
  }) = _FlatButtonWithIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ButtonThemeData buttonTheme = ButtonTheme.of(context);
    return RawMaterialButton(
      onPressed: onPressed,
      onHighlightChanged: onHighlightChanged,
      fillColor: buttonTheme.getFillColor(this),
      textStyle: theme.textTheme.button.copyWith(color: buttonTheme.getTextColor(this)),
      focusColor: buttonTheme.getFocusColor(this),
      hoverColor: buttonTheme.getHoverColor(this),
      highlightColor: buttonTheme.getHighlightColor(this),
      splashColor: buttonTheme.getSplashColor(this),
      elevation: buttonTheme.getElevation(this),
      focusElevation: buttonTheme.getFocusElevation(this),
      hoverElevation: buttonTheme.getHoverElevation(this),
      highlightElevation: buttonTheme.getHighlightElevation(this),
      disabledElevation: buttonTheme.getDisabledElevation(this),
      padding: buttonTheme.getPadding(this),
      constraints: buttonTheme.getConstraints(this),
      shape: buttonTheme.getShape(this),
      clipBehavior: clipBehavior ?? Clip.none,
      focusNode: focusNode,
      materialTapTargetSize: buttonTheme.getMaterialTapTargetSize(this),
      animationDuration: buttonTheme.getAnimationDuration(this),
      child: child,
    );
  }
}

/// The type of of FlatButtons created with [FlatButton.icon].
///
/// This class only exists to give FlatButtons created with [FlatButton.icon]
/// a distinct class for the sake of [ButtonTheme]. It can not be instantiated.
class _FlatButtonWithIcon extends FlatButton with MaterialButtonWithIconMixin {
  _FlatButtonWithIcon({
    Key key,
    @required VoidCallback onPressed,
    ValueChanged<bool> onHighlightChanged,
    ButtonTextTheme textTheme,
    Color textColor,
    Color disabledTextColor,
    Color color,
    Color disabledColor,
    Color focusColor,
    Color hoverColor,
    Color highlightColor,
    Color splashColor,
    Brightness colorBrightness,
    EdgeInsetsGeometry padding,
    ShapeBorder shape,
    Clip clipBehavior,
    FocusNode focusNode,
    MaterialTapTargetSize materialTapTargetSize,
    @required Widget icon,
    @required Widget label,
  }) : assert(icon != null),
       assert(label != null),
       super(
         key: key,
         onPressed: onPressed,
         onHighlightChanged: onHighlightChanged,
         textTheme: textTheme,
         textColor: textColor,
         disabledTextColor: disabledTextColor,
         color: color,
         disabledColor: disabledColor,
         focusColor: focusColor,
         hoverColor: hoverColor,
         highlightColor: highlightColor,
         splashColor: splashColor,
         colorBrightness: colorBrightness,
         padding: padding,
         shape: shape,
         clipBehavior: clipBehavior,
         focusNode: focusNode,
         materialTapTargetSize: materialTapTargetSize,
         child: Row(
           mainAxisSize: MainAxisSize.min,
           children: <Widget>[
             icon,
             const SizedBox(width: 8.0),
             label,
           ],
         ),
       );

}
