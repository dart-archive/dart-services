// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services_server.apitest;

import 'dart:convert';
import 'dart:html';
import 'package:codemirror/codemirror.dart';
import 'services_utils.dart' as utils;

utils.SanitizingBrowserClient client;

void main() {
  setupAnalyze();
  setupCompile();
  setupComplete();
  setupDocument();
  setupFixes();
  setupVersion();
}

void _setupClients() {
  client = utils.SanitizingBrowserClient();
}

void setupAnalyze() {
  final editor = createEditor(querySelector('#analyzeSection .editor'));
  final output = querySelector('#analyzeSection .output');
  final button = querySelector('#analyzeSection button') as ButtonElement;
  button.onClick.listen((e) {
    _setupClients();
    final source = {'source': editor.getDoc().getValue()};
    final sw = Stopwatch()..start();
    client
        .post(
          '${_uriBase}/dartservices/v2/analyze',
          encoding: utf8,
          body: json.encode(source),
        )
        .then(
            (response) => output.text = '${_formatTiming(sw)}${response.body}');
  });
}

void setupCompile() {
  final editor = createEditor(querySelector('#compileSection .editor'));
  final output = querySelector('#compileSection .output');
  final button = querySelector('#compileSection button') as ButtonElement;
  button.onClick.listen((e) {
    final source = editor.getDoc().getValue();

    _setupClients();
    final compile = {'source': source};
    final sw = Stopwatch()..start();
    client
        .post(
          '${_uriBase}/dartservices/v2/compile',
          encoding: utf8,
          body: json.encode(compile),
        )
        .then(
            (response) => output.text = '${_formatTiming(sw)}${response.body}');
  });
}

void setupComplete() {
  final editor = createEditor(querySelector('#completeSection .editor'));
  final output = querySelector('#completeSection .output');
  final offsetElement = querySelector('#completeSection .offset');
  final button = querySelector('#completeSection button') as ButtonElement;
  button.onClick.listen((e) {
    final source = _getSourceRequest(editor);
    final sw = Stopwatch()..start();
    client
        .post(
          '$_uriBase/dartservices/v2/complete',
          encoding: utf8,
          body: json.encode(source),
        )
        .then(
            (response) => output.text = '${_formatTiming(sw)}${response.body}');
  });
  offsetElement.text = 'offset ${_getOffset(editor)}';
  editor.onCursorActivity.listen((_) {
    offsetElement.text = 'offset ${_getOffset(editor)}';
  });
}

void setupDocument() {
  final editor = createEditor(querySelector('#documentSection .editor'));
  final output = querySelector('#documentSection .output');
  final offsetElement = querySelector('#documentSection .offset');
  final button = querySelector('#documentSection button') as ButtonElement;
  button.onClick.listen((e) {
    final source = _getSourceRequest(editor);
    final sw = Stopwatch()..start();
    client
        .post(
          '$_uriBase/dartservices/v2/document',
          encoding: utf8,
          body: json.encode(source),
        )
        .then(
            (response) => output.text = '${_formatTiming(sw)}${response.body}');
  });
  offsetElement.text = 'offset ${_getOffset(editor)}';
  editor.onCursorActivity.listen((_) {
    offsetElement.text = 'offset ${_getOffset(editor)}';
  });
}

void setupFixes() {
  final editor = createEditor(querySelector('#fixesSection .editor'));
  final output = querySelector('#fixesSection .output');
  final offsetElement = querySelector('#fixesSection .offset');
  final button = querySelector('#fixesSection button') as ButtonElement;
  button.onClick.listen((e) {
    final source = _getSourceRequest(editor);
    final sw = Stopwatch()..start();
    client
        .post(
          '$_uriBase/dartservices/v2/fixes',
          encoding: utf8,
          body: json.encode(source),
        )
        .then(
            (response) => output.text = '${_formatTiming(sw)}${response.body}');
  });
  offsetElement.text = 'offset ${_getOffset(editor)}';

  editor.onCursorActivity.listen((_) {
    offsetElement.text = 'offset ${_getOffset(editor)}';
  });
}

void setupVersion() {
  final output = querySelector('#versionSection .output');
  final button = querySelector('#versionSection button') as ButtonElement;
  button.onClick.listen((e) {
    final sw = Stopwatch()..start();
    client.get('$_uriBase/dartservices/v2/version').then(
        (response) => output.text = '${_formatTiming(sw)}${response.body}');
  });
}

CodeMirror createEditor(Element element, {String defaultText}) {
  final options = {
    'tabSize': 2,
    'indentUnit': 2,
    'autoCloseBrackets': true,
    'matchBrackets': true,
    'theme': 'zenburn',
    'mode': 'dart',
    'value': _text ?? defaultText
  };

  final editor = CodeMirror.fromElement(element, options: options);
  editor.refresh();
  return editor;
}

String _formatTiming(Stopwatch sw) => '${sw.elapsedMilliseconds}ms\n';

String get _uriBase =>
    (querySelector('input[type=text]') as InputElement).value;

int _getOffset(CodeMirror editor) {
  final pos = editor.getDoc().getCursor();
  return editor.getDoc().indexFromPos(pos);
}

Map<String, dynamic> _getSourceRequest(CodeMirror editor) => {
      'source': editor.getDoc().getValue(),
      'offset': _getOffset(editor),
    };

final String _text = r'''
void main() {
  for (int i = 0; i < 4; i++) {
    print('hello ${i}');
  }
}
''';
