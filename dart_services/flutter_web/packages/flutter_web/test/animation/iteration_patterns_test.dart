// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/animation.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web_ui/ui.dart' as ui;

void main() {
  setUp(() {
    ui.webOnlyScheduleFrameCallback ??= () {};
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.resetEpoch();
  });

  test('AnimationController with mutating listener', () {
    final AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    final List<String> log = <String>[];

    final VoidCallback listener1 = () {
      log.add('listener1');
    };
    final VoidCallback listener3 = () {
      log.add('listener3');
    };
    final VoidCallback listener4 = () {
      log.add('listener4');
    };
    final VoidCallback listener2 = () {
      log.add('listener2');
      controller.removeListener(listener1);
      controller.removeListener(listener3);
      controller.addListener(listener4);
    };

    controller.addListener(listener1);
    controller.addListener(listener2);
    controller.addListener(listener3);
    controller.value = 0.2;
    expect(log, <String>['listener1', 'listener2']);
    log.clear();

    controller.value = 0.3;
    expect(log, <String>['listener2', 'listener4']);
    log.clear();

    controller.value = 0.4;
    expect(log, <String>['listener2', 'listener4', 'listener4']);
    log.clear();
  });

  test('AnimationController with mutating status listener', () {
    final AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    final List<String> log = <String>[];

    final AnimationStatusListener listener1 = (AnimationStatus status) {
      log.add('listener1');
    };
    final AnimationStatusListener listener3 = (AnimationStatus status) {
      log.add('listener3');
    };
    final AnimationStatusListener listener4 = (AnimationStatus status) {
      log.add('listener4');
    };
    final AnimationStatusListener listener2 = (AnimationStatus status) {
      log.add('listener2');
      controller.removeStatusListener(listener1);
      controller.removeStatusListener(listener3);
      controller.addStatusListener(listener4);
    };

    controller.addStatusListener(listener1);
    controller.addStatusListener(listener2);
    controller.addStatusListener(listener3);
    controller.forward();
    expect(log, <String>['listener1', 'listener2']);
    log.clear();

    controller.reverse();
    expect(log, <String>['listener2', 'listener4']);
    log.clear();

    controller.forward();
    expect(log, <String>['listener2', 'listener4', 'listener4']);
    log.clear();

    controller.dispose();
  });

  testWidgets('AnimationController with throwing listener',
      (WidgetTester tester) async {
    final AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    final List<String> log = <String>[];

    final VoidCallback listener1 = () {
      log.add('listener1');
    };
    final VoidCallback badListener = () {
      log.add('badListener');
      // TODO(flutter_web): revert to throw null; after DDC issue is resolved.
      throw NullThrownError();
    };
    final VoidCallback listener2 = () {
      log.add('listener2');
    };

    controller.addListener(listener1);
    controller.addListener(badListener);
    controller.addListener(listener2);
    controller.value = 0.2;
    expect(log, <String>['listener1', 'badListener', 'listener2']);
    expect(tester.takeException(), isNullThrownError);
    log.clear();
  });

  testWidgets('AnimationController with throwing status listener',
      (WidgetTester tester) async {
    final AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: const TestVSync(),
    );
    final List<String> log = <String>[];

    final AnimationStatusListener listener1 = (AnimationStatus status) {
      log.add('listener1');
    };
    final AnimationStatusListener badListener = (AnimationStatus status) {
      log.add('badListener');
      // TODO(flutter_web): revert to throw null; after DDC issue is resolved.
      throw NullThrownError();
    };
    final AnimationStatusListener listener2 = (AnimationStatus status) {
      log.add('listener2');
    };

    controller.addStatusListener(listener1);
    controller.addStatusListener(badListener);
    controller.addStatusListener(listener2);
    controller.forward();
    expect(log, <String>['listener1', 'badListener', 'listener2']);
    expect(tester.takeException(), isNullThrownError);
    log.clear();
    controller.dispose();
  });
}
