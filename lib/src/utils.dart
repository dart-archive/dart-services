// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;

/// Normalizes any "paths" from [text], replacing the segments before the last
/// separator with either "dart:core" or "package:flutter", or removes them,
/// according to their content.
///
/// ## Examples:
///
/// "Unused import: '/path/foo.dart'" -> "Unused import: 'foo.dart'"
///
/// "Unused import: '/path/to/dart/lib/core/world.dart'" ->
/// "Unused import: 'dart:core/world.dart'"
///
/// "Unused import: 'package:flutter/material.dart'" ->
/// "Unused import: 'package:flutter/material.dart'"
String normalizeFilePaths(String text) {
  return text.replaceAllMapped(_possiblePathPattern, (match) {
    final possiblePath = match.group(0)!;

    final uri = Uri.tryParse(possiblePath);
    if (uri != null && uri.hasScheme) {
      return possiblePath;
    }

    final pathComponents = path.split(possiblePath);
    final basename = path.basename(possiblePath);

    if (pathComponents.contains('flutter')) {
      return path.join('package:flutter', basename);
    }

    if (pathComponents.contains('lib') && pathComponents.contains('core')) {
      return path.join('dart:core', basename);
    }

    return basename;
  });
}

Future<Process> runWithLogging(
  String executable, {
  List<String> arguments = const [],
  String? workingDirectory,
  Map<String, String> environment = const {},
  required void Function(String) log,
}) async {
  log([
    'Running $executable ${arguments.join(' ')}',
    if (workingDirectory != null) "from directory: '$workingDirectory'",
    if (environment.isNotEmpty) 'with additional environment: $environment',
  ].join('\n  '));

  final process = await Process.start(executable, arguments,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: true,
      runInShell: Platform.isWindows);
  process.stdout.listen((out) => log(systemEncoding.decode(out)));
  process.stderr.listen((err) => log(systemEncoding.decode(err)));
  return process;
}

/// A pattern which matches a possible path.
///
/// This pattern is essentially "possibly some letters and colons, followed by a
/// slash, followed by non-whitespace."
final _possiblePathPattern = RegExp(r'[a-zA-Z:]*\/\S*');
