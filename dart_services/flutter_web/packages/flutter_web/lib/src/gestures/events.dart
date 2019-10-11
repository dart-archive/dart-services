// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-08-15T10:04:31.515115.

import 'package:flutter_web_ui/ui.dart' show Offset, PointerDeviceKind;

import 'package:flutter_web/foundation.dart';

import 'package:vector_math/vector_math_64.dart';

export 'package:flutter_web_ui/ui.dart' show Offset, PointerDeviceKind;

/// The bit of [PointerEvent.buttons] that corresponds to a cross-device
/// behavior of "primary operation".
///
/// More specifially, it includes:
///
///  * [kTouchContact]: The pointer contacts the touch screen.
///  * [kStylusContact]: The stylus contacts the screen.
///  * [kPrimaryMouseButton]: The primary mouse button.
///
/// See also:
///
///  * [kSecondaryButton], which describes a cross-device behavior of
///    "secondary operation".
const int kPrimaryButton = 0x01;

/// The bit of [PointerEvent.buttons] that corresponds to a cross-device
/// behavior of "secondary operation".
///
/// It is equivalent to:
///
///  * [kPrimaryStylusButton]: The stylus contacts the screen.
///  * [kSecondaryMouseButton]: The primary mouse button.
///
/// See also:
///
///  * [kPrimaryButton], which describes a cross-device behavior of
///    "primary operation".
const int kSecondaryButton = 0x02;

/// The bit of [PointerEvent.buttons] that corresponds to the primary mouse button.
///
/// The primary mouse button is typically the left button on the top of the
/// mouse but can be reconfigured to be a different physical button.
///
/// See also:
///
///  * [kPrimaryButton], which has the same value but describes its cross-device
///    concept.
const int kPrimaryMouseButton = kPrimaryButton;

/// The bit of [PointerEvent.buttons] that corresponds to the secondary mouse button.
///
/// The secondary mouse button is typically the right button on the top of the
/// mouse but can be reconfigured to be a different physical button.
///
/// See also:
///
///  * [kSecondaryButton], which has the same value but describes its cross-device
///    concept.
const int kSecondaryMouseButton = kSecondaryButton;

/// The bit of [PointerEvent.buttons] that corresponds to when a stylus
/// contacting the screen.
///
/// See also:
///
///  * [kPrimaryButton], which has the same value but describes its cross-device
///    concept.
const int kStylusContact = kPrimaryButton;

/// The bit of [PointerEvent.buttons] that corresponds to the primary stylus button.
///
/// The primary stylus button is typically the top of the stylus and near the
/// tip but can be reconfigured to be a different physical button.
///
/// See also:
///
///  * [kSecondaryButton], which has the same value but describes its cross-device
///    concept.
const int kPrimaryStylusButton = kSecondaryButton;

/// The bit of [PointerEvent.buttons] that corresponds to the middle mouse button.
///
/// The middle mouse button is typically between the left and right buttons on
/// the top of the mouse but can be reconfigured to be a different physical
/// button.
const int kMiddleMouseButton = 0x04;

/// The bit of [PointerEvent.buttons] that corresponds to the secondary stylus button.
///
/// The secondary stylus button is typically on the end of the stylus farthest
/// from the tip but can be reconfigured to be a different physical button.
const int kSecondaryStylusButton = 0x04;

/// The bit of [PointerEvent.buttons] that corresponds to the back mouse button.
///
/// The back mouse button is typically on the left side of the mouse but can be
/// reconfigured to be a different physical button.
const int kBackMouseButton = 0x08;

/// The bit of [PointerEvent.buttons] that corresponds to the forward mouse button.
///
/// The forward mouse button is typically on the right side of the mouse but can
/// be reconfigured to be a different physical button.
const int kForwardMouseButton = 0x10;

/// The bit of [PointerEvent.buttons] that corresponds to the pointer contacting
/// a touch screen.
///
/// See also:
///
///  * [kPrimaryButton], which has the same value but describes its cross-device
///    concept.
const int kTouchContact = kPrimaryButton;

/// The bit of [PointerEvent.buttons] that corresponds to the nth mouse button.
///
/// The `number` argument can be at most 62 in Flutter for mobile and desktop,
/// and at most 32 on Flutter for web.
///
/// See [kPrimaryMouseButton], [kSecondaryMouseButton], [kMiddleMouseButton],
/// [kBackMouseButton], and [kForwardMouseButton] for semantic names for some
/// mouse buttons.
int nthMouseButton(int number) => (kPrimaryMouseButton << (number - 1)) & kMaxUnsignedSMI;

/// The bit of [PointerEvent.buttons] that corresponds to the nth stylus button.
///
/// The `number` argument can be at most 62 in Flutter for mobile and desktop,
/// and at most 32 on Flutter for web.
///
/// See [kPrimaryStylusButton] and [kSecondaryStylusButton] for semantic names
/// for some stylus buttons.
int nthStylusButton(int number) => (kPrimaryStylusButton << (number - 1)) & kMaxUnsignedSMI;

/// Returns the button of `buttons` with the smallest integer.
///
/// The `buttons` parameter is a bitfield where each set bit represents a button.
/// This function returns the set bit closest to the least significant bit.
///
/// It returns zero when `buttons` is zero.
///
/// Example:
///
/// ```dart
///   assert(rightmostButton(0x1) == 0x1);
///   assert(rightmostButton(0x11) == 0x1);
///   assert(rightmostButton(0) == 0);
/// ```
///
/// See also:
///
///   * [isSingleButton], which checks if a `buttons` contains exactly one button.
int smallestButton(int buttons) => buttons & (-buttons);

