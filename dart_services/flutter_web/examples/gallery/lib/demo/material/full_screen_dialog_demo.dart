// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_web/material.dart';
import 'package:intl/intl.dart';

// This demo is based on
// https://material.google.com/components/dialogs.html#dialogs-full-screen-dialogs

enum DismissDialogAction {
  cancel,
  discard,
  save,
}

class DateTimeItem extends StatelessWidget {
  DateTimeItem({Key key, DateTime dateTime, @required this.onChanged})
      : assert(onChanged != null),
        date = DateTime(dateTime.year, dateTime.month, dateTime.day),
        time = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
        super(key: key);

  final DateTime date;
  final TimeOfDay time;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DefaultTextStyle(
        style: theme.textTheme.subhead,
        child: Row(children: <Widget>[
          Expanded(
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: theme.dividerColor))),
                  child: InkWell(
                      onTap: () {
                        showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate:
                                    date.subtract(const Duration(days: 30)),
                                lastDate: date.add(const Duration(days: 30)))
                            .then<void>((DateTime value) {
                          if (value != null)
                            onChanged(DateTime(value.year, value.month,
                                value.day, time.hour, time.minute));
                        });
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(DateFormat('EEE, MMM d yyyy').format(date)),
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.black54),
                          ])))),
          Container(
              margin: const EdgeInsets.only(left: 8.0),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: theme.dividerColor))),
              child: InkWell(
                  onTap: () {
                    showTimePicker(context: context, initialTime: time)
                        .then<void>((TimeOfDay value) {
                      if (value != null)
                        onChanged(DateTime(date.year, date.month, date.day,
                            value.hour, value.minute));
                    });
                  },
                  child: Row(children: <Widget>[
                    Text('${time.format(context)}'),
                    const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ])))
        ]));
  }
}

class FullScreenDialogDemo extends StatefulWidget {
  @override
  FullScreenDialogDemoState createState() => FullScreenDialogDemoState();
}

class FullScreenDialogDemoState extends State<FullScreenDialogDemo> {
  DateTime _fromDateTime = DateTime.now();
  DateTime _toDateTime = DateTime.now();
  bool _allDayValue = false;
  bool _saveNeeded = false;
  bool _hasLocation = false;
  bool _hasName = false;
  String _eventName;

  Future<bool> _onWillPop() async {
    _saveNeeded = _hasLocation || _hasName || _saveNeeded;
    if (!_saveNeeded) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Discard new event?', style: dialogTextStyle),
              actions: <Widget>[
                FlatButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          false); // Pops the confirmation dialog but not the page.
                    }),
                FlatButton(
                    child: const Text('DISCARD'),
                    onPressed: () {
                      Navigator.of(context).pop(
                          true); // Returning true to _onWillPop will pop again.
                    })
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(_hasName ? _eventName : 'Event Name TBD'),
          actions: <Widget>[
            FlatButton(
                child: Text('SAVE',
                    style: theme.textTheme.body1.copyWith(color: Colors.white)),
                onPressed: () {
                  Navigator.pop(context, DismissDialogAction.save);
                })
          ]),
      body: Form(
          onWillPop: _onWillPop,
          child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.bottomLeft,
                    child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Event name', filled: true),
                        style: theme.textTheme.headline,
                        onChanged: (String value) {
                          setState(() {
                            _hasName = value.isNotEmpty;
                            if (_hasName) {
                              _eventName = value;
                            }
                          });
                        })),
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.bottomLeft,
                    child: TextField(
                        decoration: const InputDecoration(
                            labelText: 'Location',
                            hintText: 'Where is the event?',
                            filled: true),
                        onChanged: (String value) {
                          setState(() {
                            _hasLocation = value.isNotEmpty;
                          });
                        })),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('From', style: theme.textTheme.caption),
                      DateTimeItem(
                          dateTime: _fromDateTime,
                          onChanged: (DateTime value) {
                            setState(() {
                              _fromDateTime = value;
                              _saveNeeded = true;
                            });
                          })
                    ]),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('To', style: theme.textTheme.caption),
                      DateTimeItem(
                          dateTime: _toDateTime,
                          onChanged: (DateTime value) {
                            setState(() {
                              _toDateTime = value;
                              _saveNeeded = true;
                            });
                          }),
                      const Text('All-day'),
                    ]),
                Container(
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: theme.dividerColor))),
                    child: Row(children: <Widget>[
                      Checkbox(
                          value: _allDayValue,
                          onChanged: (bool value) {
                            setState(() {
                              _allDayValue = value;
                              _saveNeeded = true;
                            });
                          }),
                      const Text('All-day'),
                    ]))
              ].map<Widget>((Widget child) {
                return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    height: 96.0,
                    child: child);
              }).toList())),
    );
  }
}
