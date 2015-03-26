// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services_gae;

import 'dart:async';
import 'dart:io' as io;
import 'dart:convert' as convert;

import 'package:appengine/appengine.dart' as ae;
import 'package:cli_util/cli_util.dart';
import 'package:gcloud/db.dart' as db;
import 'package:logging/logging.dart';
import 'package:memcache/memcache.dart';
import 'package:rpc/rpc.dart' as rpc;

import 'src/common_server.dart';
import 'src/sharded_counter.dart' as counter;

const String _API = '/api';

final Logger _logger = new Logger('gae_server');

void main(List<String> args) {
  io.Directory sdkDir = getSdkDir(args);

  if (sdkDir == null) {
    throw 'No Dart SDk available; set the DART_SDK env variable or pass '
        '--dart-sdk on the command line.';
  }

  GaeServer server = new GaeServer(sdkDir.path);

  // Change the log level to get more or less detailed logging.
  ae.useLoggingPackageAdaptor();
  //useLoggingPackageAdaptor();
  server.start();
}

class GaeServer {
  final String sdkPath;

  bool discoveryEnabled;
  rpc.ApiServer apiServer;
  CommonServer commonServer;

  GaeServer(this.sdkPath) {
    hierarchicalLoggingEnabled = true;
    _logger.level = Level.ALL;

    discoveryEnabled = false;
    commonServer = new CommonServer(
        sdkPath,
        new GaeCache(),
        new GaeSourceRequestRecorder(),
        new GaeCounter());
    // Enabled pretty printing of returned json for debuggability.
    apiServer =
        new rpc.ApiServer(_API, prettyPrint: true)..addApi(commonServer);
  }

  Future start() => ae.runAppEngine(requestHandler);

  void requestHandler(io.HttpRequest request) {
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Credentials', 'true');
    request.response.headers.add('Access-Control-Allow-Methods',
        'POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept');

    // Explicitly handle an OPTIONS requests.
    if (request.method == 'OPTIONS') {
      var requestedMethod =
        request.headers.value('access-control-request-method');
      var statusCode;
      if (requestedMethod != null && requestedMethod.toUpperCase() == 'POST') {
        statusCode = io.HttpStatus.OK;
      } else {
        statusCode = io.HttpStatus.BAD_REQUEST;
      }
      request.response..statusCode = statusCode
                      ..close();
      return;
    }

    if (request.uri.path.startsWith(_API)) {
      if (!discoveryEnabled) {
        apiServer.enableDiscoveryApi(request.requestedUri.origin);
        discoveryEnabled = true;
      }
      // NOTE: We could read in the request body here and parse it similar to
      // the _parseRequest method to determine content-type and dispatch to e.g.
      // a plain text handler if we want to support that.
      var apiRequest = new rpc.HttpApiRequest.fromHttpRequest(request, _API);
      apiServer.handleHttpApiRequest(apiRequest)
        .then((rpc.HttpApiResponse apiResponse) {
          return rpc.sendApiResponse(apiResponse, request.response);
      }).catchError((e) {
          // This should only happen in the case where there is a bug in the
          // rpc package. Otherwise it always returns an HttpApiResponse.
          _logger.warning('Failed with error: $e when trying to call'
            'method at \'${request.uri.path}\'.');
          request.response..statusCode = io.HttpStatus.INTERNAL_SERVER_ERROR
                        ..close();
          });
    } else {
      request.response..statusCode = io.HttpStatus.INTERNAL_SERVER_ERROR
                       ..close();
    }
  }
}

class GaeCache implements ServerCache {
  Memcache get _memcache => ae.context.services.memcache;

  Future<String> get(String key) => _memcache.get(key);

  Future set(String key, String value, {Duration expiration}) {
    return _memcache.set(key, value, expiration: expiration);
  }

  Future remove(String key) => _memcache.remove(key);
}

class GaeSourceRequestRecorder implements SourceRequestRecorder {
  @override
  Future record(String verb, String source, [int offset = -99]) {
    int ms = new DateTime.now().millisecondsSinceEpoch;
    GaeSourceRecordBlob record = new GaeSourceRecordBlob.FromData(
        ms, verb, source, offset);

    return db.dbService.commit(inserts: [record]);
  }
}

class GaeCounter implements PersistentCounter {
  @override
  Future<int> getTotal(String name) {
    return counter.Counter.getTotal(name);
  }

  @override
  Future increment(String name, {int increment : 1}) {
    return counter.Counter.increment(name, increment: increment);
  }
}

/*
 * This is the schema for source code storage
 */
@db.Kind()
class GaeSourceRecordBlob extends db.Model {
  @db.StringProperty()
  String verb;

  @db.BlobProperty()
  List<int> source;

  @db.IntProperty()
  int offset;

  @db.IntProperty()
  int epochTime;

  GaeSourceRecordBlob();

  GaeSourceRecordBlob.FromData(
      int epochTime, String verb, String source, int offset) {
    this.epochTime = epochTime;
    this.verb = verb;
    this.source = io.GZIP.encode(convert.UTF8.encode(source));
    this.offset = offset;
  }
}
