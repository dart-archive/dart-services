// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:appengine/appengine.dart' as ae;
import 'db_server.dart';
import 'dart:convert';
import 'package:http_server/http_server.dart';
import 'package:logging/logging.dart';
import 'package:rpc/rpc.dart';

final ApiServer _apiServer = new ApiServer(prettyPrint: true);

// Create a virtual directory used to serve our client code from
// the 'build/web' directory.
final String _buildPath =
    Platform.script.resolve('../build/web/').toFilePath();
final VirtualDirectory _clientDir = new VirtualDirectory(_buildPath);

main(List<String> args) async {
  if (args.contains('--discovery')) {
    generateDiscovery().then((doc) {
      print(doc);
      exit(0);
    });
    return;
  }
  // Add a bit of logging...
  Logger.root..level = Level.INFO
             ..onRecord.listen(print);

  // Set up a server serving the pirate API.
  _apiServer.addApi(new dbServer());
  ae.runAppEngine(requestHandler);
}

requestHandler(HttpRequest request) {
  request.response.headers.add('Access-Control-Allow-Methods',
      'POST, DELETE');
  request.response.headers.add('Access-Control-Allow-Headers',
      'Origin, X-Requested-With, Content-Type, Accept');
  var apiRequest = new HttpApiRequest.fromHttpRequest(request);
  _apiServer.handleHttpApiRequest(apiRequest)
    .then((HttpApiResponse apiResponse) {
      return sendApiResponse(apiResponse, request.response);
  }).catchError((e) {
      request.response..statusCode = HttpStatus.INTERNAL_SERVER_ERROR
                    ..close();
      });
}

Future<String> generateDiscovery() async {
   var dbserver = new dbServer();
   var apiServer =
       new ApiServer(apiPrefix: '/api', prettyPrint: true)..addApi(dbserver);
   apiServer.enableDiscoveryApi();

   var uri = Uri.parse("/api/discovery/v1/apis/dbservices/v1/rest");

   var request =
       new HttpApiRequest('GET',
                          uri,
                          {}, new Stream.fromIterable([]));
   HttpApiResponse response = await apiServer.handleHttpApiRequest(request);
   return UTF8.decode(await response.body.first);
 }