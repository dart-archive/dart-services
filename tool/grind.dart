// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.grind;

import 'dart:async';
import 'dart:io';

import 'package:dart_services/src/sdk_manager.dart';
import 'package:grinder/grinder.dart';
import 'package:grinder/grinder_files.dart';
import 'package:grinder/src/run_utils.dart' show mergeWorkingDirectory;
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

Future<void> main(List<String> args) async {
  return grind(args);
}

@Task('Make sure SDKs are appropriately initialized')
@Depends(setupFlutterSdk)
void sdkInit() async {
  await SdkManager.sdk.init();
}

@Task()
void analyze() async {
  await runWithLogging('dart', arguments: ['analyze']);
}

@Task()
@Depends(buildStorageArtifacts)
Future<dynamic> test() => TestRunner().testAsync();

@DefaultTask()
@Depends(analyze, test)
void analyzeTest() => null;

@Task()
@Depends(buildStorageArtifacts)
Future<void> serve() async {
  await runWithLogging(Platform.executable,
      arguments: ['bin/server_dev.dart', '--port', '8082']);
}

@Task()
@Depends(buildStorageArtifacts)
Future<void> serveWithProxyTarget() async {
  await runWithLogging(Platform.executable, arguments: [
    'bin/server_dev.dart',
    '--port',
    '8082',
    '--proxy-target',
    'https://v1.api.dartpad.dev/'
  ]);
}

final _dockerVersionMatcher = RegExp(r'^FROM google/dart-runtime:(.*)$');

@Task('Update the docker and SDK versions')
void updateDockerVersion() {
  final platformVersion = Platform.version.split(' ').first;
  final dockerImageLines = File('Dockerfile').readAsLinesSync().map((String s) {
    if (s.contains(_dockerVersionMatcher)) {
      return 'FROM google/dart-runtime:$platformVersion';
    }
    return s;
  }).toList();
  dockerImageLines.add('');

  File('Dockerfile').writeAsStringSync(dockerImageLines.join('\n'));
}

final List<String> compilationArtifacts = [
  'dart_sdk.js',
  'flutter_web.js',
];

@Task('validate that we have the correct compilation artifacts available in '
    'google storage')
@Depends(sdkInit)
void validateStorageArtifacts() async {
  final version = SdkManager.sdk.versionFull;

  const urlBase = 'https://storage.googleapis.com/nnbd_artifacts/';

  for (final artifact in compilationArtifacts) {
    await _validateExists('$urlBase$version/$artifact');
  }
}

Future<void> _validateExists(String url) async {
  log('checking $url...');

  final response = await http.head(url);
  if (response.statusCode != 200) {
    fail(
      'compilation artifact not found: $url '
      '(${response.statusCode} ${response.reasonPhrase})',
    );
  }
}

@Task('build the project templates')
@Depends(sdkInit)
void buildProjectTemplates() async {
  final templatesPath =
      Directory(path.join(Directory.current.path, 'project_templates'));
  final exists = await templatesPath.exists();
  if (exists) {
    await templatesPath.delete(recursive: true);
  }

  final dartProjectPath =
      Directory(path.join(templatesPath.path, 'dart_project'));
  final dartProjectDir = await dartProjectPath.create(recursive: true);
  joinFile(dartProjectDir, ['pubspec.yaml'])
      .writeAsStringSync(createPubspec(includeFlutterWeb: false));
  await _runDartPubGet(dartProjectDir);
  joinFile(dartProjectDir, ['analysis_options.yaml'])
      .writeAsStringSync(createDartAnalysisOptions());

  final flutterProjectPath =
      Directory(path.join(templatesPath.path, 'flutter_project'));
  final flutterProjectDir = await flutterProjectPath.create(recursive: true);
  joinFile(flutterProjectDir, ['pubspec.yaml'])
      .writeAsStringSync(createPubspec(includeFlutterWeb: true));
  await _runFlutterPubGet(flutterProjectDir);
  // TODO(gspencergoog): Convert this to use the flutter recommended lints as
  // soon as those are finalized (the current proposal is to leave the
  // analysis_options_user.yaml file as-is and replace it with a package, to
  // avoid massive breakage).
  joinFile(flutterProjectDir, ['analysis_options.yaml']).writeAsStringSync(
      'include: package:flutter/analysis_options_user.yaml\n');
}

