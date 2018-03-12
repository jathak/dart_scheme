@Tags(const ["impl"])

import 'package:test/test.dart';

import 'tests.scm' show tests_scm;

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';
import 'package:cs61a_scheme_impl/impl.dart' show StaffProjectImplementation;

main() {
  /// tests.scm all runs in sequence, so we run it as one test here
  test("tests.scm", () {
    String output = runSchemeTests();
    if (output.isNotEmpty) fail(output);
  });
}

/// This is a very hacky wrapper around project-style tests.scm ported over
/// from the old interpreter.
String runSchemeTests() {
  String output = "";
  print(text) => output += '$text\n';
  int testCount = 0;
  int failedCount = 0;
  List<String> lines = tests_scm.split("\n");
  String log = "";
  List<String> run = [];
  bool foundError = false;
  var inter = new Interpreter(new StaffProjectImplementation());
  inter.importLibrary(new ExtraLibrary());
  bool awaitingInput = false;
  inter.logger = (Expression logging, [bool newline = true]) {
    if (logging is SchemeException) foundError = true;
    log += '$logging${newline ? '\n' : ''}';
  };
  int parenCount = 0;
  for (String line in lines) {
    if (line.startsWith('; expect ')) {
      List<String> expected = line.substring(9).split(";");
      List<String> actual = log.trim().split("\n");
      if (line == '; expect Error') {
        if (!foundError) {
          print("For Input:");
          print(run.join('\n'));
          print("Expected error");
          print("Actual:   ${formatActual(actual)}");
          print("");
          failedCount++;
        }
      } else if (!logsEqual(actual, expected)) {
        print("For Input:");
        print(run.join('\n'));
        print("Expected: ${line.substring(9)}");
        print("Actual:   ${formatActual(actual)}");
        print("");
        failedCount++;
      }
      testCount++;
    } else if (!line.startsWith(';')) {
      if (!awaitingInput) {
        log = "";
        run = [];
        foundError = false;
      }
      run.add(line);
      parenCount += countParens(line);
      awaitingInput = true;
      if (parenCount == 0) {
        awaitingInput = false;
        try {
          inter.run(run.join('\n'));
        } catch (e) {
          foundError = true;
          log += '$e\n';
        }
      }
    }
  }
  if (failedCount == 0) {
    return output;
  } else {
    print("Failed $failedCount/$testCount tests in tests.scm");
    return output;
  }
}

countParens(String text) {
  var tokens;
  try {
    tokens = tokenizeLines(text.split('\n')).toList();
  } on FormatException {
    return null;
  }
  int left = tokens.fold(0, (val, token) {
    return val + (token == const SchemeSymbol('(') ? 1 : 0);
  });
  int right = tokens.fold(0, (val, token) {
    return val + (token == const SchemeSymbol(')') ? 1 : 0);
  });
  return left - right;
}

formatActual(actual) {
  if (actual.length == 1) return actual[0];
  return '\n' + actual.join('\n');
}

logsEqual(actual, expected) {
  if (actual.length != expected.length) return false;
  for (int i = 0; i < actual.length; i++) {
    if (actual[i].trim() != expected[i].trim()) return false;
  }
  return true;
}