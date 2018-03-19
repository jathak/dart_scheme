import 'dart:io';
import 'dart:convert';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';
import 'package:cs61a_scheme_impl/impl.dart' show StaffProjectImplementation;

main() async {
  Interpreter interpreter = new Interpreter(new StaffProjectImplementation());
  var lines = stdin.transform(UTF8.decoder).transform(new LineSplitter());
  interpreter.logger = (e, newline) => newline ? print(e) : stdout.write(e);
  interpreter.onExit = () => exit(0);
  interpreter.importLibrary(new ExtraLibrary());
  addPrimitive(interpreter.globalEnv, const SchemeSymbol("tco"), (e, env) {
    interpreter.tailCallOptimized = e.first.isTruthy;
    return undefined;
  }, 1);
  stdout.write("scm> ");
  await for (String line in lines) {
    interpreter.run(line);
    stdout.write("scm> ");
  }
}
