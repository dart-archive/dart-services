// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.common;

import 'dart:io';

const kMainDart = 'main.dart';
const kBootstrapDart = 'bootstrap.dart';

const kBootstrapFlutterCode = r'''
import 'dart:ui' as ui;
import 'main.dart' as user_code;

void main() async {
  await ui.webOnlyInitializePlatform();
  user_code.main();
}
''';

const kBootstrapDartCode = r'''
import 'main.dart' as user_code;

void main() {
  user_code.main();
}
''';

const sampleCode = '''
void main() {
  print("hello");
}
''';

const sampleCodeWeb = """
import 'dart:html';

void main() {
  print("hello");
  querySelector('#foo')?.text = 'bar';
}
""";

const sampleCodeFlutter = '''
import 'package:flutter/material.dart';

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hey there, boo!'),
        ),
        body: Center(
          child: Text(
            'You are pretty okay.',
          ),
        ),
      ),
    ),
  );
}
''';

const sampleCodeFlutterSunflower = '''
import 'package:flutter/material.dart';
import 'dart:math' as math;

final Color primaryColor = Colors.orange;
final TargetPlatform platform = TargetPlatform.android;

void main() {
  runApp(Sunflower());
}

class SunflowerPainter extends CustomPainter {
  static const seedRadius = 2.0;
  static const scaleFactor = 4;
  static const tau = math.pi * 2;

  static final phi = (math.sqrt(5) + 1) / 2;

  final int seeds;

  SunflowerPainter(this.seeds);

  @override
  void paint(Canvas canvas, Size size) {
    var center = size.width / 2;

    for (var i = 0; i < seeds; i++) {
      var theta = i * tau / phi;
      var r = math.sqrt(i) * scaleFactor;
      var x = center + r * math.cos(theta);
      var y = center - r * math.sin(theta);
      var offset = Offset(x, y);
      if (!size.contains(offset)) {
        continue;
      }
      drawSeed(canvas, x, y);
    }
  }

  @override
  bool shouldRepaint(SunflowerPainter oldDelegate) {
    return oldDelegate.seeds != this.seeds;
  }

  // Draw a small circle representing a seed centered at (x,y).
  void drawSeed(Canvas canvas, num x, num y) {
    var paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.fill
      ..color = primaryColor;
    canvas.drawCircle(Offset(x, y), seedRadius, paint);
  }
}

class Sunflower extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SunflowerState();
  }
}

class _SunflowerState extends State<Sunflower> {
  double seeds = 100.0;

  int get seedCount => seeds.floor();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        platform: platform,
        brightness: Brightness.dark,
        sliderTheme: SliderThemeData.fromPrimaryColors(
          primaryColor: primaryColor,
          primaryColorLight: primaryColor,
          primaryColorDark: primaryColor,
          valueIndicatorTextStyle: DefaultTextStyle.fallback().style,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("Sunflower")),
        drawer: Drawer(
            child: ListView(
          children: [
            DrawerHeader(
              child: Center(
                child: Container(
                  child: Text(
                    "Sunflower 🌻",
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
          ],
        )),
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.transparent)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.transparent)),
                child: SizedBox(
                  width: 400,
                  height: 400,
                  child: CustomPaint(
                    painter: SunflowerPainter(seedCount),
                  ),
                ),
              ),
              Text("Showing \$seedCount seeds"),
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 300),
                child: Slider.adaptive(
                  min: 20,
                  max: 2000,
                  value: seeds,
                  onChanged: (newValue) {
                    setState(() {
                      seeds = newValue;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
''';

const sampleCodeMultiFoo = """
import 'bar.dart';

void main() {
  print(bar());
}
""";

const sampleCodeMultiBar = '''
bar() {
  return 4;
}
''';

const sampleCodeAsync = """
import 'dart:html';

main() async {
  print("hello");
  querySelector('#foo')?.text = 'bar';
  var foo = await HttpRequest.getString('http://www.google.com');
  print(foo);
}
""";

const sampleCodeError = '''
void main() {
  print("hello")
}
''';

const sampleCodeErrors = '''
void main() {
  print1("hello");
  print2("hello");
  print3("hello");
}
''';

const sampleStrongError = """
void main() {
  foo('whoops');
}

void foo(int i) {
  print(i);
}
""";

const sampleDart2Error = '''
class Foo {
  final bool isAlwaysNull;
  Foo(this.isAlwaysNull) {}
}

void main(List<String> argv) {
  var x = new Foo(null);
  var y = 1;
  y = x;
}
''';

class Lines {
  final List<int> _starts = <int>[];

  Lines(String source) {
    final units = source.codeUnits;
    for (var i = 0; i < units.length; i++) {
      if (units[i] == 10) _starts.add(i);
    }
  }

  /// Return the 0-based line number.
  int getLineForOffset(int offset) {
    assert(offset != null);
    for (var i = 0; i < _starts.length; i++) {
      if (offset <= _starts[i]) return i;
    }
    return _starts.length;
  }
}

/// Returns the version of the current Dart runtime.
///
/// The returned `String` is formatted as the [semver](http://semver.org) version
/// string of the current Dart runtime, possibly followed by whitespace and other
/// version and build details.
String get vmVersion => Platform.version;

/// If [str] has leading and trailing quotes, remove them.
String stripMatchingQuotes(String str) {
  if (str.length <= 1) return str;

  if (str.startsWith("'") && str.endsWith("'")) {
    str = str.substring(1, str.length - 1);
  } else if (str.startsWith('"') && str.endsWith('"')) {
    str = str.substring(1, str.length - 1);
  }
  return str;
}
