// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import '../flutter_test_alternative.dart';

import 'rendering_tester.dart';

class TestTree {
  TestTree() {
    // incoming constraints are tight 800x600
    root = RenderPositionedBox(
      child: RenderConstrainedBox(
        additionalConstraints: const BoxConstraints.tightFor(width: 800.0),
        // Place the child to be evaluated within both a repaint boundary and a
        // layout-root element (in this case a tightly constrained box). Otherwise
        // the act of transplanting the root into a new container will cause the
        // relayout/repaint of the new parent node to satisfy the test.
        child: RenderRepaintBoundary(
          child: RenderConstrainedBox(
            additionalConstraints: const BoxConstraints.tightFor(height: 20.0, width: 20.0),
            child: RenderRepaintBoundary(
              child: RenderCustomPaint(
                painter: TestCallbackPainter(
                  onPaint: () { painted = true; },
                ),
                child: RenderPositionedBox(
                  child: child = RenderConstrainedBox(
                    additionalConstraints: const BoxConstraints.tightFor(height: 20.0, width: 20.0),
                    child: RenderSemanticsAnnotations(label: 'Hello there foo', textDirection: TextDirection.ltr)
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  RenderObject root;
  RenderConstrainedBox child;
  bool painted = false;
}

class MutableCompositor extends RenderProxyBox {
  MutableCompositor({ RenderBox child }) : super(child);
  bool _alwaysComposite = false;
  @override
  bool get alwaysNeedsCompositing => _alwaysComposite;
}

class TestCompositingBitsTree {
  TestCompositingBitsTree() {
    // incoming constraints are tight 800x600
    root = RenderPositionedBox(
      child: RenderConstrainedBox(
        additionalConstraints: const BoxConstraints.tightFor(width: 800.0),
        // Place the child to be evaluated within a repaint boundary. Otherwise
        // the act of transplanting the root into a new container will cause the
        // repaint of the new parent node to satisfy the test.
        child: RenderRepaintBoundary(
          child: compositor = MutableCompositor(
            child: RenderCustomPaint(
              painter: TestCallbackPainter(
                onPaint: () { painted = true; },
              ),
              child: child = RenderConstrainedBox(
                additionalConstraints: const BoxConstraints.tightFor(height: 20.0, width: 20.0)
              ),
            ),
          ),
        ),
      ),
    );
  }
  RenderObject root;
  MutableCompositor compositor;
  RenderConstrainedBox child;
  bool painted = false;
}

void main() {
  test('objects can be detached and re-attached: layout', () {
    final TestTree testTree = TestTree();
    // Lay out
    layout(testTree.root, phase: EnginePhase.layout);
    expect(testTree.child.size, equals(const Size(20.0, 20.0)));
    // Remove testTree from the custom render view
    renderer.renderView.child = null;
    expect(testTree.child.owner, isNull);
    // Dirty one of the elements
    testTree.child.additionalConstraints =
      const BoxConstraints.tightFor(height: 5.0, width: 5.0);
    // Lay out again
    layout(testTree.root, phase: EnginePhase.layout);
    expect(testTree.child.size, equals(const Size(5.0, 5.0)));
  });
  test('objects can be detached and re-attached: compositingBits', () {
    final TestCompositingBitsTree testTree = TestCompositingBitsTree();
    // Lay out, composite, and paint
    layout(testTree.root, phase: EnginePhase.paint);
    expect(testTree.painted, isTrue);
    // Remove testTree from the custom render view
    renderer.renderView.child = null;
    expect(testTree.child.owner, isNull);
    // Dirty one of the elements
    testTree.compositor._alwaysComposite = true;
    testTree.child.markNeedsCompositingBitsUpdate();
    testTree.painted = false;
    // Lay out, composite, and paint again
    layout(testTree.root, phase: EnginePhase.paint);
    expect(testTree.painted, isTrue);
  });
  test('objects can be detached and re-attached: paint', () {
    final TestTree testTree = TestTree();
    // Lay out, composite, and paint
    layout(testTree.root, phase: EnginePhase.paint);
    expect(testTree.painted, isTrue);
    // Remove testTree from the custom render view
    renderer.renderView.child = null;
    expect(testTree.child.owner, isNull);
    // Dirty one of the elements
    testTree.child.markNeedsPaint();
    testTree.painted = false;
    // Lay out, composite, and paint again
    layout(testTree.root, phase: EnginePhase.paint);
    expect(testTree.painted, isTrue);
  });

  test('objects can be detached and re-attached: semantics (no change)', () {
    final TestTree testTree = TestTree();
    int semanticsUpdateCount = 0;
    final SemanticsHandle semanticsHandle = renderer.pipelineOwner.ensureSemantics(
      listener: () {
        ++semanticsUpdateCount;
      }
    );
    // Lay out, composite, paint, and update semantics
    layout(testTree.root, phase: EnginePhase.flushSemantics);
    expect(semanticsUpdateCount, 1);
    // Remove testTree from the custom render view
    renderer.renderView.child = null;
    expect(testTree.child.owner, isNull);
    // Dirty one of the elements
    semanticsUpdateCount = 0;
    testTree.child.markNeedsSemanticsUpdate();
    expect(semanticsUpdateCount, 0);
    // Lay out, composite, paint, and update semantics again
    layout(testTree.root, phase: EnginePhase.flushSemantics);
    expect(semanticsUpdateCount, 0); // no semantics have changed.
    semanticsHandle.dispose();
  });
  test('objects can be detached and re-attached: semantics (with change)', () {
    final TestTree testTree = TestTree();
    int semanticsUpdateCount = 0;
    final SemanticsHandle semanticsHandle = renderer.pipelineOwner.ensureSemantics(
        listener: () {
          ++semanticsUpdateCount;
        }
    );
    // Lay out, composite, paint, and update semantics
    layout(testTree.root, phase: EnginePhase.flushSemantics);
    expect(semanticsUpdateCount, 1);
    // Remove testTree from the custom render view
    renderer.renderView.child = null;
    expect(testTree.child.owner, isNull);
    // Dirty one of the elements
    semanticsUpdateCount = 0;
    testTree.child.additionalConstraints = const BoxConstraints.tightFor(height: 20.0, width: 30.0);
    testTree.child.markNeedsSemanticsUpdate();
    expect(semanticsUpdateCount, 0);
    // Lay out, composite, paint, and update semantics again
    layout(testTree.root, phase: EnginePhase.flushSemantics);
    expect(semanticsUpdateCount, 1); // semantics have changed.
    semanticsHandle.dispose();
  });
}
