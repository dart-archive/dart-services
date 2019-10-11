// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// webOnly: we do not use actual isolates on the web.

/// Signature for the callback passed to [compute].
///
/// {@macro flutter.foundation.compute.types}
///
/// Instances of [ComputeCallback] must be top-level functions or static methods
/// of classes, not closures or instance methods of objects.
///
/// {@macro flutter.foundation.compute.limitations}
typedef ComputeCallback<Q, R> = R Function(Q message);

/// Spawn an isolate, run `callback` on that isolate, passing it `message`, and
/// (eventually) return the value returned by `callback`.
///
/// This is useful for operations that take longer than a few milliseconds, and
/// which would therefore risk skipping frames. For tasks that will only take a
/// few milliseconds, consider [scheduleTask] instead.
///
/// {@template flutter.foundation.compute.types}
/// `Q` is the type of the message that kicks off the computation.
///
/// `R` is the type of the value returned.
/// {@endtemplate}
///
/// The `callback` argument must be a top-level function, not a closure or an
/// instance or static method of a class.
///
/// {@template flutter.foundation.compute.limitations}
/// There are limitations on the values that can be sent and received to and
/// from isolates. These limitations constrain the values of `Q` and `R` that
/// are possible. See the discussion at [SendPort.send].
/// {@endtemplate}
///
/// The `debugLabel` argument can be specified to provide a name to add to the
/// [Timeline]. This is useful when profiling an application.
Future<R> compute<Q, R>(ComputeCallback<Q, R> callback, Q message,
    {String debugLabel}) async {
  return callback(message);
}
