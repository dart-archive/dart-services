// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of engine;

const String _testFontFamily = 'Ahem';
const String _testFontUrl = 'packages/flutter_web_ui/assets/Ahem.ttf';
const String _robotoFontUrl =
    'packages/flutter_web_ui/assets/Roboto-Regular.ttf';

/// This class is responsible for registering and loading fonts.
///
/// Once an asset manager has been set in the framework, call
/// [registerFonts] with it to register fonts declared in the
/// font manifest. If test fonts are enabled, then call
/// [registerTestFonts] as well.
class FontCollection {
  _FontManager _assetFontManager;
  _FontManager _testFontManager;

  /// Reads the font manifest using the [assetManager] and registers all of the
  /// fonts declared within.
  Future<void> registerFonts(AssetManager assetManager) async {
    ByteData byteData;

    try {
      byteData = await assetManager.load('FontManifest.json');
    } on AssetManagerException catch (e) {
      if (e.httpStatus == 404) {
        html.window.console
            .warn('Font manifest does not exist at `${e.url}` – ignoring.');
        return;
      } else {
        rethrow;
      }
    }

    if (byteData == null) {
      throw AssertionError(
          'There was a problem trying to load FontManifest.json');
    }

    final List<dynamic> fontManifest =
        json.decode(utf8.decode(byteData.buffer.asUint8List()));
    if (fontManifest == null) {
      throw AssertionError(
          'There was a problem trying to load FontManifest.json');
    }

    if (supportsFontLoadingApi) {
      _assetFontManager = _FontManager();
    } else {
      _assetFontManager = _PolyfillFontManager();
    }

    // If not on Chrome, add Roboto to the bundled fonts since it is provided
    // by default by Flutter.
    if (browserEngine != BrowserEngine.blink) {
      _assetFontManager
          .registerAsset('Roboto', 'url($_robotoFontUrl)', <String, String>{});
    }

    for (Map<String, dynamic> fontFamily in fontManifest) {
      final String family = fontFamily['family'];
      final List<dynamic> fontAssets = fontFamily['fonts'];

      for (dynamic fontAssetItem in fontAssets) {
        final Map<String, dynamic> fontAsset = fontAssetItem;
        final String asset = fontAsset['asset'];
        final Map<String, String> descriptors = <String, String>{};
        for (String descriptor in fontAsset.keys) {
          if (descriptor != 'asset') {
            descriptors[descriptor] = '${fontAsset[descriptor]}';
          }
        }
        _assetFontManager.registerAsset(
            family, 'url(${assetManager.getAssetUrl(asset)})', descriptors);
      }
    }
  }

  /// Registers fonts that are used by tests.
  void debugRegisterTestFonts() {
    _testFontManager = _FontManager();
    _testFontManager.registerAsset(
        _testFontFamily, 'url($_testFontUrl)', const <String, String>{});
  }

  /// Returns a [Future] that completes when the registered fonts are loaded
  /// and ready to be used.
  Future<void> ensureFontsLoaded() async {
    await _assetFontManager?.ensureFontsLoaded();
    await _testFontManager?.ensureFontsLoaded();
  }

  /// Unregister all fonts that have been registered.
  void clear() {
    _assetFontManager = null;
    _testFontManager = null;
    if (supportsFontLoadingApi) {
      html.document.fonts.clear();
    }
  }
}

/// Manages a collection of fonts and ensures they are loaded.
class _FontManager {
  final List<Future<void>> _fontLoadingFutures = <Future<void>>[];

  factory _FontManager() {
    if (supportsFontLoadingApi) {
      return _FontManager._();
    } else {
      return _PolyfillFontManager();
    }
  }

  _FontManager._();

