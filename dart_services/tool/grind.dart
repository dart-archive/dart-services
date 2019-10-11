// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.grind;

import 'dart:async';
import 'dart:io';

import 'package:dart_services/src/sdk_manager.dart';
import 'package:grinder/grinder.dart';

Future<void> main(List<String> args) async {
  await SdkManager.sdk.init();
  return grind(args);
}

@Task()
void analyze() {
  Pub.run('tuneup', arguments: ['check']);
}

@Task()
Future test() => TestRunner().testAsync();

@DefaultTask()
@Depends(analyze, test)
void analyzeTest() => null;

@Task()
void fuzz() {
  log('warning: fuzz testing is a noop, see #301');
}

@Task()
@Depends(discovery, analyze, fuzz)
void buildbot() => null;

@Task('Generate the discovery doc and Dart library from the annotated API')
void discovery() {
  ProcessResult result = Process.runSync(
      Platform.executable, ['bin/server_dev.dart', '--discovery']);

  if (result.exitCode != 0) {
    throw 'Error generating the discovery document\n${result.stderr}';
  }

  File discoveryFile = File('doc/generated/dartservices.json');
  discoveryFile.parent.createSync();
  log('writing ${discoveryFile.path}');
  discoveryFile.writeAsStringSync('${result.stdout.trim()}\n');

  ProcessResult resultDb = Process.runSync(
      Platform.executable, ['bin/server_dev.dart', '--discovery', '--relay']);

  if (resultDb.exitCode != 0) {
    throw 'Error generating the discovery document\n${result.stderr}';
  }

  File discoveryDbFile = File('doc/generated/_dartpadsupportservices.json');
  discoveryDbFile.parent.createSync();
  log('writing ${discoveryDbFile.path}');
  discoveryDbFile.writeAsStringSync('${resultDb.stdout.trim()}\n');

  // Generate the Dart library from the json discovery file.
  Pub.global.activate('discoveryapis_generator');
  Pub.global.run('discoveryapis_generator:generate', arguments: [
    'files',
    '--input-dir=doc/generated',
    '--output-dir=doc/generated'
  ]);
}
