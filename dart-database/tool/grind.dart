import 'dart:io';

import 'package:grinder/grinder.dart';

main(List<String> args) => grind(args);

@Task('Generate the discovery doc and Dart library from the annotated API')
discovery() {
  ProcessResult result = Process.runSync(
      'dart', ['bin/server.dart', '--discovery']);

  if (result.exitCode != 0) {
    throw 'Error generating the discovery document\n${result.stderr}';
  }

  File discoveryFile = new File('doc/dbservices.json');
  discoveryFile.parent.createSync();
  log('writing ${discoveryFile.path}');
  discoveryFile.writeAsStringSync(result.stdout.trim() + '\n');

  // Generate the Dart library from the json discovery file.
  Pub.global.activate('discoveryapis_generator');
  Pub.global.run('discoveryapis_generator:generate', arguments: [
    'files',
    '--input-dir=doc/',
    '--output-dir=doc/',
    '--no-core-prefixes'
  ]);
}
