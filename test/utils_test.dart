import 'package:dart_services/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('utils.stripFilePaths', () {
    test('Strips temporary directory paths', () {
      var errorMessage = 'List is defined in '
          '/var/folders/4p/y54w9nqj0_n6ryqwn7lxqz6800m6cw/T/'
          'DartAnalysisWrapperintLAw/main.dart';
      var expected = 'List is defined in main.dart';
      expect(stripFilePaths(errorMessage), equals(expected));
    });

    test('Strips temporary directory paths', () {
      var errorMessage = "The argument type 'List<int> (where List is defined "
          "in /Users/username/sdk/dart/2.10.5/lib/core/list.dart)' can't be "
          "assigned to the parameter type 'List<int> (where List is defined "
          "in /var/folders/4p/tmp/T/DartAnalysisWrapperintLAw/main.dart)'.";
      var expected = "The argument type 'List<int> (where List is defined "
          "in list.dart)' can't be "
          "assigned to the parameter type 'List<int> (where List is defined "
          "in main.dart)'.";
      expect(stripFilePaths(errorMessage), equals(expected));
    });
  });
}