/// Returns whether `buttons` contains one and only one button.
///
/// The `buttons` parameter is a bitfield where each set bit represents a button.
/// This function returns whether there is only one set bit in the given integer.
///
/// It returns false when `buttons` is zero.
///
/// Example:
///
/// ```dart
///   assert(isSingleButton(0x1) == true);
///   assert(isSingleButton(0x11) == false);
///   assert(isSingleButton(0) == false);
/// ```
///
/// See also:
///
///   * [smallestButton], which returns the button in a `buttons` bitfield with
///     the smallest integer button.
bool isSingleButton(int buttons) => buttons != 0 && (smallestButton(buttons) == buttons);

/// Base class for touch, stylus, or mouse events.
///
/// Pointer events operate in the coordinate space of the screen, scaled to
/// logical pixels. Logical pixels approximate a grid with about 38 pixels per
/// centimeter, or 96 pixels per inch.
///
/// This allows gestures to be recognized independent of the precise hardware
/// characteristics of the device. In particular, features such as touch slop
/// (see [kTouchSlop]) can be defined in terms of roughly physical lengths so
/// that the user can shift their finger by the same distance on a high-density
/// display as on a low-resolution device.
///
/// For similar reasons, pointer events are not affected by any transforms in
/// the rendering layer. This means that deltas may need to be scaled before
/// being applied to movement within the rendering. For example, if a scrolling
/// list is shown scaled by 2x, the pointer deltas will have to be scaled by the
/// inverse amount if the list is to appear to scroll with the user's finger.
///
/// See also:
///
///  * [Window.devicePixelRatio], which defines the device's current resolution.
@immutable
abstract class PointerEvent extends Diagnosticable {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const PointerEvent({
    this.timeStamp = Duration.zero,
    this.pointer = 0,
    this.kind = PointerDeviceKind.touch,
    this.device = 0,
    this.position = Offset.zero,
    Offset localPosition,
    this.delta = Offset.zero,
    Offset localDelta,
    this.buttons = 0,
    this.down = false,
    this.obscured = false,
    this.pressure = 1.0,
    this.pressureMin = 1.0,
    this.pressureMax = 1.0,
    this.distance = 0.0,
    this.distanceMax = 0.0,
    this.size = 0.0,
    this.radiusMajor = 0.0,
    this.radiusMinor = 0.0,
    this.radiusMin = 0.0,
    this.radiusMax = 0.0,
    this.orientation = 0.0,
    this.tilt = 0.0,
    this.platformData = 0,
    this.synthesized = false,
    this.transform,
    this.original,
  }) : localPosition = localPosition ?? position,
       localDelta = localDelta ?? delta;


  /// Time of event dispatch, relative to an arbitrary timeline.
  final Duration timeStamp;

  /// Unique identifier for the pointer, not reused. Changes for each new
  /// pointer down event.
  final int pointer;

  /// The kind of input device for which the event was generated.
  final PointerDeviceKind kind;

  /// Unique identifier for the pointing device, reused across interactions.
  final int device;

  /// Coordinate of the position of the pointer, in logical pixels in the global
  /// coordinate space.
  ///
  /// See also:
  ///
  ///  * [localPosition], which is the [position] transformed into the local
  ///    coordinate system of the event receiver.
  final Offset position;

  /// The [position] transformed into the event receiver's local coordinate
  /// system according to [transform].
  ///
  /// If this event has not been transformed, [position] is returned as-is.
  ///
  /// See also:
  ///
  ///  * [globalPosition], which is the position in the global coordinate
  ///    system of the screen.
  final Offset localPosition;

  /// Distance in logical pixels that the pointer moved since the last
  /// [PointerMoveEvent] or [PointerHoverEvent].
  ///
  /// This value is always 0.0 for down, up, and cancel events.
  ///
  /// See also:
  ///
  ///  * [localDelta], which is the [delta] transformed into the local
  ///    coordinate space of the event receiver.
  final Offset delta;

  /// The [delta] transformed into the event receiver's local coordinate
  /// system according to [transform].
  ///
  /// If this event has not been transformed, [delta] is returned as-is.
  ///
  /// See also:
  ///
  ///  * [delta], which is the distance the pointer moved in the global
  ///    coordinate system of the screen.
  final Offset localDelta;

  /// Bit field using the *Button constants such as [kPrimaryMouseButton],
  /// [kSecondaryStylusButton], etc.
  ///
  /// For example, if this has the value 6 and the
  /// [kind] is [PointerDeviceKind.invertedStylus], then this indicates an
  /// upside-down stylus with both its primary and secondary buttons pressed.
  final int buttons;

  /// Set if the pointer is currently down.
  ///
  /// For touch and stylus pointers, this means the object (finger, pen) is in
  /// contact with the input surface. For mice, it means a button is pressed.
  final bool down;

  /// Set if an application from a different security domain is in any way
  /// obscuring this application's window.
  ///
  /// This is not currently implemented.
  final bool obscured;

  /// The pressure of the touch.
  ///
  /// This value is a number ranging from 0.0, indicating a touch with no
  /// discernible pressure, to 1.0, indicating a touch with "normal" pressure,
  /// and possibly beyond, indicating a stronger touch. For devices that do not
  /// detect pressure (e.g. mice), returns 1.0.
  final double pressure;

  /// The minimum value that [pressure] can return for this pointer.
  ///
  /// For devices that do not detect pressure (e.g. mice), returns 1.0.
  /// This will always be a number less than or equal to 1.0.
  final double pressureMin;

  /// The maximum value that [pressure] can return for this pointer.
  ///
  /// For devices that do not detect pressure (e.g. mice), returns 1.0.
  /// This will always be a greater than or equal to 1.0.
  final double pressureMax;

  /// The distance of the detected object from the input surface.
  ///
  /// For instance, this value could be the distance of a stylus or finger
  /// from a touch screen, in arbitrary units on an arbitrary (not necessarily
  /// linear) scale. If the pointer is down, this is 0.0 by definition.
  final double distance;

  /// The minimum value that [distance] can return for this pointer.
  ///
  /// This value is always 0.0.
  double get distanceMin => 0.0;

