import 'package:path/path.dart' as path;

String stripFilePaths(String s) {
  return s.replaceAllMapped(
      RegExp(r'/\S*'), (match) => path.basename(match.group(0)));
}
