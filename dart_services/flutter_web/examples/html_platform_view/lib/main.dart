// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:flutter_web_ui/ui.dart' as ui;

import 'package:flutter_web/material.dart';

void main() {
  ui.platformViewRegistry.registerViewFactory(
      'hello-world-html',
      (int viewId) => IFrameElement()
        ..width = '640'
        ..height = '360'
        ..src = 'https://www.youtube.com/embed/IyFZznAk69U'
        ..style.border = 'none');

  runApp(Directionality(
    textDirection: TextDirection.ltr,
    child: SizedBox(
      width: 640,
      height: 360,
      child: HtmlElementView(viewType: 'hello-world-html'),
    ),
  ));
}
