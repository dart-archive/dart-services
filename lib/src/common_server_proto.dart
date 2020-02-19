// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.common_server_proto;

import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'api_classes.dart' as api;
import 'common_server_impl.dart' show CommonServerImpl;
export 'common_server_impl.dart' show log, ServerContainer;
import 'protos/dart_services.pb.dart' as proto;

part 'common_server_proto.g.dart'; // generated with 'pub run build_runner build'

const PROTOBUF_MIME_TYPE = 'application/x-protobuf';
const JSON_MIME_TYPE = 'application/json';
const String PROTO_API_URL_PREFIX = '/api2';

typedef Responder = Future<Response> Function(Request request);

class CommonServerProto {
  final CommonServerImpl _impl;

  CommonServerProto(this._impl);

  @Route.post('$PROTO_API_URL_PREFIX/analyze')
  Future<Response> analyze(Request request) async {
    if (request.mimeType == PROTOBUF_MIME_TYPE) {
      final body = <int>[];
      await for (final chunk in request.read()) {
        body.addAll(chunk);
      }
      final response = await _analyze(proto.SourceRequest.fromBuffer(body));
      return Response.ok(
        response.writeToBuffer(),
        headers: {'Content-Type': PROTOBUF_MIME_TYPE},
      );
    } else {
      // Assume JSON proto3 format
      final body = await request.readAsString();
      final response = await _analyze(proto.SourceRequest.fromJson(body));
      return Response.ok(
        response.writeToJson(),
        encoding: utf8,
        headers: {'Content-Type': JSON_MIME_TYPE},
      );
    }
  }

  Future<proto.AnalyzeReply> _analyze(proto.SourceRequest request) async {
    final apiRequest = api.SourceRequest()
      ..source = request.source.source
      ..offset = request.source.offset;
    final apiResponse = await _impl.analyze(apiRequest);

    return proto.AnalyzeReply()
      ..packageImports.addAll(apiResponse.packageImports)
      ..issues.addAll(
        apiResponse.issues.map(
          (issue) => proto.AnalysisIssue()
            ..kind = issue.kind
            ..line = issue.line
            ..message = issue.message
            ..sourceName = issue.sourceName
            ..hasFixes = issue.hasFixes
            ..charStart = issue.charStart
            ..charLength = issue.charLength,
        ),
      );
  }

  @Route.post('$PROTO_API_URL_PREFIX/compile')
  Future<Response> compile(Request request) async {
    if (request.mimeType == PROTOBUF_MIME_TYPE) {
      final body = <int>[];
      await for (final chunk in request.read()) {
        body.addAll(chunk);
      }
      final response = await _compile(proto.CompileRequest.fromBuffer(body));
      return Response.ok(
        response.writeToBuffer(),
        headers: {'Content-Type': PROTOBUF_MIME_TYPE},
      );
    } else {
      // Assume JSON proto3 format
      final body = await request.readAsString();
      final response = await _compile(proto.CompileRequest.fromJson(body));
      return Response.ok(
        response.writeToJson(),
        encoding: utf8,
        headers: {'Content-Type': JSON_MIME_TYPE},
      );
    }
  }

  Future<proto.CompileResponse> _compile(proto.CompileRequest request) async {
    final apiRequest = api.CompileRequest()
      ..source = request.compile.source
      ..returnSourceMap = request.compile.returnSourceMap;
    final apiResponse = await _impl.compile(apiRequest);

    return proto.CompileResponse()
      ..result = apiResponse.result
      ..sourceMap = apiResponse.sourceMap;
  }

  @Route.post('$PROTO_API_URL_PREFIX/compileDDC')
  Future<Response> compileDDC(Request request) async {
    if (request.mimeType == PROTOBUF_MIME_TYPE) {
      final body = <int>[];
      await for (final chunk in request.read()) {
        body.addAll(chunk);
      }
      final response = await _compileDDC(proto.CompileRequest.fromBuffer(body));
      return Response.ok(
        response.writeToBuffer(),
        headers: {'Content-Type': PROTOBUF_MIME_TYPE},
      );
    } else {
      // Assume JSON proto3 format
      final body = await request.readAsString();
      final response = await _compileDDC(proto.CompileRequest.fromJson(body));
      return Response.ok(
        response.writeToJson(),
        encoding: utf8,
        headers: {'Content-Type': JSON_MIME_TYPE},
      );
    }
  }

  Future<proto.CompileDDCResponse> _compileDDC(
      proto.CompileRequest request) async {
    final apiRequest = api.CompileRequest()
      ..source = request.compile.source
      ..returnSourceMap = request.compile.returnSourceMap;
    final apiResponse = await _impl.compileDDC(apiRequest);

    return proto.CompileDDCResponse()
      ..result = apiResponse.result
      ..modulesBaseUrl = apiResponse.modulesBaseUrl;
  }

