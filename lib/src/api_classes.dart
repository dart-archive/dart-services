// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// All classes exported over the RPC protocol.
library services.api_classes;

import 'dart:convert';


class AnalysisResults {
  final List<AnalysisIssue> issues;

  final List<String> packageImports;

  AnalysisResults(this.issues, this.packageImports);
}

class AnalysisIssue implements Comparable<AnalysisIssue> {
  final String kind;
  final int line;
  final String message;
  final String sourceName;

  final bool hasFixes;

  final int charStart;
  final int charLength;

  AnalysisIssue.fromIssue(this.kind, this.line, this.message,
      {this.charStart,
      this.charLength,
      this.sourceName,
      this.hasFixes = false});

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{'kind': kind, 'line': line, 'message': message};
    if (charStart != null) m['charStart'] = charStart;
    if (charLength != null) m['charLength'] = charLength;
    if (hasFixes != null) m['hasFixes'] = hasFixes;
    if (sourceName != null) m['sourceName'] = sourceName;

    return m;
  }

  @override
  int compareTo(AnalysisIssue other) => line - other.line;

  @override
  String toString() => '$kind: $message [$line]';
}

class SourceRequest {
  String source;

  int offset;
}

class SourcesRequest {
  Map<String, String> sources;

  Location location;

  @deprecated
  bool strongMode;
}

class Location {
  String sourceName;
  int offset;

  Location();

  Location.from(this.sourceName, this.offset);
}

class CompileRequest {
  String source;

  bool returnSourceMap;
}

class CompileResponse {
  final String result;
  final String sourceMap;

  CompileResponse(this.result, [this.sourceMap]);
}

class CompileDDCRequest {
  String source;
}

class CompileDDCResponse {
  final String result;
  final String modulesBaseUrl;

  CompileDDCResponse(this.result, this.modulesBaseUrl);
}

class CounterRequest {
  String name;
}

class CounterResponse {
  final int count;

  CounterResponse(this.count);
}

class DocumentResponse {
  final Map<String, String> info;

  DocumentResponse(this.info);
}

class CompleteResponse {
  final int replacementOffset;

  final int replacementLength;

  final List<Map<String, String>> completions;

  CompleteResponse(this.replacementOffset, this.replacementLength,
      List<Map<dynamic, dynamic>> completions)
      : completions = _convert(completions);

  /// Convert any non-string values from the contained maps.
  static List<Map<String, String>> _convert(List<Map<dynamic, dynamic>> list) {
    return list.map<Map<String, String>>((Map<dynamic, dynamic> m) {
      final newMap = <String, String>{};
      for (final key in m.keys.cast<String>()) {
        dynamic data = m[key];
        // TODO: Properly support Lists, Maps (this is a hack).
        if (data is Map || data is List) {
          data = json.encode(data);
        }
        newMap[key.toString()] = '$data';
      }
      return newMap;
    }).toList();
  }
}

class FixesResponse {
  final List<ProblemAndFixes> fixes;

  FixesResponse(this.fixes);
}

/// Represents a problem detected during analysis, and a set of possible
/// ways of resolving the problem.
class ProblemAndFixes {
  // TODO(lukechurch): consider consolidating this with [AnalysisIssue]
  final List<CandidateFix> fixes;
  final String problemMessage;
  final int offset;
  final int length;

  ProblemAndFixes() : this.fromList(<CandidateFix>[]);

  ProblemAndFixes.fromList(
      [this.fixes, this.problemMessage, this.offset, this.length]);
}

class LinkedEditSuggestion {
  final String value;

  final String kind;

  LinkedEditSuggestion(this.value, this.kind);
}

class LinkedEditGroup {
  final List<int> positions;

  final int length;

  final List<LinkedEditSuggestion> suggestions;

  LinkedEditGroup(this.positions, this.length, this.suggestions);
}

/// Represents a possible way of solving an Analysis Problem.
class CandidateFix {
  final String message;
  final List<SourceEdit> edits;
  final int selectionOffset;
  final List<LinkedEditGroup> linkedEditGroups;

  CandidateFix() : this.fromEdits();

  CandidateFix.fromEdits([
    this.message,
    this.edits,
    this.selectionOffset,
    this.linkedEditGroups,
  ]);
}

/// Represents a reformatting of the code.
class FormatResponse {
  final String newString;

  final int offset;

  FormatResponse(this.newString, [this.offset = 0]);
}

/// Represents a single edit-point change to a source file.
class SourceEdit {
  final int offset;
  final int length;
  final String replacement;

  SourceEdit() : this.fromChanges();

  SourceEdit.fromChanges([this.offset, this.length, this.replacement]);

  String applyTo(String target) {
    if (offset >= replacement.length) {
      throw 'Offset beyond end of string';
    } else if (offset + length >= replacement.length) {
      throw 'Change beyond end of string';
    }

    final pre = '${target.substring(0, offset)}';
    final post = '${target.substring(offset + length)}';
    return '$pre$replacement$post';
  }
}

/// The response from the `/assists` service call.
class AssistsResponse {
  final List<CandidateFix> assists;

  AssistsResponse(this.assists);
}

/// The response from the `/version` service call.
class VersionResponse {
  final String sdkVersion;

  final String sdkVersionFull;

  final String runtimeVersion;

  final String appEngineVersion;

  final String servicesVersion;

  final String flutterVersion;

  final String flutterDartVersion;

  final String flutterDartVersionFull;

  VersionResponse(
      {this.sdkVersion,
      this.sdkVersionFull,
      this.runtimeVersion,
      this.appEngineVersion,
      this.servicesVersion,
      this.flutterDartVersion,
      this.flutterDartVersionFull,
      this.flutterVersion});
}
