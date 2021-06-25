// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import 'project.dart' as project;

List<ImportDirective> getAllImportsFor(String? dartSource) {
  if (dartSource == null) return [];

  final unit = parseString(content: dartSource, throwIfDiagnostics: false).unit;
  return unit.directives.whereType<ImportDirective>().toList();
}

/// Flutter packages which do not have version numbers in pubspec.lock.
const _flutterPackages = [
  'flutter',
  'flutter_test',
  'flutter_web_plugins',
  'sky_engine',
];

/// Each of these is expensive to calculate; they require reading from disk.
/// None of them changes during execution.
Map<String, String>? _nullSafePackageVersions;
Map<String, String>? _preNullSafePackageVersions;

/// Returns a mapping of Pub package name to package version.
Map<String, String> getPackageVersions({required bool nullSafe}) {
  if (nullSafe) {
    return _nullSafePackageVersions ??=
        packageVersionsFromPubspecLock(project.flutterTemplateProject(true));
  } else {
    return _preNullSafePackageVersions ??=
        packageVersionsFromPubspecLock(project.flutterTemplateProject(false));
  }
}

/// Returns a mapping of Pub package name to package version, retrieving data
/// from the project template's `pubspec.lock` file.
Map<String, String> packageVersionsFromPubspecLock(Directory package) {
  final pubspecLockPath = File(path.join(package.path, 'pubspec.lock'));
  final pubspecLock = loadYamlDocument(pubspecLockPath.readAsStringSync());
  final pubSpecLockContents = pubspecLock.contents as YamlMap;
  final packages = pubSpecLockContents['packages'] as YamlMap;
  final packageVersions = <String, String>{};

  packages.forEach((nameKey, packageValue) {
    final name = nameKey as String;
    if (_flutterPackages.contains(name)) {
      return;
    }
    final package = packageValue as YamlMap;
    final source = package['source'];
    if (source is! String || source != 'hosted') {
      throw StateError(
          '$name is not hosted: "$source" (${source.runtimeType})');
    }
    final version = package['version'];
    if (version is String) {
      packageVersions[name] = version;
    } else {
      throw StateError(
          '$name does not have a well-formatted version: $version');
    }
  });

  return packageVersions;
}

extension ImportIterableExtensions on Iterable<ImportDirective> {
  /// Returns the names of packages that are referenced in this collection.
  /// These package names are sanitized defensively.
  Iterable<String> filterSafePackages() {
    return where((import) => !import.uri.stringValue!.startsWith('package:../'))
        .map((import) => Uri.parse(import.uri.stringValue!))
        .where((uri) => uri.scheme == 'package' && uri.pathSegments.isNotEmpty)
        .map((uri) => uri.pathSegments.first);
  }
}
