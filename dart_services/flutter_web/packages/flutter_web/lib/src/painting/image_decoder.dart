// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_web_ui/ui.dart' as ui show Codec, FrameInfo, Image;

import 'binding.dart';

/// Creates an image from a list of bytes.
///
/// This function attempts to interpret the given bytes an image. If successful,
/// the returned [Future] resolves to the decoded image. Otherwise, the [Future]
/// resolves to null.
///
/// If the image is animated, this returns the first frame. Consider
/// [instantiateImageCodec] if support for animated images is necessary.
///
/// This function differs from [ui.decodeImageFromList] in that it defers to
/// [PaintingBinding.instantiateImageCodec], and therefore can be mocked in
/// tests.
Future<ui.Image> decodeImageFromList(Uint8List bytes) async {
  final ui.Codec codec = await PaintingBinding.instance.instantiateImageCodec(bytes);
  final ui.FrameInfo frameInfo = await codec.getNextFrame();
  return frameInfo.image;
}
