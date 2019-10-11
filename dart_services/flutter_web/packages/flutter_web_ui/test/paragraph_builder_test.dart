// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_ui/ui.dart';

import 'package:test/test.dart';

void main() {
  test('Should be able to build and layout a paragraph', () {
    final ParagraphBuilder builder = ParagraphBuilder(ParagraphStyle());
    builder.addText('Hello');
    final Paragraph paragraph = builder.build();
    expect(paragraph, isNotNull);

    paragraph.layout(const ParagraphConstraints(width: 800.0));
    expect(paragraph.width, isNonZero);
    expect(paragraph.height, isNonZero);
  });

  test('PushStyle should not segfault after build()', () {
    final ParagraphBuilder paragraphBuilder =
        ParagraphBuilder(ParagraphStyle());
    paragraphBuilder.build();
    paragraphBuilder.pushStyle(TextStyle());
  });
}
