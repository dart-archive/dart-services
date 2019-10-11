// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced. * Contains Web DELTA *

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_web_ui/ui.dart' as ui;

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/gestures.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/scheduler.dart';
import 'package:flutter_web/services.dart';
import 'package:flutter_web/widgets.dart';
import '../flutter_test_alternative.dart';

class TestServiceExtensionsBinding extends BindingBase
    with ServicesBinding,
        GestureBinding,
        SchedulerBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding,
        WidgetsBinding {

  final Map<String, ServiceExtensionCallback> extensions = <String, ServiceExtensionCallback>{};

  final Map<String, List<Map<String, dynamic>>> eventsDispatched = <String, List<Map<String, dynamic>>>{};

  @override
  void registerServiceExtension({
    @required String name,
    @required ServiceExtensionCallback callback,
  }) {
    expect(extensions.containsKey(name), isFalse);
    extensions[name] = callback;
  }

  @override
  void postEvent(String eventKind, Map<dynamic, dynamic> eventData) {
    getEventsDispatched(eventKind).add(eventData);
  }

  List<Map<String, dynamic>> getEventsDispatched(String eventKind) {
    return eventsDispatched.putIfAbsent(eventKind, () => <Map<String, dynamic>>[]);
  }

  Iterable<Map<String, dynamic>> getServiceExtensionStateChangedEvents(String extensionName) {
    return getEventsDispatched('Flutter.ServiceExtensionStateChanged')
        .where((Map<String, dynamic> event) => event['extension'] == extensionName);
  }

  Future<Map<String, dynamic>> testExtension(String name, Map<String, String> arguments) {
    expect(extensions.containsKey(name), isTrue);
    return extensions[name](arguments);
  }

  int reassembled = 0;
  bool pendingReassemble = false;
  @override
  Future<void> performReassemble() {
    reassembled += 1;
    pendingReassemble = true;
    return super.performReassemble();
  }

  bool frameScheduled = false;
  @override
  void scheduleFrame() {
    frameScheduled = true;
  }
  Future<void> doFrame() async {
    frameScheduled = false;
    if (ui.window.onBeginFrame != null)
      ui.window.onBeginFrame(Duration.zero);
    await flushMicrotasks();
    if (ui.window.onDrawFrame != null)
      ui.window.onDrawFrame();
  }

  @override
  void scheduleForcedFrame() {
    expect(true, isFalse);
  }

  @override
  void scheduleWarmUpFrame() {
    expect(pendingReassemble, isTrue);
    pendingReassemble = false;
  }

  Future<void> flushMicrotasks() {
    final Completer<void> completer = Completer<void>();
    Timer.run(completer.complete);
    return completer.future;
  }
}

TestServiceExtensionsBinding binding;

Future<Map<String, dynamic>> hasReassemble(Future<Map<String, dynamic>> pendingResult) async {
  bool completed = false;
  pendingResult.whenComplete(() { completed = true; });
  expect(binding.frameScheduled, isFalse);
  await binding.flushMicrotasks();
  expect(binding.frameScheduled, isTrue);
  expect(completed, isFalse);
  await binding.flushMicrotasks();
  await binding.doFrame();
  await binding.flushMicrotasks();
  expect(completed, isTrue);
  expect(binding.frameScheduled, isFalse);
  return pendingResult;
}

