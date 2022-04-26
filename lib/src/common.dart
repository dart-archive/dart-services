// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.common;

import 'dart:convert' show json;
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';

import 'pub.dart';

const kMainDart = 'main.dart';
const kBootstrapDart = 'bootstrap.dart';

/// This code should be kept up-to-date with WebEntrypointTarget.build() from
/// flutter_tools: https://github.com/flutter/flutter/blob/169020719bc5882e746b836629721644633b6c8a/packages/flutter_tools/lib/src/build_system/targets/web.dart#L137
const kBootstrapFlutterCode = r'''
import 'dart:ui' as ui;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'generated_plugin_registrant.dart';
import 'main.dart' as entrypoint;

Future<void> main() async {
  registerPlugins(webPluginRegistrar);
  await ui.webOnlyInitializePlatform();
  entrypoint.main();
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
          title: const Text('Hey there, boo!'),
        ),
        body: const Center(
          child: Text(
            'You are pretty okay.',
          ),
        ),
      ),
    ),
  );
}
''';

// From https://gist.github.com/johnpryan/1a28bdd9203250d3226cc25d512579ec
const sampleCodeFlutterCounter = r'''
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';

// From https://gist.github.com/RedBrogdon/e0a2e942e85fde2cd39b2741ff0c49e5
const sampleCodeFlutterSunflower = r'''
import 'dart:math' as math;
import 'package:flutter/material.dart';

final Color primaryColor = Colors.orange;
const TargetPlatform platform = TargetPlatform.android;

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
    final center = size.width / 2;

    for (var i = 0; i < seeds; i++) {
      final theta = i * tau / phi;
      final r = math.sqrt(i) * scaleFactor;
      final x = center + r * math.cos(theta);
      final y = center - r * math.sin(theta);
      final offset = Offset(x, y);
      if (!size.contains(offset)) {
        continue;
      }
      drawSeed(canvas, x, y);
    }
  }

  @override
  bool shouldRepaint(SunflowerPainter oldDelegate) {
    return oldDelegate.seeds != seeds;
  }

  // Draw a small circle representing a seed centered at (x,y).
  void drawSeed(Canvas canvas, double x, double y) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.fill
      ..color = primaryColor;
    canvas.drawCircle(Offset(x, y), seedRadius, paint);
  }
}

