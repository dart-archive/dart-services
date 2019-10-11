// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-06-04T10:01:02.507286.

import 'simulation.dart';

/// A simulation that applies limits to another simulation.
///
/// The limits are only applied to the other simulation's outputs. For example,
/// if a maximum position was applied to a gravity simulation with the
/// particle's initial velocity being up, and the acceleration being down, and
/// the maximum position being between the initial position and the curve's
/// apogee, then the particle would return to its initial position in the same
/// amount of time as it would have if the maximum had not been applied; the
/// difference would just be that the position would be reported as pinned to
/// the maximum value for the times that it would otherwise have been reported
/// as higher.
class ClampedSimulation extends Simulation {

  /// Creates a [ClampedSimulation] that clamps the given simulation.
  ///
  /// The named arguments specify the ranges for the clamping behavior, as
  /// applied to [x] and [dx].
  ClampedSimulation(
    this.simulation, {
    this.xMin = double.negativeInfinity,
    this.xMax = double.infinity,
    this.dxMin = double.negativeInfinity,
    this.dxMax = double.infinity,
  }) : assert(simulation != null),
       assert(xMax >= xMin),
       assert(dxMax >= dxMin);

  /// The simulation being clamped. Calls to [x], [dx], and [isDone] are
  /// forwarded to the simulation.
  final Simulation simulation;

  /// The minimum to apply to [x].
  final double xMin;

  /// The maximum to apply to [x].
  final double xMax;

  /// The minimum to apply to [dx].
  final double dxMin;

  /// The maximum to apply to [dx].
  final double dxMax;

  @override
  double x(double time) => simulation.x(time).clamp(xMin, xMax);

  @override
  double dx(double time) => simulation.dx(time).clamp(dxMin, dxMax);

  @override
  bool isDone(double time) => simulation.isDone(time);
}
