// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of engine;

class ViewportMetrics {
  final double devicePixelRatio;
  final double physicalWidth;
  final double physicalHeight;

  const ViewportMetrics(
    this.devicePixelRatio,
    this.physicalWidth,
    this.physicalHeight,
  );
}
