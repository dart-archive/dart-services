// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.common_server_proto;

import 'dart:async';
import 'dart:convert';

import 'package:protobuf/protobuf.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'api_classes.dart' as api;
import 'common_server_impl.dart' show CommonServerImpl;
export 'common_server_impl.dart' show log, ServerContainer;
import 'protos/dart_services.pb.dart' as proto;

part 'common_server_proto.g.dart'; // generated with 'pub run build_runner build'

const PROTOBUF_CONTENT_TYPE = 'application/x-protobuf';
const JSON_CONTENT_TYPE = 'application/json; charset=utf-8';
const String PROTO_API_URL_PREFIX = '/api/dartservices/v2';

typedef Responder = Future<Response> Function(Request request);

class CommonServerProto {
  final CommonServerImpl _impl;

  CommonServerProto(this._impl);

  @Route.post('$PROTO_API_URL_PREFIX/analyze')
  Future<Response> analyze(Request request) => _serve(
        request,
        (bytes) => _analyze(proto.Source.fromBuffer(bytes)),
        (jsonStr) => _analyze(proto.Source.create()..mergeFromProto3Json(json.decode(jsonStr))),
      );

  Future<proto.AnalyzeReply> _analyze(proto.Source request) async {
    final apiRequest = api.SourceRequest()
      ..source = request.source
      ..offset = request.offset;
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
  Future<Response> compile(Request request) => _serve(
        request,
        (bytes) => _compile(proto.Compile.fromBuffer(bytes)),
        (jsonStr) => _compile(proto.Compile.create()..mergeFromProto3Json(json.decode(jsonStr))),
      );

  Future<proto.CompileResponse> _compile(proto.Compile request) async {
    final apiRequest = api.CompileRequest()
      ..source = request.source
      ..returnSourceMap = request.returnSourceMap;
    final apiResponse = await _impl.compile(apiRequest);
    final response = proto.CompileResponse()..result = apiResponse.result;
    if (apiResponse.sourceMap != null) {
      response.sourceMap = apiResponse.sourceMap;
    }
    return response;
  }

  @Route.post('$PROTO_API_URL_PREFIX/compileDDC')
  Future<Response> compileDDC(Request request) => _serve(
        request,
        (bytes) => _compileDDC(proto.Compile.fromBuffer(bytes)),
        (jsonStr) => _compileDDC(proto.Compile.create()..mergeFromProto3Json(json.decode(jsonStr))),
      );

  Future<proto.CompileDDCResponse> _compileDDC(
      proto.Compile request) async {
    final apiRequest = api.CompileRequest()
      ..source = request.source
      ..returnSourceMap = request.returnSourceMap;
    final apiResponse = await _impl.compileDDC(apiRequest);

    return proto.CompileDDCResponse()
      ..result = apiResponse.result
      ..modulesBaseUrl = apiResponse.modulesBaseUrl;
  }

  @Route.post('$PROTO_API_URL_PREFIX/complete')
  Future<Response> complete(Request request) => _serve(
        request,
        (bytes) => _complete(proto.Source.fromBuffer(bytes)),
        (jsonStr) => _complete(proto.Source.create()..mergeFromProto3Json(json.decode(jsonStr))),
      );

  Future<proto.CompleteResponse> _complete(proto.Source request) async {
    final apiRequest = api.SourceRequest()
      ..offset = request.offset
      ..source = request.source;
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
  Future<Response> fixes(Request request) => _serve(
        request,
        (bytes) => _fixes(proto.Source.fromBuffer(bytes)),
        (jsonStr) => _fixes(proto.Source.create()..mergeFromProto3Json(json.decode(jsonStr))),
      );

  Future<proto.FixesResponse> _fixes(proto.Source request) async {
    final apiRequest = api.SourceRequest()
      ..offset = request.offset
      ..source = request.source;
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
  Future<Response> assists(Request request) => _serve(
        request,
        (bytes) => _assists(proto.Source.fromBuffer(bytes)),
        (jsonStr) => _assists(proto.Source.create()..mergeFromProto3Json(json.decode(jsonStr))),
      );

  Future<proto.AssistsResponse> _assists(proto.Source request) async {
    final apiRequest = api.SourceRequest()
      ..offset = request.offset
      ..source = request.source;
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
  Future<Response> format(Request request) => _serve(
        request,
        (bytes) => _format(proto.Source.fromBuffer(bytes)),
        (jsonStr) => _format(proto.Source.create()..mergeFromProto3Json(json.decode(jsonStr))),
      );

  Future<proto.FormatResponse> _format(proto.Source request) async {
    final apiRequest = api.SourceRequest()
      ..offset = request.offset
      ..source = request.source;
    final apiResponse = await _impl.format(apiRequest);

    return proto.FormatResponse()
      ..newString = apiResponse.newString
      ..offset = apiResponse.offset;
  }

  @Route.post('$PROTO_API_URL_PREFIX/document')
  Future<Response> document(Request request) => _serve(
        request,
        (bytes) => _document(proto.Source.fromBuffer(bytes)),
        (jsonStr) => _document(proto.Source.create()..mergeFromProto3Json(json.decode(jsonStr))),
      );

  Future<proto.DocumentResponse> _document(proto.Source request) async {
    final apiRequest = api.SourceRequest()
      ..offset = request.offset
      ..source = request.source;
    final apiResponse = await _impl.document(apiRequest);

    return proto.DocumentResponse()..info.addAll(apiResponse.info);
  }

  @Route.post('$PROTO_API_URL_PREFIX/version')
  Future<Response> version(Request request) => _serve(
        request,
        (bytes) => _version(proto.VersionRequest.fromBuffer(bytes)),
        (jsonStr) => _version(proto.VersionRequest.create()..mergeFromProto3Json(json.decode(jsonStr))),
      );

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

  Future<Response> _serve<T extends GeneratedMessage>(
      Request request,
      Future<T> Function(List<int> bytes) decodeFromBuffer,
      Future<T> Function(String json) decodeFromString) async {
    if (request.mimeType == PROTOBUF_CONTENT_TYPE) {
      final body = <int>[];
      await for (final chunk in request.read()) {
        body.addAll(chunk);
      }
      final response = await decodeFromBuffer(body);
      return Response.ok(
        response.writeToBuffer(),
        headers: {'Content-Type': PROTOBUF_CONTENT_TYPE},
      );
    } else {
      // Assume JSON proto3 format
      final body = await request.readAsString();
      final response = await decodeFromString(body);
      return Response.ok(
        json.encode(response.toProto3Json()),
        encoding: utf8,
        headers: {'Content-Type': JSON_CONTENT_TYPE},
      );
    }
  }
}
