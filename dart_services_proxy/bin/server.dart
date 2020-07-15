// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:dart_services_proxy/dart_services_proxy.dart';

const _hostname = '0.0.0.0';

void main(List<String> args) async {
  var parser = ArgParser()..addOption('port', abbr: 'p');
  var result = parser.parse(args);

  var portStr = result['port'] ?? Platform.environment['PORT'] ?? '8080';
  var port = int.tryParse(portStr);

  var api = CommonServerApi(CommonServerImpl(
      api: Uri.parse(
          'https://dart-service-cloud-run-hdjctvyqtq-uc.a.run.app/')));

  if (port == null) {
    stdout.writeln('Could not parse port value "$portStr" into a number.');
    exitCode = 64;
    return;
  }

  var handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(createCorsHeadersMiddleware(corsHeaders: <String, String>{
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers':
            'Origin, X-Requested-With, Content-Type, Accept, x-goog-api-client'
      }))
      .addHandler(api.router.handler);

  var server = await io.serve(handler, _hostname, port);
  print('Serving at http://${server.address.host}:${server.port}');
}
