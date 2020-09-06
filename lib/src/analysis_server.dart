// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A wrapper around an analysis server instance
library services.analysis_server;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analysis_server_lib/analysis_server_lib.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:pedantic/pedantic.dart';

import 'common.dart';
import 'common_server_impl.dart' show BadRequest;
import 'flutter_web.dart';
import 'protos/dart_services.pb.dart' as proto;
import 'pub.dart';
import 'scheduler.dart';
import 'sdk_manager.dart';

final Logger _logger = Logger('analysis_server');

/// Flag to determine whether we should dump the communication with the server
/// to stdout.
bool dumpServerMessages = false;

const String _WARMUP_SRC_HTML =
    "import 'dart:html'; main() { int b = 2;  b++;   b. }";
const String _WARMUP_SRC = 'main() { int b = 2;  b++;   b. }';

// Use very long timeouts to ensure that the server has enough time to restart.
const Duration _ANALYSIS_SERVER_TIMEOUT = Duration(seconds: 35);

class AnalysisServersWrapper {
  AnalysisServersWrapper();

  FlutterWebManager _flutterWebManager;
  DartAnalysisServerWrapper _dartAnalysisServer;
  FlutterAnalysisServerWrapper _flutterAnalysisServer;

  bool get running =>
      _dartAnalysisServer.analysisServer != null &&
      _flutterAnalysisServer.analysisServer != null;

  // If non-null, this value indicates that the server is starting/restarting
  // and holds the time at which that process began. If null, the server is
  // ready to handle requests.
  DateTime _restartingSince = DateTime.now();

  bool get isRestarting => (_restartingSince != null);

  // If the server has been trying and failing to restart for more than a half
  // hour, something is seriously wrong.
  bool get isHealthy => (_restartingSince == null ||
      DateTime.now().difference(_restartingSince).inMinutes < 30);

  Future<void> init() async {
    _logger.info('Beginning AnalysisServersWrapper init().');
    _dartAnalysisServer = DartAnalysisServerWrapper();
    _flutterWebManager = FlutterWebManager(SdkManager.flutterSdk);
    _flutterAnalysisServer = FlutterAnalysisServerWrapper(_flutterWebManager);

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

    await init();
    await warmup();
    _logger.warning('Restart complete');
  }

  Future warmup() => Future.wait(<Future<dynamic>>[
        _flutterWebManager.warmup(),
        _flutterAnalysisServer.warmup(),
        _dartAnalysisServer.warmup(),
      ]);

  Future<dynamic> shutdown() {
    _restartingSince = DateTime.now();

    return Future.wait(<Future<dynamic>>[
      _flutterWebManager.dispose(),
      _flutterAnalysisServer.shutdown(),
      _dartAnalysisServer.shutdown(),
    ]);
  }

  AnalysisServerWrapper _getCorrectAnalysisServer(String source) {
    final imports = getAllImportsFor(source);
    return _flutterWebManager.usesFlutterWeb(imports)
        ? _flutterAnalysisServer
        : _dartAnalysisServer;
  }

  Future<proto.AnalysisResults> analyze(String source) => _perfLogAndRestart(
      source,
      () => _getCorrectAnalysisServer(source).analyze(source),
      'analysis',
      'Error during analyze on "$source"');

  Future<proto.CompleteResponse> complete(String source, int offset) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source).complete(source, offset),
          'completions',
          'Error during complete on "$source" at $offset');

  Future<proto.FixesResponse> getFixes(String source, int offset) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source).getFixes(source, offset),
          'fixes',
          'Error during fixes on "$source" at $offset');

  Future<proto.AssistsResponse> getAssists(String source, int offset) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source).getAssists(source, offset),
          'assists',
          'Error during assists on "$source" at $offset');

  Future<proto.FormatResponse> format(String source, int offset) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source).format(source, offset),
          'format',
          'Error during format on "$source" at $offset');

  Future<Map<String, String>> dartdoc(String source, int offset) =>
      _perfLogAndRestart(
          source,
          () => _getCorrectAnalysisServer(source).dartdoc(source, offset),
          'dartdoc',
          'Error during dartdoc on "$source" at $offset');

  Future<T> _perfLogAndRestart<T>(String source, Future<T> Function() body,
      String action, String errorDescription) async {
    await _checkPackageReferences(source);
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
  Future<void> _checkPackageReferences(String source) async {
    final imports = getAllImportsFor(source);

    if (_flutterWebManager.hasUnsupportedImport(imports)) {
      throw BadRequest(
          'Unsupported input: ${_flutterWebManager.getUnsupportedImport(imports)}');
    }
  }
}

