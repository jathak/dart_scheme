library cs61a_scheme.extra.logic_library;

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'package:cs61a_scheme/logic.dart' as logic;

import 'operand_procedures.dart';

part 'logic_library.g.dart';

/// Note: When the signatures (including any annotations) of any of theses methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the primitives and performs type checking on arguments).
@schemelib
class LogicLibrary extends SchemeLibrary with _$LogicLibraryMixin {
  List<logic.Fact> facts = [];

  @SchemeSymbol('fact')
  @SchemeSymbol('!')
  @noeval
  void fact(List<Expression> exprs) {
    facts.add(logic.Fact(exprs.first, exprs.skip(1)));
  }

  @SchemeSymbol('query')
  @SchemeSymbol('?')
  @noeval
  void query(List<Expression> exprs, Frame env) {
    bool success = false;
    for (var sol in logic.evaluate(logic.Query(exprs), facts)) {
      if (!success) env.interpreter.logText('Success!');
      success = true;
      env.interpreter.logger(sol, true);
    }
    if (!success) env.interpreter.logText('Failure.');
    return null;
  }

  @SchemeSymbol('query-one')
  @noeval
  void queryOne(List<Expression> exprs, Frame env) {
    var sols = logic.evaluate(logic.Query(exprs), facts);
    if (sols.isNotEmpty) {
      env.interpreter.logText('Success!');
      env.interpreter.logger(sols.first, true);
    } else {
      env.interpreter.logText('Failure.');
    }
    return null;
  }

  @SchemeSymbol('prolog')
  String prolog() => facts.map((f) => f.toProlog()).join('\n') + '\n';
}
