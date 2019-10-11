// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_web/material.dart';

import '../../gallery/demo.dart';
import 'full_screen_dialog_demo.dart';

enum DialogDemoAction {
  cancel,
  discard,
  disagree,
  agree,
}

const String _alertWithoutTitleText = 'Discard draft?';

const String _alertWithTitleText =
    'Let Google help apps determine location. This means sending anonymous location '
    'data to Google, even when no apps are running.';

class DialogDemoItem extends StatelessWidget {
  const DialogDemoItem(
      {Key key, this.icon, this.color, this.text, this.onPressed})
      : super(key: key);

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 36.0, color: color),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

class DialogDemo extends StatefulWidget {
  static const String routeName = '/material/dialog';

  @override
  DialogDemoState createState() => DialogDemoState();
}

class DialogDemoState extends State<DialogDemo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
  }

  void showDemoDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text('You selected: $value')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Dialogs'),
          actions: <Widget>[
            MaterialDemoDocumentationButton(DialogDemo.routeName)
          ],
        ),
        body: ListView(
            padding:
                const EdgeInsets.symmetric(vertical: 24.0, horizontal: 72.0),
            children: <Widget>[
              RaisedButton(
                  child: const Text('ALERT'),
                  onPressed: () {
                    showDemoDialog<DialogDemoAction>(
                        context: context,
                        child: AlertDialog(
                            content: Text(_alertWithoutTitleText,
                                style: dialogTextStyle),
                            actions: <Widget>[
                              FlatButton(
                                  child: const Text('CANCEL'),
                                  onPressed: () {
                                    Navigator.pop(
                                        context, DialogDemoAction.cancel);
                                  }),
                              FlatButton(
                                  child: const Text('DISCARD'),
                                  onPressed: () {
                                    Navigator.pop(
                                        context, DialogDemoAction.discard);
                                  })
                            ]));
                  }),
              RaisedButton(
                  child: const Text('ALERT WITH TITLE'),
                  onPressed: () {
                    showDemoDialog<DialogDemoAction>(
                        context: context,
                        child: AlertDialog(
                            title:
                                const Text('Use Google\'s location service?'),
                            content: Text(_alertWithTitleText,
                                style: dialogTextStyle),
                            actions: <Widget>[
                              FlatButton(
                                  child: const Text('DISAGREE'),
                                  onPressed: () {
                                    Navigator.pop(
                                        context, DialogDemoAction.disagree);
                                  }),
                              FlatButton(
                                  child: const Text('AGREE'),
                                  onPressed: () {
                                    Navigator.pop(
                                        context, DialogDemoAction.agree);
                                  })
                            ]));
                  }),
              RaisedButton(
                  child: const Text('SIMPLE'),
                  onPressed: () {
                    showDemoDialog<String>(
                        context: context,
                        child: SimpleDialog(
                            title: const Text('Set backup account'),
                            children: <Widget>[
                              DialogDemoItem(
                                  icon: Icons.account_circle,
                                  color: theme.primaryColor,
                                  text: 'username@gmail.com',
                                  onPressed: () {
                                    Navigator.pop(
                                        context, 'username@gmail.com');
                                  }),
                              DialogDemoItem(
                                  icon: Icons.account_circle,
                                  color: theme.primaryColor,
                                  text: 'user02@gmail.com',
                                  onPressed: () {
                                    Navigator.pop(context, 'user02@gmail.com');
                                  }),
                              DialogDemoItem(
                                  icon: Icons.add_circle,
                                  text: 'add account',
                                  color: theme.disabledColor)
                            ]));
                  }),
              RaisedButton(
                  child: const Text('CONFIRMATION'),
                  onPressed: () {
                    showTimePicker(context: context, initialTime: _selectedTime)
                        .then<void>((TimeOfDay value) {
                      if (value != null && value != _selectedTime) {
                        _selectedTime = value;
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                                'You selected: ${value.format(context)}')));
                      }
                    });
                  }),
              RaisedButton(
                  child: const Text('FULLSCREEN'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute<DismissDialogAction>(
                          builder: (BuildContext context) =>
                              FullScreenDialogDemo(),
                          fullscreenDialog: true,
                        ));
                  }),
            ]
                // Add a little space between the buttons
                .map<Widget>((Widget button) {
              return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: button);
            }).toList()));
  }
}
