// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dart_services/src/project_creator.dart';
import 'package:dart_services/src/sdk.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

final channel = Platform.environment['FLUTTER_CHANNEL'] ?? stableChannel;

void main() => defineTests();

void defineTests() {
  Future<ProjectCreator> projectCreator() async {
    final dependenciesFile = d.file('dependencies.json', '''
{
  "meta": "1.7.0"
}
''');
    await dependenciesFile.create();
    final templatesPath = d.dir('project_templates');
    await templatesPath.create();
    final sdk = Sdk.create('stable');
    return ProjectCreator(
      sdk,
      templatesPath.io.path,
      dependenciesFile: dependenciesFile.io,
      log: (_) {},
    );
  }

  group('basic dart project template', () {
    setUpAll(() async {
      await (await projectCreator()).buildDartProjectTemplate();
    });

    test('project directory is created', () async {
      await d.dir('project_templates', [
        d.dir('null-safe', [
          d.dir('dart_project'),
        ]),
      ]).validate();
    });

    test('pubspec is created', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('dart_project', [
          d.file(
              'pubspec.yaml',
              allOf([
                matches("sdk: '>=2.14.0 <3.0.0'"),
                matches('meta: 1.7.0'),
              ])),
        ]),
      ]).validate();
    });

    test('pub get creates pubspec.lock', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('dart_project', [d.file('pubspec.lock', isNotEmpty)]),
      ]).validate();
    });

    test('recommended lints are enabled', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('dart_project', [
          d.file('analysis_options.yaml',
              matches('include: package:lints/recommended.yaml')),
        ]),
      ]).validate();
    });
  });

  group('basic Flutter project template', () {
    setUpAll(() async {
      await (await projectCreator())
          .buildFlutterProjectTemplate(firebaseStyle: FirebaseStyle.none);
    });

    test('project directory is created', () async {
      await d.dir('project_templates', [
        d.dir('null-safe', [
          d.dir('flutter_project'),
        ]),
      ]).validate();
    });

    test('Flutter Web directories are created', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('flutter_project', [
          d.dir('lib'),
          d.dir('web', [d.file('index.html', isEmpty)]),
        ])
      ]).validate();
    });

    test('pubspec is created', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('flutter_project', [
          d.file(
              'pubspec.yaml',
              allOf([
                matches("sdk: '>=2.14.0 <3.0.0'"),
                matches('meta: 1.7.0'),
                matches('sdk: flutter'),
              ])),
        ]),
      ]).validate();
    });

    test('pub get creates pubspec.lock', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('flutter_project', [d.file('pubspec.lock', isNotEmpty)]),
      ]).validate();
    });

    test('flutter lints are enabled', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('flutter_project', [
          d.file('analysis_options.yaml',
              matches('include: package:flutter_lints/flutter.yaml')),
        ]),
      ]).validate();
    });

    test('plugins are registered', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('flutter_project/lib', [
          d.file('generated_plugin_registrant.dart',
              matches('UrlLauncherPlugin.registerWith')),
        ]),
      ]).validate();
    });
  });

  group('Firebase project template', () {
    setUpAll(() async {
      await (await projectCreator()).buildFlutterProjectTemplate(
          firebaseStyle: FirebaseStyle.flutterFire);
    });

    test('project directory is created', () async {
      await d.dir('project_templates', [
        d.dir('null-safe', [
          d.dir('firebase_project'),
        ]),
      ]).validate();
    });

    test('Flutter Web directories are created', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('firebase_project', [
          d.dir('lib'),
          d.dir('web', [d.file('index.html', isEmpty)]),
        ])
      ]).validate();
    });

    test('pubspec is created', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('firebase_project', [
          d.file(
              'pubspec.yaml',
              allOf([
                matches("sdk: '>=2.14.0 <3.0.0'"),
                matches('meta: 1.7.0'),
                matches('sdk: flutter'),
              ])),
        ]),
      ]).validate();
    });

    test('pub get creates pubspec.lock', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('firebase_project', [d.file('pubspec.lock', isNotEmpty)]),
      ]).validate();
    });

    test('flutter lints are enabled', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('firebase_project', [
          d.file('analysis_options.yaml',
              matches('include: package:flutter_lints/flutter.yaml')),
        ]),
      ]).validate();
    });

    test('plugins are registered', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('firebase_project/lib', [
          d.file(
              'generated_plugin_registrant.dart',
              allOf([
                matches('FirebaseFirestoreWeb.registerWith'),
                matches('FirebaseFunctionsWeb.registerWith'),
                matches('FirebaseFunctionsWeb.registerWith'),
                matches('FirebaseAuthWeb.registerWith'),
                matches('FirebaseCoreWeb.registerWith'),
                matches('FirebaseDatabaseWeb.registerWith'),
                matches('FirebaseStorageWeb.registerWith'),
                matches('UrlLauncherPlugin.registerWith'),
              ])),
        ]),
      ]).validate();
    });
  });

  group('deprecated Firebase project template', () {
    setUpAll(() async {
      await (await projectCreator())
          .buildFlutterProjectTemplate(firebaseStyle: FirebaseStyle.deprecated);
    });

    test('project directory is created', () async {
      await d.dir('project_templates', [
        d.dir('null-safe', [
          d.dir('firebase_deprecated_project'),
        ]),
      ]).validate();
    });

    test('Flutter Web directories are created', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('firebase_deprecated_project', [
          d.dir('lib'),
          d.dir('web', [d.file('index.html', isEmpty)]),
        ])
      ]).validate();
    });

    test('pubspec is created', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('firebase_deprecated_project', [
          d.file(
              'pubspec.yaml',
              allOf([
                matches("sdk: '>=2.14.0 <3.0.0'"),
                matches('meta: 1.7.0'),
                matches('sdk: flutter'),
              ])),
        ]),
      ]).validate();
    });

    test('pub get creates pubspec.lock', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('firebase_deprecated_project',
            [d.file('pubspec.lock', isNotEmpty)]),
      ]).validate();
    });

    test('flutter lints are enabled', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('firebase_deprecated_project', [
          d.file('analysis_options.yaml',
              matches('include: package:flutter_lints/flutter.yaml')),
        ]),
      ]).validate();
    });

    test('plugins are registered', () async {
      await d.dir('project_templates/null-safe', [
        d.dir('firebase_deprecated_project/lib', [
          d.file(
              'generated_plugin_registrant.dart',
              allOf([
                isNot(matches('FirebaseFirestoreWeb.registerWith')),
                isNot(matches('FirebaseFunctionsWeb.registerWith')),
                isNot(matches('FirebaseFunctionsWeb.registerWith')),
                isNot(matches('FirebaseAuthWeb.registerWith')),
                matches('FirebaseCoreWeb.registerWith'),
                isNot(matches('FirebaseDatabaseWeb.registerWith')),
                isNot(matches('FirebaseStorageWeb.registerWith')),
                matches('UrlLauncherPlugin.registerWith'),
              ])),
        ]),
      ]).validate();
    });
  });
}
