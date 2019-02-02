library cs61a_scheme.core.special_forms;

import 'expressions.dart';
import 'frame.dart';
import 'logging.dart';
import 'procedures.dart';
import 'utils.dart' show checkForm, schemeEval;
import 'values.dart';
import 'wrappers.dart';

typedef SpecialForm = Value Function(
    SchemeList<Expression> expressions, Frame env);

Value doDefineForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.doDefineForm(expressions, env);

Value doIfForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.doIfForm(expressions, env);

Value doCondForm(SchemeList<Expression> expressions, Frame env) {
  for (Expression clauseExpr in expressions) {
    var clause = SchemeList<Expression>(clauseExpr);
    checkForm(clause, 1);
    Value test;
    if (clause.first == const SchemeSymbol('else')) {
      test = schemeTrue;
    } else {
      test = schemeEval(clause.first, env);
    }
    if (test.isTruthy) {
      return env.interpreter.impl.evalCondResult(clause, env, test);
    }
  }
  return undefined;
}

Value doAndForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.doAndForm(expressions, env);

Value doOrForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.doOrForm(expressions, env);

Value doLetForm(SchemeList<Expression> expressions, Frame env) {
  checkForm(expressions, 2);
  var bindings = SchemeList<Expression>(expressions.first);
  var body = expressions.rest;
  Frame letEnv = env.interpreter.impl.makeLetFrame(bindings, env);
  env.interpreter.triggerEvent(const SchemeSymbol('new-frame'), [], letEnv);
  Value result = env.interpreter.impl.evalAll(body, letEnv);
  env.interpreter.triggerEvent(const SchemeSymbol('return'), [result], letEnv);
  return result;
}

Value doBeginForm(SchemeList<Expression> expressions, Frame env) {
  checkForm(expressions, 1);
  return env.interpreter.impl.evalAll(expressions, env);
}

LambdaProcedure doLambdaForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.doLambdaForm(expressions, env);

MuProcedure doMuForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.doMuForm(expressions, env);

Expression doQuoteForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.doQuoteForm(expressions, env);

Promise doDelayForm(SchemeList<Expression> expressions, Frame env) {
  checkForm(expressions, 1, 1);
  return Promise(expressions.first, env);
}

Pair<Value, Promise> doConsStreamForm(
    SchemeList<Expression> expressions, Frame env) {
  checkForm(expressions, 2, 2);
  Promise promise = doDelayForm(expressions.rest, env);
  return Pair(schemeEval(expressions.first, env), promise);
}

Value doDefineMacroForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.doDefineMacro(expressions, env);

Undefined doSetForm(SchemeList<Expression> expressions, Frame env) {
  checkForm(expressions, 2, 2);
  Expression name = expressions.first;
  if (name is! SchemeSymbol) throw SchemeException("$name is not a symbol");
  Expression value = schemeEval(expressions.skip(1).first, env);
  env.update(name as SchemeSymbol, value);
  return undefined;
}

Value doQuasiquoteForm(SchemeList<Expression> expressions, Frame env) {
  checkForm(expressions, 1, 1);
  Expression expr = expressions.first;
  Pair<Value, Boolean> result = quasiquoteItem(expr, env);
  if (result.second.isTruthy) {
    throw SchemeException("unquote-splicing not in list template: $expr");
  }
  return result.first;
}

Pair<Value, Boolean> quasiquoteItem(Value v, Frame env, [int level = 1]) {
  if (v is! Pair) return Pair(v, schemeFalse);
  Pair val = v.pair;
  bool splice = val.first == const SchemeSymbol('unquote-splicing');
  if (val.first == const SchemeSymbol('unquote') || splice) {
    if (--level == 0) {
      SchemeList exprs = SchemeList(val.second);
      checkForm(exprs, 1, 1);
      Value eval = schemeEval(exprs.first, env);
      if (splice && !(eval is PairOrEmpty && eval.wellFormed)) {
        throw SchemeException('unquote-splicing used on non-list $eval');
      }
      return Pair(eval, Boolean(splice));
    }
  } else if (val.first == const SchemeSymbol('quasiquote')) {
    level++;
  }
  Pair<Value, Boolean> result = quasiquoteItem(val.first, env, level);
  Value first = result.first;
  splice = result.second.isTruthy;
  Value second = quasiquoteItem(val.second, env, level).first;
  if (splice) {
    if (!second.isNil) {
      return Pair(Pair.append([first, second]), schemeFalse);
    }
    return Pair(first, schemeFalse);
  }
  return Pair(Pair(first, second), schemeFalse);
}

Value doUnquoteForm(SchemeList<Expression> expressions, Frame env) {
  throw SchemeException("Unquote outside of quasiquote");
}