Future<void> _runDartPubGet(Directory dir) async {
  log('running dart pub get (${dir.path})');

  await runWithLogging(
    path.join(SdkManager.sdk.sdkPath, 'bin', 'dart'),
    arguments: ['pub', 'get'],
    workingDirectory: dir.path,
  );
}

Future<void> _runFlutterPubGet(Directory dir) async {
  log('running flutter pub get (${dir.path})');

  await runWithLogging(
    path.join(SdkManager.sdk.flutterBinPath, 'flutter'),
    arguments: ['pub', 'get'],
    workingDirectory: dir.path,
  );
}

@Task('build the sdk compilation artifacts for upload to google storage')
@Depends(sdkInit, buildProjectTemplates)
void buildStorageArtifacts() async {
  // build and copy dart_sdk.js, flutter_web.js, and flutter_web.dill
  final temp = Directory.systemTemp.createTempSync('flutter_web_sample');

  try {
    await _buildStorageArtifacts(temp);
  } finally {
    temp.deleteSync(recursive: true);
  }
}

Future<void> _buildStorageArtifacts(Directory dir) async {
  final pubspec = createPubspec(includeFlutterWeb: true);
  joinFile(dir, ['pubspec.yaml']).writeAsStringSync(pubspec);

  // run flutter pub get
  await runWithLogging(
    path.join(flutterSdkPath, 'bin', 'flutter'),
    arguments: ['pub', 'get'],
    workingDirectory: dir.path,
  );

  // locate the artifacts
  final flutterPackages = ['flutter', 'flutter_test'];

  final flutterLibraries = <String>[];
  final packageLines = joinFile(dir, ['.packages']).readAsLinesSync();
  for (var line in packageLines) {
    line = line.trim();
    if (line.startsWith('#') || line.isEmpty) {
      continue;
    }
    final index = line.indexOf(':');
    if (index == -1) {
      continue;
    }
    final packageName = line.substring(0, index);
    final url = line.substring(index + 1);
    if (flutterPackages.contains(packageName)) {
      // This is a package we're interested in - add all the public libraries to
      // the list.
      final libPath = Uri.parse(url).toFilePath();
      for (final entity in getDir(libPath).listSync()) {
        if (entity is File && entity.path.endsWith('.dart')) {
          flutterLibraries.add('package:$packageName/${fileName(entity)}');
        }
      }
    }
  }

  // Make sure flutter-sdk/bin/cache/flutter_web_sdk/flutter_web_sdk/kernel/flutter_ddc_sdk_sound.dill
  // is installed.
  await runWithLogging(
    path.join(flutterSdkPath, 'bin', 'flutter'),
    arguments: ['precache', '--web'],
    workingDirectory: dir.path,
  );

  // Build the artifacts using DDC:
  // dart-sdk/bin/dartdevc -s kernel/flutter_ddc_sdk_sound.dill
  //     --modules=amd package:flutter/animation.dart ...
  final compilerPath =
      path.join(flutterSdkPath, 'bin', 'cache', 'dart-sdk', 'bin', 'dartdevc');
  final dillPath = path.join(flutterSdkPath, 'bin', 'cache', 'flutter_web_sdk',
      'flutter_web_sdk', 'kernel', 'flutter_ddc_sdk_sound.dill');

  final args = <String>[
    '-s',
    dillPath,
    '--sound-null-safety',
    '--enable-experiment=non-nullable',
    '--modules=amd',
    '-o',
    'flutter_web.js',
    ...flutterLibraries
  ];

  await runWithLogging(
    compilerPath,
    arguments: args,
    workingDirectory: dir.path,
  );

  // Copy both to the project directory.
  final artifactsDir = getDir('artifacts');
  delete(artifactsDir);
  artifactsDir.createSync();

  final sdkJsPath = path.join(flutterSdkPath, 'bin', 'cache', 'flutter_web_sdk',
      'flutter_web_sdk', 'kernel', 'amd-canvaskit-html-sound', 'dart_sdk.js');

  copy(getFile(sdkJsPath), artifactsDir);
  copy(joinFile(dir, ['flutter_web.js']), artifactsDir);
  copy(joinFile(dir, ['flutter_web.dill']), artifactsDir);

  // Emit some good google storage upload instructions.
  final version = SdkManager.sdk.versionFull;
  log('\nFrom the dart-services project root dir, run:');
  log('  gsutil -h "Cache-Control:public, max-age=86400" cp -z js '
      'artifacts/*.js gs://nnbd_artifacts/$version/');
}

