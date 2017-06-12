// Copyright 2015 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:html';

void main() {
  var count = querySelector('#count');

  for (int i = 0; i < 4; i++) {
    count.text = '${i}';
    print('hello ${i}');
  }
}
