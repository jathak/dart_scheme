import 'dart:io';

import 'package:cli_repl/cli_repl.dart';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';
import 'package:cs61a_scheme_impl/impl.dart' show StaffProjectImplementation;

main() {
  Interpreter interpreter = Interpreter(StaffProjectImplementation());
  interpreter.importLibrary(ExtraLibrary());
  interpreter.importLibrary(LogicLibrary());
  interpreter.logger = (e, newline) => newline ? print(e) : stdout.write(e);
  interpreter.onExit = () => exit(0);
  addPrimitive(interpreter.globalEnv, const SchemeSymbol("tco"), (e, env) {
    interpreter.tailCallOptimized = e.first.isTruthy;
    return undefined;
  }, 1);
  var repl = Repl(prompt: 'scm> ', validator: matchingParens);
  repl.run().forEach(interpreter.run);
}

bool matchingParens(String text) {
  int count = countParens(text);
  return count == 0 || count == null;
}
