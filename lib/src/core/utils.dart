library cs61a_scheme.core.utils;

import 'expressions.dart';
import 'logging.dart';
import 'procedures.dart';

void checkForm(Expression expressions, int min, [int max = -1]) {
  if (expressions is PairOrEmpty && expressions.isWellFormedList()) {
    int length = expressions.length;
    if (length < min) throw new SchemeException("$expressions must contain at least $min items.");
    if (max > -1 && length > max) {
      throw new SchemeException("$expressions may contain at most $max items.");
    }
    return;
  } 
  throw new SchemeException("$expressions is not a valid list.");
}

void checkFormals(Expression formals) {
  var symbols = new Set<SchemeSymbol>();
  void checkAndAdd(Expression symbol) {
    if (symbol is! SchemeSymbol) {
      throw new SchemeException("Non-symbol: $symbol");
    } else if (symbols.contains(symbol)) {
      throw new SchemeException("Duplicate symbol: $symbol");
    }
    symbols.add(symbol);
  }
  while (formals is Pair) {
    checkAndAdd(formals.pair.first);
    formals = formals.pair.second;
  }
  if (!formals.isNil) checkAndAdd(formals);
}

Expression schemeEval(Expression expr, Frame env) {
  return completeEval(expr.evaluate(env));
}

Expression completeEval(val) => val is Thunk ? val.evaluate(null) : val;

addPrimitive(Frame env, SchemeSymbol name, SchemePrimitive fn, int args) {
  env.define(name, new PrimitiveProcedure.fixed(name, fn, args));
}

addVariablePrimitive(Frame env, SchemeSymbol name, SchemePrimitive fn,
    int minArgs, [int maxArgs = -1]) {
  var p = new PrimitiveProcedure.variable(name, fn, minArgs, maxArgs);
  env.define(name, p);
}

Boolean b(bool val) => val ? schemeTrue : schemeFalse;
Number n(num dartNum) => dartNum is double ? d(dartNum) : i(dartNum as int);
Number i(int dartInt) => new Number.fromInteger(dartInt);
Number d(double dartDouble) => new Number.fromDouble(dartDouble);
Iterable<Number> allNumbers(List<Expression> expr) {
  return expr.map((ex) => ex is Number ? ex : throw new SchemeException("$ex is not a number."));
}