class Sunflower extends StatefulWidget {
  @override
  State<Sunflower> createState() {
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
          valueIndicatorTextStyle: const DefaultTextStyle.fallback().style,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text("Sunflower")),
        drawer: Drawer(
            child: ListView(
          children: const [
            DrawerHeader(
              child: Center(
                child: Text(
                  "Sunflower 🌻",
                  style: TextStyle(fontSize: 32),
                ),
              ),
            ),
          ],
        )),
        body: Container(
          constraints: const BoxConstraints.expand(),
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
              Text("Showing $seedCount seeds"),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 300),
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

// https://gist.github.com/johnpryan/5e28c5273c2c1a41d30bad9f9d11da56
const sampleCodeFlutterDraggableCard = '''
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PhysicsCardDragDemo(),
    ),
  );
}

class PhysicsCardDragDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A draggable card!'),
      ),
      body: const DraggableCard(
        child: FlutterLogo(
          size: 128,
        ),
      ),
    );
  }
}

class DraggableCard extends StatefulWidget {
  final Widget child;
  const DraggableCard({required this.child});

  @override
  State<DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Alignment _dragAlignment = Alignment.center;
  Animation<Alignment>? _animation;

  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller!.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );

    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    _controller!.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller!.addListener(() {
      setState(() {
        _dragAlignment = _animation!.value;
      });
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanDown: (details) {
        _controller!.stop();
      },
      onPanUpdate: (details) {
        setState(() {
          _dragAlignment += Alignment(
            details.delta.dx / (size.width / 2),
            details.delta.dy / (size.height / 2),
          );
        });
      },
      onPanEnd: (details) {
        _runAnimation(details.velocity.pixelsPerSecond, size);
      },
      child: Align(
        alignment: _dragAlignment,
        child: Card(
          child: widget.child,
        ),
      ),
    );
  }
}
''';

// From https://gist.github.com/johnpryan/289ecf8480ad005f01faeace70bd529a
const sampleCodeFlutterImplicitAnimations = '''
import 'dart:math';
import 'package:flutter/material.dart';

class DiscData {
  static final _rng = Random();

  final double size;
  final Color color;
  final Alignment alignment;

  DiscData()
      : size = _rng.nextDouble() * 40 + 10,
        color = Color.fromARGB(
          _rng.nextInt(200),
          _rng.nextInt(255),
          _rng.nextInt(255),
          _rng.nextInt(255),
        ),
        alignment = Alignment(
          _rng.nextDouble() * 2 - 1,
          _rng.nextDouble() * 2 - 1,
        );
}

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: const Color(0xFF15202D),
          child: const SizedBox.expand(
            child: VariousDiscs(50),
          ),
        ),
      ),
    ),
  );
}

class VariousDiscs extends StatefulWidget {
  final int numberOfDiscs;

  const VariousDiscs(this.numberOfDiscs);

  @override
  State<VariousDiscs> createState() => _VariousDiscsState();
}

class _VariousDiscsState extends State<VariousDiscs> {
  final _discs = <DiscData>[];

  @override
  void initState() {
    super.initState();
    _makeDiscs();
  }

  void _makeDiscs() {
    _discs.clear();
    for (int i = 0; i < widget.numberOfDiscs; i++) {
      _discs.add(DiscData());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _makeDiscs();
      }),
      child: Stack(
        children: [
          const Center(
            child: Text(
              'Click a disc!',
              style: TextStyle(color: Colors.white, fontSize: 50),
            ),
          ),
          for (final disc in _discs)
            Positioned.fill(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: disc.alignment,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    color: disc.color,
                    shape: BoxShape.circle,
                  ),
                  height: disc.size,
                  width: disc.size,
                ),
              ),
            ),
        ],
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

void main() async {
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

class _SourcesGroupFile {
  String filename;
  String content;

  _SourcesGroupFile(this.filename, this.content);
}

/// Holds all source files as well as reference to source
/// file that is active on client
class SourcesAndActiveSourceName {
  /// map of filename:content for all files in sources group
  final Map<String, String> sources;

  /// active source on client
  final String activeSourceName;

  const SourcesAndActiveSourceName(this.sources, this.activeSourceName);
}

///this RegExp matches a variety of possible `main` function definition formats
///Like:
///`Future<void> main(List<String> args) async {`
///`void main(List<String> args) async {`
///`void main() {`
///`void main( List < String >  args ) async {`
///`void main(Args arg) {`
///`main() {`
///`void main() {}`
final RegExp mainFunctionDefinition = RegExp(
    r'''[\s]*(Future)?[\<]?(void)?[\>]?[\s]*main[\s]*\((\s*\w*\s*\<?\s*\w*\s*\>?\s*\w*\s*)?\)\s*(async)?\s*{''');

/// this finds `{ "files" :` with any whitespace
///  (used to find multi file json as source)
final RegExp filesAtStartOfMap = RegExp(r'''\s*{\s*["']+files['"]+\s*:''');

/// this find `{ "active_source_name" :` with any whitespace
///  (used to find multi file json as source)
final RegExp activeSourceNameAtStartOfMap =
    RegExp(r'''\s*{\s*["']+active_source_name['"]+\s*:''');

/// remove 2 or more '..' and any number of following slashes of / or \ and
final RegExp sanitizeUpDirectories = RegExp(r'[\.]{2,}[\\\/]*');

/// this will get 'package:', 'dart:', 'http://', 'https://' etc.
final RegExp sanitizePackageDartHttp = RegExp(r'^[\w]*[\:][\/]*');

/// remove anything like package:, dart: http:// from filename
/// remove runs of more han '.' (no '..' up directories to escape temp)
String _sanitizeFileName(String filename) {
  filename = filename.replaceAll(sanitizePackageDartHttp, '');
  filename = filename.replaceAll(sanitizeUpDirectories, '');
  return filename;
}

/// Transforms incoming source or json into uniform representation.
/// [inputSrcOrSources] contains either simple source code
/// for the only file, or it contains a json object containing
/// set of source files and the client active source file.
/// This json object takes form of
/// `{"files":{"filename1":"sourcecode"...},"active_source_name":"filename from files"}`
/// returns a SourcesAndActiveSourceName object containing
/// a uniform representation of the SINGLE or MULTIPLE source
/// files represented by the original [inputSrcOrSources] string.
SourcesAndActiveSourceName getSourcesAndActiveSourceName(
    String inputSrcOrSources) {
  List<_SourcesGroupFile> files;
  String activeSourceName;

  if (inputSrcOrSources.startsWith(filesAtStartOfMap) ||
      inputSrcOrSources.startsWith(activeSourceNameAtStartOfMap)) {
    // We have a json object which must have a 'files' entry of a map file filenames to content
    // and a 'active_source_name' entry with the active source name (active editor on client)
    final jsonObj = json.decode(inputSrcOrSources) as Map<String, dynamic>;

    // with multiple files 'active_source_name' entry specifies the filename of the
    // within the files=[] list that any passed location applies to
    // default to kMainDart
    activeSourceName = _sanitizeFileName(
        (jsonObj['active_source_name'] as String?) ?? kMainDart);

    files = (jsonObj['files'] as Map<String, dynamic>?)
            ?.entries
            .map((e) => _SourcesGroupFile(e.key, e.value as String))
            .toList() ??
        [];

    bool foundKMain = false;
    // check for kMainDart file and also sanitize filenames
    for (final sourceFile in files) {
      if (sourceFile.filename == kMainDart) {
        foundKMain = true;
        continue;
      }
      sourceFile.filename = _sanitizeFileName(sourceFile.filename);
    }
    //one of the files must be called kMainDart!! this isn what
    //the bootstrap dart file will import and call main() on
    if (!foundKMain && files.isNotEmpty) {
      // We need to rename one to kMainDart, We really want the one with the main() function
      for (final sourceFile in files) {
        print(
            'Testing ${sourceFile.filename} hasMatch=${mainFunctionDefinition.hasMatch(sourceFile.content)}');

        if (mainFunctionDefinition.hasMatch(sourceFile.content)) {
          // this has a main() function, rename file file kMainDart
          // (and change activeSourceName if this was that)
          if (sourceFile.filename == activeSourceName) {
            activeSourceName = kMainDart;
          }
          sourceFile.filename = kMainDart;
          foundKMain = true;
          break;
        }
      }
      if (!foundKMain) {
        // still no kMainDart found, so just change the first file to be kMainDart
        if (files[0].filename == activeSourceName) {
          activeSourceName = kMainDart;
        }
        files[0].filename = kMainDart;
      }
    }
  } else {
    files = [_SourcesGroupFile(kMainDart, inputSrcOrSources)];
    activeSourceName = kMainDart;
  }

  // take our file list and make a files {filename:content} map
  final Map<String, String> sources = {
    for (final sourceFiles in files) sourceFiles.filename: sourceFiles.content,
  };

  return SourcesAndActiveSourceName(sources, activeSourceName);
}

/// Takes a map of a set of {"filename":"sourcecode"} source
/// files and extracts the imports from each file's sourcecode and
/// returns an overall list of all imports across all files in the set
List<ImportDirective> getAllImportsForFiles(Map<String, String> files) {
  final List<ImportDirective> imports = [];
  files.forEach((filename, content) {
    imports.addAll(getAllImportsFor(content));
  });
  return imports;
}