class DartAnalysisServerWrapper extends AnalysisServerWrapper {
  Directory _tempProject;
  DartAnalysisServerWrapper() : super(SdkManager.sdk.sdkPath);

  @override
  Future<AnalysisServer> init() async {
    _logger.info('DartAnalysisServerWrapper init');
    _tempProject = await Directory.systemTemp.createTemp('DartAnalysisWrapper');
    return super.init();
  }

  @override
  String get _sourceDirPath => _tempProject.path;

  @override
  Future<proto.AnalysisResults> analyze(String source) {
    _logger.info('DartAnalysisServerWrapper analyze');
    return super.analyze(source);
  }

  @override
  Future shutdown() {
    _logger.info('DartAnalysisServerWrapper shutdown');
    return _tempProject
        .delete(recursive: true)
        .then((value) => super.shutdown());
  }
}

class FlutterAnalysisServerWrapper extends AnalysisServerWrapper {
  final FlutterWebManager flutterWebManager;

  FlutterAnalysisServerWrapper(this.flutterWebManager)
      : super(SdkManager.flutterSdk.sdkPath);

  @override
  Future<AnalysisServer> init() async {
    _logger.info('FlutterAnalysisServerWrapper init');
    return super.init();
  }

  @override
  String get _sourceDirPath => flutterWebManager.projectDirectory.path;

  @override
  Future<proto.AnalysisResults> analyze(String source) {
    _logger.info('FlutterAnalysisServerWrapper analyze');
    return super.analyze(source);
  }

  @override
  Future shutdown() {
    _logger.info('FlutterAnalysisServerWrapper shutdown');
    return super.shutdown();
  }
}

abstract class AnalysisServerWrapper {
  final String sdkPath;
  final TaskScheduler serverScheduler = TaskScheduler();

  Future<AnalysisServer> _init;

  /// Instance to handle communication with the server.
  AnalysisServer analysisServer;

  AnalysisServerWrapper(this.sdkPath);

  String get mainPath => _getPathFromName(kMainDart);

  String get _sourceDirPath;

  Future<AnalysisServer> init() {
    if (_init == null) {
      void onRead(String str) {
        if (dumpServerMessages) _logger.info('<-- $str');
      }

      void onWrite(String str) {
        if (dumpServerMessages) _logger.info('--> $str');
      }

      final serverArgs = <String>[
        '--dartpad',
        '--client-id=DartPad',
        '--client-version=$_sdkVersion'
      ];
      _logger.info(
          'About to start with server with SDK path `$sdkPath` and args: $serverArgs');

      _init = AnalysisServer.create(
        onRead: onRead,
        onWrite: onWrite,
        sdkPath: sdkPath,
        serverArgs: serverArgs,
      ).then((AnalysisServer server) async {
        analysisServer = server;
        analysisServer.server.onError.listen((ServerError error) {
          _logger.severe('server error${error.isFatal ? ' (fatal)' : ''}',
              error.message, StackTrace.fromString(error.stackTrace));
        });
        await analysisServer.server.onConnected.first;
        await analysisServer.server.setSubscriptions(<String>['STATUS']);

        listenForCompletions();
        listenForAnalysisComplete();
        listenForErrors();

        final analysisComplete = getAnalysisCompleteCompleter();
        await analysisServer.analysis
            .setAnalysisRoots(<String>[_sourceDirPath], <String>[]);
        await _sendAddOverlays(<String, String>{mainPath: _WARMUP_SRC});
        await analysisComplete.future;
        await _sendRemoveOverlays();

        return analysisServer;
      }).catchError((err, st) {
        _logger.severe('Error starting analysis server ($sdkPath): $err.\n$st');
      });
    }

    return _init;
  }

