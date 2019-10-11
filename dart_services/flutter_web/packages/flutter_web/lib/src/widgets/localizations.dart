// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter_web_ui/ui.dart' show Locale;

import 'package:flutter_web/foundation.dart';

import 'basic.dart';
import 'binding.dart';
import 'container.dart';
import 'framework.dart';

// Examples can assume:
// class Intl { static String message(String s, { String name, String locale }) => ''; }
// Future<void> initializeMessages(String locale) => null;

// Used by loadAll() to record LocalizationsDelegate.load() futures we're
// waiting for.
class _Pending {
  _Pending(this.delegate, this.futureValue);
  final LocalizationsDelegate<dynamic> delegate;
  final Future<dynamic> futureValue;
}

// A utility function used by Localizations to generate one future
// that completes when all of the LocalizationsDelegate.load() futures
// complete. The returned map is indexed by each delegate's type.
//
// The input future values must have distinct types.
//
// The returned Future<Map> will resolve when all of the input map's
// future values have resolved. If all of the input map's values are
// SynchronousFutures then a SynchronousFuture will be returned
// immediately.
//
// This is more complicated than just applying Future.wait to input
// because some of the input.values may be SynchronousFutures. We don't want
// to Future.wait for the synchronous futures.
Future<Map<Type, dynamic>> _loadAll(
    Locale locale, Iterable<LocalizationsDelegate<dynamic>> allDelegates) {
  final Map<Type, dynamic> output = <Type, dynamic>{};
  List<_Pending> pendingList;

  // Only load the first delegate for each delegate type that supports
  // locale.languageCode.
  final Set<Type> types = Set<Type>();
  final List<LocalizationsDelegate<dynamic>> delegates =
      <LocalizationsDelegate<dynamic>>[];
  for (LocalizationsDelegate<dynamic> delegate in allDelegates) {
    if (!types.contains(delegate.type) && delegate.isSupported(locale)) {
      types.add(delegate.type);
      delegates.add(delegate);
    }
  }

  for (LocalizationsDelegate<dynamic> delegate in delegates) {
    final Future<dynamic> inputValue = delegate.load(locale);
    dynamic completedValue;
    final Future<dynamic> futureValue =
        inputValue.then<dynamic>((dynamic value) {
      return completedValue = value;
    });
    if (completedValue != null) {
      // inputValue was a SynchronousFuture
      final Type type = delegate.type;
      assert(!output.containsKey(type));
      output[type] = completedValue;
    } else {
      pendingList ??= <_Pending>[];
      pendingList.add(_Pending(delegate, futureValue));
    }
  }

  // All of the delegate.load() values were synchronous futures, we're done.
  if (pendingList == null) return SynchronousFuture<Map<Type, dynamic>>(output);

  // Some of delegate.load() values were asynchronous futures. Wait for them.
  return Future.wait<dynamic>(pendingList.map((_Pending p) => p.futureValue))
      .then<Map<Type, dynamic>>((List<dynamic> values) {
    assert(values.length == pendingList.length);
    for (int i = 0; i < values.length; i += 1) {
      final Type type = pendingList[i].delegate.type;
      assert(!output.containsKey(type));
      output[type] = values[i];
    }
    return output;
  });
}

