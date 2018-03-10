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
  checkForm(expressions, 1, 1);
  Expression expr = expressions.first;
  Pair<Expression, Boolean> result = quasiquoteItem(expr, env);
  if (result.second.isTruthy) {
    throw new SchemeException("unquote-splicing not in list template: ${expr}");
  }
  return result.first;
}

Pair<Expression, Boolean> quasiquoteItem(Expression v, Frame env, [int level = 1]) {
  if (v is! Pair) return new Pair(v, schemeFalse);
  Pair val = v.pair;
  bool splice = val.first == const SchemeSymbol('unquote-splicing');
  if (val.first == const SchemeSymbol('unquote') || splice) {
    if (--level == 0) {
      Expression exprs = val.second;
      checkForm(exprs, 1, 1);
      Expression eval = schemeEval(exprs.pair.first, env);
      if (splice && !(eval is PairOrEmpty && eval.wellFormed)) {
        throw new SchemeException('unquote-splicing used on non-list ${eval}');
      }
      return new Pair(eval, new Boolean(splice));
    }
  } else if (val.first == const SchemeSymbol('quasiquote')) {
    level++;
  }
  Pair<Expression, Boolean> result = quasiquoteItem(val.first, env, level);
  Expression first = result.first;
  splice = result.second.isTruthy;
  Expression second = quasiquoteItem(val.second, env, level).first;
  if (splice) {
    if (!second.isNil) {
      return new Pair(Pair.append([first, second]), schemeFalse);
    }
    return new Pair(first, schemeFalse);
  }
  return new Pair(new Pair(first, second), schemeFalse);
}

Expression doUnquoteForm(PairOrEmpty expressions, Frame env) {
  throw new SchemeException("Unquote outside of quasiquote");
}
