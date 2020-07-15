// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:grinder/grinder.dart';
import 'package:grinder/src/run_utils.dart' show mergeWorkingDirectory;

Future<void> main(List<String> args) async {
  return grind(args);
}

@DefaultTask('Generate Protobuf classes')
void generateProtos() async {
  await runWithLogging(
    'protoc',
    arguments: ['--dart_out=lib/src', 'protos/dart_services.proto'],
  );

  // reformat generated classes so travis dartfmt test doesn't fail
  await runWithLogging(
    'dartfmt',
    arguments: ['--fix', '-w', 'lib/src/protos'],
  );

  // generate common_server_proto.g.dart
  Pub.run('build_runner', arguments: ['build', '--delete-conflicting-outputs']);
}

Future<void> runWithLogging(String executable,
    {List<String> arguments = const [],
    RunOptions runOptions,
    String workingDirectory}) async {
  runOptions = mergeWorkingDirectory(workingDirectory, runOptions);
  log("${executable} ${arguments.join(' ')}");
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
