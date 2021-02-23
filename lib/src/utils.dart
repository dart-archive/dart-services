import 'package:path/path.dart' as path;

String stripFilePaths(String s) {
  return s.replaceAllMapped(RegExp(r'/\S*'), (match) {
    final urlString = match.group(0);
    final isDartPath = path.split(urlString).contains('lib');
    final basename = path.basename(urlString);

    if (isDartPath) {
      return path.join('dart:core', basename);
    }
    return basename;
  });
}
