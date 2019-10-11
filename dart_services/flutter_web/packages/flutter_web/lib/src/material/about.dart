// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/scheduler.dart';
import 'package:flutter_web/widgets.dart' hide Flow;

import 'app_bar.dart';
import 'debug.dart';
import 'dialog.dart';
import 'flat_button.dart';
import 'list_tile.dart';
import 'material_localizations.dart';
import 'page.dart';
import 'progress_indicator.dart';
import 'scaffold.dart';
import 'scrollbar.dart';
import 'theme.dart';

/// A [ListTile] that shows an about box.
///
/// This widget is often added to an app's [Drawer]. When tapped it shows
/// an about box dialog with [showAboutDialog].
///
/// The about box will include a button that shows licenses for software used by
/// the application. The licenses shown are those returned by the
/// [LicenseRegistry] API, which can be used to add more licenses to the list.
///
/// If your application does not have a [Drawer], you should provide an
/// affordance to call [showAboutDialog] or (at least) [showLicensePage].
class AboutListTile extends StatelessWidget {
  /// Creates a list tile for showing an about box.
  ///
  /// The arguments are all optional. The application name, if omitted, will be
  /// derived from the nearest [Title] widget. The version, icon, and legalese
  /// values default to the empty string.
  const AboutListTile(
      {Key key,
      this.icon = const Icon(null),
      this.child,
      this.applicationName,
      this.applicationVersion,
      this.applicationIcon,
      this.applicationLegalese,
      this.aboutBoxChildren})
      : super(key: key);

  /// The icon to show for this drawer item.
  ///
  /// By default no icon is shown.
  ///
  /// This is not necessarily the same as the image shown in the dialog box
  /// itself; which is controlled by the [applicationIcon] property.
  final Widget icon;

  /// The label to show on this drawer item.
  ///
  /// Defaults to a text widget that says "About Foo" where "Foo" is the
  /// application name specified by [applicationName].
  final Widget child;

  /// The name of the application.
  ///
  /// This string is used in the default label for this drawer item (see
  /// [child]) and as the caption of the [AboutDialog] that is shown.
  ///
  /// Defaults to the value of [Title.title], if a [Title] widget can be found.
  /// Otherwise, defaults to [Platform.resolvedExecutable].
  final String applicationName;

  /// The version of this build of the application.
  ///
  /// This string is shown under the application name in the [AboutDialog].
  ///
  /// Defaults to the empty string.
  final String applicationVersion;

  /// The icon to show next to the application name in the [AboutDialog].
  ///
  /// By default no icon is shown.
  ///
  /// Typically this will be an [ImageIcon] widget. It should honor the
  /// [IconTheme]'s [IconThemeData.size].
  ///
  /// This is not necessarily the same as the icon shown on the drawer item
  /// itself, which is controlled by the [icon] property.
  final Widget applicationIcon;

  /// A string to show in small print in the [AboutDialog].
  ///
  /// Typically this is a copyright notice.
  ///
  /// Defaults to the empty string.
  final String applicationLegalese;

  /// Widgets to add to the [AboutDialog] after the name, version, and legalese.
  ///
  /// This could include a link to a Web site, some descriptive text, credits,
  /// or other information to show in the about box.
  ///
  /// Defaults to nothing.
  final List<Widget> aboutBoxChildren;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    return ListTile(
        leading: icon,
        title: child ??
            Text(MaterialLocalizations.of(context).aboutListTileTitle(
                applicationName ?? _defaultApplicationName(context))),
        onTap: () {
          showAboutDialog(
              context: context,
              applicationName: applicationName,
              applicationVersion: applicationVersion,
              applicationIcon: applicationIcon,
              applicationLegalese: applicationLegalese,
              children: aboutBoxChildren);
        });
  }
}

/// Displays an [AboutDialog], which describes the application and provides a
/// button to show licenses for software used by the application.
///
/// The arguments correspond to the properties on [AboutDialog].
///
/// If the application has a [Drawer], consider using [AboutListTile] instead
/// of calling this directly.
///
/// If you do not need an about box in your application, you should at least
/// provide an affordance to call [showLicensePage].
///
/// The licenses shown on the [LicensePage] are those returned by the
/// [LicenseRegistry] API, which can be used to add more licenses to the list.
///
/// The `context` argument is passed to [showDialog], the documentation for
/// which discusses how it is used.
void showAboutDialog({
  @required BuildContext context,
  String applicationName,
  String applicationVersion,
  Widget applicationIcon,
  String applicationLegalese,
  List<Widget> children,
}) {
  assert(context != null);
  showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AboutDialog(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
          children: children,
        );
      });
}