  @Route.post('$PROTO_API_URL_PREFIX/complete')
  Future<Response> complete(Request request) async {
    if (request.mimeType == PROTOBUF_MIME_TYPE) {
      final body = <int>[];
      await for (final chunk in request.read()) {
        body.addAll(chunk);
      }
      final response = await _complete(proto.SourceRequest.fromBuffer(body));
      return Response.ok(
        response.writeToBuffer(),
        headers: {'Content-Type': PROTOBUF_MIME_TYPE},
      );
    } else {
      // Assume JSON proto3 format
      final body = await request.readAsString();
      final response = await _complete(proto.SourceRequest.fromJson(body));
      return Response.ok(
        response.writeToJson(),
        encoding: utf8,
        headers: {'Content-Type': JSON_MIME_TYPE},
      );
    }
  }

  Future<proto.CompleteResponse> _complete(proto.SourceRequest request) async {
    final apiRequest = api.SourceRequest()
      ..offset = request.source.offset
      ..source = request.source.source;
    final apiResponse = await _impl.complete(apiRequest);

    return proto.CompleteResponse()
      ..replacementOffset = apiResponse.replacementOffset
      ..replacementLength = apiResponse.replacementLength
      ..completions.addAll(
        apiResponse.completions.map(
          (completion) => proto.Completion()..completion.addAll(completion),
        ),
      );
  }

  @Route.post('$PROTO_API_URL_PREFIX/fixes')
  Future<Response> fixes(Request request) async {
    if (request.mimeType == PROTOBUF_MIME_TYPE) {
      final body = <int>[];
      await for (final chunk in request.read()) {
        body.addAll(chunk);
      }
      final response = await _fixes(proto.SourceRequest.fromBuffer(body));
      return Response.ok(
        response.writeToBuffer(),
        headers: {'Content-Type': PROTOBUF_MIME_TYPE},
      );
    } else {
      // Assume JSON proto3 format
      final body = await request.readAsString();
      final response = await _fixes(proto.SourceRequest.fromJson(body));
      return Response.ok(
        response.writeToJson(),
        encoding: utf8,
        headers: {'Content-Type': JSON_MIME_TYPE},
      );
    }
  }

  Future<proto.FixesResponse> _fixes(proto.SourceRequest request) async {
    final apiRequest = api.SourceRequest()
      ..offset = request.source.offset
      ..source = request.source.source;
    final apiResponse = await _impl.fixes(apiRequest);

    return proto.FixesResponse()
      ..fixes.addAll(
        apiResponse.fixes.map(
          (apiFix) => proto.ProblemAndFixes()
            ..problemMessage = apiFix.problemMessage
            ..offset = apiFix.offset
            ..length = apiFix.length
            ..fixes.addAll(
              apiFix.fixes.map(
                (apiCandidateFix) => proto.CandidateFix()
                  ..message = apiCandidateFix.message
                  ..selectionOffset = apiCandidateFix.selectionOffset
                  ..linkedEditGroups.addAll(
                    apiCandidateFix.linkedEditGroups.map(
                      (group) => proto.LinkedEditGroup()
                        ..positions.addAll(group.positions)
                        ..length = group.length
                        ..suggestions.addAll(
                          group.suggestions.map(
                            (suggestion) => proto.LinkedEditSuggestion()
                              ..value = suggestion.value
                              ..kind = suggestion.kind,
                          ),
                        ),
                    ),
                  ),
              ),
            ),
        ),
      );
  }

  @Route.post('$PROTO_API_URL_PREFIX/assists')
  Future<Response> assists(Request request) async {
    if (request.mimeType == PROTOBUF_MIME_TYPE) {
      final body = <int>[];
      await for (final chunk in request.read()) {
        body.addAll(chunk);
      }
      final response = await _assists(proto.SourceRequest.fromBuffer(body));
      return Response.ok(
        response.writeToBuffer(),
        headers: {'Content-Type': PROTOBUF_MIME_TYPE},
      );
    } else {
      // Assume JSON proto3 format
      final body = await request.readAsString();
      final response = await _assists(proto.SourceRequest.fromJson(body));
      return Response.ok(
        response.writeToJson(),
        encoding: utf8,
        headers: {'Content-Type': JSON_MIME_TYPE},
      );
    }
  }

