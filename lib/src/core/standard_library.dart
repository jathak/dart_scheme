library cs61a_scheme.core.standard_library;

import 'dart:math' show pow;

import 'expressions.dart';
import 'logging.dart';
import 'procedures.dart';
import 'scheme_library.dart';
import 'utils.dart';

part '../../gen/core/standard_library.gen.dart';

@register
class StandardLibrary extends SchemeLibrary with _$StandardLibraryMixin {
  
  @primitive static Expression apply(Procedure procedure, PairOrEmpty args, Frame env) {
    return procedure.apply(args, env);
  }
  
  @primitive static Undefined display(Expression message, Frame env) {
    env.interpreter.logger(new DisplayOutput(message), false);
    return undefined;
  }
  
  @primitive static Expression error(Expression message) {
    throw new SchemeException(message.toString(), true, message);
  }
  
  @primitive static Expression eval(Expression expr, Frame env) {
    return schemeEval(expr, env);
  }
  
  @primitive static Expression exit() {
    throw const ExitException();
  }
  
  @primitive static Expression load(Expression file, Frame env) {
    throw new UnimplementedError("load has not yet been implemented");
  }
  
  @primitive static Undefined newline(Frame env) {
    env.interpreter.logger(new TextMessage(""), true);
    return undefined;
  }
  
  @primitive static Undefined print(Expression message, Frame env) {
    env.interpreter.logger(message, true);
    return undefined;
  }
  
  @primitive @SchemeSymbol("atom?") static Boolean isAtom(Expression val) {
    return b(val is Boolean || val is Number || val is SchemeSymbol || val.isNil);
  }
  
  @primitive @SchemeSymbol("integer?") static Boolean isInteger(Expression val) => b(val is Number && val.isInteger);
  @primitive @SchemeSymbol("list?") static Boolean isList(Expression val) => b(val is PairOrEmpty && val.isWellFormedList());
  @primitive @SchemeSymbol("number?") static Boolean isNumber(Expression val) => b(val is Number);
  @primitive @SchemeSymbol("null?") static Boolean isNull(Expression val) => b(val.isNil);
  @primitive @SchemeSymbol("pair?") static Boolean isPair(Expression val) => b(val is Pair);
  @primitive @SchemeSymbol("procedure?") static Boolean isProcedure(Expression val) => b(val is Procedure);
  @primitive @SchemeSymbol("promise?") static Boolean isPromise(Expression val) => b(val is Promise);
  @primitive @SchemeSymbol("string?") static Boolean isString(Expression val) => b(val is SchemeString);
  @primitive @SchemeSymbol("symbol?") static Boolean isSymbol(Expression val) => b(val is SchemeSymbol);
  @primitive static Expression append(List<Expression> args) {
    if (args.isEmpty) return nil;
    List<Expression> lst = [];
    for (Expression arg in args.take(args.length - 1)) {
      if (arg.isNil) continue;
      if (arg is Pair && arg.isWellFormedList()) lst.addAll(arg);
      else throw new SchemeException("Argument is not a well-formed list.");
    }
    Expression result = nil;
    Expression lastArg = args.last;
    if (lastArg is PairOrEmpty && lastArg.isWellFormedList()) lst.addAll(lastArg);
    else result = lastArg;
    for (Expression expr in lst.reversed) {
      result = new Pair(expr, result);
    }
    return result;
  }
  @primitive static Expression car(Pair val) => val.first;
  @primitive static Expression cdr(Pair val) => val.second;
  @primitive static Pair cons(Expression car, Expression cdr) => new Pair(car, cdr);
  @primitive static Number length(PairOrEmpty lst) => i(lst.length);
  @primitive static PairOrEmpty list(List<Expression> args) => new PairOrEmpty.fromIterable(args);
  @primitive @SchemeSymbol("+") static Number add(List<Expression> args) => allNumbers(args).fold(Number.ZERO, (a, b) => a + b);
  @primitive @SchemeSymbol("-") @MinArgs(1) static Number sub(List<Expression> args) {
    Iterable<Number> numbers = allNumbers(args);
    if (numbers.length == 1) return -(numbers.first);
    return numbers.skip(1).fold(numbers.first, (a, b) => a - b);
  }
  @primitive @SchemeSymbol("*") static Number mul(List<Expression> args) => allNumbers(args).fold(Number.ONE, (a, b) => a * b);
  @primitive @SchemeSymbol("/") @MinArgs(1) static Number truediv(List<Expression> args) {
    Iterable<Number> numbers = allNumbers(args);
    if (numbers.length == 1) return Number.ONE / (numbers.first);
    return numbers.skip(1).fold(numbers.first, (a, b) => a / b);
  }
  @primitive static Number abs(Number arg) => arg < Number.ZERO ? -arg : arg;
  @primitive static Number expt(Number base, Number power) {
    if (power.isInteger) {
      Number total = Number.ONE;
      for (Number i = Number.ZERO; i < power; i += Number.ONE) {
        total *= base;
      }
      return total;
    }
    return n(pow(base.toJS(), power.toJS()));
  }
  @primitive static Number modulo(Number a, Number b) => a % b;
  @primitive static Number quotient(Number a, Number b) => a ~/ b;
  @primitive static Number remainder(Number a, Number b) {
    Number mod = modulo(a, b);
    while ((mod < Number.ZERO && a > Number.ZERO) ||
           (mod > Number.ZERO && a < Number.ZERO)) {
      mod -= a;
    }
    return mod;
  }
  @primitive @SchemeSymbol("eq?") static Boolean isEq(Expression x, Expression y) {
    if (x is Number && y is Number) return b(x == y);
    if (x is SchemeSymbol && y is SchemeSymbol) return b(x == y);
    if (x is SchemeString && y is SchemeString) return b(x == y);
    return b(identical(x, y));
  }
  @primitive @SchemeSymbol("equal?") static Boolean isEqual(Expression x, Expression y) => b(x == y);
  @primitive @SchemeSymbol("not") static Boolean not(Expression arg) => b(!arg.isTruthy);
  @primitive @SchemeSymbol("=") static Boolean eqNumbers(Number x, Number y) => b(x == y);
  @primitive @SchemeSymbol("<") static Boolean lt(Number x, Number y) => b(x < y);
  @primitive @SchemeSymbol(">") static Boolean gt(Number x, Number y) => b(x > y);
  @primitive @SchemeSymbol("<=") static Boolean le(Number x, Number y) => b(x <= y);
  @primitive @SchemeSymbol(">=") static Boolean ge(Number x, Number y) => b(x >= y);
  @primitive @SchemeSymbol("even?") static Boolean isEven(Number x) => b(x % Number.TWO == Number.ZERO);
  @primitive @SchemeSymbol("odd?") static Boolean isOdd(Number x) => b(x % Number.TWO == Number.ONE);
  @primitive @SchemeSymbol("zero?") static Boolean isZero(Number x) => b(x == Number.ZERO);
  @primitive static Expression force(Promise p) => p.force();
  @primitive @SchemeSymbol("cdr-stream") static Expression cdrStream(Pair p) => force(cdr(p));
  @primitive @SchemeSymbol("set-car!") static Undefined setCar(Pair p, Expression val) {
    p.first = val;
    return undefined;
  }
  @primitive @SchemeSymbol("set-cdr!") static Undefined setCdr(Pair p, Expression val) {
    p.second = val;
    return undefined;
  }
}
