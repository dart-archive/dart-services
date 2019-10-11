// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_web_ui/ui.dart' as ui;

import 'package:flutter_web/foundation.dart';

import 'asset_bundle.dart';
import 'binary_messenger.dart';

/// Listens for platform messages and directs them to the [defaultBinaryMessenger].
///
/// The [ServicesBinding] also registers a [LicenseEntryCollector] that exposes
/// the licenses found in the `LICENSE` file stored at the root of the asset
/// bundle, and implements the `ext.flutter.evict` service extension (see
/// [evict]).
mixin ServicesBinding on BindingBase {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    _defaultBinaryMessenger = createBinaryMessenger();
    window
      ..onPlatformMessage = defaultBinaryMessenger.handlePlatformMessage;
    initLicenses();
  }

  /// The current [ServicesBinding], if one has been created.
  static ServicesBinding get instance => _instance;
  static ServicesBinding _instance;

  /// The default instance of [BinaryMessenger].
  ///
  /// This is used to send messages from the application to the platform, and
  /// keeps track of which handlers have been registered on each channel so
  /// it may dispatch incoming messages to the registered handler.
  BinaryMessenger get defaultBinaryMessenger => _defaultBinaryMessenger;
  BinaryMessenger _defaultBinaryMessenger;

  /// Creates a default [BinaryMessenger] instance that can be used for sending
  /// platform messages.
  @protected
  BinaryMessenger createBinaryMessenger() {
    return const _DefaultBinaryMessenger._();
  }

  /// Adds relevant licenses to the [LicenseRegistry].
  ///
  /// By default, the [ServicesBinding]'s implementation of [initLicenses] adds
  /// all the licenses collected by the `flutter` tool during compilation.
  @protected
  @mustCallSuper
  void initLicenses() {
    LicenseRegistry.addLicense(_addLicenses);
  }

  Stream<LicenseEntry> _addLicenses() async* {
    // We use timers here (rather than scheduleTask from the scheduler binding)
    // because the services layer can't use the scheduler binding (the scheduler
    // binding uses the services layer to manage its lifecycle events). Timers
    // are what scheduleTask uses under the hood anyway. The only difference is
    // that these will just run next, instead of being prioritized relative to
    // the other tasks that might be running. Using _something_ here to break
    // this into two parts is important because isolates take a while to copy
    // data at the moment, and if we receive the data in the same event loop
    // iteration as we send the data to the next isolate, we are definitely
    // going to miss frames. Another solution would be to have the work all
    // happen in one isolate, and we may go there eventually, but first we are
    // going to see if isolate communication can be made cheaper.
    // See: https://github.com/dart-lang/sdk/issues/31959
    //      https://github.com/dart-lang/sdk/issues/31960
    // TODO(ianh): Remove this complexity once these bugs are fixed.
    final Completer<String> rawLicenses = Completer<String>();
    Timer.run(() async {
      rawLicenses.complete(rootBundle.loadString('LICENSE', cache: false));
    });
    await rawLicenses.future;
    final Completer<List<LicenseEntry>> parsedLicenses = Completer<List<LicenseEntry>>();
    Timer.run(() async {
      parsedLicenses.complete(compute(_parseLicenses, await rawLicenses.future, debugLabel: 'parseLicenses'));
    });
    await parsedLicenses.future;
    yield* Stream<LicenseEntry>.fromIterable(await parsedLicenses.future);
  }

  // This is run in another isolate created by _addLicenses above.
  static List<LicenseEntry> _parseLicenses(String rawLicenses) {
    final String _licenseSeparator = '\n' + ('-' * 80) + '\n';
    final List<LicenseEntry> result = <LicenseEntry>[];
    final List<String> licenses = rawLicenses.split(_licenseSeparator);
    for (String license in licenses) {
      final int split = license.indexOf('\n\n');
      if (split >= 0) {
        result.add(LicenseEntryWithLineBreaks(
          license.substring(0, split).split('\n'),
          license.substring(split + 2),
        ));
      } else {
        result.add(LicenseEntryWithLineBreaks(const <String>[], license));
      }
    }
    return result;
  }

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();

    assert(() {
      registerStringServiceExtension(
        // ext.flutter.evict value=foo.png will cause foo.png to be evicted from
        // the rootBundle cache and cause the entire image cache to be cleared.
        // This is used by hot reload mode to clear out the cache of resources
        // that have changed.
        name: 'evict',
        getter: () async => '',
        setter: (String value) async {
          evict(value);
        },
      );
      return true;
    }());
  }

  /// Called in response to the `ext.flutter.evict` service extension.
  ///
  /// This is used by the `flutter` tool during hot reload so that any images
  /// that have changed on disk get cleared from caches.
  @protected
  @mustCallSuper
  void evict(String asset) {
    rootBundle.evict(asset);
  }
}

/// The default implementation of [BinaryMessenger].
///
/// This messenger sends messages from the app-side to the platform-side and
/// dispatches incoming messages from the platform-side to the appropriate
/// handler.
class _DefaultBinaryMessenger extends BinaryMessenger {
  const _DefaultBinaryMessenger._();

  // Handlers for incoming messages from platform plugins.
  // This is static so that this class can have a const constructor.
  static final Map<String, MessageHandler> _handlers =
      <String, MessageHandler>{};

  // Mock handlers that intercept and respond to outgoing messages.
  // This is static so that this class can have a const constructor.
  static final Map<String, MessageHandler> _mockHandlers =
      <String, MessageHandler>{};

  Future<ByteData> _sendPlatformMessage(String channel, ByteData message) {
    final Completer<ByteData> completer = Completer<ByteData>();
    // ui.window is accessed directly instead of using ServicesBinding.instance.window
    // because this method might be invoked before any binding is initialized.
    // This issue was reported in #27541. It is not ideal to statically access
    // ui.window because the Window may be dependency injected elsewhere with
    // a different instance. However, static access at this location seems to be
    // the least bad option.
    ui.window.sendPlatformMessage(channel, message, (ByteData reply) {
      try {
        completer.complete(reply);
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'services library',
          context: ErrorDescription('during a platform message response callback'),
        ));
      }
    });
    return completer.future;
  }

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData data,
    ui.PlatformMessageResponseCallback callback,
  ) async {
    ByteData response;
    try {
      final MessageHandler handler = _handlers[channel];
      if (handler != null)
        response = await handler(data);
    } catch (exception, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: 'services library',
        context: ErrorDescription('during a platform message callback'),
      ));
    } finally {
      callback(response);
    }
  }

  @override
  Future<ByteData> send(String channel, ByteData message) {
    final MessageHandler handler = _mockHandlers[channel];
    if (handler != null)
      return handler(message);
    return _sendPlatformMessage(channel, message);
  }

  @override
  void setMessageHandler(String channel, MessageHandler handler) {
    if (handler == null)
      _handlers.remove(channel);
    else
      _handlers[channel] = handler;
  }

  @override
  void setMockMessageHandler(String channel, MessageHandler handler) {
    if (handler == null)
      _mockHandlers.remove(channel);
    else
      _mockHandlers[channel] = handler;
  }
}
