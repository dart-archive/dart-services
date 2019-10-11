// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data' show Uint8List;

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web/painting.dart';

import 'image_data.dart';
import 'painting_utils.dart';

void main() {
  final PaintingBindingSpy binding = PaintingBindingSpy();

  test('instantiateImageCodec used for loading images', () async {
    expect(binding.instantiateImageCodecCalledCount, 0);

    final Uint8List bytes = Uint8List.fromList(kTransparentImage);
    final MemoryImage memoryImage = MemoryImage(bytes);
    memoryImage.load(memoryImage);
    expect(binding.instantiateImageCodecCalledCount, 1);
  });
}
