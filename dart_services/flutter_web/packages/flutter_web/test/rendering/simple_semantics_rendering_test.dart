// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import '../flutter_test_alternative.dart';

import 'rendering_tester.dart';


void main() {
  test('only send semantics update if semantics have changed', () {
    final TestRender testRender = TestRender()
      ..label = 'hello'
      ..textDirection = TextDirection.ltr;

    final RenderObject tree = RenderConstrainedBox(
      additionalConstraints: const BoxConstraints.tightFor(height: 20.0, width: 20.0),
      child: testRender,
    );
    int semanticsUpdateCount = 0;
    final SemanticsHandle semanticsHandle = renderer.pipelineOwner.ensureSemantics(
        listener: () {
          ++semanticsUpdateCount;
        }
    );

    layout(tree, phase: EnginePhase.flushSemantics);

    // Initial render does semantics.
    expect(semanticsUpdateCount, 1);
    expect(testRender.describeSemanticsConfigurationCallCount, isPositive);

    testRender.describeSemanticsConfigurationCallCount = 0;
    semanticsUpdateCount = 0;

    // Request semantics update even though nothing changed.
    testRender.markNeedsSemanticsUpdate();
    pumpFrame(phase: EnginePhase.flushSemantics);

    // Object is asked for semantics, but no update is sent.
    expect(semanticsUpdateCount, 0);
    expect(testRender.describeSemanticsConfigurationCallCount, isPositive);

    testRender.describeSemanticsConfigurationCallCount = 0;
    semanticsUpdateCount = 0;

    // Change semantics and request update.
    testRender.label = 'bye';
    testRender.markNeedsSemanticsUpdate();
    pumpFrame(phase: EnginePhase.flushSemantics);

    // Object is asked for semantics, and update is sent.
    expect(semanticsUpdateCount, 1);
    expect(testRender.describeSemanticsConfigurationCallCount, isPositive);

    semanticsHandle.dispose();
  });
}

class TestRender extends RenderSemanticsAnnotations {
  int describeSemanticsConfigurationCallCount = 0;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    describeSemanticsConfigurationCallCount += 1;
  }
}