  String get _sdkVersion {
    return File(path.join(sdkPath, 'version')).readAsStringSync().trim();
  }

  Future<int> get onExit {
    // Return when the analysis server exits. We introduce a delay so that when
    // we terminate the analysis server we can exit normally.
    return analysisServer.processCompleter.future.then((int code) {
      return Future<int>.delayed(const Duration(seconds: 1), () {
        return code;
      });
    });
  }

  Future<proto.CompleteResponse> complete(String src, int offset) async {
    final sources = <String, String>{kMainDart: src};
    final location = Location(kMainDart, offset);

    final results =
        await _completeImpl(sources, location.sourceName, location.offset);
    var suggestions = results.results;

    final source = sources[location.sourceName];
    final prefix = source.substring(results.replacementOffset, location.offset);
    suggestions = suggestions
        .where(
            (s) => s.completion.toLowerCase().startsWith(prefix.toLowerCase()))
        .toList();

    suggestions.sort((CompletionSuggestion x, CompletionSuggestion y) {
      if (x.relevance == y.relevance) {
        return x.completion.compareTo(y.completion);
      } else {
        return y.relevance.compareTo(x.relevance);
      }
    });

    return proto.CompleteResponse()
      ..replacementOffset = results.replacementOffset
      ..replacementLength = results.replacementLength
      ..completions
          .addAll(suggestions.map((CompletionSuggestion c) => proto.Completion()
            ..completion.addAll(c.toMap().map((key, value) {
              // TODO: Properly support Lists, Maps (this is a hack).
              if (value is Map || value is List) {
                value = json.encode(value);
              }
              return MapEntry(key.toString(), value.toString());
            }))));
  }

  Future<proto.FixesResponse> getFixes(String src, int offset) {
    return getFixesMulti(
      <String, String>{kMainDart: src},
      Location(kMainDart, offset),
    );
  }

  Future<proto.FixesResponse> getFixesMulti(
      Map<String, String> sources, Location location) async {
    final results =
        await _getFixesImpl(sources, location.sourceName, location.offset);
    final responseFixes = results.fixes.map(_convertAnalysisErrorFix);
    return proto.FixesResponse()..fixes.addAll(responseFixes);
  }

  Future<proto.AssistsResponse> getAssists(String src, int offset) async {
    final sources = {kMainDart: src};
    final sourceName = Location(kMainDart, offset).sourceName;
    final results = await _getAssistsImpl(sources, sourceName, offset);
    final fixes = _convertSourceChangesToCandidateFixes(results.assists);
    return proto.AssistsResponse()..assists.addAll(fixes);
  }

  Future<proto.FormatResponse> format(String src, int offset) {
    return _formatImpl(src, offset).then((FormatResult editResult) {
      final edits = editResult.edits;

      edits.sort((SourceEdit e1, SourceEdit e2) =>
          -1 * e1.offset.compareTo(e2.offset));

      for (final edit in edits) {
        src = src.replaceRange(
            edit.offset, edit.offset + edit.length, edit.replacement);
      }

      return proto.FormatResponse()
        ..newString = src
        ..offset = editResult.selectionOffset;
    }).catchError((dynamic error) {
      _logger.fine('format error: $error');
      return proto.FormatResponse()
        ..newString = src
        ..offset = offset;
    });
  }

  Future<Map<String, String>> dartdoc(String source, int offset) {
    _logger.fine('dartdoc: Scheduler queue: ${serverScheduler.queueCount}');

    return serverScheduler.schedule(ClosureTask<Map<String, String>>(() async {
      final analysisCompleter = getAnalysisCompleteCompleter();
      await _loadSources(<String, String>{mainPath: source});
      await analysisCompleter.future;

      final result = await analysisServer.analysis.getHover(mainPath, offset);
      await _unloadSources();

      if (result.hovers.isEmpty) {
        return null;
      }

      final info = result.hovers.first;
      final m = <String, String>{};

      m['description'] = info.elementDescription;
      m['kind'] = info.elementKind;
      m['dartdoc'] = info.dartdoc;

      m['enclosingClassName'] = info.containingClassDescription;
      m['libraryName'] = info.containingLibraryName;

      m['deprecated'] = info.parameter;
      if (info.isDeprecated != null) m['deprecated'] = '${info.isDeprecated}';

      m['staticType'] = info.staticType;
      m['propagatedType'] = info.propagatedType;

      for (final key in m.keys.toList()) {
        if (m[key] == null) m.remove(key);
      }

      return m;
    }, timeoutDuration: _ANALYSIS_SERVER_TIMEOUT));
  }

