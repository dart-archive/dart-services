// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:flutter_web_ui/ui.dart' show hashValues;

/// A Key is an identifier for [Widget]s and [Element]s. A new Widget will only
/// be used to reconfigure an existing Element if its Key is the same as its
/// original Widget's Key.
///
/// Keys must be unique amongst the Elements with the same parent.
abstract class Key {
  /// Construct a ValueKey<String> with the given String.
  /// This is the simplest way to create keys.
  const factory Key(String value) = ValueKey<String>;

  /// Default constructor, used by subclasses.
  ///
  /// Useful so that subclasses can call us, because the [new Key] factory
  /// constructor shadows the implicit constructor.
  @protected
  const Key.empty();
}

/// A key that is not a [GlobalKey].
///
/// Keys must be unique amongst the [Element]s with the same parent. By
/// contrast, [GlobalKey]s must be unique across the entire app.
///
/// See also the discussion at [Widget.key].
abstract class LocalKey extends Key {
  /// Default constructor, used by subclasses.
  const LocalKey() : super.empty();
}

/// A key that uses a value of a particular type to identify itself.
///
/// A [ValueKey<T>] is equal to another [ValueKey<T>] if, and only if, their
/// values are [operator==].
///
/// This class can be subclassed to create value keys that will not be equal to
/// other value keys that happen to use the same value. If the subclass is
/// private, this results in a value key type that cannot collide with keys from
/// other sources, which could be useful, for example, if the keys are being
/// used as fallbacks in the same scope as keys supplied from another widget.
///
/// See also the discussion at [Widget.key].
class ValueKey<T> extends LocalKey {
  /// Creates a key that delegates its [operator==] to the given value.
  const ValueKey(this.value);

  /// The value to which this key delegates its [operator==]
  final T value;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final ValueKey<T> typedOther = other;
    return value == typedOther.value;
  }

  @override
  int get hashCode => hashValues(runtimeType, value);

  @override
  String toString() {
    final String valueString = T == String ? '<\'$value\'>' : '<$value>';
    // The crazy on the next line is a workaround for
    // https://github.com/dart-lang/sdk/issues/28548
    if (runtimeType == new _TypeLiteral<ValueKey<T>>().type)
      return '[$valueString]';
    return '[$T $valueString]';
  }
}

class _TypeLiteral<T> {
  Type get type => T;
}
