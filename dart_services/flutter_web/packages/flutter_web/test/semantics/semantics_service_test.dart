// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_ui/ui.dart' show TextDirection;

import 'package:flutter_web/semantics.dart';
import 'package:flutter_web/services.dart' show SystemChannels;
import 'package:test/test.dart';

void main() {
  test('Semantic announcement', () async {
    final List<Map<dynamic, dynamic>> log = <Map<dynamic, dynamic>>[];

    SystemChannels.accessibility
        .setMockMessageHandler((Object mockMessage) async {
      final Map<dynamic, dynamic> message = mockMessage;
      log.add(message);
    });

    await SemanticsService.announce('announcement 1', TextDirection.ltr);
    await SemanticsService.announce('announcement 2', TextDirection.rtl);

    expect(
        log,
        equals(<Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'announce',
            'data': <String, dynamic>{
              'message': 'announcement 1',
              'textDirection': 1
            }
          },
          <String, dynamic>{
            'type': 'announce',
            'data': <String, dynamic>{
              'message': 'announcement 2',
              'textDirection': 0
            }
          },
        ]));
  });
}
