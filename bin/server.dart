// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// To meet GAE needs this file must be called 'server.dart'.

library appengine.services.bin;

import 'dart:async';

import 'package:dart_services/services_gae.dart' as server;

Future<void> main(List<String> args) async {
  server.main(args);
}
