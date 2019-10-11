// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_web_ui/ui.dart' as ui show Image, ImageByteFormat;
import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/painting.dart';

class TestImageInfo implements ImageInfo {
  const TestImageInfo(this.value, {this.image, this.scale});

  @override
  final ui.Image image;

  @override
  final double scale;

  final int value;

  @override
  String toString() => '$runtimeType($value)';
}

class TestImageProvider extends ImageProvider<int> {
  const TestImageProvider(this.key, this.imageValue, {this.image});
  final int key;
  final int imageValue;
  final ui.Image image;

  @override
  Future<int> obtainKey(ImageConfiguration configuration) {
    return new Future<int>.value(key);
  }

  @override
  ImageStreamCompleter load(int key) {
    return new OneFrameImageStreamCompleter(new SynchronousFuture<ImageInfo>(
        new TestImageInfo(imageValue, image: image)));
  }

  @override
  String toString() => '$runtimeType($key, $imageValue)';
}

Future<ImageInfo> extractOneFrame(ImageStream stream) {
  final Completer<ImageInfo> completer = new Completer<ImageInfo>();
  void listener(ImageInfo image, bool synchronousCall) {
    completer.complete(image);
    stream.removeListener(listener);
  }

  stream.addListener(listener);
  return completer.future;
}

class TestImage implements ui.Image {
  const TestImage({this.height = 0, this.width = 0});
  @override
  final int height;
  @override
  final int width;

  @override
  void dispose() {}

  @override
  Future<ByteData> toByteData(
      {ui.ImageByteFormat format = ui.ImageByteFormat.rawRgba}) {
    throw UnsupportedError('Not supported in this test');
  }
}
