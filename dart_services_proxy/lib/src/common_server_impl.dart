// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:protobuf/protobuf.dart';
import 'package:uri/uri.dart' as uri;
import 'protos/dart_services.pb.dart' as proto;
import 'common_server_api.dart' show JSON_CONTENT_TYPE;

class CommonServerImpl {
  CommonServerImpl({@required this.api});
  final Uri api;

  Future<proto.AnalysisResults> analyze(proto.SourceRequest request) =>
      _processRequest(
          path: '/api/dartservices/v2/analyze',
          request: request,
          responseBase: proto.AnalysisResults.create());

  Future<proto.CompileResponse> compile(proto.CompileRequest request) =>
      _processRequest(
          path: '/api/dartservices/v2/compile',
          request: request,
          responseBase: proto.CompileResponse.create());

  Future<proto.CompileDDCResponse> compileDDC(
          proto.CompileDDCRequest request) =>
      _processRequest(
          path: '/api/dartservices/v2/compileDDC',
          request: request,
          responseBase: proto.CompileDDCResponse.create());

  Future<proto.CompleteResponse> complete(proto.SourceRequest request) =>
      _processRequest(
          path: '/api/dartservices/v2/complete',
          request: request,
          responseBase: proto.CompleteResponse.create());

  Future<proto.FixesResponse> fixes(proto.SourceRequest request) =>
      _processRequest(
          path: '/api/dartservices/v2/fixes',
          request: request,
          responseBase: proto.FixesResponse.create());

  Future<proto.AssistsResponse> assists(proto.SourceRequest request) =>
      _processRequest(
          path: '/api/dartservices/v2/assists',
          request: request,
          responseBase: proto.AssistsResponse.create());

  Future<proto.FormatResponse> format(proto.SourceRequest request) =>
      _processRequest(
          path: '/api/dartservices/v2/format',
          request: request,
          responseBase: proto.FormatResponse.create());

  Future<proto.DocumentResponse> document(proto.SourceRequest request) =>
      _processRequest(
          path: '/api/dartservices/v2/document',
          request: request,
          responseBase: proto.DocumentResponse.create());

  Future<proto.VersionResponse> version(proto.VersionRequest request) =>
      _processRequest(
          path: '/api/dartservices/v2/version',
          request: request,
          responseBase: proto.VersionResponse.create());

  Future<O>
      _processRequest<I extends GeneratedMessage, O extends GeneratedMessage>({
    @required String path,
    @required I request,
    @required O responseBase,
  }) async {
    var builder = uri.UriBuilder.fromUri(api)..path = path;
    var response = await http.post(
      builder.build(),
      headers: {'Content-Type': JSON_CONTENT_TYPE},
      body: json.encode(request.toProto3Json()),
    );
    if (response.statusCode == HttpStatus.ok) {
      return responseBase..mergeFromProto3Json(json.decode(response.body));
    } else {
      try {
        var badRequest = proto.BadRequest.create()
          ..mergeFromBuffer(json.decode(response.body));
        throw BadRequest(badRequest.error.message);
      } catch (_) {
        throw BadRequest(response.body);
      }
    }
  }
}

class BadRequest {
  BadRequest(this.cause);
  final String cause;
}
