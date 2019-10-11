// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/services.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

void main() {
  test('Haptic feedback control test', () async {
    final List<MethodCall> log = <MethodCall>[];

    SystemChannels.platform
        .setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
    });

    await HapticFeedback.vibrate();

    expect(log, hasLength(1));
    expect(log.single, isMethodCall('HapticFeedback.vibrate', arguments: null));
  });

  test('Haptic feedback variation tests', () async {
    Future<void> callAndVerifyHapticFunction(
        Function hapticFunction, String platformMethodArgument) async {
      final List<MethodCall> log = <MethodCall>[];

      SystemChannels.platform
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
      });

      await Function.apply(hapticFunction, null);
      expect(log, hasLength(1));
      expect(
        log.last,
        isMethodCall('HapticFeedback.vibrate',
            arguments: platformMethodArgument),
      );
    }

    await callAndVerifyHapticFunction(
        HapticFeedback.lightImpact, 'HapticFeedbackType.lightImpact');
    await callAndVerifyHapticFunction(
        HapticFeedback.mediumImpact, 'HapticFeedbackType.mediumImpact');
    await callAndVerifyHapticFunction(
        HapticFeedback.heavyImpact, 'HapticFeedbackType.heavyImpact');
    await callAndVerifyHapticFunction(
        HapticFeedback.selectionClick, 'HapticFeedbackType.selectionClick');
  });
}
