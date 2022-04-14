// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.compiler_test;

import 'dart:convert' show json;
import 'dart:io';

import 'package:dart_services/src/common.dart';
import 'package:dart_services/src/compiler.dart';
import 'package:dart_services/src/sdk.dart';
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  late Compiler compiler;

  Future<void> Function() generateCompilerDDCTest(String sample) => () async {
        final result = await compiler.compileDDC(sample);
        expect(result.problems, isEmpty);
        expect(result.success, true);
        expect(result.compiledJS, isNotEmpty);
        expect(result.modulesBaseUrl, isNotEmpty);

        expect(result.compiledJS, contains("define('dartpad_main', ["));
      };

  for (final nullSafety in [false, true]) {
    group('Null ${nullSafety ? 'Safe' : 'Unsafe'} Compiler', () {
      setUpAll(() async {
        final channel =
            Platform.environment['FLUTTER_CHANNEL'] ?? stableChannel;
        compiler = Compiler(Sdk.create(channel));
        await compiler.warmup();
      });

      tearDownAll(() async {
        await compiler.dispose();
      });

      test('simple', () async {
        final result = await compiler.compile(sampleCode);

        expect(result.problems, isEmpty);
        expect(result.success, true);
        expect(result.compiledJS, isNotEmpty);
        expect(result.sourceMap, isNull);
      });

      test(
        'compileDDC simple',
        generateCompilerDDCTest(sampleCode),
      );

      test(
        'compileDDC with web',
        generateCompilerDDCTest(sampleCodeWeb),
      );

      test(
        'compileDDC with Flutter',
        generateCompilerDDCTest(sampleCodeFlutter),
      );

      test(
        'compileDDC with Flutter Counter',
        generateCompilerDDCTest(sampleCodeFlutterCounter),
      );

      test(
        'compileDDC with Flutter Sunflower',
        generateCompilerDDCTest(sampleCodeFlutterSunflower),
      );

      test(
        'compileDDC with Flutter Draggable Card',
        generateCompilerDDCTest(sampleCodeFlutterDraggableCard),
      );

      test(
        'compileDDC with Flutter Implicit Animations',
        generateCompilerDDCTest(sampleCodeFlutterImplicitAnimations),
      );

      test(
        'compileDDC with async',
        generateCompilerDDCTest(sampleCodeAsync),
      );

      test('compileDDC with single error', () async {
        final result = await compiler.compileDDC(sampleCodeError);
        expect(result.success, false);
        expect(result.problems.length, 1);
        expect(result.problems[0].toString(),
            contains('Error: Expected \';\' after this.'));
      });

      test('compileDDC with multiple errors', () async {
        final result = await compiler.compileDDC(sampleCodeErrors);
        expect(result.success, false);
        expect(result.problems.length, 1);
        expect(result.problems[0].toString(),
            contains('Error: Method not found: \'print1\'.'));
        expect(result.problems[0].toString(),
            contains('Error: Method not found: \'print2\'.'));
        expect(result.problems[0].toString(),
            contains('Error: Method not found: \'print3\'.'));
      });

      test('sourcemap', () async {
        final result =
            await compiler.compile(sampleCode, returnSourceMap: true);
        expect(result.success, true);
        expect(result.compiledJS, isNotEmpty);
        expect(result.sourceMap, isNotNull);
        expect(result.sourceMap, isNotEmpty);
      });

      test('version', () async {
        final result =
            await compiler.compile(sampleCode, returnSourceMap: true);
        expect(result.sourceMap, isNotNull);
        expect(result.sourceMap, isNotEmpty);
      });

      test('simple web', () async {
        final result = await compiler.compile(sampleCodeWeb);
        expect(result.success, true);
      });

      test('web async', () async {
        final result = await compiler.compile(sampleCodeAsync);
        expect(result.success, true);
      });

      test('errors', () async {
        final result = await compiler.compile(sampleCodeError);
        expect(result.success, false);
        expect(result.problems.length, 1);
        expect(result.problems[0].toString(), contains('Error: Expected'));
      });

      test('good import', () async {
        const code = '''
import 'dart:html';

void main() {
  var count = querySelector('#count');
  print('hello');
}

''';
        final result = await compiler.compile(code);
        expect(result.problems.length, 0);
      });

      test('bad import - local', () async {
        const code = '''
import 'foo.dart';
void main() { missingMethod ('foo'); }
''';
        final result = await compiler.compile(code);
        expect(result.problems, hasLength(1));
        expect(result.problems.single.message,
            equals('unsupported import: foo.dart'));
      });

      test('bad import - http', () async {
        const code = '''
import 'http://example.com';
void main() { missingMethod ('foo'); }
''';
        final result = await compiler.compile(code);
        expect(result.problems, hasLength(1));
        expect(result.problems.single.message,
            equals('unsupported import: http://example.com'));
      });

      test('multiple bad imports', () async {
        const code = '''
import 'package:foo';
import 'package:bar';
''';
        final result = await compiler.compile(code);
        expect(result.problems, hasLength(2));
        expect(result.problems[0].message,
            equals('unsupported import: package:foo'));
        expect(result.problems[1].message,
            equals('unsupported import: package:bar'));
      });

      test('disallow compiler warnings', () async {
        final result = await compiler.compile(sampleCodeErrors);
        expect(result.success, false);
      });

      test('transitive errors', () async {
        const code = '''
import 'dart:foo';
void main() { print ('foo'); }
''';
        final result = await compiler.compile(code);
        expect(result.problems.length, 1);
      });
    });

    group('Null ${nullSafety ? 'Safe' : 'Unsafe'} Compiler  files={} multifile',
        () {
      //-----------------------------------------------------------
      // Now test multi file 'files:{}' source format
      final Map<String, String> files = {};
      final Map<String, dynamic> filesinfo = {};
      const kMainDart = 'main.dart';

      files[kMainDart] = sampleCode;
      filesinfo['files'] = files;
      filesinfo['active_source_name'] = kMainDart;
      String filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC simple',
        generateCompilerDDCTest(filesInfoJson),
      );

      files[kMainDart] = sampleCodeWeb;
      filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC with web',
        generateCompilerDDCTest(filesInfoJson),
      );

      // try not using 'main.dart' filename, should be handled OK
      files.clear();
      files['mymainthing.dart'] = sampleCodeFlutter;
      filesinfo['active_source_name'] = 'mymainthing.dart';
      filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC with Flutter',
        generateCompilerDDCTest(filesInfoJson),
      );

      // filename other than 'main.dart'
      files.clear();
      files['different.dart'] = sampleCodeFlutterCounter;
      filesinfo['active_source_name'] = 'different.dart';
      filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC with Flutter Counter',
        generateCompilerDDCTest(filesInfoJson),
      );

      // 2 separate files, main importing various
      files.clear();
      files[kMainDart] = sampleCodeFlutterImplicitAnimationsImports +
          "\nimport 'various.dart';\n" +
          sampleCodeFlutterImplicitAnimationsMain;
      files['various.dart'] = sampleCodeFlutterImplicitAnimationsImports +
          sampleCodeFlutterImplicitAnimationsDiscData +
          sampleCodeFlutterImplicitAnimationsVarious;
      filesinfo['active_source_name'] = kMainDart;
      filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC with 2 file',
        generateCompilerDDCTest(filesInfoJson),
      );

      // 2 separate filesm main importing various but with
      //    up paths in names... test sanitizing filenames of '..\.../..' and '..'
      //    santizing should strip off all up dir chars and leave just the plain filenames
      files.clear();
      files['..\\.../../' + kMainDart] =
          sampleCodeFlutterImplicitAnimationsImports +
              "\nimport 'various.dart';\n" +
              sampleCodeFlutterImplicitAnimationsMain;
      files['../various.dart'] = sampleCodeFlutterImplicitAnimationsImports +
          sampleCodeFlutterImplicitAnimationsDiscData +
          sampleCodeFlutterImplicitAnimationsVarious;
      filesinfo['active_source_name'] = kMainDart;
      filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC with 2 files and file names sanitized',
        generateCompilerDDCTest(filesInfoJson),
      );

      // Using "part 'various.dart'" to bring in second file
      files.clear();
      files[kMainDart] = 'library testanim;\n' +
          sampleCodeFlutterImplicitAnimationsImports +
          "\npart 'various.dart';\n\n" +
          sampleCodeFlutterImplicitAnimationsMain;
      files['various.dart'] = 'part of testanim;\n' +
          sampleCodeFlutterImplicitAnimationsDiscData +
          sampleCodeFlutterImplicitAnimationsVarious;
      filesinfo['active_source_name'] = kMainDart;
      filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC with 2 file using LIBRARY/PART/PART OF',
        generateCompilerDDCTest(filesInfoJson),
      );

      // Using "part 'various.dart'" and "part 'discdata.dart'" to bring in second/third file
      files.clear();
      files[kMainDart] = 'library testanim;\n' +
          sampleCodeFlutterImplicitAnimationsImports +
          "\npart 'discdart.dart';\npart 'various.dart';\n" +
          sampleCodeFlutterImplicitAnimationsMain;
      files['discdart.dart'] =
          'part of testanim;\n' + sampleCodeFlutterImplicitAnimationsDiscData;
      files['various.dart'] =
          'part of testanim;\n' + sampleCodeFlutterImplicitAnimationsVarious;
      filesinfo['active_source_name'] = kMainDart;
      filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC with 3 files using LIBRARY/PART/PART OF',
        generateCompilerDDCTest(filesInfoJson),
      );

      // Check sanitizing of package:, dart:, http:// from filenames
      files.clear();
      files['package:' + kMainDart] = 'library testanim;\n' +
          sampleCodeFlutterImplicitAnimationsImports +
          "\npart 'discdart.dart';\npart 'various.dart';\n" +
          sampleCodeFlutterImplicitAnimationsMain;
      files['dart:discdart.dart'] =
          'part of testanim;\n' + sampleCodeFlutterImplicitAnimationsDiscData;
      files['http://various.dart'] =
          'part of testanim;\n' + sampleCodeFlutterImplicitAnimationsVarious;
      filesinfo['active_source_name'] =
          'package:' + kMainDart; // check that this gets sanitized also
      filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC with 3 SANITIZED files using LIBRARY/PART/PART OF',
        generateCompilerDDCTest(filesInfoJson),
      );

      // test renaming the file with the main function ('mymain.dart') to be kMainDart if none found
      files.clear();
      files['discdart.dart'] =
          'part of testanim;\n' + sampleCodeFlutterImplicitAnimationsDiscData;
      files['various.dart'] =
          'part of testanim;\n' + sampleCodeFlutterImplicitAnimationsVarious;
      files['mymain.dart'] = 'library testanim;\n' +
          sampleCodeFlutterImplicitAnimationsImports +
          "\npart 'discdart.dart';\npart 'various.dart';\n" +
          sampleCodeFlutterImplicitAnimationsMain;
      filesinfo['active_source_name'] = 'mymain.dart';
      filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC with 3 files and none named kMainDart',
        generateCompilerDDCTest(filesInfoJson),
      );

      // make the 'active_source_name' entry be the first one in the fileinfo json
      final Map<String, dynamic> filesinfoActiveSourceFirst = {};
      filesinfoActiveSourceFirst['active_source_name'] = kMainDart;
      files.clear();
      files[kMainDart] = sampleCode;
      filesinfoActiveSourceFirst['files'] = files;
      filesInfoJson = json.encode(filesinfo);
      test(
        'files:{} compileDDC "active_source_name" first - simple',
        generateCompilerDDCTest(filesInfoJson),
      );

      // Two separate files, illegal import in second file
      //  test that illegal imports on all files are detected
      files.clear();
      const String badImports = '''
                            import 'package:foo';
                            import 'package:bar';
                            ''';
      files[kMainDart] = sampleCodeFlutterImplicitAnimationsImports +
          "\nimport 'various.dart';\n" +
          sampleCodeFlutterImplicitAnimationsMain;
      files['various.dart'] = sampleCodeFlutterImplicitAnimationsImports +
          badImports +
          sampleCodeFlutterImplicitAnimationsDiscData +
          sampleCodeFlutterImplicitAnimationsVarious;
      filesinfo['active_source_name'] = kMainDart;
      filesInfoJson = json.encode(filesinfo);
      test('multiple files, second file with multiple bad imports compile',
          () async {
        final result = await compiler.compile(filesInfoJson);
        expect(result.problems, hasLength(2));
        expect(result.problems[0].message,
            equals('unsupported import: package:foo'));
        expect(result.problems[1].message,
            equals('unsupported import: package:bar'));
      });
      test('multiple files, second file with multiple bad imports compileDDC()',
          () async {
        final result = await compiler.compileDDC(filesInfoJson);
        expect(result.problems, hasLength(2));
        expect(result.problems[0].message,
            equals('unsupported import: package:foo'));
        expect(result.problems[1].message,
            equals('unsupported import: package:bar'));
      });
    });
  }
}