  void registerAsset(
    String family,
    String asset,
    Map<String, String> descriptors,
  ) {
    // Safari crashes if you create a [html.FontFace] with a font family that
    // is not correct CSS syntax. To ensure the font family is accepted on
    // Safari, wrap it in quotes.
    // See: https://drafts.csswg.org/css-fonts-3/#font-family-prop
    if (browserEngine == BrowserEngine.webkit) {
      family = "'$family'";
    }
    // try/catch because `new FontFace` can crash with an improper font family.
    try {
      final html.FontFace fontFace = html.FontFace(family, asset, descriptors);
      _fontLoadingFutures.add(fontFace
          .load()
          .then((_) => html.document.fonts.add(fontFace), onError: (dynamic e) {
        html.window.console
            .warn('Error while trying to load font family "$family":\n$e');
        return null;
      }));
    } catch (e) {
      html.window.console
          .warn('Error while loading font family "$family":\n$e');
    }
  }

  /// Returns a [Future] that completes when all fonts that have been
  /// registered with this font manager have been loaded and are ready to use.
  Future<void> ensureFontsLoaded() {
    return Future.wait(_fontLoadingFutures);
  }
}

/// A font manager that works without using the CSS Font Loading API.
///
/// The CSS Font Loading API is not implemented in IE 11 or Edge. To tell if a
/// font is loaded, we continuously measure some text using that font until the
/// width changes.
class _PolyfillFontManager extends _FontManager {
  _PolyfillFontManager() : super._();

  /// A String containing characters whose width varies greatly between fonts.
  static const String _testString = 'giItT1WQy@!-/#';

  static const Duration _fontLoadTimeout = Duration(seconds: 2);
  static const Duration _fontLoadRetryDuration = Duration(milliseconds: 50);

  @override
  void registerAsset(
    String family,
    String asset,
    Map<String, String> descriptors,
  ) {
    final html.ParagraphElement paragraph = html.ParagraphElement();
    paragraph.style.position = 'absolute';
    paragraph.style.visibility = 'hidden';
    paragraph.style.fontSize = '72px';
    paragraph.style.fontFamily = 'sans-serif';
    if (descriptors['style'] != null) {
      paragraph.style.fontStyle = descriptors['style'];
    }
    if (descriptors['weight'] != null) {
      paragraph.style.fontWeight = descriptors['weight'];
    }
    paragraph.text = _testString;

    html.document.body.append(paragraph);
    final int sansSerifWidth = paragraph.offsetWidth;

    paragraph.style.fontFamily = "'$family', sans-serif";

    final Completer<void> completer = Completer<void>();

    DateTime _fontLoadStart;

    void _watchWidth() {
      if (paragraph.offsetWidth != sansSerifWidth) {
        paragraph.remove();
        completer.complete();
      } else {
        if (DateTime.now().difference(_fontLoadStart) > _fontLoadTimeout) {
          completer.completeError(
              Exception('Timed out trying to load font: $family'));
        } else {
          Timer(_fontLoadRetryDuration, _watchWidth);
        }
      }
    }

    final Map<String, String> fontStyleMap = <String, String>{};
    fontStyleMap['font-family'] = "'$family'";
    fontStyleMap['src'] = asset;
    if (descriptors['style'] != null) {
      fontStyleMap['font-style'] = descriptors['style'];
    }
    if (descriptors['weight'] != null) {
      fontStyleMap['font-weight'] = descriptors['weight'];
    }
    final String fontFaceDeclaration = fontStyleMap.keys
        .map((String name) => '$name: ${fontStyleMap[name]};')
        .join(' ');
    final html.StyleElement fontLoadStyle = html.StyleElement();
    fontLoadStyle.type = 'text/css';
    fontLoadStyle.innerHtml = '@font-face { $fontFaceDeclaration }';
    html.document.head.append(fontLoadStyle);

    // HACK: If this is an icon font, then when it loads it won't change the
    // width of our test string. So we just have to hope it loads before the
    // layout phase.
    if (family.toLowerCase().contains('icon')) {
      paragraph.remove();
      return;
    }

    _fontLoadStart = DateTime.now();
    _watchWidth();

    _fontLoadingFutures.add(completer.future);
  }
}

final bool supportsFontLoadingApi = html.document.fonts != null;
