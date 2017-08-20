library cs61a_scheme.core.special_forms;

import 'expressions.dart';
import 'logging.dart';
import 'procedures.dart';
import 'utils.dart' show checkForm, schemeEval;

typedef Expression SpecialForm(PairOrEmpty expressions, Frame env);

Expression doDefineForm(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.doDefineForm(expressions, env);
}

Expression doIfForm(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.doIfForm(expressions, env);
}

Expression doCondForm(PairOrEmpty expressions, Frame env) {
  while (!expressions.isNil) {
    Expression clause = expressions.pair.first;
    checkForm(clause, 1);
    Expression test;
    if (clause.pair.first == const SchemeSymbol('else')) {
      test = schemeTrue;
    } else {
      test = schemeEval(clause.pair.first, env);
    }
    if (test.isTruthy) {
      return env.interpreter.implementation.evalCondResult(clause, env, test);
    }
    expressions = expressions.pair.second;
  }
  return undefined;
}

Expression doAndForm(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.doAndForm(expressions, env);
}

Expression doOrForm(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.doOrForm(expressions, env);
}

Expression doLetForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 2);
  Expression bindings = expressions.pair.first;
  Expression body = expressions.pair.second;
  Frame letEnv = env.interpreter.implementation.makeLetFrame(bindings, env);
  env.interpreter.triggerEvent(const SchemeSymbol('new-frame'), [], letEnv);
  Expression result = env.interpreter.implementation.evalAll(body, letEnv);
  env.interpreter.triggerEvent(const SchemeSymbol('return'), [result], letEnv);
  return result;
}

Expression doBeginForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 1);
  return env.interpreter.implementation.evalAll(expressions, env);
}

LambdaProcedure doLambdaForm(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.doLambdaForm(expressions, env);
}

MuProcedure doMuForm(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.doMuForm(expressions, env);
}

Expression doQuoteForm(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.doQuoteForm(expressions, env);
}

Promise doDelayForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 1, 1);
  return new Promise(expressions.pair.first, env);
}

Pair<Expression, Promise> doConsStreamForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 2, 2);
  Promise promise = doDelayForm(expressions.pair.second, env);
  return new Pair(schemeEval(expressions.pair.first, env), promise);
}

Expression doDefineMacroForm(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.doDefineMacro(expressions, env);
}

Expression doSetForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 2, 2);
  Expression name = expressions.first;
  if (name is! SchemeSymbol) throw new SchemeException("$name is not a symbol");
  Expression value = schemeEval(expressions.elementAt(1), env);
  env.update(name as SchemeSymbol, value);
  return undefined;
}

Expression doQuasiquoteForm(PairOrEmpty expressions, Frame env) {
  throw new UnimplementedError("Special form not yet implemented.");
}

Expression doUnquoteForm(PairOrEmpty expressions, Frame env) {
  throw new UnimplementedError("Special form not yet implemented.");
}

Expression doUnquoteSplicingForm(PairOrEmpty expressions, Frame env) {
  throw new UnimplementedError("Special form not yet implemented.");
}
