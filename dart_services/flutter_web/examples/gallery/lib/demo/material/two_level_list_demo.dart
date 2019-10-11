// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';

import '../../gallery/demo.dart';

class TwoLevelListDemo extends StatelessWidget {
  static const String routeName = '/material/two-level-list';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Expand/collapse list control'),
          actions: <Widget>[MaterialDemoDocumentationButton(routeName)],
        ),
        body: ListView(children: <Widget>[
          const ListTile(title: Text('Top')),
          ExpansionTile(
              title: const Text('Sublist'),
              backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
              children: const <Widget>[
                ListTile(title: Text('One')),
                ListTile(title: Text('Two')),
                // https://en.wikipedia.org/wiki/Free_Four
                ListTile(title: Text('Free')),
                ListTile(title: Text('Four'))
              ]),
          const ListTile(title: Text('Bottom'))
        ]));
  }
}
