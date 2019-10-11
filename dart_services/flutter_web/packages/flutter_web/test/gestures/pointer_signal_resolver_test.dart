// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/gestures.dart';

import '../flutter_test_alternative.dart';

class TestPointerSignalListener {
  TestPointerSignalListener(this.event);

  final PointerSignalEvent event;
  bool callbackRan = false;

  void callback(PointerSignalEvent event) {
    expect(event, equals(this.event));
    expect(callbackRan, isFalse);
    callbackRan = true;
  }
}

class PointerSignalTester {
  final PointerSignalResolver resolver = PointerSignalResolver();
  PointerSignalEvent event = const PointerScrollEvent();

  TestPointerSignalListener addListener() {
    final TestPointerSignalListener listener = TestPointerSignalListener(event);
    resolver.register(event, listener.callback);
    return listener;
  }

  /// Simulates a new event dispatch cycle by resolving the current event and
  /// setting a new event to use for future calls.
  void resolve() {
    resolver.resolve(event);
    event = const PointerScrollEvent();
  }
}

void main() {
  test('Resolving with no entries should be a no-op', () {
    final PointerSignalTester tester = PointerSignalTester();
    tester.resolver.resolve(tester.event);
  });

  test('First entry should always win', () {
    final PointerSignalTester tester = PointerSignalTester();
    final TestPointerSignalListener first = tester.addListener();
    final TestPointerSignalListener second = tester.addListener();
    tester.resolve();
    expect(first.callbackRan, isTrue);
    expect(second.callbackRan, isFalse);
  });

  test('Re-use after resolve should work', () {
    final PointerSignalTester tester = PointerSignalTester();
    final TestPointerSignalListener first = tester.addListener();
    final TestPointerSignalListener second = tester.addListener();
    tester.resolve();
    expect(first.callbackRan, isTrue);
    expect(second.callbackRan, isFalse);

    final TestPointerSignalListener newEventListener = tester.addListener();
    tester.resolve();
    expect(newEventListener.callbackRan, isTrue);
    // Nothing should have changed for the previous event's listeners.
    expect(first.callbackRan, isTrue);
    expect(second.callbackRan, isFalse);
  });
}
