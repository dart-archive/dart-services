// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_ui/ui.dart' as ui;

import 'main.dart' as app;

void main() {
  ui.persistedPictureFactory = ui.houdiniPictureFactory;
  app.main();
}
