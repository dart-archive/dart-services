// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';

class X {}

class Y extends X {}

class A<U extends X> {
  U u;
}

void main() {
  test('Assignment through a covariant template throws exception', () {
    final A<Y> ay = A<Y>();
    final A<X> ayAsAx = ay;
    expect(() {
      ayAsAx.u = X();
    }, throwsAssertionError);
  });
}