/// Code fragments for testing multi file compiling
///  these are just taken from [sampleCodeFlutterImplicitAnimations] but
///  re-arranged to facilitate testing

const sampleCodeFlutterImplicitAnimationsImports = r'''
import 'dart:math';
import 'package:flutter/material.dart';
''';

const sampleCodeFlutterImplicitAnimationsMain = r'''


void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: const Color(0xFF15202D),
          child: const SizedBox.expand(
            child: VariousDiscs(50),
          ),
        ),
      ),
    ),
  );
}
''';

const sampleCodeFlutterImplicitAnimationsDiscData = r'''

class DiscData {
  static final _rng = Random();

  final double size;
  final Color color;
  final Alignment alignment;

  DiscData()
      : size = _rng.nextDouble() * 40 + 10,
        color = Color.fromARGB(
          _rng.nextInt(200),
          _rng.nextInt(255),
          _rng.nextInt(255),
          _rng.nextInt(255),
        ),
        alignment = Alignment(
          _rng.nextDouble() * 2 - 1,
          _rng.nextDouble() * 2 - 1,
        );
}
''';

const sampleCodeFlutterImplicitAnimationsVarious = r'''

class VariousDiscs extends StatefulWidget {
  final int numberOfDiscs;

  const VariousDiscs(this.numberOfDiscs);

  @override
  _VariousDiscsState createState() => _VariousDiscsState();
}

class _VariousDiscsState extends State<VariousDiscs> {
  final _discs = <DiscData>[];

  @override
  void initState() {
    super.initState();
    _makeDiscs();
  }

  void _makeDiscs() {
    _discs.clear();
    for (int i = 0; i < widget.numberOfDiscs; i++) {
      _discs.add(DiscData());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _makeDiscs();
      }),
      child: Stack(
        children: [
          const Center(
            child: Text(
              'Click a disc!',
              style: TextStyle(color: Colors.white, fontSize: 50),
            ),
          ),
          for (final disc in _discs)
            Positioned.fill(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: disc.alignment,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    color: disc.color,
                    shape: BoxShape.circle,
                  ),
                  height: disc.size,
                  width: disc.size,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
''';
