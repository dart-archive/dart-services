// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data' show Uint8List;

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'sdk_manager.dart';

Logger _logger = Logger('flutter_web');

/// Handle provisioning package:flutter_web and related work.
class FlutterWebManager {
  final FlutterSdk flutterSdk;

  // TODO(redbrogdon): Find a better way to determine the number of an unused
  // port.
  static const observatoryPort = 49003;

  Directory _projectDirectory;

  bool _initedFlutterWeb = false;

  FlutterWebManager(this.flutterSdk) {
    _projectDirectory = Directory.systemTemp.createTempSync('dartpad');
    _init();
  }

  void dispose() {
    _projectDirectory.deleteSync(recursive: true);
  }

  Directory get projectDirectory => _projectDirectory;

  String get packagesFilePath => path.join(projectDirectory.path, '.packages');

  void _init() {
    // create a pubspec.yaml file
    String pubspec = createPubspec(false);
    File(path.join(_projectDirectory.path, 'pubspec.yaml'))
        .writeAsStringSync(pubspec);

    // create a .packages file
    final String packagesFileContents = '''
$_samplePackageName:lib/
''';
    File(path.join(_projectDirectory.path, '.packages'))
        .writeAsStringSync(packagesFileContents);

    // and create a lib/ folder for completeness
    Directory(path.join(_projectDirectory.path, 'lib')).createSync();
  }

  Future<void> warmup() async {
    try {
      await initFlutterWeb();
    } catch (e, s) {
      _logger.warning('Error initializing flutter web', e, s);
    }
  }

  Future<void> initFlutterWeb() async {
    if (_initedFlutterWeb) {
      return;
    }

    _logger.info('creating flutter web pubspec');
    String pubspec = createPubspec(true);
    await File(path.join(_projectDirectory.path, 'pubspec.yaml'))
        .writeAsString(pubspec);

    await _runPubGet();

    final String sdkVersion = flutterSdk.versionFull;

    // Download and save the flutter_web.dill file.
    String url = 'https://storage.googleapis.com/compilation_artifacts/'
        '$sdkVersion/flutter_web.dill';

    Uint8List summaryContents = await http.readBytes(url);
    await File(path.join(_projectDirectory.path, 'flutter_web.dill'))
        .writeAsBytes(summaryContents);

    _initedFlutterWeb = true;
  }

  String get summaryFilePath {
    return path.join(_projectDirectory.path, 'flutter_web.dill');
  }

  static final Set<String> _flutterWebImportPrefixes = <String>{
    'package:flutter',
  };

  bool usesFlutterWeb(Set<String> imports) {
    return imports.any((String import) {
      return _flutterWebImportPrefixes.any(
        (String prefix) => import.startsWith(prefix),
      );
    });
  }

  bool hasUnsupportedImport(Set<String> imports) {
    return getUnsupportedImport(imports) != null;
  }

  String getUnsupportedImport(Set<String> imports) {
    for (String import in imports) {
      // All dart: imports are ok;
      if (import.startsWith('dart:')) {
        continue;
      }

      // Currently we only allow flutter web imports.
      if (import.startsWith('package:')) {
        if (_flutterWebImportPrefixes
            .any((String prefix) => import.startsWith(prefix))) {
          continue;
        }

        return import;
      }

      // Don't allow file imports.
      return import;
    }

    return null;
  }

  Future<void> _runPubGet() async {
    _logger.info('running flutter pub get (${_projectDirectory.path})');

    // The DART_VM_OPTIONS flag is included here to override the one sent by the
    // Dart SDK during tests. Without the flag, the Flutter tool will attempt to
    // spin up its own observatory on the same port as the one already
    // instantiated by the Dart SDK running the test, causing a hang.
    //
    // The value should be an available port number.
    final result = await Process.start(
      path.join(flutterSdk.flutterBinPath, 'flutter'),
      ['packages', 'get'],
      workingDirectory: _projectDirectory.path,
      environment: {'DART_VM_OPTIONS': '--enable-vm-service=$observatoryPort'},
    );

    final allErr = StringBuffer();
    final allOut = StringBuffer();

    result.stdout.transform(utf8.decoder).listen((data) {
      allErr.write(data);
    });

    result.stderr.transform(utf8.decoder).listen((data) {
      allOut.write(data);
    });

    _logger.info('${result.stdout}'.trim());

    final code = await result.exitCode;

    if (code != 0) {
      _logger.warning('pub get failed: ${result.exitCode}');
      _logger.warning(result.stderr);

      throw 'pub get failed: ${result.exitCode}: ${result.stderr}';
    }
  }

  static const String _samplePackageName = 'dartpad_sample';

  static String createPubspec(bool includeFlutterWeb) {
    String content = '''
name: $_samplePackageName
''';

    if (includeFlutterWeb) {
      content += '''
dependencies:
  flutter:
    sdk: flutter
  flutter_test:
    sdk: flutter
''';
    }

    return content;
  }
}
