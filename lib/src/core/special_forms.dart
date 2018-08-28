library cs61a_scheme.core.special_forms;

import 'expressions.dart';
import 'frame.dart';
import 'logging.dart';
import 'procedures.dart';
import 'utils.dart' show checkForm, schemeEval;
import 'values.dart';

typedef SpecialForm = Value Function(PairOrEmpty expressions, Frame env);

Value doDefineForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.doDefineForm(expressions, env);

Value doIfForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.doIfForm(expressions, env);

Value doCondForm(PairOrEmpty expressions, Frame env) {
  while (!expressions.isNil) {
    Expression clause = expressions.pair.first;
    checkForm(clause, 1);
    Value test;
    if (clause.pair.first == const SchemeSymbol('else')) {
      test = schemeTrue;
    } else {
      test = schemeEval(clause.pair.first, env);
    }
    if (test.isTruthy) {
      return env.interpreter.impl.evalCondResult(clause, env, test);
    }
    expressions = expressions.pair.second;
  }
  return undefined;
}

Value doAndForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.doAndForm(expressions, env);

Value doOrForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.doOrForm(expressions, env);

Value doLetForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 2);
  Expression bindings = expressions.pair.first;
  Expression body = expressions.pair.second;
  Frame letEnv = env.interpreter.impl.makeLetFrame(bindings, env);
  env.interpreter.triggerEvent(const SchemeSymbol('new-frame'), [], letEnv);
  Value result = env.interpreter.impl.evalAll(body, letEnv);
  env.interpreter.triggerEvent(const SchemeSymbol('return'), [result], letEnv);
  return result;
}

Value doBeginForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 1);
  return env.interpreter.impl.evalAll(expressions, env);
}

LambdaProcedure doLambdaForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.doLambdaForm(expressions, env);

MuProcedure doMuForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.doMuForm(expressions, env);

Expression doQuoteForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.doQuoteForm(expressions, env);

Promise doDelayForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 1, 1);
  return Promise(expressions.pair.first, env);
}

Pair<Value, Promise> doConsStreamForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 2, 2);
  Promise promise = doDelayForm(expressions.pair.second, env);
  return Pair(schemeEval(expressions.pair.first, env), promise);
}

Value doDefineMacroForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.doDefineMacro(expressions, env);

Undefined doSetForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 2, 2);
  Expression name = expressions.first;
  if (name is! SchemeSymbol) throw SchemeException("$name is not a symbol");
  Expression value = schemeEval(expressions.elementAt(1), env);
  env.update(name as SchemeSymbol, value);
  return undefined;
}

Expression doQuasiquoteForm(PairOrEmpty expressions, Frame env) {
  checkForm(expressions, 1, 1);
  Expression expr = expressions.first;
  Pair<Expression, Boolean> result = quasiquoteItem(expr, env);
  if (result.second.isTruthy) {
    throw SchemeException("unquote-splicing not in list template: $expr");
  }
  return result.first;
}

Pair<Expression, Boolean> quasiquoteItem(Expression v, Frame env,
    [int level = 1]) {
  if (v is! Pair) return Pair(v, schemeFalse);
  Pair val = v.pair;
  bool splice = val.first == const SchemeSymbol('unquote-splicing');
  if (val.first == const SchemeSymbol('unquote') || splice) {
    if (--level == 0) {
      Expression exprs = val.second;
      checkForm(exprs, 1, 1);
      Expression eval = schemeEval(exprs.pair.first, env);
      if (splice && !(eval is PairOrEmpty && eval.wellFormed)) {
        throw SchemeException('unquote-splicing used on non-list $eval');
      }
      return Pair(eval, Boolean(splice));
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
      return Pair(Pair.append([first, second]), schemeFalse);
    }
    return Pair(first, schemeFalse);
  }
  return Pair(Pair(first, second), schemeFalse);
}

Expression doUnquoteForm(PairOrEmpty expressions, Frame env) {
  throw SchemeException("Unquote outside of quasiquote");
}
