// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.all_test;

import 'analysis_server_test.dart' as analysis_server_test;
import 'api_classes_test.dart' as api_classes_test;
import 'bench_test.dart' as bench_test;
import 'common_server_test.dart' as common_server_test;
import 'common_test.dart' as common_test;
import 'compiler_test.dart' as compiler_test;
import 'dartpad_server_test.dart' as dartpad_server_test;
import 'flutter_web_test.dart' as flutter_web_test;
import 'gae_deployed_test.dart' as gae_deployed_test;
import 'pub_test.dart' as pub_test;
import 'shelf_cors_test.dart' as shelf_cors_test;
import 'summarize_test.dart' as summarize_test;

void main() async {
  analysis_server_test.defineTests();
  api_classes_test.defineTests();
  bench_test.defineTests();
  common_server_test.defineTests();
  common_test.defineTests();
  compiler_test.defineTests();
  dartpad_server_test.defineTests();
  flutter_web_test.defineTests();
  gae_deployed_test.defineTests();
  pub_test.defineTests();
  shelf_cors_test.defineTests();
  summarize_test.defineTests();
}