@Task('Reinitialize the Flutter submodule.')
void setupFlutterSdk() async {
  final info = DownloadingSdkManager.getSdkConfigInfo();
  print('Flutter SDK configuration: $info\n');

  // Download the SDK into ./futter-sdk/
  await DownloadingSdkManager().createFromConfigFile();

  // Set up the  Flutter SDK the way dart-services needs it.

  final flutterBinFlutter = path.join(flutterSdkPath, 'bin', 'flutter');
  await runWithLogging(
    flutterBinFlutter,
    arguments: ['doctor'],
  );

  await runWithLogging(
    flutterBinFlutter,
    arguments: ['config', '--enable-web'],
  );

  await runWithLogging(
    flutterBinFlutter,
    arguments: [
      'precache',
      '--web',
      '--no-android',
      '--no-ios',
      '--no-linux',
      '--no-windows',
      '--no-macos',
      '--no-fuchsia',
    ],
  );
}

@Task()
void fuzz() {
  log('warning: fuzz testing is a noop, see #301');
}

@Task('Update generated files and run all checks prior to deployment')
@Depends(sdkInit, updateDockerVersion, generateProtos, analyze, test, fuzz,
    validateStorageArtifacts)
void deploy() {
  log('Run: gcloud app deploy --project=dart-services --no-promote');
}

@Task()
@Depends(generateProtos, analyze, fuzz, buildStorageArtifacts)
void buildbot() => null;

@Task('Generate Protobuf classes')
void generateProtos() async {
  await runWithLogging(
    'protoc',
    arguments: ['--dart_out=lib/src', 'protos/dart_services.proto'],
  );

  // reformat generated classes so travis dart format test doesn't fail
  await runWithLogging(
    'dart',
    arguments: ['format', '--fix', 'lib/src/protos'],
  );

  // And reformat again, for $REASONS
  await runWithLogging(
    'dart',
    arguments: ['format', '--fix', 'lib/src/protos'],
  );

  // generate common_server_proto.g.dart
  Pub.run('build_runner', arguments: ['build', '--delete-conflicting-outputs']);
}

Future<void> runWithLogging(String executable,
    {List<String> arguments = const [],
    RunOptions runOptions,
    String workingDirectory}) async {
  runOptions = mergeWorkingDirectory(workingDirectory, runOptions);
  log("$executable ${arguments.join(' ')}");
  runOptions ??= RunOptions();

  final proc = await Process.start(executable, arguments,
      workingDirectory: runOptions.workingDirectory,
      environment: runOptions.environment,
      includeParentEnvironment: runOptions.includeParentEnvironment,
      runInShell: runOptions.runInShell);

  proc.stdout.listen((out) => log(runOptions.stdoutEncoding.decode(out)));
  proc.stderr.listen((err) => log(runOptions.stdoutEncoding.decode(err)));
  final exitCode = await proc.exitCode;

  if (exitCode != 0) {
    fail('Unable to exec $executable, failed with code $exitCode');
  }
}

const String _samplePackageName = 'dartpad_sample';

String createPubspec({@required bool includeFlutterWeb}) {
  // Mark the samples as not null safe.
  var content = '''
name: $_samplePackageName
environment:
  sdk: '>=2.12.0-0 <3.0.0'
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

String createDartAnalysisOptions() {
  // TODO(gspencergoog): Update this to Dart "recommended" list once that is
  // finalized.
  return '''
linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_relative_lib_imports
    - avoid_shadowing_type_parameters
    - avoid_types_as_parameter_names
    - await_only_futures
    - camel_case_extensions
    - camel_case_types
    - curly_braces_in_flow_control_structures
    - empty_catches
    - file_names
    - hash_and_equals
    - iterable_contains_unrelated_type
    - list_remove_unrelated_type
    - no_duplicate_case_values
    - non_constant_identifier_names
    - package_prefixed_library_names
    - prefer_generic_function_type_aliases
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_iterable_whereType
    - prefer_typing_uninitialized_variables
    - provide_deprecation_message
    - unawaited_futures
    - unnecessary_overrides
    - unrelated_type_equality_checks
    - valid_regexps
    - void_checks
''';
}
