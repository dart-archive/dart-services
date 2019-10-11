// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Synced 2019-05-30T14:20:56.270409.

import 'package:flutter_web/widgets.dart';

import 'material.dart';
import 'scaffold.dart';
import 'material_localizations.dart';

/// Asserts that the given context has a [Material] ancestor.
///
/// Used by many material design widgets to make sure that they are
/// only used in contexts where they can print ink onto some material.
///
/// To call this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasMaterial(context));
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasMaterial(BuildContext context) {
  assert(() {
    if (context.widget is! Material && context.ancestorWidgetOfExactType(Material) == null) {
      final StringBuffer message = StringBuffer();
      message.writeln('No Material widget found.');
      message.writeln(
        '${context.widget.runtimeType} widgets require a Material '
        'widget ancestor.'
      );
      message.writeln(
        'In material design, most widgets are conceptually "printed" on '
        'a sheet of material. In Flutter\'s material library, that '
        'material is represented by the Material widget. It is the '
        'Material widget that renders ink splashes, for instance. '
        'Because of this, many material library widgets require that '
        'there be a Material widget in the tree above them.'
      );
      message.writeln(
        'To introduce a Material widget, you can either directly '
        'include one, or use a widget that contains Material itself, '
        'such as a Card, Dialog, Drawer, or Scaffold.'
      );
      message.writeln(
        'The specific widget that could not find a Material ancestor was:'
      );
      message.writeln('  ${context.widget}');
      final List<Widget> ancestors = <Widget>[];
      context.visitAncestorElements((Element element) {
        ancestors.add(element.widget);
        return true;
      });
      if (ancestors.isNotEmpty) {
        message.write('The ancestors of this widget were:');
        for (Widget ancestor in ancestors)
          message.write('\n  $ancestor');
      } else {
        message.writeln(
          'This widget is the root of the tree, so it has no '
          'ancestors, let alone a "Material" ancestor.'
        );
      }
      throw FlutterError(message.toString());
    }
    return true;
  }());
  return true;
}


/// Asserts that the given context has a [Localizations] ancestor that contains
/// a [MaterialLocalizations] delegate.
///
/// Used by many material design widgets to make sure that they are
/// only used in contexts where they have access to localizations.
///
/// To call this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasMaterialLocalizations(context));
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasMaterialLocalizations(BuildContext context) {
  assert(() {
    if (Localizations.of<MaterialLocalizations>(context, MaterialLocalizations) == null) {
      final StringBuffer message = StringBuffer();
      message.writeln('No MaterialLocalizations found.');
      message.writeln(
        '${context.widget.runtimeType} widgets require MaterialLocalizations '
        'to be provided by a Localizations widget ancestor.'
      );
      message.writeln(
        'Localizations are used to generate many different messages, labels,'
        'and abbreviations which are used by the material library. '
      );
      message.writeln(
        'To introduce a MaterialLocalizations, either use a '
        ' MaterialApp at the root of your application to include them '
        'automatically, or add a Localization widget with a '
        'MaterialLocalizations delegate.'
      );
      message.writeln(
        'The specific widget that could not find a MaterialLocalizations ancestor was:'
      );
      message.writeln('  ${context.widget}');
      final List<Widget> ancestors = <Widget>[];
      context.visitAncestorElements((Element element) {
        ancestors.add(element.widget);
        return true;
      });
      if (ancestors.isNotEmpty) {
        message.write('The ancestors of this widget were:');
        for (Widget ancestor in ancestors)
          message.write('\n  $ancestor');
      } else {
        message.writeln(
          'This widget is the root of the tree, so it has no '
          'ancestors, let alone a "Localizations" ancestor.'
        );
      }
      throw FlutterError(message.toString());
    }
    return true;
  }());
  return true;
}

/// Asserts that the given context has a [Scaffold] ancestor.
///
/// Used by various widgets to make sure that they are only used in an
/// appropriate context.
///
/// To invoke this function, use the following pattern, typically in the
/// relevant Widget's build method:
///
/// ```dart
/// assert(debugCheckHasScaffold(context));
/// ```
///
/// Does nothing if asserts are disabled. Always returns true.
bool debugCheckHasScaffold(BuildContext context) {
  assert(() {
    if (context.widget is! Scaffold && context.ancestorWidgetOfExactType(Scaffold) == null) {
      final Element element = context;
      throw FlutterError(
          'No Scaffold widget found.\n'
          '${context.widget.runtimeType} widgets require a Scaffold widget ancestor.\n'
          'The Specific widget that could not find a Scaffold ancestor was:\n'
          '  ${context.widget}\n'
          'The ownership chain for the affected widget is:\n'
          '  ${element.debugGetCreatorChain(10)}\n'
          'Typically, the Scaffold widget is introduced by the MaterialApp or '
          'WidgetsApp widget at the top of your application widget tree.'
      );
    }
    return true;
  }());
  return true;
}
