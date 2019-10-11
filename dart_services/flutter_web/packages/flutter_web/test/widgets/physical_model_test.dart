// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

void main() {
  testWidgets('PhysicalModel - creates a physical model layer when it needs compositing', (WidgetTester tester) async {
    debugDisableShadows = false;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(devicePixelRatio: 1.0),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: PhysicalModel(
            shape: BoxShape.rectangle,
            color: Colors.grey,
            shadowColor: Colors.red,
            elevation: 1.0,
            child: Material(child: TextField(controller: TextEditingController())),
          ),
        ),
      ),
    );
    await tester.pump();

    final RenderPhysicalModel renderPhysicalModel = tester.allRenderObjects.firstWhere((RenderObject object) => object is RenderPhysicalModel);
    expect(renderPhysicalModel.needsCompositing, true);

    final PhysicalModelLayer physicalModelLayer = tester.layers.firstWhere((Layer layer) => layer is PhysicalModelLayer);
    expect(physicalModelLayer.shadowColor, Colors.red);
    expect(physicalModelLayer.color, Colors.grey);
    expect(physicalModelLayer.elevation, 1.0);
    debugDisableShadows = true;
  });
}
