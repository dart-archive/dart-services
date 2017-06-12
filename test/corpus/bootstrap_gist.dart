// Copyright 2015 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:html';

void main() {
  for (Element e in querySelectorAll('a, button')) {
    e.onClick.listen((e) => handleClick(e.target));
  }
}

void handleClick(var element) {
  print('[${element.text.trim()}]');
}