  Future<proto.AnalysisResults> analyze(String source) {
    var sources = <String, String>{kMainDart: source};

    _logger.fine('analyze: Scheduler queue: ${serverScheduler.queueCount}');

    return serverScheduler
        .schedule(ClosureTask<proto.AnalysisResults>(() async {
      clearErrors();

      final analysisCompleter = getAnalysisCompleteCompleter();
      sources = _getOverlayMapWithPaths(sources);
      await _loadSources(sources);
      await analysisCompleter.future;

      // Calculate the issues.
      final issues = getErrors().map((AnalysisError error) {
        return proto.AnalysisIssue()
          ..kind = error.severity.toLowerCase()
          ..line = error.location.startLine
          ..message = error.message
          ..sourceName = path.basename(error.location.file)
          ..hasFixes = error.hasFix
          ..charStart = error.location.offset
          ..charLength = error.location.length;
      }).toList();

      issues.sort((a, b) {
        // Order issues by character position of the bug/warning.
        return a.charStart.compareTo(b.charStart);
      });

      // Calculate the imports.
      final packageImports = <String>{};
      for (final source in sources.values) {
        packageImports
            .addAll(filterSafePackagesFromImports(getAllImportsFor(source)));
      }

      return proto.AnalysisResults()
        ..issues.addAll(issues)
        ..packageImports.addAll(packageImports);
    }, timeoutDuration: _ANALYSIS_SERVER_TIMEOUT));
  }

  Future<AssistsResult> _getAssistsImpl(
      Map<String, String> sources, String sourceName, int offset) {
    sources = _getOverlayMapWithPaths(sources);
    final path = _getPathFromName(sourceName);

    if (serverScheduler.queueCount > 0) {
      _logger.fine(
          'getRefactoringsImpl: Scheduler queue: ${serverScheduler.queueCount}');
    }

    return serverScheduler.schedule(ClosureTask<AssistsResult>(() async {
      final analysisCompleter = getAnalysisCompleteCompleter();
      await _loadSources(sources);
      await analysisCompleter.future;
      const length = 1;
      final assists =
          await analysisServer.edit.getAssists(path, offset, length);
      await _unloadSources();
      return assists;
    }, timeoutDuration: _ANALYSIS_SERVER_TIMEOUT));
  }

  /// Convert between the Analysis Server type and the API protocol types.
  static proto.ProblemAndFixes _convertAnalysisErrorFix(
      AnalysisErrorFixes analysisFixes) {
    final problemMessage = analysisFixes.error.message;
    final problemOffset = analysisFixes.error.location.offset;
    final problemLength = analysisFixes.error.location.length;

    final possibleFixes = <proto.CandidateFix>[];

    for (final sourceChange in analysisFixes.fixes) {
      final edits = <proto.SourceEdit>[];

      // A fix that tries to modify other files is considered invalid.

      var invalidFix = false;
      for (final sourceFileEdit in sourceChange.edits) {
        // TODO(lukechurch): replace this with a more reliable test based on the
        // psuedo file name in Analysis Server
        if (!sourceFileEdit.file.endsWith('/main.dart')) {
          invalidFix = true;
          break;
        }

        for (final sourceEdit in sourceFileEdit.edits) {
          edits.add(proto.SourceEdit()
            ..offset = sourceEdit.offset
            ..length = sourceEdit.length
            ..replacement = sourceEdit.replacement);
        }
      }
      if (!invalidFix) {
        final possibleFix = proto.CandidateFix()
          ..message = sourceChange.message
          ..edits.addAll(edits);
        possibleFixes.add(possibleFix);
      }
    }
    return proto.ProblemAndFixes()
      ..fixes.addAll(possibleFixes)
      ..problemMessage = problemMessage
      ..offset = problemOffset
      ..length = problemLength;
  }

