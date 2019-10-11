// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';
import 'package:flutter_web/services.dart';

class _ContactCategory extends StatelessWidget {
  const _ContactCategory({Key key, this.icon, this.children}) : super(key: key);

  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: themeData.dividerColor))),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.subhead,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  width: 72.0,
                  child: Icon(icon, color: themeData.primaryColor)),
              Expanded(child: Column(children: children))
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  _ContactItem({Key key, this.icon, this.lines, this.tooltip, this.onPressed})
      : assert(lines.length > 1),
        super(key: key);

  final IconData icon;
  final List<String> lines;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final List<Widget> columnChildren = lines
        .sublist(0, lines.length - 1)
        .map<Widget>((String line) => Text(line))
        .toList();
    columnChildren.add(Text(lines.last, style: themeData.textTheme.caption));

    final List<Widget> rowChildren = <Widget>[
      Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnChildren))
    ];
    if (icon != null) {
      rowChildren.add(SizedBox(
          width: 72.0,
          child: IconButton(
              icon: Icon(icon),
              color: themeData.primaryColor,
              onPressed: onPressed)));
    }
    return MergeSemantics(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: rowChildren)),
    );
  }
}

class ContactsDemo extends StatefulWidget {
  static const String routeName = '/contacts';

  @override
  ContactsDemoState createState() => ContactsDemoState();
}

enum AppBarBehavior { normal, pinned, floating, snapping }

class ContactsDemoState extends State<ContactsDemo> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  final double _appBarHeight = 256.0;

  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        platform: Theme.of(context).platform,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: _appBarHeight,
              pinned: _appBarBehavior == AppBarBehavior.pinned,
              floating: _appBarBehavior == AppBarBehavior.floating ||
                  _appBarBehavior == AppBarBehavior.snapping,
              snap: _appBarBehavior == AppBarBehavior.snapping,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.create),
                  tooltip: 'Edit',
                  onPressed: () {
                    _scaffoldKey.currentState.showSnackBar(const SnackBar(
                        content:
                            Text("Editing isn't supported in this screen.")));
                  },
                ),
                PopupMenuButton<AppBarBehavior>(
                  onSelected: (AppBarBehavior value) {
                    setState(() {
                      _appBarBehavior = value;
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<AppBarBehavior>>[
                        const PopupMenuItem<AppBarBehavior>(
                            value: AppBarBehavior.normal,
                            child: Text('App bar scrolls away')),
                        const PopupMenuItem<AppBarBehavior>(
                            value: AppBarBehavior.pinned,
                            child: Text('App bar stays put')),
                        const PopupMenuItem<AppBarBehavior>(
                            value: AppBarBehavior.floating,
                            child: Text('App bar floats')),
                        const PopupMenuItem<AppBarBehavior>(
                            value: AppBarBehavior.snapping,
                            child: Text('App bar snaps')),
                      ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Ali Connors'),
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.asset(
                      'people/ali_landscape.png',
                      // package: 'flutter_gallery_assets',
                      fit: BoxFit.cover,
                      height: _appBarHeight,
                    ),
                    // This gradient ensures that the toolbar icons are distinct
                    // against the background image.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, -1.0),
                          end: Alignment(0.0, -0.4),
                          colors: <Color>[Color(0x60000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.dark,
                  child: _ContactCategory(
                    icon: Icons.call,
                    children: <Widget>[
                      _ContactItem(
                        icon: Icons.message,
                        tooltip: 'Send message',
                        onPressed: () {
                          _scaffoldKey.currentState.showSnackBar(const SnackBar(
                              content: Text(
                                  'Pretend that this opened your SMS application.')));
                        },
                        lines: const <String>[
                          '(650) 555-1234',
                          'Mobile',
                        ],
                      ),
                      _ContactItem(
                        icon: Icons.message,
                        tooltip: 'Send message',
                        onPressed: () {
                          _scaffoldKey.currentState.showSnackBar(const SnackBar(
                              content: Text('A messaging app appears.')));
                        },
                        lines: const <String>[
                          '(323) 555-6789',
                          'Work',
                        ],
                      ),
                      _ContactItem(
                        icon: Icons.message,
                        tooltip: 'Send message',
                        onPressed: () {
                          _scaffoldKey.currentState.showSnackBar(const SnackBar(
                              content: Text(
                                  'Imagine if you will, a messaging application.')));
                        },
                        lines: const <String>[
                          '(650) 555-6789',
                          'Home',
                        ],
                      ),
                    ],
                  ),
                ),
                _ContactCategory(
                  icon: Icons.contact_mail,
                  children: <Widget>[
                    _ContactItem(
                      icon: Icons.email,
                      tooltip: 'Send personal e-mail',
                      onPressed: () {
                        _scaffoldKey.currentState.showSnackBar(const SnackBar(
                            content: Text(
                                'Here, your e-mail application would open.')));
                      },
                      lines: const <String>[
                        'ali_connors@example.com',
                        'Personal',
                      ],
                    ),
                    _ContactItem(
                      icon: Icons.email,
                      tooltip: 'Send work e-mail',
                      onPressed: () {
                        _scaffoldKey.currentState.showSnackBar(const SnackBar(
                            content: Text(
                                'Summon your favorite e-mail application here.')));
                      },
                      lines: const <String>[
                        'aliconnors@example.com',
                        'Work',
                      ],
                    ),
                  ],
                ),
                _ContactCategory(
                  icon: Icons.location_on,
                  children: <Widget>[
                    _ContactItem(
                      icon: Icons.map,
                      tooltip: 'Open map',
                      onPressed: () {
                        _scaffoldKey.currentState.showSnackBar(const SnackBar(
                            content: Text(
                                'This would show a map of San Francisco.')));
                      },
                      lines: const <String>[
                        '2000 Main Street',
                        'San Francisco, CA',
                        'Home',
                      ],
                    ),
                    _ContactItem(
                      icon: Icons.map,
                      tooltip: 'Open map',
                      onPressed: () {
                        _scaffoldKey.currentState.showSnackBar(const SnackBar(
                            content: Text(
                                'This would show a map of Mountain View.')));
                      },
                      lines: const <String>[
                        '1600 Amphitheater Parkway',
                        'Mountain View, CA',
                        'Work',
                      ],
                    ),
                    _ContactItem(
                      icon: Icons.map,
                      tooltip: 'Open map',
                      onPressed: () {
                        _scaffoldKey.currentState.showSnackBar(const SnackBar(
                            content: Text(
                                'This would also show a map, if this was not a demo.')));
                      },
                      lines: const <String>[
                        '126 Severyns Ave',
                        'Mountain View, CA',
                        'Jet Travel',
                      ],
                    ),
                  ],
                ),
                _ContactCategory(
                  icon: Icons.today,
                  children: <Widget>[
                    _ContactItem(
                      lines: const <String>[
                        'Birthday',
                        'January 9th, 1989',
                      ],
                    ),
                    _ContactItem(
                      lines: const <String>[
                        'Wedding anniversary',
                        'June 21st, 2014',
                      ],
                    ),
                    _ContactItem(
                      lines: const <String>[
                        'First day in office',
                        'January 20th, 2015',
                      ],
                    ),
                    _ContactItem(
                      lines: const <String>[
                        'Last day in office',
                        'August 9th, 2018',
                      ],
                    ),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
