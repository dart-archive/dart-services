// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.flutter_analyzer_server_test;

import 'package:dart_services/src/common.dart';
import 'package:dart_services/src/analysis_server.dart';
import 'package:dart_services/src/analysis_servers.dart';
import 'package:dart_services/src/common_server_impl.dart';
import 'package:dart_services/src/common_server_api.dart';
import 'package:dart_services/src/protos/dart_services.pbserver.dart';
import 'package:dart_services/src/server_cache.dart';
import 'package:dart_services/src/sdk_manager.dart';
import 'package:test/test.dart';

const nullSafety = false;

void main() => defineTests();

void defineTests() {
  group('Flutter SDK analysis_server', () {
    AnalysisServerWrapper analysisServer;

    setUp(() async {
      await SdkManager.sdk.init();
      analysisServer = FlutterAnalysisServerWrapper(nullSafety);
      await analysisServer.init();
      await analysisServer.warmup();
    });

    tearDown(() async {
      await analysisServer.shutdown();
    });

    test('analyze counter app', () async {
      final results = await analysisServer.analyze(sampleCodeFlutterCounter);
      expect(results.issues, isEmpty);
    });

    test('analyze Draggable Physics sample', () async {
      final results =
          await analysisServer.analyze(sampleCodeFlutterDraggableCard);
      expect(results.issues, isEmpty);
    });
  });

  group('Flutter SDK analysis_server with analysis servers', () {
    AnalysisServersWrapper analysisServersWrapper;

    setUp(() async {
      await SdkManager.sdk.init();

      analysisServersWrapper = AnalysisServersWrapper(nullSafety);
      await analysisServersWrapper.warmup();
    });

    tearDown(() async {
      await analysisServersWrapper.shutdown();
    });

    test('analyze counter app', () async {
      final results =
          await analysisServersWrapper.analyze(sampleCodeFlutterCounter);
      expect(results.issues, isEmpty);
    });

    test('analyze Draggable Physics sample', () async {
      final results =
          await analysisServersWrapper.analyze(sampleCodeFlutterDraggableCard);
      expect(results.issues, isEmpty);
    });
  });

  group('CommonServerImpl flutter analyze', () {
    CommonServerImpl commonServerImpl;

    _MockContainer container;
    _MockCache cache;

    setUp(() async {
      await SdkManager.sdk.init();
      container = _MockContainer();
      cache = _MockCache();
      commonServerImpl = CommonServerImpl(container, cache, nullSafety);
      await commonServerImpl.init();
    });

    tearDown(() async {
      await commonServerImpl.shutdown();
    });

    test('counter app', () async {
      final results = await commonServerImpl
          .analyze(SourceRequest()..source = sampleCodeFlutterCounter);
      expect(results.issues, isEmpty);
    });

    test('Draggable Physics sample', () async {
      final results = await commonServerImpl
          .analyze(SourceRequest()..source = sampleCodeFlutterDraggableCard);
      expect(results.issues, isEmpty);
    });
  });
}

class _MockContainer implements ServerContainer {
  @override
  String get version => vmVersion;
}

class _MockCache implements ServerCache {
  @override
  Future<String> get(String key) => Future.value(null);

  @override
  Future<void> set(String key, String value, {Duration expiration}) =>
      Future.value();

  @override
  Future<void> remove(String key) => Future.value();

  @override
  Future<void> shutdown() => Future.value();
}
