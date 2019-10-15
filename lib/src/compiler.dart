// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library is a wrapper around the Dart to JavaScript (dart2js) compiler.
library services.compiler;

import 'dart:async';
import 'dart:io';

import 'package:bazel_worker/driver.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'common.dart';
import 'flutter_web.dart';
import 'pub.dart';
import 'sdk_manager.dart';

Logger _logger = Logger('compiler');

/// An interface to the dart2js compiler. A compiler object can process one
/// compile at a time.
class Compiler {
  final Sdk _sdk;
  final FlutterSdk _flutterSdk;
  final FlutterWebManager _flutterWebManager;
  final String _dartdevcPath;
  final BazelWorkerDriver _flutterDdcDriver;

  Compiler(this._sdk, this._flutterSdk, this._flutterWebManager)
      : _dartdevcPath = path.join(_flutterSdk.sdkPath, 'bin', 'dartdevc'),
        _flutterDdcDriver = BazelWorkerDriver(
            () => Process.start(
                path.join(_flutterSdk.sdkPath, 'bin', 'dartdevc'),
                <String>['--persistent_worker']),
            maxWorkers: 1);

  bool importsOkForCompile(Set<String> imports) {
    return !_flutterWebManager.hasUnsupportedImport(imports);
  }

  Future<CompilationResults> warmup({bool useHtml = false}) {
    return compile(useHtml ? sampleCodeWeb : sampleCode);
  }

  /// Compile the given string and return the resulting [CompilationResults].
  Future<CompilationResults> compile(
    String input, {
    bool returnSourceMap = false,
  }) async {
    Set<String> imports = getAllImportsFor(input);
    if (!importsOkForCompile(imports)) {
      return CompilationResults(problems: <CompilationProblem>[
        CompilationProblem._(
          'unsupported import: ${_flutterWebManager.getUnsupportedImport(imports)}',
        ),
      ]);
    }

    Directory temp = await Directory.systemTemp.createTemp('dartpad');

    try {
      List<String> arguments = <String>[
        '--suppress-hints',
        '--terse',
        if (!returnSourceMap) '--no-source-maps',
        '--packages=${_flutterWebManager.packagesFilePath}',
        '-o$kMainDart.js',
        kMainDart,
      ];

      String compileTarget = path.join(temp.path, kMainDart);
      File mainDart = File(compileTarget);
      await mainDart.writeAsString(input);

      File mainJs = File(path.join(temp.path, '$kMainDart.js'));
      File mainSourceMap = File(path.join(temp.path, '$kMainDart.js.map'));

      final String dart2JSPath = path.join(_sdk.sdkPath, 'bin', 'dart2js');
      _logger.info('About to exec: $dart2JSPath $arguments');

      ProcessResult result = await Process.run(dart2JSPath, arguments,
          workingDirectory: temp.path);

      if (result.exitCode != 0) {
        final CompilationResults results =
            CompilationResults(problems: <CompilationProblem>[
          CompilationProblem._(result.stdout as String),
        ]);
        return results;
      } else {
        String sourceMap;
        if (returnSourceMap && await mainSourceMap.exists()) {
          sourceMap = await mainSourceMap.readAsString();
        }
        final CompilationResults results = CompilationResults(
          compiledJS: await mainJs.readAsString(),
          sourceMap: sourceMap,
        );
        return results;
      }
    } catch (e, st) {
      _logger.warning('Compiler failed: $e\n$st');
      rethrow;
    } finally {
      await temp.delete(recursive: true);
      _logger.info('temp folder removed: ${temp.path}');
    }
  }

  /// Compile the given string and return the resulting [DDCCompilationResults].
  Future<DDCCompilationResults> compileDDC(String input) async {
    Set<String> imports = getAllImportsFor(input);
    if (!importsOkForCompile(imports)) {
      return DDCCompilationResults.failed(<CompilationProblem>[
        CompilationProblem._(
          'unsupported import: ${_flutterWebManager.getUnsupportedImport(imports)}',
        ),
      ]);
    }

    Directory temp = await Directory.systemTemp.createTemp('dartpad');

    try {
      String compileTarget = path.join(temp.path, kMainDart);
      File mainDart = File(compileTarget);
      await mainDart.writeAsString(input);

      List<String> arguments = <String>[
        '--modules=amd',
        if (_flutterWebManager.usesFlutterWeb(imports)) ...[
          '-k',
          '-s',
          _flutterWebManager.summaryFilePath,
          '-s',
          '${_flutterSdk.flutterBinPath}/cache/flutter_web_sdk/flutter_web_sdk/kernel/flutter_ddc_sdk.dill'
        ],
        ...['-o', path.join(temp.path, '$kMainDart.js')],
        '--single-out-file',
        ...['--module-name', 'dartpad_main'],
        compileTarget,
        '--packages=${_flutterWebManager.packagesFilePath}',
      ];

      File mainJs = File(path.join(temp.path, '$kMainDart.js'));

      _logger.info('About to exec "$_dartdevcPath ${arguments.join(' ')}"');
      _logger.info('Compiling: $input');

      final WorkResponse response = await _flutterDdcDriver
          .doWork(WorkRequest()..arguments.addAll(arguments));

      if (response.exitCode != 0) {
        return DDCCompilationResults.failed(<CompilationProblem>[
          CompilationProblem._(response.output),
        ]);
      } else {
        final DDCCompilationResults results = DDCCompilationResults(
          compiledJS: await mainJs.readAsString(),
          modulesBaseUrl: 'https://storage.googleapis.com/'
              'compilation_artifacts/${_flutterSdk.versionFull}/',
        );
        return results;
      }
    } catch (e, st) {
      _logger.warning('Compiler failed: $e\n$st');
      rethrow;
    } finally {
      await temp.delete(recursive: true);
      _logger.info('temp folder removed: ${temp.path}');
    }
  }

  Future<void> dispose() => _flutterDdcDriver.terminateWorkers();
}

/// The result of a dart2js compile.
class CompilationResults {
  final String compiledJS;
  final String sourceMap;
  final List<CompilationProblem> problems;

  CompilationResults({
    this.compiledJS,
    this.problems = const <CompilationProblem>[],
    this.sourceMap,
  });

  bool get hasOutput => compiledJS != null && compiledJS.isNotEmpty;

  /// This is true if there were no errors.
  bool get success => problems.isEmpty;

  @override
  String toString() => success
      ? 'CompilationResults: Success'
      : 'Compilation errors: ${problems.join('\n')}';
}

/// The result of a DDC compile.
class DDCCompilationResults {
  final String compiledJS;
  final String modulesBaseUrl;
  final List<CompilationProblem> problems;

  DDCCompilationResults({this.compiledJS, this.modulesBaseUrl})
      : problems = const <CompilationProblem>[];

  DDCCompilationResults.failed(this.problems)
      : compiledJS = null,
        modulesBaseUrl = null;

  bool get hasOutput => compiledJS != null && compiledJS.isNotEmpty;

  /// This is true if there were no errors.
  bool get success => problems.isEmpty;
  @override
  String toString() => success
      ? 'CompilationResults: Success'
      : 'Compilation errors: ${problems.join('\n')}';
}

/// An issue associated with [CompilationResults].
class CompilationProblem implements Comparable<CompilationProblem> {
  final String message;

  CompilationProblem._(this.message);

  @override
  int compareTo(CompilationProblem other) => message.compareTo(other.message);

  @override
  String toString() => message;
}