/// A factory for a set of localized resources of type `T`, to be loaded by a
/// [Localizations] widget.
///
/// Typical applications have one [Localizations] widget which is created by the
/// [WidgetsApp] and configured with the app's `localizationsDelegates`
/// parameter (a list of delegates). The delegate's [type] is used to identify
/// the object created by an individual delegate's [load] method.
abstract class LocalizationsDelegate<T> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const LocalizationsDelegate();

  /// Whether resources for the given locale can be loaded by this delegate.
  ///
  /// Return true if the instance of `T` loaded by this delegate's [load]
  /// method supports the given `locale`'s language.
  bool isSupported(Locale locale);

  /// Start loading the resources for `locale`. The returned future completes
  /// when the resources have finished loading.
  ///
  /// It's assumed that the this method will return an object that contains
  /// a collection of related resources (typically defined with one method per
  /// resource). The object will be retrieved with [Localizations.of].
  Future<T> load(Locale locale);

  /// Returns true if the resources for this delegate should be loaded
  /// again by calling the [load] method.
  ///
  /// This method is called whenever its [Localizations] widget is
  /// rebuilt. If it returns true then dependent widgets will be rebuilt
  /// after [load] has completed.
  bool shouldReload(covariant LocalizationsDelegate<T> old);

  /// The type of the object returned by the [load] method, T by default.
  ///
  /// This type is used to retrieve the object "loaded" by this
  /// [LocalizationsDelegate] from the [Localizations] inherited widget.
  /// For example the object loaded by `LocalizationsDelegate<Foo>` would
  /// be retrieved with:
  /// ```dart
  /// Foo foo = Localizations.of<Foo>(context, Foo);
  /// ```
  ///
  /// It's rarely necessary to override this getter.
  Type get type => T;

  @override
  String toString() => '$runtimeType[$type]';
}

/// Interface for localized resource values for the lowest levels of the Flutter
/// framework.
///
/// In particular, this maps locales to a specific [Directionality] using the
/// [textDirection] property.
///
/// See also:
///
///  * [DefaultWidgetsLocalizations], which implements this interface and
///    supports a variety of locales.
abstract class WidgetsLocalizations {
  /// The reading direction for text in this locale.
  TextDirection get textDirection;

  /// The `WidgetsLocalizations` from the closest [Localizations] instance
  /// that encloses the given context.
  ///
  /// This method is just a convenient shorthand for:
  /// `Localizations.of<WidgetsLocalizations>(context, WidgetsLocalizations)`.
  ///
  /// References to the localized resources defined by this class are typically
  /// written in terms of this method. For example:
  ///
  /// ```dart
  /// textDirection: WidgetsLocalizations.of(context).textDirection,
  /// ```
  static WidgetsLocalizations of(BuildContext context) {
    return Localizations.of<WidgetsLocalizations>(
        context, WidgetsLocalizations);
  }
}

class _WidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _WidgetsLocalizationsDelegate();

  // This is convenient simplification. It would be more correct test if the locale's
  // text-direction is LTR.
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      DefaultWidgetsLocalizations.load(locale);

  @override
  bool shouldReload(_WidgetsLocalizationsDelegate old) => false;
}

/// US English localizations for the widgets library.
///
/// See also:
///
/// * [GlobalWidgetsLocalizations], which provides widgets localizations for
///   many languages.
/// * [WidgetsApp.delegates], which automatically includes
///   [DefaultWidgetsLocalizations.delegate] by default.
class DefaultWidgetsLocalizations implements WidgetsLocalizations {
  /// Construct an object that defines the localized values for the widgets
  /// library for US English (only).
  ///
  /// [LocalizationsDelegate] implementations typically call the static [load]
  const DefaultWidgetsLocalizations();

  @override
  TextDirection get textDirection => TextDirection.ltr;

  /// Creates an object that provides US English resource values for the
  /// lowest levels of the widgets library.
  ///
  /// The [locale] parameter is ignored.
  ///
  /// This method is typically used to create a [LocalizationsDelegate].
  /// The [WidgetsApp] does so by default.
  static Future<WidgetsLocalizations> load(Locale locale) {
    return SynchronousFuture<WidgetsLocalizations>(
        const DefaultWidgetsLocalizations());
  }

  /// A [LocalizationsDelegate] that uses [DefaultWidgetsLocalizations.load]
  /// to create an instance of this class.
  ///
  /// [WidgetsApp] automatically adds this value to [WidgetApp.localizationsDelegates].
  static const LocalizationsDelegate<WidgetsLocalizations> delegate =
      _WidgetsLocalizationsDelegate();
}

