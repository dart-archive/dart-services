// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// All classes exported over the RPC protocol.
library services.api_classes;

import 'dart:convert';

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
