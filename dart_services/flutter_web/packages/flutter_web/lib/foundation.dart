// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-05-30T14:20:56.103588.

/// Core Flutter framework primitives.
///
/// The features defined in this library are the lowest-level utility
/// classes and functions used by all the other layers of the Flutter
/// framework.
library foundation;

export 'package:meta/meta.dart' show
  immutable,
  mustCallSuper,
  optionalTypeArgs,
  protected,
  required,
  visibleForTesting;


export 'src/foundation/assertions.dart';
export 'src/foundation/basic_types.dart';
export 'src/foundation/binding.dart';
export 'src/foundation/bitfield.dart';
export 'src/foundation/constants.dart';
export 'src/foundation/change_notifier.dart';
export 'src/foundation/collections.dart';
export 'src/foundation/debug.dart';
export 'src/foundation/diagnostics.dart';
export 'src/foundation/key.dart';
export 'src/foundation/isolates.dart';
export 'src/foundation/licenses.dart';
export 'src/foundation/node.dart';
export 'src/foundation/observer_list.dart';
export 'src/foundation/platform.dart';
export 'src/foundation/print.dart';
export 'src/foundation/profile.dart';
export 'src/foundation/serialization.dart';
export 'src/foundation/synchronous_future.dart';
export 'src/foundation/unicode.dart';
