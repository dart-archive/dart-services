// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MyHomePage();
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextStyle(
        style: TextStyle(
          fontFamily: 'Raleway',
          color: Colors.black,
          fontSize: 24.0,
        ),
        child: Column(
          children: [
            Text('Should be Raleway'),
            Text(
              'Roboto Mono Sample',
              style: TextStyle(fontFamily: 'RobotoMono'),
            ),
          ],
        ),
      ),
    );
  }
}
