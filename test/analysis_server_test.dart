// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.analysis_server_test;

import 'package:cli_util/cli_util.dart';
import 'package:services/src/analysis_server.dart';
import 'package:services/src/common.dart';
import 'package:unittest/unittest.dart';

void defineTests() {
  AnalysisServerWrapper analysisServer;

  group('analysis_server', () {
    String sdkPath = getSdkDir().path;

    setUp(() {
      analysisServer = new AnalysisServerWrapper(sdkPath);
    });

    tearDown(() => analysisServer.dispose());

    test('simple', () {
      return analysisServer.codeComplete(sampleCode, 19).then(
          (CompletionResult result) {
        // TODO: verify expected results
        //expect(result.success, true);
      });
    });

    test('simple web', () {
      return analysisServer.codeComplete(sampleCodeWeb, 69).then(
          (CompletionResult result) {
        // TODO: verify expected results
        //expect(result.success, true);
      });
    });
  });
}