/// Displays a [LicensePage], which shows licenses for software used by the
/// application.
///
/// The arguments correspond to the properties on [LicensePage].
///
/// If the application has a [Drawer], consider using [AboutListTile] instead
/// of calling this directly.
///
/// The [AboutDialog] shown by [showAboutDialog] includes a button that calls
/// [showLicensePage].
///
/// The licenses shown on the [LicensePage] are those returned by the
/// [LicenseRegistry] API, which can be used to add more licenses to the list.
void showLicensePage(
    {@required BuildContext context,
    String applicationName,
    String applicationVersion,
    Widget applicationIcon,
    String applicationLegalese}) {
  assert(context != null);
  Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => LicensePage(
              applicationName: applicationName,
              applicationVersion: applicationVersion,
              applicationLegalese: applicationLegalese)));
}

/// An about box. This is a dialog box with the application's icon, name,
/// version number, and copyright, plus a button to show licenses for software
/// used by the application.
///
/// To show an [AboutDialog], use [showAboutDialog].
///
/// If the application has a [Drawer], the [AboutListTile] widget can make the
/// process of showing an about dialog simpler.
///
/// The [AboutDialog] shown by [showAboutDialog] includes a button that calls
/// [showLicensePage].
///
/// The licenses shown on the [LicensePage] are those returned by the
/// [LicenseRegistry] API, which can be used to add more licenses to the list.
class AboutDialog extends StatelessWidget {
  /// Creates an about box.
  ///
  /// The arguments are all optional. The application name, if omitted, will be
  /// derived from the nearest [Title] widget. The version, icon, and legalese
  /// values default to the empty string.
  const AboutDialog({
    Key key,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
    this.children,
  }) : super(key: key);

  /// The name of the application.
  ///
  /// Defaults to the value of [Title.title], if a [Title] widget can be found.
  /// Otherwise, defaults to [Platform.resolvedExecutable].
  final String applicationName;

  /// The version of this build of the application.
  ///
  /// This string is shown under the application name.
  ///
  /// Defaults to the empty string.
  final String applicationVersion;

  /// The icon to show next to the application name.
  ///
  /// By default no icon is shown.
  ///
  /// Typically this will be an [ImageIcon] widget. It should honor the
  /// [IconTheme]'s [IconThemeData.size].
  final Widget applicationIcon;

  /// A string to show in small print.
  ///
  /// Typically this is a copyright notice.
  ///
  /// Defaults to the empty string.
  final String applicationLegalese;

  /// Widgets to add to the dialog box after the name, version, and legalese.
  ///
  /// This could include a link to a Web site, some descriptive text, credits,
  /// or other information to show in the about box.
  ///
  /// Defaults to nothing.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final String name = applicationName ?? _defaultApplicationName(context);
    final String version =
        applicationVersion ?? _defaultApplicationVersion(context);
    final Widget icon = applicationIcon ?? _defaultApplicationIcon(context);
    List<Widget> body = <Widget>[];
    if (icon != null)
      body.add(IconTheme(data: const IconThemeData(size: 48.0), child: icon));
    body.add(Expanded(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListBody(children: <Widget>[
              Text(name, style: Theme.of(context).textTheme.headline),
              Text(version, style: Theme.of(context).textTheme.body1),
              Container(height: 18.0),
              Text(applicationLegalese ?? '',
                  style: Theme.of(context).textTheme.caption)
            ]))));
    body = <Widget>[
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: body),
    ];
    if (children != null) body.addAll(children);
    return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(children: body),
        ),
        actions: <Widget>[
          FlatButton(
              child: Text(
                  MaterialLocalizations.of(context).viewLicensesButtonLabel),
              onPressed: () {
                showLicensePage(
                    context: context,
                    applicationName: applicationName,
                    applicationVersion: applicationVersion,
                    applicationIcon: applicationIcon,
                    applicationLegalese: applicationLegalese);
              }),
          FlatButton(
              child: Text(MaterialLocalizations.of(context).closeButtonLabel),
              onPressed: () {
                Navigator.pop(context);
              }),
        ]);
  }
}