  /// The maximum value that [distance] can return for this pointer.
  ///
  /// If this input device cannot detect "hover touch" input events,
  /// then this will be 0.0.
  final double distanceMax;

  /// The area of the screen being pressed.
  ///
  /// This value is scaled to a range between 0 and 1. It can be used to
  /// determine fat touch events. This value is only set on Android and is
  /// a device specific approximation within the range of detectable values.
  /// So, for example, the value of 0.1 could mean a touch with the tip of
  /// the finger, 0.2 a touch with full finger, and 0.3 the full palm.
  ///
  /// Because this value uses device-specific range and is uncalibrated,
  /// it is of limited use and is primarily retained in order to be able
  /// to reconstruct original pointer events for [AndroidView].
  final double size;

  /// The radius of the contact ellipse along the major axis, in logical pixels.
  final double radiusMajor;

  /// The radius of the contact ellipse along the minor axis, in logical pixels.
  final double radiusMinor;

  /// The minimum value that could be reported for [radiusMajor] and [radiusMinor]
  /// for this pointer, in logical pixels.
  final double radiusMin;

  /// The minimum value that could be reported for [radiusMajor] and [radiusMinor]
  /// for this pointer, in logical pixels.
  final double radiusMax;

  /// The orientation angle of the detected object, in radians.
  ///
  /// For [PointerDeviceKind.touch] events:
  ///
  /// The angle of the contact ellipse, in radians in the range:
  ///
  ///    -pi/2 < orientation <= pi/2
  ///
  /// ...giving the angle of the major axis of the ellipse with the y-axis
  /// (negative angles indicating an orientation along the top-left /
  /// bottom-right diagonal, positive angles indicating an orientation along the
  /// top-right / bottom-left diagonal, and zero indicating an orientation
  /// parallel with the y-axis).
  ///
  /// For [PointerDeviceKind.stylus] and [PointerDeviceKind.invertedStylus] events:
  ///
  /// The angle of the stylus, in radians in the range:
  ///
  ///    -pi < orientation <= pi
  ///
  /// ...giving the angle of the axis of the stylus projected onto the input
  /// surface, relative to the positive y-axis of that surface (thus 0.0
  /// indicates the stylus, if projected onto that surface, would go from the
  /// contact point vertically up in the positive y-axis direction, pi would
  /// indicate that the stylus would go down in the negative y-axis direction;
  /// pi/4 would indicate that the stylus goes up and to the right, -pi/2 would
  /// indicate that the stylus goes to the left, etc).
  final double orientation;

  /// The tilt angle of the detected object, in radians.
  ///
  /// For [PointerDeviceKind.stylus] and [PointerDeviceKind.invertedStylus] events:
  ///
  /// The angle of the stylus, in radians in the range:
  ///
  ///    0 <= tilt <= pi/2
  ///
  /// ...giving the angle of the axis of the stylus, relative to the axis
  /// perpendicular to the input surface (thus 0.0 indicates the stylus is
  /// orthogonal to the plane of the input surface, while pi/2 indicates that
  /// the stylus is flat on that surface).
  final double tilt;

  /// Opaque platform-specific data associated with the event.
  final int platformData;

  /// Set if the event was synthesized by Flutter.
  ///
  /// We occasionally synthesize PointerEvents that aren't exact translations
  /// of [ui.PointerData] from the engine to cover small cross-OS discrepancies
  /// in pointer behaviors.
  ///
  /// For instance, on end events, Android always drops any location changes
  /// that happened between its reporting intervals when emitting the end events.
  ///
  /// On iOS, minor incorrect location changes from the previous move events
  /// can be reported on end events. We synthesize a [PointerEvent] to cover
  /// the difference between the 2 events in that case.
  final bool synthesized;

  /// The transformation used to transform this event from the global coordinate
  /// space into the coordinate space of the event receiver.
  ///
  /// This value affects what is returned by [localPosition] and [localDelta].
  /// If this value is null, it is treated as the identity transformation.
  ///
  /// Unlike a paint transform, this transform usually does not contain any
  /// "perspective" components, meaning that the third row and the third column
  /// of the matrix should be equal to "0, 0, 1, 0". This ensures that
  /// [localPosition] describes the point in the local coordinate system of the
  /// event receiver at which the user is actually touching the screen.
  ///
  /// See also:
  ///
  ///  * [transformed], which transforms this event into a different coordinate
  ///    space.
  final Matrix4 transform;

  /// The original un-transformed [PointerEvent] before any [transform]s were
  /// applied.
  ///
  /// If [transform] is null or the identity transformation this may be null.
  ///
  /// When multiple event receivers in different coordinate spaces receive an
  /// event, they all receive the event transformed to their local coordinate
  /// space. The [original] property can be used to determine if all those
  /// transformed events actually originated from the same pointer interaction.
  final PointerEvent original;