class _LocalizationsScope extends InheritedWidget {
  const _LocalizationsScope({
    Key key,
    @required this.locale,
    @required this.localizationsState,
    @required this.typeToResources,
    Widget child,
  })  : assert(localizationsState != null),
        assert(typeToResources != null),
        super(key: key, child: child);

  final Locale locale;
  final _LocalizationsState localizationsState;
  final Map<Type, dynamic> typeToResources;

  @override
  bool updateShouldNotify(_LocalizationsScope old) {
    return typeToResources != old.typeToResources;
  }
}

/// Defines the [Locale] for its `child` and the localized resources that the
/// child depends on.
///
/// Localized resources are loaded by the list of [LocalizationsDelegate]
/// `delegates`. Each delegate is essentially a factory for a collection
/// of localized resources. There are multiple delegates because there are
/// multiple sources for localizations within an app.
///
/// Delegates are typically simple subclasses of [LocalizationsDelegate] that
/// override [LocalizationsDelegate.load]. For example a delegate for the
/// `MyLocalizations` class defined below would be:
///
/// ```dart
/// class _MyDelegate extends LocalizationsDelegate<MyLocalizations> {
///   @override
///   Future<MyLocalizations> load(Locale locale) => MyLocalizations.load(locale);
///
///   @override
///   bool shouldReload(MyLocalizationsDelegate old) => false;
/// }
/// ```
///
/// Each delegate can be viewed as a factory for objects that encapsulate a
/// a set of localized resources. These objects are retrieved with
/// by runtime type with [Localizations.of].
///
/// The [WidgetsApp] class creates a `Localizations` widget so most apps
/// will not need to create one. The widget app's `Localizations` delegates can
/// be initialized with [WidgetsApp.localizationsDelegates]. The [MaterialApp]
/// class also provides a `localizationsDelegates` parameter that's just
/// passed along to the [WidgetsApp].
///
/// Apps should retrieve collections of localized resources with
/// `Localizations.of<MyLocalizations>(context, MyLocalizations)`,
/// where MyLocalizations is an app specific class defines one function per
/// resource. This is conventionally done by a static `.of` method on the
/// MyLocalizations class.
///
/// For example, using the `MyLocalizations` class defined below, one would
/// lookup a localized title string like this:
/// ```dart
/// MyLocalizations.of(context).title()
/// ```
/// If `Localizations` were to be rebuilt with a new `locale` then
/// the widget subtree that corresponds to [BuildContext] `context` would
/// be rebuilt after the corresponding resources had been loaded.
///
/// This class is effectively an [InheritedWidget]. If it's rebuilt with
/// a new `locale` or a different list of delegates or any of its
/// delegates' [LocalizationsDelegate.shouldReload()] methods returns true,
/// then widgets that have created a dependency by calling
/// `Localizations.of(context)` will be rebuilt after the resources
/// for the new locale have been loaded.
///
/// ## Sample code
///
/// This following class is defined in terms of the
/// [Dart `intl` package](https://github.com/dart-lang/intl). Using the `intl`
/// package isn't required.
///
/// ```dart
/// class MyLocalizations {
///   MyLocalizations(this.locale);
///
///   final Locale locale;
///
///   static Future<MyLocalizations> load(Locale locale) {
///     return initializeMessages(locale.toString())
///       .then((Null _) {
///         return MyLocalizations(locale);
///       });
///   }
///
///   static MyLocalizations of(BuildContext context) {
///     return Localizations.of<MyLocalizations>(context, MyLocalizations);
///   }
///
///   String title() => Intl.message('<title>', name: 'title', locale: locale.toString());
///   // ... more Intl.message() methods like title()
/// }
/// ```
/// A class based on the `intl` package imports a generated message catalog that provides
/// the `initializeMessages()` function and the per-locale backing store for `Intl.message()`.
/// The message catalog is produced by an `intl` tool that analyzes the source code for
/// classes that contain `Intl.message()` calls. In this case that would just be the
/// `MyLocalizations` class.
///
/// One could choose another approach for loading localized resources and looking them up while
/// still conforming to the structure of this example.
class Localizations extends StatefulWidget {
  /// Create a widget from which localizations (like translated strings) can be obtained.
  Localizations({
    Key key,
    @required this.locale,
    @required this.delegates,
    this.child,
  })  : assert(locale != null),
        assert(delegates != null),
        assert(delegates.any((LocalizationsDelegate<dynamic> delegate) =>
            delegate is LocalizationsDelegate<WidgetsLocalizations>)),
        super(key: key);

