// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// All classes exported over the RPC protocol.
library services.api_classes;

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
