import 'dart:io';

import 'package:cli_repl/cli_repl.dart';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';
import 'package:cs61a_scheme_impl/impl.dart' show StaffProjectImplementation;

main() {
  Interpreter interpreter = new Interpreter(new StaffProjectImplementation());
  interpreter.importLibrary(new ExtraLibrary());
  interpreter.importLibrary(new LogicLibrary());
  interpreter.logger = (e, newline) => newline ? print(e) : stdout.write(e);
  interpreter.onExit = () => exit(0);
  addPrimitive(interpreter.globalEnv, const SchemeSymbol("tco"), (e, env) {
    interpreter.tailCallOptimized = e.first.isTruthy;
    return undefined;
  }, 1);
  var repl = new Repl(prompt: 'scm> ', validator: matchingParens);
  for (var expr in repl.run()) {
    interpreter.run(expr);
  }
}

bool matchingParens(String text) {
  var tokens;
  try {
    tokens = tokenizeLines(text.split('\n')).toList();
  } on FormatException {
    return true;
  }
  int left = tokens.fold(0, (val, token) {
    return val + (token == const SchemeSymbol('(') ? 1 : 0);
  });
  int right = tokens.fold(0, (val, token) {
    return val + (token == const SchemeSymbol(')') ? 1 : 0);
  });
  return right >= left;
}
