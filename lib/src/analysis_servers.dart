// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A wrapper around an analysis server instance.
library services.analysis_servers;

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:pedantic/pedantic.dart';

import 'analysis_server.dart';
import 'common_server_impl.dart' show BadRequest;
import 'project.dart' as project;
import 'protos/dart_services.pb.dart' as proto;
import 'pub.dart';

final Logger _logger = Logger('analysis_servers');

class AnalysisServersWrapper {
  final String _dartSdkPath;

  AnalysisServersWrapper(this._dartSdkPath);

  late DartAnalysisServerWrapper _dartAnalysisServer;
  late FlutterAnalysisServerWrapper _flutterAnalysisServer;

  // If non-null, this value indicates that the server is starting/restarting
  // and holds the time at which that process began. If null, the server is
  // ready to handle requests.
  DateTime? _restartingSince = DateTime.now();

  bool get isRestarting => (_restartingSince != null);

  // If the server has been trying and failing to restart for more than a half
  // hour, something is seriously wrong.
  bool get isHealthy => (_restartingSince == null ||
      DateTime.now().difference(_restartingSince!).inMinutes < 30);

  Future<void> warmup() async {
    _logger.info('Beginning AnalysisServersWrapper init().');
    _dartAnalysisServer = DartAnalysisServerWrapper(dartSdkPath: _dartSdkPath);
    _flutterAnalysisServer =
        FlutterAnalysisServerWrapper(dartSdkPath: _dartSdkPath);

    await _dartAnalysisServer.init();
    _logger.info('Dart analysis server initialized.');

    await _flutterAnalysisServer.init();
    _logger.info('Flutter analysis server initialized.');

    unawaited(_dartAnalysisServer.onExit.then((int code) {
      _logger.severe('dartAnalysisServer exited, code: $code');
      if (code != 0) {
        exit(code);
      }
    }));

    unawaited(_flutterAnalysisServer.onExit.then((int code) {
      _logger.severe('flutterAnalysisServer exited, code: $code');
      if (code != 0) {
        exit(code);
      }
    }));

    _restartingSince = null;
  }

  Future<void> _restart() async {
    _logger.warning('Restarting');
    await shutdown();
    _logger.info('shutdown');

    await warmup();
    _logger.warning('Restart complete');
  }

  Future<dynamic> shutdown() {
    _restartingSince = DateTime.now();

    return Future.wait(<Future<dynamic>>[
      _flutterAnalysisServer.shutdown(),
      _dartAnalysisServer.shutdown(),
    ]);
  }

  AnalysisServerWrapper _getCorrectAnalysisServer(String source,
      {required String channel}) {
    final imports = getAllImportsFor(source);
    return project.usesFlutterWeb(imports, channel: channel)
        ? _flutterAnalysisServer
        : _dartAnalysisServer;
  }

  Future<proto.AnalysisResults> analyze(String source,
          {required String channel}) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source, channel: channel)
              .analyze(source),
          'analysis',
          'Error during analyze on "$source"',
          channel: channel);

  Future<proto.CompleteResponse> complete(String source, int offset,
          {required String channel}) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source, channel: channel)
              .complete(source, offset),
          'completions',
          'Error during complete on "$source" at $offset',
          channel: channel);

  Future<proto.FixesResponse> getFixes(String source, int offset,
          {required String channel}) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source, channel: channel)
              .getFixes(source, offset),
          'fixes',
          'Error during fixes on "$source" at $offset',
          channel: channel);

  Future<proto.AssistsResponse> getAssists(String source, int offset,
          {required String channel}) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source, channel: channel)
              .getAssists(source, offset),
          'assists',
          'Error during assists on "$source" at $offset',
          channel: channel);

  Future<proto.FormatResponse> format(String source, int offset,
          {required String channel}) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source, channel: channel)
              .format(source, offset),
          'format',
          'Error during format on "$source" at $offset',
          channel: channel);

  Future<Map<String, String>> dartdoc(String source, int offset,
          {required String channel}) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source, channel: channel)
              .dartdoc(source, offset),
          'dartdoc',
          'Error during dartdoc on "$source" at $offset',
          channel: channel);

  Future<T> _perfLogAndRestart<T>(String source, Future<T> Function() body,
      String action, String errorDescription,
      {required String channel}) async {
    await _checkPackageReferences(source, channel: channel);
    try {
      final watch = Stopwatch()..start();
      final response = await body();
      _logger.info('PERF: Computed $action in ${watch.elapsedMilliseconds}ms.');
      return response;
    } catch (e, st) {
      _logger.severe(errorDescription, e, st);
      await _restart();
      rethrow;
    }
  }

  /// Check that the set of packages referenced is valid.
  Future<void> _checkPackageReferences(String source,
      {required String channel}) async {
    final unsupportedImports = project
        .getUnsupportedImports(getAllImportsFor(source), channel: channel);

    if (unsupportedImports.isNotEmpty) {
      // TODO(srawlins): Do the work so that each unsupported input is its own
      // error, with a proper SourceSpan.
      final unsupportedUris =
          unsupportedImports.map((import) => import.uri.stringValue);
      throw BadRequest('Unsupported import(s): $unsupportedUris');
    }
  }
}