void main() {
  final List<String> console = <String>[];

  test('Service extensions - pretest', () async {
    // TODO(flutter_web): upstream initialization.
    if (ui.isWeb) {
      await ui.webOnlyInitializeTestDomRenderer();
    }
    binding = TestServiceExtensionsBinding();
    expect(binding.frameScheduled, isTrue);

    // We need to test this service extension here because the result is true
    // after the first binding.doFrame() call.
    Map<String, dynamic> firstFrameResult;
    expect(binding.debugDidSendFirstFrameEvent, isFalse);
    firstFrameResult = await binding.testExtension('didSendFirstFrameEvent', <String, String>{});
    expect(firstFrameResult, <String, String>{ 'enabled': 'false' });

    await binding.doFrame(); // initial frame scheduled by creating the binding

    expect(binding.debugDidSendFirstFrameEvent, isTrue);
    firstFrameResult = await binding.testExtension('didSendFirstFrameEvent', <String, String>{});
    expect(firstFrameResult, <String, String>{ 'enabled': 'true' });

    expect(binding.frameScheduled, isFalse);

    expect(debugPrint, equals(debugPrintThrottled));
    debugPrint = (String message, { int wrapWidth }) {
      console.add(message);
    };
  });

  // The following list is alphabetical, one test per extension.
  //
  // The order doesn't really matter except that the pretest and posttest tests
  // must be first and last respectively.

  test('Service extensions - debugAllowBanner', () async {
    Map<String, dynamic> result;

    expect(binding.frameScheduled, isFalse);
    expect(WidgetsApp.debugAllowBannerOverride, true);
    result = await binding.testExtension('debugAllowBanner', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(WidgetsApp.debugAllowBannerOverride, true);
    result = await binding.testExtension('debugAllowBanner', <String, String>{ 'enabled': 'false' });
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(WidgetsApp.debugAllowBannerOverride, false);
    result = await binding.testExtension('debugAllowBanner', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(WidgetsApp.debugAllowBannerOverride, false);
    result = await binding.testExtension('debugAllowBanner', <String, String>{ 'enabled': 'true' });
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(WidgetsApp.debugAllowBannerOverride, true);
    result = await binding.testExtension('debugAllowBanner', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(WidgetsApp.debugAllowBannerOverride, true);
    expect(binding.frameScheduled, isFalse);
  });

  test('Service extensions - debugDumpApp', () async {
    Map<String, dynamic> result;

    result = await binding.testExtension('debugDumpApp', <String, String>{});
    expect(result, <String, String>{});
    expect(console, <String>['TestServiceExtensionsBinding - CHECKED MODE', '<no tree currently mounted>']);
    console.clear();
  });

  test('Service extensions - debugDumpRenderTree', () async {
    Map<String, dynamic> result;

    await binding.doFrame();
    result = await binding.testExtension('debugDumpRenderTree', <String, String>{});
    expect(result, <String, String>{});
    expect(console, <Matcher>[
      matches(
          r'^'
          r'RenderView#[0-9a-f]{5}\n'
          r'   debug mode enabled - [a-zA-Z]+\n'
          r'   window size: Size\(2400\.0, 1800\.0\) \(in physical pixels\)\n'
          r'   device pixel ratio: 3\.0 \(physical pixels per logical pixel\)\n'
          r'   configuration: Size\(800\.0, 600\.0\) at 3\.0x \(in logical pixels\)\n'
          r'$'
      ),
    ]);
    console.clear();
  });

  test('Service extensions - debugDumpLayerTree', () async {
    Map<String, dynamic> result;

    await binding.doFrame();
    result = await binding.testExtension('debugDumpLayerTree', <String, String>{});
    expect(result, <String, String>{});
    expect(console, <Matcher>[
      matches(
          r'^'
          r'TransformLayer#[0-9a-f]{5}\n'
          r'   owner: RenderView#[0-9a-f]{5}\n'
          r'   creator: RenderView\n'
          r'   offset: Offset\(0\.0, 0\.0\)\n'
          r'   transform:\n'
          r'     \[0] 3\.0,0\.0,0\.0,0\.0\n'
          r'     \[1] 0\.0,3\.0,0\.0,0\.0\n'
          r'     \[2] 0\.0,0\.0,1\.0,0\.0\n'
          r'     \[3] 0\.0,0\.0,0\.0,1\.0\n'
          r'$'
      ),
    ]);
    console.clear();
  });

  test('Service extensions - debugDumpSemanticsTreeInTraversalOrder', () async {
    Map<String, dynamic> result;

    await binding.doFrame();
    result = await binding.testExtension('debugDumpSemanticsTreeInTraversalOrder', <String, String>{});
    expect(result, <String, String>{});
    expect(console, <String>['Semantics not collected.']);
    console.clear();
  });

  test('Service extensions - debugDumpSemanticsTreeInInverseHitTestOrder', () async {
    Map<String, dynamic> result;

    await binding.doFrame();
    result = await binding.testExtension('debugDumpSemanticsTreeInInverseHitTestOrder', <String, String>{});
    expect(result, <String, String>{});
    expect(console, <String>['Semantics not collected.']);
    console.clear();
  });

  test('Service extensions - debugPaint', () async {
    final Iterable<Map<String, dynamic>> extensionChangedEvents = binding.getServiceExtensionStateChangedEvents('ext.flutter.debugPaint');
    Map<String, dynamic> extensionChangedEvent;
    Map<String, dynamic> result;
    Future<Map<String, dynamic>> pendingResult;
    bool completed;

    expect(binding.frameScheduled, isFalse);
    expect(debugPaintSizeEnabled, false);
    result = await binding.testExtension('debugPaint', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugPaintSizeEnabled, false);
    expect(extensionChangedEvents, isEmpty);
    expect(binding.frameScheduled, isFalse);
    pendingResult = binding.testExtension('debugPaint', <String, String>{ 'enabled': 'true' });
    completed = false;
    pendingResult.whenComplete(() { completed = true; });
    await binding.flushMicrotasks();
    expect(binding.frameScheduled, isTrue);
    expect(completed, isFalse);
    await binding.doFrame();
    await binding.flushMicrotasks();
    expect(completed, isTrue);
    expect(binding.frameScheduled, isFalse);
    result = await pendingResult;
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(debugPaintSizeEnabled, true);
    expect(extensionChangedEvents.length, 1);
    extensionChangedEvent = extensionChangedEvents.last;
    expect(extensionChangedEvent['extension'], 'ext.flutter.debugPaint');
    expect(extensionChangedEvent['value'], 'true');
    result = await binding.testExtension('debugPaint', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(debugPaintSizeEnabled, true);
    expect(extensionChangedEvents.length, 1);
    expect(binding.frameScheduled, isFalse);
    pendingResult = binding.testExtension('debugPaint', <String, String>{ 'enabled': 'false' });
    await binding.flushMicrotasks();
    expect(binding.frameScheduled, isTrue);
    await binding.doFrame();
    expect(binding.frameScheduled, isFalse);
    result = await pendingResult;
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugPaintSizeEnabled, false);
    expect(extensionChangedEvents.length, 2);
    extensionChangedEvent = extensionChangedEvents.last;
    expect(extensionChangedEvent['extension'], 'ext.flutter.debugPaint');
    expect(extensionChangedEvent['value'], 'false');
    result = await binding.testExtension('debugPaint', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugPaintSizeEnabled, false);
    expect(extensionChangedEvents.length, 2);
    expect(binding.frameScheduled, isFalse);
  });

  test('Service extensions - debugPaintBaselinesEnabled', () async {
    Map<String, dynamic> result;
    Future<Map<String, dynamic>> pendingResult;
    bool completed;

    expect(binding.frameScheduled, isFalse);
    expect(debugPaintBaselinesEnabled, false);
    result = await binding.testExtension('debugPaintBaselinesEnabled', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugPaintBaselinesEnabled, false);
    expect(binding.frameScheduled, isFalse);
    pendingResult = binding.testExtension('debugPaintBaselinesEnabled', <String, String>{ 'enabled': 'true' });
    completed = false;
    pendingResult.whenComplete(() { completed = true; });
    await binding.flushMicrotasks();
    expect(binding.frameScheduled, isTrue);
    expect(completed, isFalse);
    await binding.doFrame();
    await binding.flushMicrotasks();
    expect(completed, isTrue);
    expect(binding.frameScheduled, isFalse);
    result = await pendingResult;
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(debugPaintBaselinesEnabled, true);
    result = await binding.testExtension('debugPaintBaselinesEnabled', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(debugPaintBaselinesEnabled, true);
    expect(binding.frameScheduled, isFalse);
    pendingResult = binding.testExtension('debugPaintBaselinesEnabled', <String, String>{ 'enabled': 'false' });
    await binding.flushMicrotasks();
    expect(binding.frameScheduled, isTrue);
    await binding.doFrame();
    expect(binding.frameScheduled, isFalse);
    result = await pendingResult;
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugPaintBaselinesEnabled, false);
    result = await binding.testExtension('debugPaintBaselinesEnabled', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugPaintBaselinesEnabled, false);
    expect(binding.frameScheduled, isFalse);
  });

  test('Service extensions - profileWidgetBuilds', () async {
    Map<String, dynamic> result;

    expect(binding.frameScheduled, isFalse);
    expect(debugProfileBuildsEnabled, false);

    result = await binding.testExtension('profileWidgetBuilds', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugProfileBuildsEnabled, false);

    result = await binding.testExtension('profileWidgetBuilds', <String, String>{ 'enabled': 'true' });
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(debugProfileBuildsEnabled, true);

    result = await binding.testExtension('profileWidgetBuilds', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(debugProfileBuildsEnabled, true);

    result = await binding.testExtension('profileWidgetBuilds', <String, String>{ 'enabled': 'false' });
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugProfileBuildsEnabled, false);

    result = await binding.testExtension('profileWidgetBuilds', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugProfileBuildsEnabled, false);

    expect(binding.frameScheduled, isFalse);
  });

  test('Service extensions - evict', () async {
    Map<String, dynamic> result;
    bool completed;

    completed = false;
    BinaryMessages.setMockMessageHandler('flutter/assets', (ByteData message) async {
      expect(utf8.decode(message.buffer.asUint8List()), 'test');
      completed = true;
      return ByteData(5); // 0x0000000000
    });
    bool data;
    data = await rootBundle.loadStructuredData<bool>('test', (String value) async { expect(value, '\x00\x00\x00\x00\x00'); return true; });
    expect(data, isTrue);
    expect(completed, isTrue);
    completed = false;
    data = await rootBundle.loadStructuredData('test', (String value) async { expect(true, isFalse); return null; });
    expect(data, isTrue);
    expect(completed, isFalse);
    result = await binding.testExtension('evict', <String, String>{ 'value': 'test' });
    expect(result, <String, String>{ 'value': '' });
    expect(completed, isFalse);
    data = await rootBundle.loadStructuredData<bool>('test', (String value) async { expect(value, '\x00\x00\x00\x00\x00'); return false; });
    expect(data, isFalse);
    expect(completed, isTrue);
    BinaryMessages.setMockMessageHandler('flutter/assets', null);
  });

  test('Service extensions - exit', () async {
    // no test for _calling_ 'exit', because that should terminate the process!
    expect(binding.extensions.containsKey('exit'), isTrue);
  }, skip: ui.isWeb);

  test('Service extensions - platformOverride', () async {
    final Iterable<Map<String, dynamic>> extensionChangedEvents = binding.getServiceExtensionStateChangedEvents('ext.flutter.platformOverride');
    Map<String, dynamic> extensionChangedEvent;
    Map<String, dynamic> result;

    expect(binding.reassembled, 0);
    expect(defaultTargetPlatform, TargetPlatform.android);
    result = await binding.testExtension('platformOverride', <String, String>{});
    expect(result, <String, String>{'value': 'android'});
    expect(defaultTargetPlatform, TargetPlatform.android);
    expect(extensionChangedEvents, isEmpty);
    result = await hasReassemble(binding.testExtension('platformOverride', <String, String>{'value': 'iOS'}));
    expect(result, <String, String>{'value': 'iOS'});
    expect(binding.reassembled, 1);
    expect(defaultTargetPlatform, TargetPlatform.iOS);
    expect(extensionChangedEvents.length, 1);
    extensionChangedEvent = extensionChangedEvents.last;
    expect(extensionChangedEvent['extension'], 'ext.flutter.platformOverride');
    expect(extensionChangedEvent['value'], 'iOS');
    result = await hasReassemble(binding.testExtension('platformOverride', <String, String>{'value': 'android'}));
    expect(result, <String, String>{'value': 'android'});
    expect(binding.reassembled, 2);
    expect(defaultTargetPlatform, TargetPlatform.android);
    expect(extensionChangedEvents.length, 2);
    extensionChangedEvent = extensionChangedEvents.last;
    expect(extensionChangedEvent['extension'], 'ext.flutter.platformOverride');
    expect(extensionChangedEvent['value'], 'android');
    result = await hasReassemble(binding.testExtension('platformOverride', <String, String>{'value': 'fuchsia'}));
    expect(result, <String, String>{'value': 'fuchsia'});
    expect(binding.reassembled, 3);
    expect(defaultTargetPlatform, TargetPlatform.fuchsia);
    expect(extensionChangedEvents.length, 3);
    extensionChangedEvent = extensionChangedEvents.last;
    expect(extensionChangedEvent['extension'], 'ext.flutter.platformOverride');
    expect(extensionChangedEvent['value'], 'fuchsia');
    result = await hasReassemble(binding.testExtension('platformOverride', <String, String>{'value': 'default'}));
    expect(result, <String, String>{'value': 'android'});
    expect(binding.reassembled, 4);
    expect(defaultTargetPlatform, TargetPlatform.android);
    expect(extensionChangedEvents.length, 4);
    extensionChangedEvent = extensionChangedEvents.last;
    expect(extensionChangedEvent['extension'], 'ext.flutter.platformOverride');
    expect(extensionChangedEvent['value'], 'android');
    result = await hasReassemble(binding.testExtension('platformOverride', <String, String>{'value': 'iOS'}));
    expect(result, <String, String>{'value': 'iOS'});
    expect(binding.reassembled, 5);
    expect(defaultTargetPlatform, TargetPlatform.iOS);
    expect(extensionChangedEvents.length, 5);
    extensionChangedEvent = extensionChangedEvents.last;
    expect(extensionChangedEvent['extension'], 'ext.flutter.platformOverride');
    expect(extensionChangedEvent['value'], 'iOS');
    result = await hasReassemble(binding.testExtension('platformOverride', <String, String>{'value': 'bogus'}));
    expect(result, <String, String>{'value': 'android'});
    expect(binding.reassembled, 6);
    expect(defaultTargetPlatform, TargetPlatform.android);
    expect(extensionChangedEvents.length, 6);
    extensionChangedEvent = extensionChangedEvents.last;
    expect(extensionChangedEvent['extension'], 'ext.flutter.platformOverride');
    expect(extensionChangedEvent['value'], 'android');
    binding.reassembled = 0;
  }, skip: ui.isWeb);

  test('Service extensions - repaintRainbow', () async {
    Map<String, dynamic> result;
    Future<Map<String, dynamic>> pendingResult;
    bool completed;

    expect(binding.frameScheduled, isFalse);
    expect(debugRepaintRainbowEnabled, false);
    result = await binding.testExtension('repaintRainbow', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugRepaintRainbowEnabled, false);
    expect(binding.frameScheduled, isFalse);
    pendingResult = binding.testExtension('repaintRainbow', <String, String>{ 'enabled': 'true' });
    completed = false;
    pendingResult.whenComplete(() { completed = true; });
    await binding.flushMicrotasks();
    expect(completed, true);
    expect(binding.frameScheduled, isFalse);
    result = await pendingResult;
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(debugRepaintRainbowEnabled, true);
    result = await binding.testExtension('repaintRainbow', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(debugRepaintRainbowEnabled, true);
    expect(binding.frameScheduled, isFalse);
    pendingResult = binding.testExtension('repaintRainbow', <String, String>{ 'enabled': 'false' });
    completed = false;
    pendingResult.whenComplete(() { completed = true; });
    await binding.flushMicrotasks();
    expect(completed, false);
    expect(binding.frameScheduled, isTrue);
    await binding.doFrame();
    await binding.flushMicrotasks();
    expect(completed, true);
    expect(binding.frameScheduled, isFalse);
    result = await pendingResult;
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugRepaintRainbowEnabled, false);
    result = await binding.testExtension('repaintRainbow', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(debugRepaintRainbowEnabled, false);
    expect(binding.frameScheduled, isFalse);
  }, skip: ui.isWeb);

  test('Service extensions - reassemble', () async {
    Map<String, dynamic> result;
    Future<Map<String, dynamic>> pendingResult;
    bool completed;

    completed = false;
    expect(binding.reassembled, 0);
    pendingResult = binding.testExtension('reassemble', <String, String>{});
    pendingResult.whenComplete(() { completed = true; });
    await binding.flushMicrotasks();
    expect(binding.frameScheduled, isTrue);
    expect(completed, false);
    await binding.flushMicrotasks();
    await binding.doFrame();
    await binding.flushMicrotasks();
    expect(completed, true);
    expect(binding.frameScheduled, isFalse);
    result = await pendingResult;
    expect(result, <String, String>{});
    expect(binding.reassembled, 1);
  });

  test('Service extensions - showPerformanceOverlay', () async {
    Map<String, dynamic> result;

    expect(binding.frameScheduled, isFalse);
    expect(WidgetsApp.showPerformanceOverlayOverride, false);
    result = await binding.testExtension('showPerformanceOverlay', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(WidgetsApp.showPerformanceOverlayOverride, false);
    result = await binding.testExtension('showPerformanceOverlay', <String, String>{ 'enabled': 'true' });
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(WidgetsApp.showPerformanceOverlayOverride, true);
    result = await binding.testExtension('showPerformanceOverlay', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(WidgetsApp.showPerformanceOverlayOverride, true);
    result = await binding.testExtension('showPerformanceOverlay', <String, String>{ 'enabled': 'false' });
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(WidgetsApp.showPerformanceOverlayOverride, false);
    result = await binding.testExtension('showPerformanceOverlay', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(WidgetsApp.showPerformanceOverlayOverride, false);
    expect(binding.frameScheduled, isFalse);
  }, skip: ui.isWeb);

  test('Service extensions - debugWidgetInspector', () async {
    Map<String, dynamic> result;
    expect(binding.frameScheduled, isFalse);
    expect(WidgetsApp.debugShowWidgetInspectorOverride, false);
    result = await binding.testExtension('debugWidgetInspector', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(WidgetsApp.debugShowWidgetInspectorOverride, false);
    result = await binding.testExtension('debugWidgetInspector', <String, String>{ 'enabled': 'true' });
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(WidgetsApp.debugShowWidgetInspectorOverride, true);
    result = await binding.testExtension('debugWidgetInspector', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'true' });
    expect(WidgetsApp.debugShowWidgetInspectorOverride, true);
    result = await binding.testExtension('debugWidgetInspector', <String, String>{ 'enabled': 'false' });
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(WidgetsApp.debugShowWidgetInspectorOverride, false);
    result = await binding.testExtension('debugWidgetInspector', <String, String>{});
    expect(result, <String, String>{ 'enabled': 'false' });
    expect(WidgetsApp.debugShowWidgetInspectorOverride, false);
    expect(binding.frameScheduled, isFalse);
  });

  test('Service extensions - timeDilation', () async {
    final Iterable<Map<String, dynamic>> extensionChangedEvents = binding.getServiceExtensionStateChangedEvents('ext.flutter.timeDilation');
    Map<String, dynamic> extensionChangedEvent;
    Map<String, dynamic> result;

    expect(binding.frameScheduled, isFalse);
    expect(timeDilation, 1.0);
    result = await binding.testExtension('timeDilation', <String, String>{});
    // TODO(flutter_web): upstream isWeb check.
    expect(result, <String, String>{ 'timeDilation': ui.isWeb ? '1' : '1.0' });
    expect(timeDilation, 1.0);
    expect(extensionChangedEvents, isEmpty);
    result = await binding.testExtension('timeDilation', <String, String>{ 'timeDilation': '100.0' });
    expect(result, <String, String>{ 'timeDilation': ui.isWeb ? '100' : '100.0' });
    expect(timeDilation, 100.0);
    expect(extensionChangedEvents.length, 1);
    extensionChangedEvent = extensionChangedEvents.last;
    expect(extensionChangedEvent['extension'], 'ext.flutter.timeDilation');
    expect(extensionChangedEvent['value'], ui.isWeb ? '100' : '100.0');
    result = await binding.testExtension('timeDilation', <String, String>{});
    expect(result, <String, String>{ 'timeDilation': ui.isWeb ? '100' : '100.0' });
    expect(timeDilation, 100.0);
    expect(extensionChangedEvents.length, 1);
    result = await binding.testExtension('timeDilation', <String, String>{ 'timeDilation': '1.0' });
    expect(result, <String, String>{ 'timeDilation': ui.isWeb ? '1' : '1.0' });
    expect(timeDilation, 1.0);
    expect(extensionChangedEvents.length, 2);
    extensionChangedEvent = extensionChangedEvents.last;
    expect(extensionChangedEvent['extension'], 'ext.flutter.timeDilation');
    expect(extensionChangedEvent['value'], ui.isWeb ? '1' : '1.0');
    result = await binding.testExtension('timeDilation', <String, String>{});
    expect(result, <String, String>{ 'timeDilation': ui.isWeb ? '1' : '1.0' });
    expect(timeDilation, 1.0);
    expect(extensionChangedEvents.length, 2);
    expect(binding.frameScheduled, isFalse);
  });

  test('Service extensions - saveCompilationTrace', () async {
    Map<String, dynamic> result;
    result = await binding.testExtension('saveCompilationTrace', <String, String>{});
    final String trace = String.fromCharCodes(result['value']);
    expect(trace, contains('dart:core,Object,Object.\n'));
    expect(trace, contains('package:test_api/test_api.dart,::,test\n'));
    expect(trace, contains('service_extensions_test.dart,::,main\n'));
  }, skip: ui.isWeb);

  test('Service extensions - posttest', () async {
    // See widget_inspector_test.dart for tests of the ext.flutter.inspector
    // service extensions included in this count.
    int widgetInspectorExtensionCount = 15;
    if (WidgetInspectorService.instance.isWidgetCreationTracked()) {
      // Some inspector extensions are only exposed if widget creation locations
      // are tracked.
      widgetInspectorExtensionCount += 2;
    }

    // If you add a service extension... TEST IT! :-)
    // ...then increment this number.
    // TODO(flutter_web): upstream , 3 extensions are not supported for web.
    expect(binding.extensions.length, 26 + widgetInspectorExtensionCount
      - (ui.isWeb ? 3 : 0));

    expect(console, isEmpty);
    debugPrint = debugPrintThrottled;
  });
}
