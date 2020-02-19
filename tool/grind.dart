// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.grind;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dart_services/src/flutter_web.dart';
import 'package:dart_services/src/sdk_manager.dart';
import 'package:grinder/grinder.dart';
import 'package:grinder/grinder_files.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

Future<void> main(List<String> args) async {
  await SdkManager.sdk.init();
  await SdkManager.flutterSdk.init();
  return grind(args);
}

@Task()
void analyze() {
  Pub.run('tuneup', arguments: ['check']);
}

@Task()
@Depends(buildStorageArtifacts)
Future test() => TestRunner().testAsync();

@DefaultTask()
@Depends(analyze, test)
void analyzeTest() => null;

@Task()
@Depends(buildStorageArtifacts)
Future<void> serve() async {
  final proc = await Process.start(
      Platform.executable, ['bin/server_dev.dart', '--port', '8082']);
  final output = StreamGroup.merge([proc.stdout, proc.stderr]);
  await for (final message in output) {
    log(utf8.decode(message));
  }
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
void validateStorageArtifacts() async {
  final version = SdkManager.flutterSdk.versionFull;

  const urlBase = 'https://storage.googleapis.com/compilation_artifacts/';

  for (final artifact in compilationArtifacts) {
    await _validateExists('$urlBase$version/$artifact');
  }
}

Future _validateExists(String url) async {
  log('checking $url...');

  final response = await http.head(url);
  if (response.statusCode != 200) {
    fail(
      'compilation artifact not found: $url '
      '(${response.statusCode} ${response.reasonPhrase})',
    );
  }
}

@Task('build the sdk compilation artifacts for upload to google storage')
void buildStorageArtifacts() {
  // build and copy dart_sdk.js, flutter_web.js, and flutter_web.dill
  final temp = Directory.systemTemp.createTempSync('flutter_web_sample');

  try {
    _buildStorageArtifacts(temp);
  } finally {
    temp.deleteSync(recursive: true);
  }
}

void _buildStorageArtifacts(Directory dir) {
  final flutterSdkPath =
      Directory(path.join(Directory.current.path, 'flutter'));
  final pubspec = FlutterWebManager.createPubspec(true);
  joinFile(dir, ['pubspec.yaml']).writeAsStringSync(pubspec);

  // run flutter pub get
  run(
    path.join(flutterSdkPath.path, 'bin/flutter'),
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

  // Make sure flutter/bin/cache/flutter_web_sdk/flutter_web_sdk/kernel/flutter_ddc_sdk.dill
  // is installed.
  run(
    path.join(flutterSdkPath.path, 'bin/flutter'),
    arguments: ['precache', '--web'],
    workingDirectory: dir.path,
  );

  // Build the artifacts using DDC:
  // dart-sdk/bin/dartdevc -s kernel/flutter_ddc_sdk.dill
  //     --modules=amd package:flutter_web/animation.dart ...
  final compilerPath =
      path.join(flutterSdkPath.path, 'bin/cache/dart-sdk/bin/dartdevc');
  final dillPath = path.join(flutterSdkPath.path,
      'bin/cache/flutter_web_sdk/flutter_web_sdk/kernel/flutter_ddc_sdk.dill');

  final args = <String>[
    '-s',
    dillPath,
    '--modules=amd',
    '-o',
    'flutter_web.js',
    ...flutterLibraries
  ];

  run(
    compilerPath,
    arguments: args,
    workingDirectory: dir.path,
  );

  // Copy both to the project directory.
  final artifactsDir = getDir('artifacts');
  artifactsDir.create();

  final sdkJsPath = path.join(flutterSdkPath.path,
      'bin/cache/flutter_web_sdk/flutter_web_sdk/kernel/amd/dart_sdk.js');

  copy(getFile(sdkJsPath), artifactsDir);
  copy(joinFile(dir, ['flutter_web.js']), artifactsDir);
  copy(joinFile(dir, ['flutter_web.dill']), artifactsDir);

  // Emit some good google storage upload instructions.
  final version = SdkManager.flutterSdk.versionFull;
  log('\nFrom the dart-services project root dir, run:');
  log('  gsutil -h "Cache-Control:public, max-age=86400" cp -z js '
      'artifacts/*.js gs://compilation_artifacts/$version/');
}

@Task('Delete, re-download, and reinitialize the Flutter submodule.')
void setupFlutterSubmodule() {
  final flutterDir = Directory('flutter');

  // Remove all files currently in the submodule. This is done to clear any
  // internal state the Flutter/Dart SDKs may have created on their own.
  flutterDir.listSync().forEach((e) => e.deleteSync(recursive: true));

  // Pull clean files into the submodule, based on whatever commit it's set to.
  run(
    'git',
    arguments: ['submodule', 'update'],
  );

  // Set up the submodule's copy of the Flutter SDK the way dart-services needs
  // it.
  run(
    path.join(flutterDir.path, 'bin/flutter'),
    arguments: ['doctor'],
  );

  run(
    path.join(flutterDir.path, 'bin/flutter'),
    arguments: ['config', '--enable-web'],
  );

  run(
    path.join(flutterDir.path, 'bin/flutter'),
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

@Task('Update discovery files and run all checks prior to deployment')
@Depends(setupFlutterSubmodule, updateDockerVersion, discovery, protobuf,
    analyze, test, fuzz, validateStorageArtifacts)
void deploy() {
  log('Run: gcloud app deploy --project=dart-services --no-promote');
}

@Task()
@Depends(discovery, protobuf, analyze, fuzz, buildStorageArtifacts)
void buildbot() => null;

@Task('Generate the discovery doc and Dart library from the annotated API')
void discovery() {
  final result = Process.runSync(
      Platform.executable, ['bin/server_dev.dart', '--discovery']);

  if (result.exitCode != 0) {
    throw 'Error generating the discovery document\n${result.stderr}';
  }

  final discoveryFile = File('doc/generated/dartservices.json');
  discoveryFile.parent.createSync();
  log('writing ${discoveryFile.path}');
  discoveryFile.writeAsStringSync('${result.stdout.trim()}\n');

  // Generate the Dart library from the json discovery file.
  Pub.global.activate('discoveryapis_generator');
  Pub.global.run('discoveryapis_generator:generate', arguments: [
    'files',
    '--input-dir=doc/generated',
    '--output-dir=doc/generated'
  ]);
}

@Task('Generate Protobuf classes')
void protobuf() {
  final result = Process.runSync(
    'protoc',
    ['--dart_out=lib/src', 'protos/dart_services.proto'],
  );
  print(result.stdout);
  if (result.exitCode != 0) {
    throw 'Error generating the Protobuf classes\n${result.stderr}';
  }

  // generate common_server_proto.g.dart
  Pub.run('build_runner', arguments: ['build']);
}
