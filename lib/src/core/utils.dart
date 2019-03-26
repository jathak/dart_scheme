library cs61a_scheme.core.utils;

import 'dart:async';

import 'documentation.dart';
import 'expressions.dart';
import 'frame.dart';
import 'logging.dart';
import 'procedures.dart';
import 'reader.dart';
import 'values.dart';
import 'wrappers.dart';

void checkForm(SchemeList expressions, int min, [int max = -1]) {
  int length = expressions.length;
  if (length < min) {
    throw SchemeException("$expressions must contain at least $min items.");
  }
  if (max > -1 && length > max) {
    throw SchemeException("$expressions may contain at most $max items.");
  }
  return;
}

void checkFormals(Expression formals) {
  var symbols = <SchemeSymbol>{};
  void checkAndAdd(Expression symbol) {
    if (symbol is! SchemeSymbol) {
      throw SchemeException("Non-symbol: $symbol");
    } else if (symbols.contains(symbol)) {
      throw SchemeException("Duplicate symbol: $symbol");
    }
    symbols.add(symbol);
  }

  while (formals is Pair) {
    checkAndAdd(formals.pair.first);
    formals = formals.pair.second;
  }
  if (!formals.isNil) checkAndAdd(formals);
}

Value schemeEval(Expression expr, Frame env) {
  try {
    return completeEval(expr.evaluate(env));
  } on SchemeException catch (e) {
    e.addCall(expr);
    rethrow;
  }
}

Value schemeApply(Procedure procedure, SchemeList args, Frame env) =>
    completeEval(procedure.apply(args, env));

Value evalCallExpression(Pair expr, Frame env) {
  if (!expr.wellFormed) {
    throw SchemeException("Malformed list: $expr");
  }
  Expression first = expr.first;
  Expression rest = expr.second;
  if (first is SchemeSymbol &&
      env.interpreter.specialForms.containsKey(first)) {
    var result =
        env.interpreter.specialForms[first](SchemeList<Expression>(rest), env);
    env.interpreter.triggerEvent(first, [rest], env);
    return result;
  }
  env.interpreter
      .triggerEvent(const SchemeSymbol('call-expression'), [expr], env);
  return env.interpreter.impl.evalProcedureCall(first, rest, env);
}

Value completeEval(Value val) =>
    val is Thunk ? schemeEval(val.expr, val.env) : val;

addBuiltin(Frame env, SchemeSymbol name, SchemeBuiltin fn, int args,
    {Docs docs}) {
  env.define(name, BuiltinProcedure.fixed(name, fn, args)..docs = docs, true);
}

addVariableBuiltin(Frame env, SchemeSymbol name, SchemeBuiltin fn, int minArgs,
    {int maxArgs = -1, Docs docs}) {
  var p = BuiltinProcedure.variable(name, fn, minArgs, maxArgs);
  p.docs = docs;
  env.define(name, p, true);
}

int countParens(String text) {
  Iterable<Expression> tokens;
  try {
    tokens = tokenizeLines(text.split('\n')).toList();
  } on FormatException {
    return null;
  }
  int left = tokens.fold(
      0, (val, token) => val + (token == const SchemeSymbol('(') ? 1 : 0));
  int right = tokens.fold(
      0, (val, token) => val + (token == const SchemeSymbol(')') ? 1 : 0));
  return left - right;
}

Future delay(int milliseconds) =>
    Future.delayed(Duration(milliseconds: milliseconds));

Map<String, Docs> allDocumentedForms(Frame env) {
  var forms = <String, Docs>{};
  for (var value in env.bindings.values) {
    if (value is Procedure && value.docs != null) {
      forms[value.name.value] = value.docs;
    }
  }
  for (var special in env.interpreter.specialForms.keys) {
    if (miscDocumentation.containsKey(special.value)) {
      forms[special.value] = miscDocumentation[special.value];
    }
  }
  return forms;
}