  Future<proto.AssistsResponse> _assists(proto.SourceRequest request) async {
    final apiRequest = api.SourceRequest()
      ..offset = request.source.offset
      ..source = request.source.source;
    final apiResponse = await _impl.assists(apiRequest);

    return proto.AssistsResponse()
      ..assists.addAll(
        apiResponse.assists.map(
          (candidateFix) => proto.CandidateFix()
            ..message = candidateFix.message
            ..edits.addAll(
              candidateFix.edits.map(
                (edit) => proto.SourceEdit()
                  ..offset = edit.offset
                  ..length = edit.length
                  ..replacement = edit.replacement,
              ),
            )
            ..selectionOffset = candidateFix.selectionOffset
            ..linkedEditGroups.addAll(
              candidateFix.linkedEditGroups.map(
                (group) => proto.LinkedEditGroup()
                  ..positions.addAll(group.positions)
                  ..length = group.length
                  ..suggestions.addAll(
                    group.suggestions.map(
                      (suggestion) => proto.LinkedEditSuggestion()
                        ..value = suggestion.value
                        ..kind = suggestion.kind,
                    ),
                  ),
              ),
            ),
        ),
      );
  }

  @Route.post('$PROTO_API_URL_PREFIX/format')
  Future<Response> format(Request request) async {
    if (request.mimeType == PROTOBUF_MIME_TYPE) {
      final body = <int>[];
      await for (final chunk in request.read()) {
        body.addAll(chunk);
      }
      final response = await _format(proto.SourceRequest.fromBuffer(body));
      return Response.ok(
        response.writeToBuffer(),
        headers: {'Content-Type': PROTOBUF_MIME_TYPE},
      );
    } else {
      // Assume JSON proto3 format
      final body = await request.readAsString();
      final response = await _format(proto.SourceRequest.fromJson(body));
      return Response.ok(
        response.writeToJson(),
        encoding: utf8,
        headers: {'Content-Type': JSON_MIME_TYPE},
      );
    }
  }

  Future<proto.FormatResponse> _format(proto.SourceRequest request) async {
    final apiRequest = api.SourceRequest()
      ..offset = request.source.offset
      ..source = request.source.source;
    final apiResponse = await _impl.format(apiRequest);

    return proto.FormatResponse()
      ..newString = apiResponse.newString
      ..offset = apiResponse.offset;
  }

  @Route.post('$PROTO_API_URL_PREFIX/document')
  Future<Response> document(Request request) async {
    if (request.mimeType == PROTOBUF_MIME_TYPE) {
      final body = <int>[];
      await for (final chunk in request.read()) {
        body.addAll(chunk);
      }
      final response = await _document(proto.SourceRequest.fromBuffer(body));
      return Response.ok(
        response.writeToBuffer(),
        headers: {'Content-Type': PROTOBUF_MIME_TYPE},
      );
    } else {
      // Assume JSON proto3 format
      final body = await request.readAsString();
      final response = await _document(proto.SourceRequest.fromJson(body));
      return Response.ok(
        response.writeToJson(),
        encoding: utf8,
        headers: {'Content-Type': JSON_MIME_TYPE},
      );
    }
  }

  Future<proto.DocumentResponse> _document(proto.SourceRequest request) async {
    final apiRequest = api.SourceRequest()
      ..offset = request.source.offset
      ..source = request.source.source;
    final apiResponse = await _impl.document(apiRequest);

    return proto.DocumentResponse()..info.addAll(apiResponse.info);
  }

  @Route.post('$PROTO_API_URL_PREFIX/version')
  Future<Response> version(Request request) async {
    if (request.mimeType == PROTOBUF_MIME_TYPE) {
      final body = <int>[];
      await for (final chunk in request.read()) {
        body.addAll(chunk);
      }
      final response = await _version(proto.VersionRequest.fromBuffer(body));
      return Response.ok(
        response.writeToBuffer(),
        headers: {'Content-Type': PROTOBUF_MIME_TYPE},
      );
    } else {
      // Assume JSON proto3 format
      final body = await request.readAsString();
      final response = await _version(proto.VersionRequest.fromJson(body));
      return Response.ok(
        response.writeToJson(),
        encoding: utf8,
        headers: {'Content-Type': JSON_MIME_TYPE},
      );
    }
  }

  Future<proto.VersionResponse> _version(proto.VersionRequest request) async {
    final apiResponse = await _impl.version();

    return proto.VersionResponse()
      ..sdkVersion = apiResponse.sdkVersion
      ..sdkVersionFull = apiResponse.sdkVersionFull
      ..runtimeVersion = apiResponse.runtimeVersion
      ..appEngineVersion = apiResponse.appEngineVersion
      ..servicesVersion = apiResponse.servicesVersion;
  }

  Router get router => _$CommonServerProtoRouter(this);
}
