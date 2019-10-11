// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web_test/flutter_web_test.dart';
import 'package:flutter_web/widgets.dart';

final RouteFactory generateRoute =
    (RouteSettings settings) => PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (BuildContext context, Animation<double> animation1,
              Animation<double> animation2) {
            return const Placeholder();
          },
        );

void main() {
  testWidgets('WidgetsApp.navigatorKey', (WidgetTester tester) async {
    final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(WidgetsApp(
      navigatorKey: key,
      color: const Color(0xFF112233),
      onGenerateRoute: generateRoute,
    ));
    expect(key.currentState, isInstanceOf<NavigatorState>());
    await tester.pumpWidget(WidgetsApp(
      color: const Color(0xFF112233),
      onGenerateRoute: generateRoute,
    ));
    expect(key.currentState, isNull);
    await tester.pumpWidget(WidgetsApp(
      navigatorKey: key,
      color: const Color(0xFF112233),
      onGenerateRoute: generateRoute,
    ));
    expect(key.currentState, isInstanceOf<NavigatorState>());
  });
}
