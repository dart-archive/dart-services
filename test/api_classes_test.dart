// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.api_classes_test;

import 'package:dart_services/src/protos/dart_services.pb.dart' as proto;
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  group('AnalysisIssue', () {
    test('toMap', () {
      final issue = proto.AnalysisIssue()
        ..kind = 'error'
        ..line = 1
        ..message = 'not found'
        ..charStart = 123;
      final m = issue.toProto3Json() as Map<String, dynamic>;
      expect(m['kind'], 'error');
      expect(m['line'], 1);
      expect(m['message'], isNotNull);
      expect(m['charStart'], isNotNull);
      expect(m['charLength'], isNull);
    });

    test('toString', () {
      final issue = proto.AnalysisIssue()
        ..kind = 'error'
        ..line = 1
        ..message = 'not found';
      expect(issue.toString(), isNotNull);
    });
  });
}
