// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_web_ui/ui.dart' as ui show Image, ImageByteFormat;

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web/services.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web_test/flutter_web_test.dart';

class TestImage implements ui.Image {
  TestImage(this.scale);
  final double scale;

  @override
  int get width => (48 * scale).floor();

  @override
  int get height => (48 * scale).floor();

  @override
  void dispose() {}

  @override
  Future<ByteData> toByteData(
      {ui.ImageByteFormat format = ui.ImageByteFormat.rawRgba}) async {
    throw UnsupportedError('Cannot encode test image');
  }
}

class TestByteData implements ByteData {
  TestByteData(this.scale);
  final double scale;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

const String testManifest = '''
{
  "assets/image.png" : [
    "assets/image.png",
    "assets/1.5x/image.png",
    "assets/2.0x/image.png",
    "assets/3.0x/image.png",
    "assets/4.0x/image.png"
  ]
}
''';

class TestAssetBundle extends CachingAssetBundle {
  TestAssetBundle({this.manifest = testManifest});

  final String manifest;

  @override
  Future<ByteData> load(String key) {
    ByteData data;
    switch (key) {
      case 'assets/image.png':
        data = TestByteData(1.0);
        break;
      case 'assets/1.0x/image.png':
        data =
            TestByteData(10.0); // see "...with a main asset and a 1.0x asset"
        break;
      case 'assets/1.5x/image.png':
        data = TestByteData(1.5);
        break;
      case 'assets/2.0x/image.png':
        data = TestByteData(2.0);
        break;
      case 'assets/3.0x/image.png':
        data = TestByteData(3.0);
        break;
      case 'assets/4.0x/image.png':
        data = TestByteData(4.0);
        break;
    }
    return SynchronousFuture<ByteData>(data);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    if (key == 'AssetManifest.json') return SynchronousFuture<String>(manifest);
    return null;
  }

  @override
  String toString() => '${describeIdentity(this)}()';
}

class FakeImageStreamCompleter extends ImageStreamCompleter {
  FakeImageStreamCompleter(Future<ImageInfo> image) {
    image.then<void>(setImage);
  }
}

class TestAssetImage extends AssetImage {
  TestAssetImage(String name) : super(name);