  /// Transforms the event from the global coordinate space into the coordinate
  /// space of an event receiver.
  ///
  /// The coordinate space of the event receiver is described by `transform`. A
  /// null value for `transform` is treated as the identity transformation.
  ///
  /// The method may return the same object instance if for example the
  /// transformation has no effect on the event.
  ///
  /// Transforms are not commutative. If this method is called on a
  /// [PointerEvent] that has a non-null [transform] value, that value will be
  /// overridden by the provided `transform`.
  PointerEvent transformed(Matrix4 transform);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Offset>('position', position));
    properties.add(DiagnosticsProperty<Offset>('localPosition', localPosition, defaultValue: position, level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Offset>('delta', delta, defaultValue: Offset.zero, level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Offset>('localDelta', localDelta, defaultValue: delta, level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<Duration>('timeStamp', timeStamp, defaultValue: Duration.zero, level: DiagnosticLevel.debug));
    properties.add(IntProperty('pointer', pointer, level: DiagnosticLevel.debug));
    properties.add(EnumProperty<PointerDeviceKind>('kind', kind, level: DiagnosticLevel.debug));
    properties.add(IntProperty('device', device, defaultValue: 0, level: DiagnosticLevel.debug));
    properties.add(IntProperty('buttons', buttons, defaultValue: 0, level: DiagnosticLevel.debug));
    properties.add(DiagnosticsProperty<bool>('down', down, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('pressure', pressure, defaultValue: 1.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('pressureMin', pressureMin, defaultValue: 1.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('pressureMax', pressureMax, defaultValue: 1.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('distance', distance, defaultValue: 0.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('distanceMin', distanceMin, defaultValue: 0.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('distanceMax', distanceMax, defaultValue: 0.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('size', size, defaultValue: 0.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('radiusMajor', radiusMajor, defaultValue: 0.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('radiusMinor', radiusMinor, defaultValue: 0.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('radiusMin', radiusMin, defaultValue: 0.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('radiusMax', radiusMax, defaultValue: 0.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('orientation', orientation, defaultValue: 0.0, level: DiagnosticLevel.debug));
    properties.add(DoubleProperty('tilt', tilt, defaultValue: 0.0, level: DiagnosticLevel.debug));
    properties.add(IntProperty('platformData', platformData, defaultValue: 0, level: DiagnosticLevel.debug));
    properties.add(FlagProperty('obscured', value: obscured, ifTrue: 'obscured', level: DiagnosticLevel.debug));
    properties.add(FlagProperty('synthesized', value: synthesized, ifTrue: 'synthesized', level: DiagnosticLevel.debug));
  }

  /// Returns a complete textual description of this event.
  String toStringFull() {
    return toString(minLevel: DiagnosticLevel.fine);
  }

  /// Returns the transformation of `position` into the coordinate system
  /// described by `transform`.
  ///
  /// The z-value of `position` is assumed to be 0.0. If `transform` is null,
  /// `position` is returned as-is.
  static Offset transformPosition(Matrix4 transform, Offset position) {
    if (transform == null) {
      return position;
    }
    final Vector3 position3 = Vector3(position.dx, position.dy, 0.0);
    final Vector3 transformed3 = transform.perspectiveTransform(position3);
    return Offset(transformed3.x, transformed3.y);
  }

  /// Transforms `untransformedDelta` into the coordinate system described by
  /// `transform`.
  ///
  /// It uses the provided `untransformedEndPosition` and
  /// `transformedEndPosition` of the provided delta to increase accuracy.
  ///
  /// If `transform` is null, `untransformedDelta` is returned.
  static Offset transformDeltaViaPositions({
    @required Offset untransformedEndPosition,
    Offset transformedEndPosition,
    @required Offset untransformedDelta,
    @required Matrix4 transform,
  }) {
    if (transform == null) {
      return untransformedDelta;
    }
    // We could transform the delta directly with the transformation matrix.
    // While that is mathematically equivalent, in practice we are seeing a
    // greater precision error with that approach. Instead, we are transforming
    // start and end point of the delta separately and calculate the delta in
    // the new space for greater accuracy.
    transformedEndPosition ??= transformPosition(transform, untransformedEndPosition);
    final Offset transformedStartPosition = transformPosition(transform, untransformedEndPosition - untransformedDelta);
    return transformedEndPosition - transformedStartPosition;
  }

  /// Removes the "perspective" component from `transform`.
  ///
  /// When applying the resulting transform matrix to a point with a
  /// z-coordinate of zero (which is generally assumed for all points
  /// represented by an [Offset]), the other coordinates will get transformed as
  /// before, but the new z-coordinate is going to be zero again. This is
  /// achieved by setting the third column and third row of the matrix to
  /// "0, 0, 1, 0".
  static Matrix4 removePerspectiveTransform(Matrix4 transform) {
    final Vector4 vector = Vector4(0, 0, 1, 0);
    return transform.clone()
      ..setColumn(2, vector)
      ..setRow(2, vector);
  }
}

/// The device has started tracking the pointer.
///
/// For example, the pointer might be hovering above the device, having not yet
/// made contact with the surface of the device.
class PointerAddedEvent extends PointerEvent {
  /// Creates a pointer added event.
  ///
  /// All of the arguments must be non-null.
  const PointerAddedEvent({
    Duration timeStamp = Duration.zero,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    bool obscured = false,
    double pressureMin = 1.0,
    double pressureMax = 1.0,
    double distance = 0.0,
    double distanceMax = 0.0,
    double radiusMin = 0.0,
    double radiusMax = 0.0,
    double orientation = 0.0,
    double tilt = 0.0,
    Matrix4 transform,
    PointerAddedEvent original,
  }) : super(
         timeStamp: timeStamp,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         obscured: obscured,
         pressure: 0.0,
         pressureMin: pressureMin,
         pressureMax: pressureMax,
         distance: distance,
         distanceMax: distanceMax,
         radiusMin: radiusMin,
         radiusMax: radiusMax,
         orientation: orientation,
         tilt: tilt,
         transform: transform,
         original: original,
       );

  @override
  PointerAddedEvent transformed(Matrix4 transform) {
    if (transform == null || transform == this.transform) {
      return this;
    }
    return PointerAddedEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: device,
      position: position,
      localPosition: PointerEvent.transformPosition(transform, position),
      obscured: obscured,
      pressureMin: pressureMin,
      pressureMax: pressureMax,
      distance: distance,
      distanceMax: distanceMax,
      radiusMin: radiusMin,
      radiusMax: radiusMax,
      orientation: orientation,
      tilt: tilt,
      transform: transform,
      original: original ?? this,
    );
  }
}

/// The device is no longer tracking the pointer.
///
/// For example, the pointer might have drifted out of the device's hover
/// detection range or might have been disconnected from the system entirely.
class PointerRemovedEvent extends PointerEvent {
  /// Creates a pointer removed event.
  ///
  /// All of the arguments must be non-null.
  const PointerRemovedEvent({
    Duration timeStamp = Duration.zero,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    bool obscured = false,
    double pressureMin = 1.0,
    double pressureMax = 1.0,
    double distanceMax = 0.0,
    double radiusMin = 0.0,
    double radiusMax = 0.0,
    Matrix4 transform,
    PointerRemovedEvent original,
  }) : super(
         timeStamp: timeStamp,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         obscured: obscured,
         pressure: 0.0,
         pressureMin: pressureMin,
         pressureMax: pressureMax,
         distanceMax: distanceMax,
         radiusMin: radiusMin,
         radiusMax: radiusMax,
         transform: transform,
         original: original,
       );

  @override
  PointerRemovedEvent transformed(Matrix4 transform) {
    if (transform == null || transform == this.transform) {
      return this;
    }
    return PointerRemovedEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: device,
      position: position,
      localPosition: PointerEvent.transformPosition(transform, position),
      obscured: obscured,
      pressureMin: pressureMin,
      pressureMax: pressureMax,
      distanceMax: distanceMax,
      radiusMin: radiusMin,
      radiusMax: radiusMax,
      transform: transform,
      original: original ?? this,
    );
  }
}

/// The pointer has moved with respect to the device while the pointer is not
/// in contact with the device.
///
/// See also:
///
///  * [PointerEnterEvent], which reports when the pointer has entered an
///    object.
///  * [PointerExitEvent], which reports when the pointer has left an object.
///  * [PointerMoveEvent], which reports movement while the pointer is in
///    contact with the device.
class PointerHoverEvent extends PointerEvent {
  /// Creates a pointer hover event.
  ///
  /// All of the arguments must be non-null.
  const PointerHoverEvent({
    Duration timeStamp = Duration.zero,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    Offset delta = Offset.zero,
    Offset localDelta,
    int buttons = 0,
    bool obscured = false,
    double pressureMin = 1.0,
    double pressureMax = 1.0,
    double distance = 0.0,
    double distanceMax = 0.0,
    double size = 0.0,
    double radiusMajor = 0.0,
    double radiusMinor = 0.0,
    double radiusMin = 0.0,
    double radiusMax = 0.0,
    double orientation = 0.0,
    double tilt = 0.0,
    bool synthesized = false,
    Matrix4 transform,
    PointerHoverEvent original,
  }) : super(
         timeStamp: timeStamp,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         delta: delta,
         localDelta: localDelta,
         buttons: buttons,
         down: false,
         obscured: obscured,
         pressure: 0.0,
         pressureMin: pressureMin,
         pressureMax: pressureMax,
         distance: distance,
         distanceMax: distanceMax,
         size: size,
         radiusMajor: radiusMajor,
         radiusMinor: radiusMinor,
         radiusMin: radiusMin,
         radiusMax: radiusMax,
         orientation: orientation,
         tilt: tilt,
         synthesized: synthesized,
         transform: transform,
         original: original,
       );

  @override
  PointerHoverEvent transformed(Matrix4 transform) {
    if (transform == null || transform == this.transform) {
      return this;
    }
    final Offset transformedPosition = PointerEvent.transformPosition(transform, position);
    return PointerHoverEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: device,
      position: position,
      localPosition: transformedPosition,
      delta: delta,
      localDelta: PointerEvent.transformDeltaViaPositions(
        transform: transform,
        untransformedDelta: delta,
        untransformedEndPosition: position,
        transformedEndPosition: transformedPosition,
      ),
      buttons: buttons,
      obscured: obscured,
      pressureMin: pressureMin,
      pressureMax: pressureMax,
      distance: distance,
      distanceMax: distanceMax,
      size: size,
      radiusMajor: radiusMajor,
      radiusMinor: radiusMinor,
      radiusMin: radiusMin,
      radiusMax: radiusMax,
      orientation: orientation,
      tilt: tilt,
      synthesized: synthesized,
      transform: transform,
      original: original ?? this,
    );
  }
}

/// The pointer has moved with respect to the device while the pointer is not
/// in contact with the device, and it has entered a target object.
///
/// See also:
///
///  * [PointerHoverEvent], which reports when the pointer has moved while
///    within an object.
///  * [PointerExitEvent], which reports when the pointer has left an object.
///  * [PointerMoveEvent], which reports movement while the pointer is in
///    contact with the device.
class PointerEnterEvent extends PointerEvent {
  /// Creates a pointer enter event.
  ///
  /// All of the arguments must be non-null.
  const PointerEnterEvent({
    Duration timeStamp = Duration.zero,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    Offset delta = Offset.zero,
    Offset localDelta,
    int buttons = 0,
    bool obscured = false,
    double pressureMin = 1.0,
    double pressureMax = 1.0,
    double distance = 0.0,
    double distanceMax = 0.0,
    double size = 0.0,
    double radiusMajor = 0.0,
    double radiusMinor = 0.0,
    double radiusMin = 0.0,
    double radiusMax = 0.0,
    double orientation = 0.0,
    double tilt = 0.0,
    bool synthesized = false,
    Matrix4 transform,
    PointerEnterEvent original,
  }) : super(
         timeStamp: timeStamp,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         delta: delta,
         localDelta: localDelta,
         buttons: buttons,
         down: false,
         obscured: obscured,
         pressure: 0.0,
         pressureMin: pressureMin,
         pressureMax: pressureMax,
         distance: distance,
         distanceMax: distanceMax,
         size: size,
         radiusMajor: radiusMajor,
         radiusMinor: radiusMinor,
         radiusMin: radiusMin,
         radiusMax: radiusMax,
         orientation: orientation,
         tilt: tilt,
         synthesized: synthesized,
         transform: transform,
         original: original,
       );

  /// Creates an enter event from a [PointerHoverEvent].
  ///
  /// Deprecated. Please use [PointerEnterEvent.fromMouseEvent] instead.
  @Deprecated('use PointerEnterEvent.fromMouseEvent instead')
  PointerEnterEvent.fromHoverEvent(PointerHoverEvent event) : this.fromMouseEvent(event);

  /// Creates an enter event from a [PointerEvent].
  ///
  /// This is used by the [MouseTracker] to synthesize enter events.
  PointerEnterEvent.fromMouseEvent(PointerEvent event) : this(
    timeStamp: event?.timeStamp,
    kind: event?.kind,
    device: event?.device,
    position: event?.position,
    localPosition: event?.localPosition,
    delta: event?.delta,
    localDelta: event?.localDelta,
    buttons: event?.buttons,
    obscured: event?.obscured,
    pressureMin: event?.pressureMin,
    pressureMax: event?.pressureMax,
    distance: event?.distance,
    distanceMax: event?.distanceMax,
    size: event?.size,
    radiusMajor: event?.radiusMajor,
    radiusMinor: event?.radiusMinor,
    radiusMin: event?.radiusMin,
    radiusMax: event?.radiusMax,
    orientation: event?.orientation,
    tilt: event?.tilt,
    synthesized: event?.synthesized,
    transform: event?.transform,
    original: event?.original,
  );

  @override
  PointerEnterEvent transformed(Matrix4 transform) {
    if (transform == null || transform == this.transform) {
      return this;
    }
    final Offset transformedPosition = PointerEvent.transformPosition(transform, position);
    return PointerEnterEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: device,
      position: position,
      localPosition: transformedPosition,
      delta: delta,
      localDelta: PointerEvent.transformDeltaViaPositions(
        transform: transform,
        untransformedDelta: delta,
        untransformedEndPosition: position,
        transformedEndPosition: transformedPosition,
      ),
      buttons: buttons,
      obscured: obscured,
      pressureMin: pressureMin,
      pressureMax: pressureMax,
      distance: distance,
      distanceMax: distanceMax,
      size: size,
      radiusMajor: radiusMajor,
      radiusMinor: radiusMinor,
      radiusMin: radiusMin,
      radiusMax: radiusMax,
      orientation: orientation,
      tilt: tilt,
      synthesized: synthesized,
      transform: transform,
      original: original ?? this,
    );
  }
}

/// The pointer has moved with respect to the device while the pointer is not
/// in contact with the device, and entered a target object.
///
/// See also:
///
///  * [PointerHoverEvent], which reports when the pointer has moved while
///    within an object.
///  * [PointerEnterEvent], which reports when the pointer has entered an object.
///  * [PointerMoveEvent], which reports movement while the pointer is in
///    contact with the device.
class PointerExitEvent extends PointerEvent {
  /// Creates a pointer exit event.
  ///
  /// All of the arguments must be non-null.
  const PointerExitEvent({
    Duration timeStamp = Duration.zero,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    Offset delta = Offset.zero,
    Offset localDelta,
    int buttons = 0,
    bool obscured = false,
    double pressureMin = 1.0,
    double pressureMax = 1.0,
    double distance = 0.0,
    double distanceMax = 0.0,
    double size = 0.0,
    double radiusMajor = 0.0,
    double radiusMinor = 0.0,
    double radiusMin = 0.0,
    double radiusMax = 0.0,
    double orientation = 0.0,
    double tilt = 0.0,
    bool synthesized = false,
    Matrix4 transform,
    PointerExitEvent original,
  }) : super(
         timeStamp: timeStamp,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         delta: delta,
         localDelta: localDelta,
         buttons: buttons,
         down: false,
         obscured: obscured,
         pressure: 0.0,
         pressureMin: pressureMin,
         pressureMax: pressureMax,
         distance: distance,
         distanceMax: distanceMax,
         size: size,
         radiusMajor: radiusMajor,
         radiusMinor: radiusMinor,
         radiusMin: radiusMin,
         radiusMax: radiusMax,
         orientation: orientation,
         tilt: tilt,
         synthesized: synthesized,
         transform: transform,
         original: original,
       );

  /// Creates an exit event from a [PointerHoverEvent].
  ///
  /// Deprecated. Please use [PointerExitEvent.fromMouseEvent] instead.
  @Deprecated('use PointerExitEvent.fromMouseEvent instead')
  PointerExitEvent.fromHoverEvent(PointerHoverEvent event) : this.fromMouseEvent(event);

  /// Creates an exit event from a [PointerEvent].
  ///
  /// This is used by the [MouseTracker] to synthesize exit events.
  PointerExitEvent.fromMouseEvent(PointerEvent event) : this(
    timeStamp: event?.timeStamp,
    kind: event?.kind,
    device: event?.device,
    position: event?.position,
    localPosition: event?.localPosition,
    delta: event?.delta,
    localDelta: event?.localDelta,
    buttons: event?.buttons,
    obscured: event?.obscured,
    pressureMin: event?.pressureMin,
    pressureMax: event?.pressureMax,
    distance: event?.distance,
    distanceMax: event?.distanceMax,
    size: event?.size,
    radiusMajor: event?.radiusMajor,
    radiusMinor: event?.radiusMinor,
    radiusMin: event?.radiusMin,
    radiusMax: event?.radiusMax,
    orientation: event?.orientation,
    tilt: event?.tilt,
    synthesized: event?.synthesized,
    transform: event?.transform,
    original: event?.original,
  );

  @override
  PointerExitEvent transformed(Matrix4 transform) {
    if (transform == null || transform == this.transform) {
      return this;
    }
    final Offset transformedPosition = PointerEvent.transformPosition(transform, position);
    return PointerExitEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: device,
      position: position,
      localPosition: transformedPosition,
      delta: delta,
      localDelta: PointerEvent.transformDeltaViaPositions(
        transform: transform,
        untransformedDelta: delta,
        untransformedEndPosition: position,
        transformedEndPosition: transformedPosition,
      ),
      buttons: buttons,
      obscured: obscured,
      pressureMin: pressureMin,
      pressureMax: pressureMax,
      distance: distance,
      distanceMax: distanceMax,
      size: size,
      radiusMajor: radiusMajor,
      radiusMinor: radiusMinor,
      radiusMin: radiusMin,
      radiusMax: radiusMax,
      orientation: orientation,
      tilt: tilt,
      synthesized: synthesized,
      transform: transform,
      original: original ?? this,
    );
  }
}

/// The pointer has made contact with the device.
class PointerDownEvent extends PointerEvent {
  /// Creates a pointer down event.
  ///
  /// All of the arguments must be non-null.
  const PointerDownEvent({
    Duration timeStamp = Duration.zero,
    int pointer = 0,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    int buttons = kPrimaryButton,
    bool obscured = false,
    double pressure = 1.0,
    double pressureMin = 1.0,
    double pressureMax = 1.0,
    double distanceMax = 0.0,
    double size = 0.0,
    double radiusMajor = 0.0,
    double radiusMinor = 0.0,
    double radiusMin = 0.0,
    double radiusMax = 0.0,
    double orientation = 0.0,
    double tilt = 0.0,
    Matrix4 transform,
    PointerDownEvent original,
  }) : super(
         timeStamp: timeStamp,
         pointer: pointer,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         buttons: buttons,
         down: true,
         obscured: obscured,
         pressure: pressure,
         pressureMin: pressureMin,
         pressureMax: pressureMax,
         distance: 0.0,
         distanceMax: distanceMax,
         size: size,
         radiusMajor: radiusMajor,
         radiusMinor: radiusMinor,
         radiusMin: radiusMin,
         radiusMax: radiusMax,
         orientation: orientation,
         tilt: tilt,
         transform: transform,
         original: original,
       );

  @override
  PointerDownEvent transformed(Matrix4 transform) {
    if (transform == null || transform == this.transform) {
      return this;
    }
    return PointerDownEvent(
      timeStamp: timeStamp,
      pointer: pointer,
      kind: kind,
      device: device,
      position: position,
      localPosition: PointerEvent.transformPosition(transform, position),
      buttons: buttons,
      obscured: obscured,
      pressure: pressure,
      pressureMin: pressureMin,
      pressureMax: pressureMax,
      distanceMax: distanceMax,
      size: size,
      radiusMajor: radiusMajor,
      radiusMinor: radiusMinor,
      radiusMin: radiusMin,
      radiusMax: radiusMax,
      orientation: orientation,
      tilt: tilt,
      transform: transform,
      original: original ?? this,
    );
  }
}

/// The pointer has moved with respect to the device while the pointer is in
/// contact with the device.
///
/// See also:
///
///  * [PointerHoverEvent], which reports movement while the pointer is not in
///    contact with the device.
class PointerMoveEvent extends PointerEvent {
  /// Creates a pointer move event.
  ///
  /// All of the arguments must be non-null.
  const PointerMoveEvent({
    Duration timeStamp = Duration.zero,
    int pointer = 0,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    Offset delta = Offset.zero,
    Offset localDelta,
    int buttons = kPrimaryButton,
    bool obscured = false,
    double pressure = 1.0,
    double pressureMin = 1.0,
    double pressureMax = 1.0,
    double distanceMax = 0.0,
    double size = 0.0,
    double radiusMajor = 0.0,
    double radiusMinor = 0.0,
    double radiusMin = 0.0,
    double radiusMax = 0.0,
    double orientation = 0.0,
    double tilt = 0.0,
    int platformData = 0,
    bool synthesized = false,
    Matrix4 transform,
    PointerMoveEvent original,
  }) : super(
         timeStamp: timeStamp,
         pointer: pointer,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         delta: delta,
         localDelta: localDelta,
         buttons: buttons,
         down: true,
         obscured: obscured,
         pressure: pressure,
         pressureMin: pressureMin,
         pressureMax: pressureMax,
         distance: 0.0,
         distanceMax: distanceMax,
         size: size,
         radiusMajor: radiusMajor,
         radiusMinor: radiusMinor,
         radiusMin: radiusMin,
         radiusMax: radiusMax,
         orientation: orientation,
         tilt: tilt,
         platformData: platformData,
         synthesized: synthesized,
         transform: transform,
         original: original,
       );

  @override
  PointerMoveEvent transformed(Matrix4 transform) {
    if (transform == null || transform == this.transform) {
      return this;
    }
    final Offset transformedPosition = PointerEvent.transformPosition(transform, position);

    return PointerMoveEvent(
      timeStamp: timeStamp,
      pointer: pointer,
      kind: kind,
      device: device,
      position: position,
      localPosition: transformedPosition,
      delta: delta,
      localDelta: PointerEvent.transformDeltaViaPositions(
        transform: transform,
        untransformedDelta: delta,
        untransformedEndPosition: position,
        transformedEndPosition: transformedPosition,
      ),
      buttons: buttons,
      obscured: obscured,
      pressure: pressure,
      pressureMin: pressureMin,
      pressureMax: pressureMax,
      distanceMax: distanceMax,
      size: size,
      radiusMajor: radiusMajor,
      radiusMinor: radiusMinor,
      radiusMin: radiusMin,
      radiusMax: radiusMax,
      orientation: orientation,
      tilt: tilt,
      platformData: platformData,
      synthesized: synthesized,
      transform: transform,
      original: original ?? this,
    );
  }
}

/// The pointer has stopped making contact with the device.
class PointerUpEvent extends PointerEvent {
  /// Creates a pointer up event.
  ///
  /// All of the arguments must be non-null.
  const PointerUpEvent({
    Duration timeStamp = Duration.zero,
    int pointer = 0,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    int buttons = 0,
    bool obscured = false,
    // Allow pressure customization here because PointerUpEvent can contain
    // non-zero pressure. See https://github.com/flutter/flutter/issues/31340
    double pressure = 0.0,
    double pressureMin = 1.0,
    double pressureMax = 1.0,
    double distance = 0.0,
    double distanceMax = 0.0,
    double size = 0.0,
    double radiusMajor = 0.0,
    double radiusMinor = 0.0,
    double radiusMin = 0.0,
    double radiusMax = 0.0,
    double orientation = 0.0,
    double tilt = 0.0,
    Matrix4 transform,
    PointerUpEvent original,
  }) : super(
         timeStamp: timeStamp,
         pointer: pointer,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         buttons: buttons,
         down: false,
         obscured: obscured,
         pressure: pressure,
         pressureMin: pressureMin,
         pressureMax: pressureMax,
         distance: distance,
         distanceMax: distanceMax,
         size: size,
         radiusMajor: radiusMajor,
         radiusMinor: radiusMinor,
         radiusMin: radiusMin,
         radiusMax: radiusMax,
         orientation: orientation,
         tilt: tilt,
         transform: transform,
         original: original,
       );

  @override
  PointerUpEvent transformed(Matrix4 transform) {
    if (transform == null || transform == this.transform) {
      return this;
    }
    return PointerUpEvent(
      timeStamp: timeStamp,
      pointer: pointer,
      kind: kind,
      device: device,
      position: position,
      localPosition: PointerEvent.transformPosition(transform, position),
      buttons: buttons,
      obscured: obscured,
      pressure: pressure,
      pressureMin: pressureMin,
      pressureMax: pressureMax,
      distance: distance,
      distanceMax: distanceMax,
      size: size,
      radiusMajor: radiusMajor,
      radiusMinor: radiusMinor,
      radiusMin: radiusMin,
      radiusMax: radiusMax,
      orientation: orientation,
      tilt: tilt,
      transform: transform,
      original: original ?? this,
    );
  }
}

/// An event that corresponds to a discrete pointer signal.
///
/// Pointer signals are events that originate from the pointer but don't change
/// the state of the pointer itself, and are discrete rather than needing to be
/// interpreted in the context of a series of events.
abstract class PointerSignalEvent extends PointerEvent {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const PointerSignalEvent({
    Duration timeStamp = Duration.zero,
    int pointer = 0,
    PointerDeviceKind kind = PointerDeviceKind.mouse,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    Matrix4 transform,
    PointerSignalEvent original,
  }) : super(
         timeStamp: timeStamp,
         pointer: pointer,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         transform: transform,
         original: original,
       );
}

/// The pointer issued a scroll event.
///
/// Scrolling the scroll wheel on a mouse is an example of an event that
/// would create a [PointerScrollEvent].
class PointerScrollEvent extends PointerSignalEvent {
  /// Creates a pointer scroll event.
  ///
  /// All of the arguments must be non-null.
  const PointerScrollEvent({
    Duration timeStamp = Duration.zero,
    PointerDeviceKind kind = PointerDeviceKind.mouse,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    this.scrollDelta = Offset.zero,
    Matrix4 transform,
    PointerScrollEvent original,
  }) : assert(timeStamp != null),
       assert(kind != null),
       assert(device != null),
       assert(position != null),
       assert(scrollDelta != null),
       super(
         timeStamp: timeStamp,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         transform: transform,
         original: original,
       );

  /// The amount to scroll, in logical pixels.
  final Offset scrollDelta;

  @override
  PointerScrollEvent transformed(Matrix4 transform) {
    if (transform == null || transform == this.transform) {
      return this;
    }
    return PointerScrollEvent(
      timeStamp: timeStamp,
      kind: kind,
      device: device,
      position: position,
      localPosition: PointerEvent.transformPosition(transform, position),
      scrollDelta: scrollDelta,
      transform: transform,
      original: original ?? this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Offset>('scrollDelta', scrollDelta));
  }
}

/// The input from the pointer is no longer directed towards this receiver.
class PointerCancelEvent extends PointerEvent {
  /// Creates a pointer cancel event.
  ///
  /// All of the arguments must be non-null.
  const PointerCancelEvent({
    Duration timeStamp = Duration.zero,
    int pointer = 0,
    PointerDeviceKind kind = PointerDeviceKind.touch,
    int device = 0,
    Offset position = Offset.zero,
    Offset localPosition,
    int buttons = 0,
    bool obscured = false,
    double pressureMin = 1.0,
    double pressureMax = 1.0,
    double distance = 0.0,
    double distanceMax = 0.0,
    double size = 0.0,
    double radiusMajor = 0.0,
    double radiusMinor = 0.0,
    double radiusMin = 0.0,
    double radiusMax = 0.0,
    double orientation = 0.0,
    double tilt = 0.0,
    Matrix4 transform,
    PointerCancelEvent original,
  }) : super(
         timeStamp: timeStamp,
         pointer: pointer,
         kind: kind,
         device: device,
         position: position,
         localPosition: localPosition,
         buttons: buttons,
         down: false,
         obscured: obscured,
         pressure: 0.0,
         pressureMin: pressureMin,
         pressureMax: pressureMax,
         distance: distance,
         distanceMax: distanceMax,
         size: size,
         radiusMajor: radiusMajor,
         radiusMinor: radiusMinor,
         radiusMin: radiusMin,
         radiusMax: radiusMax,
         orientation: orientation,
         tilt: tilt,
         transform: transform,
         original: original,
       );

  @override
  PointerCancelEvent transformed(Matrix4 transform) {
    if (transform == null || transform == this.transform) {
      return this;
    }
    return PointerCancelEvent(
      timeStamp: timeStamp,
      pointer: pointer,
      kind: kind,
      device: device,
      position: position,
      localPosition: PointerEvent.transformPosition(transform, position),
      buttons: buttons,
      obscured: obscured,
      pressureMin: pressureMin,
      pressureMax: pressureMax,
      distance: distance,
      distanceMax: distanceMax,
      size: size,
      radiusMajor: radiusMajor,
      radiusMinor: radiusMinor,
      radiusMin: radiusMin,
      radiusMax: radiusMax,
      orientation: orientation,
      tilt: tilt,
      transform: transform,
      original: original ?? this,
    );
  }
}