  /// Overrides the inherited [Locale] or [LocalizationsDelegate]s for `child`.
  ///
  /// This factory constructor is used for the (usually rare) situation where part
  /// of an app should be localized for a different locale than the one defined
  /// for the device, or if its localizations should come from a different list
  /// of [LocalizationsDelegate]s than the list defined by
  /// [WidgetsApp.localizationsDelegates].
  ///
  /// For example you could specify that `myWidget` was only to be localized for
  /// the US English locale:
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return Localizations.override(
  ///     context: context,
  ///     locale: const Locale('en', 'US'),
  ///     child: myWidget,
  ///   );
  /// }
  /// ```
  ///
  /// The `locale` and `delegates` parameters default to the [Localizations.locale]
  /// and [Localizations.delegates] values from the nearest [Localizations] ancestor.
  ///
  /// To override the [Localizations.locale] or [Localizations.delegates] for an
  /// entire app, specify [WidgetsApp.locale] or [WidgetsApp.localizationsDelegates]
  /// (or specify the same parameters for [MaterialApp]).
  factory Localizations.override({
    Key key,
    @required BuildContext context,
    Locale locale,
    List<LocalizationsDelegate<dynamic>> delegates,
    Widget child,
  }) {
    final List<LocalizationsDelegate<dynamic>> mergedDelegates =
        Localizations._delegatesOf(context);
    if (delegates != null) mergedDelegates.insertAll(0, delegates);
    return Localizations(
      key: key,
      locale: locale ?? Localizations.localeOf(context),
      delegates: mergedDelegates,
      child: child,
    );
  }

  /// The resources returned by [Localizations.of] will be specific to this locale.
  final Locale locale;

  /// This list collectively defines the localized resources objects that can
  /// be retrieved with [Localizations.of].
  final List<LocalizationsDelegate<dynamic>> delegates;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The locale of the Localizations widget for the widget tree that
  /// corresponds to [BuildContext] `context`.
  ///
  /// If no [Localizations] widget is in scope then the [Localizations.localeOf]
  /// method will throw an exception, unless the `nullOk` argument is set to
  /// true, in which case it returns null.
  static Locale localeOf(BuildContext context, {bool nullOk = false}) {
    assert(context != null);
    assert(nullOk != null);
    final _LocalizationsScope scope =
        context.inheritFromWidgetOfExactType(_LocalizationsScope);
    if (nullOk && scope == null) return null;
    assert(scope != null, 'a Localizations ancestor was not found');
    return scope.localizationsState.locale;
  }

  // There doesn't appear to be a need to make this public. See the
  // Localizations.override factory constructor.
  static List<LocalizationsDelegate<dynamic>> _delegatesOf(
      BuildContext context) {
    assert(context != null);
    final _LocalizationsScope scope =
        context.inheritFromWidgetOfExactType(_LocalizationsScope);
    assert(scope != null, 'a Localizations ancestor was not found');
    return List<LocalizationsDelegate<dynamic>>.from(
        scope.localizationsState.widget.delegates);
  }

  /// Returns the localized resources object of the given `type` for the widget
  /// tree that corresponds to the given `context`.
  ///
  /// Returns null if no resources object of the given `type` exists within
  /// the given `context`.
  ///
  /// This method is typically used by a static factory method on the `type`
  /// class. For example Flutter's MaterialLocalizations class looks up Material
  /// resources with a method defined like this:
  ///
  /// ```dart
  /// static MaterialLocalizations of(BuildContext context) {
  ///    return Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);
  /// }
  /// ```
  static T of<T>(BuildContext context, Type type) {
    assert(context != null);
    assert(type != null);
    final _LocalizationsScope scope =
        context.inheritFromWidgetOfExactType(_LocalizationsScope);
    return scope?.localizationsState?.resourcesFor<T>(type);
  }

  @override
  _LocalizationsState createState() => _LocalizationsState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Locale>('locale', locale));
    properties.add(IterableProperty<LocalizationsDelegate<dynamic>>(
        'delegates', delegates));
  }
}

