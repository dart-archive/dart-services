// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/scheduler.dart';

import 'framework.dart';

/// Enables or disables tickers (and thus animation controllers) in the widget
/// subtree.
///
/// This only works if [AnimationController] objects are created using
/// widget-aware ticker providers. For example, using a
/// [TickerProviderStateMixin] or a [SingleTickerProviderStateMixin].
class TickerMode extends InheritedWidget {
  /// Creates a widget that enables or disables tickers.
  ///
  /// The [enabled] argument must not be null.
  const TickerMode({Key key, @required this.enabled, Widget child})
      : assert(enabled != null),
        super(key: key, child: child);

  /// The current ticker mode of this subtree.
  ///
  /// If true, then tickers in this subtree will tick.
  ///
  /// If false, then tickers in this subtree will not tick. Animations driven by
  /// such tickers are not paused, they just don't call their callbacks. Time
  /// still elapses.
  final bool enabled;

  /// Whether tickers in the given subtree should be enabled or disabled.
  ///
  /// This is used automatically by [TickerProviderStateMixin] and
  /// [SingleTickerProviderStateMixin] to decide if their tickers should be
  /// enabled or disabled.
  ///
  /// In the absence of a [TickerMode] widget, this function defaults to true.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// bool tickingEnabled = TickerMode.of(context);
  /// ```
  static bool of(BuildContext context) {
    final TickerMode widget = context.inheritFromWidgetOfExactType(TickerMode);
    return widget?.enabled ?? true;
  }

  @override
  bool updateShouldNotify(TickerMode oldWidget) => enabled != oldWidget.enabled;
}

/// Provides a single [Ticker] that is configured to only tick while the current
/// tree is enabled, as defined by [TickerMode].
///
/// To create the [AnimationController] in a [State] that only uses a single
/// [AnimationController], mix in this class, then pass `vsync: this`
/// to the animation controller constructor.
///
/// This mixin only supports vending a single ticker. If you might have multiple
/// [AnimationController] objects over the lifetime of the [State], use a full
/// [TickerProviderStateMixin] instead.
@optionalTypeArgs
mixin SingleTickerProviderStateMixin<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  Ticker _ticker;

  @override
  Ticker createTicker(TickerCallback onTick) {
    assert(() {
      if (_ticker == null) return true;
      throw FlutterError(
          '$runtimeType is a SingleTickerProviderStateMixin but multiple tickers were created.\n'
          'A SingleTickerProviderStateMixin can only be used as a TickerProvider once. If a '
          'State is used for multiple AnimationController objects, or if it is passed to other '
          'objects and those objects might use it more than one time in total, then instead of '
          'mixing in a SingleTickerProviderStateMixin, use a regular TickerProviderStateMixin.');
    }());
    _ticker = Ticker(onTick, debugLabel: kDebugMode ? '${widget.toStringShort()}' : null);
    // We assume that this is called from initState, build, or some sort of
    // event handler, and that thus TickerMode.of(context) would return true. We
    // can't actually check that here because if we're in initState then we're
    // not allowed to do inheritance checks yet.
    return _ticker;
  }

  @override
  void dispose() {
    assert(() {
      if (_ticker == null || !_ticker.isActive) return true;
      throw FlutterError('$this was disposed with an active Ticker.\n'
          '$runtimeType created a Ticker via its SingleTickerProviderStateMixin, but at the time '
          'dispose() was called on the mixin, that Ticker was still active. The Ticker must '
          'be disposed before calling super.dispose(). Tickers used by AnimationControllers '
          'should be disposed by calling dispose() on the AnimationController itself. '
          'Otherwise, the ticker will leak.\n'
          'The offending ticker was: ${_ticker.toString(debugIncludeStack: true)}');
    }());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_ticker != null) _ticker.muted = !TickerMode.of(context);
    super.didChangeDependencies();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    String tickerDescription;
    if (_ticker != null) {
      if (_ticker.isActive && _ticker.muted)
        tickerDescription = 'active but muted';
      else if (_ticker.isActive)
        tickerDescription = 'active';
      else if (_ticker.muted)
        tickerDescription = 'inactive and muted';
      else
        tickerDescription = 'inactive';
    }
    properties.add(DiagnosticsProperty<Ticker>('ticker', _ticker,
        description: tickerDescription,
        showSeparator: false,
        defaultValue: null));
  }
}

/// Provides [Ticker] objects that are configured to only tick while the current
/// tree is enabled, as defined by [TickerMode].
///
/// To create an [AnimationController] in a class that uses this mixin, pass
/// `vsync: this` to the animation controller constructor whenever you
/// create a new animation controller.
///
/// If you only have a single [Ticker] (for example only a single
/// [AnimationController]) for the lifetime of your [State], then using a
/// [SingleTickerProviderStateMixin] is more efficient. This is the common case.
@optionalTypeArgs
mixin TickerProviderStateMixin<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  Set<Ticker> _tickers;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _tickers ??= new Set<_WidgetTicker>();
    final _WidgetTicker result = new _WidgetTicker(onTick, this);
    _tickers.add(result);
    return result;
  }

  void _removeTicker(_WidgetTicker ticker) {
    assert(_tickers != null);
    assert(_tickers.contains(ticker));
    _tickers.remove(ticker);
  }

  @override
  void dispose() {
    assert(() {
      if (_tickers != null) {
        for (Ticker ticker in _tickers) {
          if (ticker.isActive) {
            throw new FlutterError('$this was disposed with an active Ticker.\n'
                '$runtimeType created a Ticker via its '
                'TickerProviderStateMixin, but at the time dispose() was '
                'called on the mixin, that Ticker was still active. All '
                'Tickers must be disposed before calling super.dispose(). '
                'Tickers used by AnimationControllers should be disposed by '
                'calling dispose() on the AnimationController itself. '
                'Otherwise, the ticker will leak.\n'
                'The offending ticker was: ${ticker}');
          }
        }
      }
      return true;
    }());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final bool muted = !TickerMode.of(context);
    if (_tickers != null) {
      for (Ticker ticker in _tickers) ticker.muted = muted;
    }
    super.didChangeDependencies();
  }
}

// This class should really be called _DisposingTicker or some such, but this
// class name leaks into stack traces and error messages and that name would be
// confusing. Instead we use the less precise but more anodyne "_WidgetTicker",
// which attracts less attention.
class _WidgetTicker extends Ticker {
  _WidgetTicker(TickerCallback onTick, this._creator) : super(onTick);

  final TickerProviderStateMixin _creator;

  @override
  void dispose() {
    _creator._removeTicker(this);
    super.dispose();
  }
}
