// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-05-30T14:20:56.125425.

import 'package:flutter_web_ui/ui.dart' show VoidCallback;

import 'package:flutter_web/foundation.dart';

import 'animation.dart';

/// A mixin that helps listen to another object only when this object has registered listeners.
///
/// This mixin provides implementations of [didRegisterListener] and [didUnregisterListener],
/// and therefore can be used in conjunction with mixins that require these methods,
/// [AnimationLocalListenersMixin] and [AnimationLocalStatusListenersMixin].
mixin AnimationLazyListenerMixin {
  int _listenerCounter = 0;

  /// Calls [didStartListening] every time a registration of a listener causes
  /// an empty list of listeners to become non-empty.
  ///
  /// See also:
  ///
  ///  * [didUnregisterListener], which may cause the listener list to
  ///    become empty again, and in turn cause this method to call
  ///    [didStartListening] again.
  void didRegisterListener() {
    assert(_listenerCounter >= 0);
    if (_listenerCounter == 0)
      didStartListening();
    _listenerCounter += 1;
  }

  /// Calls [didStopListening] when an only remaining listener is unregistered,
  /// thus making the list empty.
  ///
  /// See also:
  ///
  ///  * [didRegisterListener], which causes the listener list to become non-empty.
  void didUnregisterListener() {
    assert(_listenerCounter >= 1);
    _listenerCounter -= 1;
    if (_listenerCounter == 0)
      didStopListening();
  }

  /// Called when the number of listeners changes from zero to one.
  @protected
  void didStartListening();

  /// Called when the number of listeners changes from one to zero.
  @protected
  void didStopListening();

  /// Whether there are any listeners.
  bool get isListening => _listenerCounter > 0;
}

/// A mixin that replaces the [didRegisterListener]/[didUnregisterListener] contract
/// with a dispose contract.
///
/// This mixin provides implementations of [didRegisterListener] and [didUnregisterListener],
/// and therefore can be used in conjunction with mixins that require these methods,
/// [AnimationLocalListenersMixin] and [AnimationLocalStatusListenersMixin].
mixin AnimationEagerListenerMixin {
  /// This implementation ignores listener registrations.
  void didRegisterListener() { }

  /// This implementation ignores listener registrations.
  void didUnregisterListener() { }

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  @mustCallSuper
  void dispose() { }
}

/// A mixin that implements the [addListener]/[removeListener] protocol and notifies
/// all the registered listeners when [notifyListeners] is called.
///
/// This mixin requires that the mixing class provide methods [didRegisterListener]
/// and [didUnregisterListener]. Implementations of these methods can be obtained
/// by mixing in another mixin from this library, such as [AnimationLazyListenerMixin].
mixin AnimationLocalListenersMixin {
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();

  /// Called immediately before a listener is added via [addListener].
  ///
  /// At the time this method is called the registered listener is not yet
  /// notified by [notifyListeners].
  void didRegisterListener();

  /// Called immediately after a listener is removed via [removeListener].
  ///
  /// At the time this method is called the removed listener is no longer
  /// notified by [notifyListeners].
  void didUnregisterListener();

  /// Calls the listener every time the value of the animation changes.
  ///
  /// Listeners can be removed with [removeListener].
  void addListener(VoidCallback listener) {
    didRegisterListener();
    _listeners.add(listener);
  }

  /// Stop calling the listener every time the value of the animation changes.
  ///
  /// Listeners can be added with [addListener].
  void removeListener(VoidCallback listener) {
    final bool removed = _listeners.remove(listener);
    if (removed) {
      didUnregisterListener();
    }
  }

  /// Calls all the listeners.
  ///
  /// If listeners are added or removed during this function, the modifications
  /// will not change which listeners are called during this iteration.
  void notifyListeners() {
    final List<VoidCallback> localListeners = List<VoidCallback>.from(_listeners);
    for (VoidCallback listener in localListeners) {
      try {
        if (_listeners.contains(listener))
          listener();
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'animation library',
          context: ErrorDescription('while notifying listeners for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<AnimationLocalListenersMixin>(
              'The $runtimeType notifying listeners was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
  }
}

/// A mixin that implements the addStatusListener/removeStatusListener protocol
/// and notifies all the registered listeners when notifyStatusListeners is
/// called.
///
/// This mixin requires that the mixing class provide methods [didRegisterListener]
/// and [didUnregisterListener]. Implementations of these methods can be obtained
/// by mixing in another mixin from this library, such as [AnimationLazyListenerMixin].
mixin AnimationLocalStatusListenersMixin {
  final ObserverList<AnimationStatusListener> _statusListeners = ObserverList<AnimationStatusListener>();

  /// Called immediately before a status listener is added via [addStatusListener].
  ///
  /// At the time this method is called the registered listener is not yet
  /// notified by [notifyStatusListeners].
  void didRegisterListener();

  /// Called immediately after a status listener is removed via [removeStatusListener].
  ///
  /// At the time this method is called the removed listener is no longer
  /// notified by [notifyStatusListeners].
  void didUnregisterListener();

  /// Calls listener every time the status of the animation changes.
  ///
  /// Listeners can be removed with [removeStatusListener].
  void addStatusListener(AnimationStatusListener listener) {
    didRegisterListener();
    _statusListeners.add(listener);
  }

  /// Stops calling the listener every time the status of the animation changes.
  ///
  /// Listeners can be added with [addStatusListener].
  void removeStatusListener(AnimationStatusListener listener) {
    final bool removed = _statusListeners.remove(listener);
    if (removed) {
      didUnregisterListener();
    }
  }

  /// Calls all the status listeners.
  ///
  /// If listeners are added or removed during this function, the modifications
  /// will not change which listeners are called during this iteration.
  void notifyStatusListeners(AnimationStatus status) {
    final List<AnimationStatusListener> localListeners = List<AnimationStatusListener>.from(_statusListeners);
    for (AnimationStatusListener listener in localListeners) {
      try {
        if (_statusListeners.contains(listener))
          listener(status);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'animation library',
          context: ErrorDescription('while notifying status listeners for $runtimeType'),
          informationCollector: () sync* {
            yield DiagnosticsProperty<AnimationLocalStatusListenersMixin>(
              'The $runtimeType notifying status listeners was',
              this,
              style: DiagnosticsTreeStyle.errorProperty,
            );
          },
        ));
      }
    }
  }
}