class _LocalizationsState extends State<Localizations> {
  final GlobalKey _localizedResourcesScopeKey = GlobalKey();
  Map<Type, dynamic> _typeToResources = <Type, dynamic>{};

  Locale get locale => _locale;
  Locale _locale;

  @override
  void initState() {
    super.initState();
    load(widget.locale);
  }

  bool _anyDelegatesShouldReload(Localizations old) {
    if (widget.delegates.length != old.delegates.length) return true;
    final List<LocalizationsDelegate<dynamic>> delegates =
        widget.delegates.toList();
    final List<LocalizationsDelegate<dynamic>> oldDelegates =
        old.delegates.toList();
    for (int i = 0; i < delegates.length; i += 1) {
      final LocalizationsDelegate<dynamic> delegate = delegates[i];
      final LocalizationsDelegate<dynamic> oldDelegate = oldDelegates[i];
      if (delegate.runtimeType != oldDelegate.runtimeType ||
          delegate.shouldReload(oldDelegate)) return true;
    }
    return false;
  }

  @override
  void didUpdateWidget(Localizations old) {
    super.didUpdateWidget(old);
    if (widget.locale != old.locale ||
        (widget.delegates == null && old.delegates != null) ||
        (widget.delegates != null && old.delegates == null) ||
        (widget.delegates != null && _anyDelegatesShouldReload(old)))
      load(widget.locale);
  }

  void load(Locale locale) {
    final Iterable<LocalizationsDelegate<dynamic>> delegates = widget.delegates;
    if (delegates == null || delegates.isEmpty) {
      _locale = locale;
      return;
    }

    Map<Type, dynamic> typeToResources;
    final Future<Map<Type, dynamic>> typeToResourcesFuture =
        _loadAll(locale, delegates).then((Map<Type, dynamic> value) {
      return typeToResources = value;
    });

    if (typeToResources != null) {
      // All of the delegates' resources loaded synchronously.
      _typeToResources = typeToResources;
      _locale = locale;
    } else {
      // - Don't rebuild the dependent widgets until the resources for the new locale
      // have finished loading. Until then the old locale will continue to be used.
      // - If we're running at app startup time then defer reporting the first
      // "useful" frame until after the async load has completed.
      WidgetsBinding.instance.deferFirstFrameReport();
      typeToResourcesFuture.then((Map<Type, dynamic> value) {
        WidgetsBinding.instance.allowFirstFrameReport();
        if (!mounted) return;
        setState(() {
          _typeToResources = value;
          _locale = locale;
        });
      });
    }
  }

  T resourcesFor<T>(Type type) {
    assert(type != null);
    final T resources = _typeToResources[type];
    return resources;
  }

  TextDirection get _textDirection {
    final WidgetsLocalizations resources =
        _typeToResources[WidgetsLocalizations];
    assert(resources != null);
    return resources.textDirection;
  }

  @override
  Widget build(BuildContext context) {
    if (_locale == null) return Container();
    return Semantics(
      textDirection: _textDirection,
      child: _LocalizationsScope(
        key: _localizedResourcesScopeKey,
        locale: _locale,
        localizationsState: this,
        typeToResources: _typeToResources,
        child: Directionality(
          textDirection: _textDirection,
          child: widget.child,
        ),
      ),
    );
  }
}
