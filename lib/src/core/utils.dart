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

/// Checks that [expressions] contains at least [min] items and (if set) no
/// more than [max] items.
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

/// Checks that [formals] is a valid formal parameter list.
void checkFormals(Expression formals) {
  var symbols = <SchemeSymbol>{};
  void checkAndAdd(Expression symbol) {
    if (symbol is Pair && symbol.first == const SchemeSymbol("variadic")) {
      checkForm(SchemeList(symbol.second), 1, 1);
      if (symbol.second is Pair) {
        checkAndAdd(symbol.second.pair.first);
      }
    } else if (symbol is! SchemeSymbol) {
      throw SchemeException("Non-symbol: $symbol");
    } else if (symbols.contains(symbol)) {
      throw SchemeException("Duplicate symbol: $symbol");
    } else {
      symbols.add(symbol);
    }
  }

  while (formals is Pair) {
    checkAndAdd(formals.pair.first);
    formals = formals.pair.second;
  }
  if (!formals.isNil) checkAndAdd(formals);
}

/// Evaluates [expr] in the environment [env].
Value schemeEval(Expression expr, Frame env) {
  try {
    return completeEval(expr.evaluate(env));
  } on SchemeException catch (e) {
    e.addCall(expr);
    rethrow;
  }
}

/// Applies [procedure] with [args] in environment [env].
Value schemeApply(Procedure procedure, SchemeList args, Frame env) =>
    completeEval(procedure.apply(args, env));

/// Evaluates a call expression [expr] in [env].
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

/// Unwraps [val] until it is no longer a thunk.
Value completeEval(Value val) =>
    val is Thunk ? schemeEval(val.expr, val.env) : val;

/// Adds a built-in procedure to [env] that takes a fixed number of arguments.
addBuiltin(Frame env, SchemeSymbol name, SchemeBuiltin fn, int args,
    {Docs docs}) {
  env.define(name, BuiltinProcedure.fixed(name, fn, args)..docs = docs, true);
}

/// Adds a variable-arity built-in procedure to [env].
addVariableBuiltin(Frame env, SchemeSymbol name, SchemeBuiltin fn, int minArgs,
    {int maxArgs = -1, Docs docs}) {
  var p = BuiltinProcedure.variable(name, fn, minArgs, maxArgs);
  p.docs = docs;
  env.define(name, p, true);
}

/// Counts the number of unmatched parens in [text].
///
/// If greater than 0, there are that many unclosed open parens.
/// If less than 0, there are extra closed parens.
/// If equal to 0, the parens match.
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

/// Returns a future that completes after the given number of [milliseconds].
Future delay(int milliseconds) =>
    Future.delayed(Duration(milliseconds: milliseconds));

/// Returns a map from names to documentation for all forms in [env].
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