  @override
  ImageStreamCompleter load(AssetBundleImageKey key) {
    ImageInfo imageInfo;
    key.bundle.load(key.name).then<void>((ByteData data) {
      final TestByteData testData = data;
      final ui.Image image = TestImage(testData.scale);
      imageInfo = ImageInfo(image: image, scale: key.scale);
    });
    assert(imageInfo != null);
    return FakeImageStreamCompleter(SynchronousFuture<ImageInfo>(imageInfo));
  }
}

Widget buildImageAtRatio(String image, Key key, double ratio, bool inferSize,
    [AssetBundle bundle]) {
  const double windowSize = 500.0; // 500 logical pixels
  const double imageSize = 200.0; // 200 logical pixels

  return MediaQuery(
      data: MediaQueryData(
          size: const Size(windowSize, windowSize),
          devicePixelRatio: ratio,
          padding: const EdgeInsets.all(0.0)),
      child: DefaultAssetBundle(
          bundle: bundle ?? TestAssetBundle(),
          child: Center(
              child: inferSize
                  ? Image(
                      key: key,
                      excludeFromSemantics: true,
                      image: TestAssetImage(image))
                  : Image(
                      key: key,
                      excludeFromSemantics: true,
                      image: TestAssetImage(image),
                      height: imageSize,
                      width: imageSize,
                      fit: BoxFit.fill))));
}

RenderImage getRenderImage(WidgetTester tester, Key key) {
  return tester.renderObject<RenderImage>(find.byKey(key));
}

TestImage getTestImage(WidgetTester tester, Key key) {
  return tester.renderObject<RenderImage>(find.byKey(key)).image;
}

Future<void> pumpTreeToLayout(WidgetTester tester, Widget widget) {
  const Duration pumpDuration = Duration(milliseconds: 0);
  const EnginePhase pumpPhase = EnginePhase.layout;
  return tester.pumpWidget(widget, pumpDuration, pumpPhase);
}

void main() {
  const String image = 'assets/image.png';

  testWidgets('Image for device pixel ratio 1.0', (WidgetTester tester) async {
    const double ratio = 1.0;
    Key key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, false));
    expect(getRenderImage(tester, key).size, const Size(200.0, 200.0));
    expect(getTestImage(tester, key).scale, 1.0);
    key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, true));
    expect(getRenderImage(tester, key).size, const Size(48.0, 48.0));
    expect(getTestImage(tester, key).scale, 1.0);
  });

  testWidgets('Image for device pixel ratio 0.5', (WidgetTester tester) async {
    const double ratio = 0.5;
    Key key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, false));
    expect(getRenderImage(tester, key).size, const Size(200.0, 200.0));
    expect(getTestImage(tester, key).scale, 1.0);
    key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, true));
    expect(getRenderImage(tester, key).size, const Size(48.0, 48.0));
    expect(getTestImage(tester, key).scale, 1.0);
  });

  testWidgets('Image for device pixel ratio 1.5', (WidgetTester tester) async {
    const double ratio = 1.5;
    Key key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, false));
    expect(getRenderImage(tester, key).size, const Size(200.0, 200.0));
    expect(getTestImage(tester, key).scale, 1.5);
    key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, true));
    expect(getRenderImage(tester, key).size, const Size(48.0, 48.0));
    expect(getTestImage(tester, key).scale, 1.5);
  });

  testWidgets('Image for device pixel ratio 1.75', (WidgetTester tester) async {
    const double ratio = 1.75;
    Key key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, false));
    expect(getRenderImage(tester, key).size, const Size(200.0, 200.0));
    expect(getTestImage(tester, key).scale, 1.5);
    key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, true));
    expect(getRenderImage(tester, key).size, const Size(48.0, 48.0));
    expect(getTestImage(tester, key).scale, 1.5);
  });

  testWidgets('Image for device pixel ratio 2.3', (WidgetTester tester) async {
    const double ratio = 2.3;
    Key key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, false));
    expect(getRenderImage(tester, key).size, const Size(200.0, 200.0));
    expect(getTestImage(tester, key).scale, 2.0);
    key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, true));
    expect(getRenderImage(tester, key).size, const Size(48.0, 48.0));
    expect(getTestImage(tester, key).scale, 2.0);
  });

  testWidgets('Image for device pixel ratio 3.7', (WidgetTester tester) async {
    const double ratio = 3.7;
    Key key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, false));
    expect(getRenderImage(tester, key).size, const Size(200.0, 200.0));
    expect(getTestImage(tester, key).scale, 4.0);
    key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, true));
    expect(getRenderImage(tester, key).size, const Size(48.0, 48.0));
    expect(getTestImage(tester, key).scale, 4.0);
  });

  testWidgets('Image for device pixel ratio 5.1', (WidgetTester tester) async {
    const double ratio = 5.1;
    Key key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, false));
    expect(getRenderImage(tester, key).size, const Size(200.0, 200.0));
    expect(getTestImage(tester, key).scale, 4.0);
    key = GlobalKey();
    await pumpTreeToLayout(tester, buildImageAtRatio(image, key, ratio, true));
    expect(getRenderImage(tester, key).size, const Size(48.0, 48.0));
    expect(getTestImage(tester, key).scale, 4.0);
  });

  testWidgets('Image for device pixel ratio 1.0, with no main asset',
      (WidgetTester tester) async {
    const String manifest = '''
    {
      "assets/image.png" : [
        "assets/1.5x/image.png",
        "assets/2.0x/image.png",
        "assets/3.0x/image.png",
        "assets/4.0x/image.png"
      ]
    }
    ''';
    final AssetBundle bundle = TestAssetBundle(manifest: manifest);

    const double ratio = 1.0;
    Key key = GlobalKey();
    await pumpTreeToLayout(
        tester, buildImageAtRatio(image, key, ratio, false, bundle));
    expect(getRenderImage(tester, key).size, const Size(200.0, 200.0));
    expect(getTestImage(tester, key).scale, 1.5);
    key = GlobalKey();
    await pumpTreeToLayout(
        tester, buildImageAtRatio(image, key, ratio, true, bundle));
    expect(getRenderImage(tester, key).size, const Size(48.0, 48.0));
    expect(getTestImage(tester, key).scale, 1.5);
  });

  testWidgets(
      'Image for device pixel ratio 1.0, with a main asset and a 1.0x asset',
      (WidgetTester tester) async {
    // If both a main asset and a 1.0x asset are specified, then prefer
    // the 1.0x asset.

    const String manifest = '''
    {
      "assets/image.png" : [
        "assets/image.png",
        "assets/1.0x/image.png",
        "assets/1.5x/image.png",
        "assets/2.0x/image.png",
        "assets/3.0x/image.png",
        "assets/4.0x/image.png"
      ]
    }
    ''';
    final AssetBundle bundle = TestAssetBundle(manifest: manifest);

    const double ratio = 1.0;
    Key key = GlobalKey();
    await pumpTreeToLayout(
        tester, buildImageAtRatio(image, key, ratio, false, bundle));
    expect(getRenderImage(tester, key).size, const Size(200.0, 200.0));
    expect(getTestImage(tester, key).scale, 10.0);
    key = GlobalKey();
    await pumpTreeToLayout(
        tester, buildImageAtRatio(image, key, ratio, true, bundle));
    expect(getRenderImage(tester, key).size, const Size(480.0, 480.0));
    expect(getTestImage(tester, key).scale, 10.0);
  });
}
