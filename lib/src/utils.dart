import 'package:path/path.dart' as path;

String stripFilePaths(String s) {
  return s.replaceAllMapped(RegExp(r'(?:package:?)?[a-z]*\/\S*'), (match) {
    final urlString = match.group(0);
    final isDartPath = path.split(urlString).contains('lib');
    final isPackagePath = urlString.contains('package:');
    final basename = path.basename(urlString);

    if (isDartPath) {
      return path.join('dart:core', basename);
    }

    if (isPackagePath) {
      return urlString;
    }
    return basename;
  });
}
