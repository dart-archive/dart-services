library utils.tests;
import 'package:dart_services/src/utils.dart';
import 'package:expected_output/expected_output.dart';
import 'package:test/test.dart';

void main() {
  group('utils.stripFilePaths', () {
    for (var dataCase in dataCasesUnder(library: #utils.tests)) {
      test(dataCase.testDescription, () {
        var actualOutput = stripFilePaths(dataCase.input);
        expect(actualOutput, equals(dataCase.expectedOutput));
      });
    }
  });
}