  static List<proto.CandidateFix> _convertSourceChangesToCandidateFixes(
      List<SourceChange> sourceChanges) {
    final assists = <proto.CandidateFix>[];

    for (final sourceChange in sourceChanges) {
      for (final sourceFileEdit in sourceChange.edits) {
        if (!sourceFileEdit.file.endsWith('/main.dart')) {
          break;
        }

        final sourceEdits = sourceFileEdit.edits.map((sourceEdit) {
          return proto.SourceEdit()
            ..offset = sourceEdit.offset
            ..length = sourceEdit.length
            ..replacement = sourceEdit.replacement;
        });

        final candidateFix = proto.CandidateFix();
        candidateFix.message = sourceChange.message;
        candidateFix.edits.addAll(sourceEdits);
        final selectionOffset = sourceChange.selection?.offset;
        if (selectionOffset != null) {
          candidateFix.selectionOffset = selectionOffset;
        }
        candidateFix.linkedEditGroups
            .addAll(_convertLinkedEditGroups(sourceChange.linkedEditGroups));
        assists.add(candidateFix);
      }
    }

    return assists;
  }

  /// Convert a list of the analysis server's [LinkedEditGroup]s into the API's
  /// equivalent.
  static Iterable<proto.LinkedEditGroup> _convertLinkedEditGroups(
      Iterable<LinkedEditGroup> groups) {
    return groups?.map<proto.LinkedEditGroup>((g) {
          return proto.LinkedEditGroup()
            ..positions.addAll(g.positions?.map((p) => p.offset)?.toList())
            ..length = g.length
            ..suggestions.addAll(g.suggestions
                ?.map((s) => proto.LinkedEditSuggestion()
                  ..value = s.value
                  ..kind = s.kind)
                ?.toList());
        }) ??
        [];
  }

  /// Cleanly shutdown the Analysis Server.
  Future<dynamic> shutdown() {
    // TODO(jcollins-g): calling dispose() sometimes prevents
    // --pause-isolates-on-exit from working; fix.
    return analysisServer.server
        .shutdown()
        .timeout(const Duration(seconds: 1))
        .catchError((dynamic e) => null);
  }

  /// Internal implementation of the completion mechanism.
  Future<CompletionResults> _completeImpl(
      Map<String, String> sources, String sourceName, int offset) async {
    if (serverScheduler.queueCount > 0) {
      _logger
          .info('completeImpl: Scheduler queue: ${serverScheduler.queueCount}');
    }

    return serverScheduler.schedule(ClosureTask<CompletionResults>(() async {
      sources = _getOverlayMapWithPaths(sources);
      await _loadSources(sources);
      final id = await analysisServer.completion.getSuggestions(
        _getPathFromName(sourceName),
        offset,
      );
      final results = await getCompletionResults(id.id);
      await _unloadSources();
      return results;
    }, timeoutDuration: _ANALYSIS_SERVER_TIMEOUT));
  }

  Future<FixesResult> _getFixesImpl(
      Map<String, String> sources, String sourceName, int offset) async {
    sources = _getOverlayMapWithPaths(sources);
    final path = _getPathFromName(sourceName);

    if (serverScheduler.queueCount > 0) {
      _logger
          .fine('getFixesImpl: Scheduler queue: ${serverScheduler.queueCount}');
    }

    return serverScheduler.schedule(ClosureTask<FixesResult>(() async {
      final analysisCompleter = getAnalysisCompleteCompleter();
      await _loadSources(sources);
      await analysisCompleter.future;
      final fixes = await analysisServer.edit.getFixes(path, offset);
      await _unloadSources();
      return fixes;
    }, timeoutDuration: _ANALYSIS_SERVER_TIMEOUT));
  }

