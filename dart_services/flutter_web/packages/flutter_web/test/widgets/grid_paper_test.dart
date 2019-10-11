// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';

void main() {
  testWidgets('GridPaper control test', (WidgetTester tester) async {
    await tester.pumpWidget(const GridPaper());
    final List<Layer> layers1 = tester.layers;
    await tester.pumpWidget(const GridPaper());
    final List<Layer> layers2 = tester.layers;
    expect(layers1, equals(layers2));
  });
}
