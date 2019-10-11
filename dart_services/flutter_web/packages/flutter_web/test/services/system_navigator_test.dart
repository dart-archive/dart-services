// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/services.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

void main() {
  test('System navigator control test', () async {
    final List<MethodCall> log = <MethodCall>[];

    SystemChannels.platform
        .setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
    });

    await SystemNavigator.pop();

    expect(log, hasLength(1));
    expect(log.single, isMethodCall('SystemNavigator.pop', arguments: null));
  });
}