  Future<FormatResult> _formatImpl(String src, int offset) async {
    _logger.fine('FormatImpl: Scheduler queue: ${serverScheduler.queueCount}');

    return serverScheduler.schedule(ClosureTask<FormatResult>(() async {
      await _loadSources(<String, String>{mainPath: src});
      final result = await analysisServer.edit.format(mainPath, offset, 0);
      await _unloadSources();
      return result;
    }, timeoutDuration: _ANALYSIS_SERVER_TIMEOUT));
  }

  Map<String, String> _getOverlayMapWithPaths(Map<String, String> overlay) {
    final newOverlay = <String, String>{};
    for (final key in overlay.keys) {
      newOverlay[_getPathFromName(key)] = overlay[key];
    }
    return newOverlay;
  }

  String _getPathFromName(String sourceName) =>
      path.join(_sourceDirPath, sourceName);

  /// Warm up the analysis server to be ready for use.
  Future<proto.CompleteResponse> warmup({bool useHtml = false}) =>
      complete(useHtml ? _WARMUP_SRC_HTML : _WARMUP_SRC, 10);

  final Set<String> _overlayPaths = <String>{};

  Future<void> _loadSources(Map<String, String> sources) async {
    if (_overlayPaths.isNotEmpty) {
      await _sendRemoveOverlays();
    }
    await _sendAddOverlays(sources);
    await analysisServer.analysis.setPriorityFiles(sources.keys.toList());
  }

  Future<dynamic> _unloadSources() {
    return Future.wait(<Future<dynamic>>[
      _sendRemoveOverlays(),
      analysisServer.analysis.setPriorityFiles(<String>[]),
    ]);
  }

  Future<dynamic> _sendAddOverlays(Map<String, String> overlays) {
    final params = <String, ContentOverlayType>{};
    for (final overlayPath in overlays.keys) {
      params[overlayPath] = AddContentOverlay(overlays[overlayPath]);
    }

    _logger.fine('About to send analysis.updateContent');
    _logger.fine('  ${params.keys}');

    _overlayPaths.addAll(params.keys);

    return analysisServer.analysis.updateContent(params);
  }

  Future<dynamic> _sendRemoveOverlays() {
    _logger.fine('About to send analysis.updateContent remove overlays:');
    _logger.fine('  $_overlayPaths');

    final params = <String, ContentOverlayType>{};
    for (final overlayPath in _overlayPaths) {
      params[overlayPath] = RemoveContentOverlay();
    }
    _overlayPaths.clear();
    return analysisServer.analysis.updateContent(params);
  }

  final Map<String, Completer<CompletionResults>> _completionCompleters =
      <String, Completer<CompletionResults>>{};

  void listenForCompletions() {
    analysisServer.completion.onResults.listen((CompletionResults result) {
      if (result.isLast) {
        final completer = _completionCompleters.remove(result.id);
        if (completer != null) {
          completer.complete(result);
        }
      }
    });
  }

  Future<CompletionResults> getCompletionResults(String id) {
    _completionCompleters[id] = Completer<CompletionResults>();
    return _completionCompleters[id].future;
  }

  final List<Completer<dynamic>> _analysisCompleters = <Completer<dynamic>>[];

  void listenForAnalysisComplete() {
    analysisServer.server.onStatus.listen((ServerStatus status) {
      if (status.analysis == null) return;

      if (!status.analysis.isAnalyzing) {
        for (final completer in _analysisCompleters) {
          completer.complete();
        }

        _analysisCompleters.clear();
      }
    });
  }

  Completer<dynamic> getAnalysisCompleteCompleter() {
    final completer = Completer<dynamic>();
    _analysisCompleters.add(completer);
    return completer;
  }

  final Map<String, List<AnalysisError>> _errors =
      <String, List<AnalysisError>>{};

  void listenForErrors() {
    analysisServer.analysis.onErrors.listen((AnalysisErrors result) {
      if (result.errors.isEmpty) {
        _errors.remove(result.file);
      } else {
        _errors[result.file] = result.errors;
      }
    });
  }

  void clearErrors() => _errors.clear();

  List<AnalysisError> getErrors() {
    final errors = <AnalysisError>[];
    for (final e in _errors.values) {
      errors.addAll(e);
    }
    return errors;
  }
}

class Location {
  final String sourceName;
  final int offset;

  const Location(this.sourceName, this.offset);
}