/// A page that shows licenses for software used by the application.
///
/// To show a [LicensePage], use [showLicensePage].
///
/// The [AboutDialog] shown by [showAboutDialog] and [AboutListTile] includes
/// a button that calls [showLicensePage].
///
/// The licenses shown on the [LicensePage] are those returned by the
/// [LicenseRegistry] API, which can be used to add more licenses to the list.
class LicensePage extends StatefulWidget {
  /// Creates a page that shows licenses for software used by the application.
  ///
  /// The arguments are all optional. The application name, if omitted, will be
  /// derived from the nearest [Title] widget. The version and legalese values
  /// default to the empty string.
  ///
  /// The licenses shown on the [LicensePage] are those returned by the
  /// [LicenseRegistry] API, which can be used to add more licenses to the list.
  const LicensePage(
      {Key key,
      this.applicationName,
      this.applicationVersion,
      this.applicationLegalese})
      : super(key: key);

  /// The name of the application.
  ///
  /// Defaults to the value of [Title.title], if a [Title] widget can be found.
  /// Otherwise, defaults to [Platform.resolvedExecutable].
  final String applicationName;

  /// The version of this build of the application.
  ///
  /// This string is shown under the application name.
  ///
  /// Defaults to the empty string.
  final String applicationVersion;

  /// A string to show in small print.
  ///
  /// Typically this is a copyright notice.
  ///
  /// Defaults to the empty string.
  final String applicationLegalese;

  @override
  _LicensePageState createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  @override
  void initState() {
    super.initState();
    _initLicenses();
  }

  final List<Widget> _licenses = <Widget>[];
  bool _loaded = false;

  Future<void> _initLicenses() async {
    await for (LicenseEntry license in LicenseRegistry.licenses) {
      if (!mounted) return;
      final List<LicenseParagraph> paragraphs =
          await SchedulerBinding.instance.scheduleTask<List<LicenseParagraph>>(
        () => license.paragraphs.toList(),
        Priority.animation,
        debugLabel: 'License',
      );
      setState(() {
        _licenses.add(const Padding(
            padding: EdgeInsets.symmetric(vertical: 18.0),
            child: Text(
                '🍀‬', // That's U+1F340. Could also use U+2766 (❦) if U+1F340 doesn't work everywhere.
                textAlign: TextAlign.center)));
        _licenses.add(Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(width: 0.0))),
            child: Text(license.packages.join(', '),
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)));
        for (LicenseParagraph paragraph in paragraphs) {
          if (paragraph.indent == LicenseParagraph.centeredIndent) {
            _licenses.add(Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(paragraph.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)));
          } else {
            assert(paragraph.indent >= 0);
            _licenses.add(Padding(
                padding: EdgeInsetsDirectional.only(
                    top: 8.0, start: 16.0 * paragraph.indent),
                child: Text(paragraph.text)));
          }
        }
      });
    }
    setState(() {
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final String name =
        widget.applicationName ?? _defaultApplicationName(context);
    final String version =
        widget.applicationVersion ?? _defaultApplicationVersion(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final List<Widget> contents = <Widget>[
      Text(name,
          style: Theme.of(context).textTheme.headline,
          textAlign: TextAlign.center),
      Text(version,
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.center),
      Container(height: 18.0),
      Text(widget.applicationLegalese ?? '',
          style: Theme.of(context).textTheme.caption,
          textAlign: TextAlign.center),
      Container(height: 18.0),
      Text('Powered by Flutter',
          style: Theme.of(context).textTheme.body1,
          textAlign: TextAlign.center),
      Container(height: 24.0),
    ];
    contents.addAll(_licenses);
    if (!_loaded) {
      contents.add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Center(child: CircularProgressIndicator())));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.licensesPageTitle),
      ),
      // All of the licenses page text is English. We don't want localized text
      // or text direction.
      body: Localizations.override(
        locale: const Locale('en', 'US'),
        context: context,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.caption,
          child: Scrollbar(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              children: contents,
            ),
          ),
        ),
      ),
    );
  }
}

String _defaultApplicationName(BuildContext context) {
  final Title ancestorTitle = context.ancestorWidgetOfExactType(Title);
  return ancestorTitle?.title ?? 'App';
}

String _defaultApplicationVersion(BuildContext context) {
  // TODO(ianh): Get this from the embedder somehow.
  return '';
}

Widget _defaultApplicationIcon(BuildContext context) {
  // TODO(ianh): Get this from the embedder somehow.
  return null;
}
