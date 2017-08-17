library cs61a_scheme.core.standard_library;

import 'dart:math' show pow;

import 'expressions.dart';
import 'logging.dart';
import 'procedures.dart';
import 'scheme_library.dart';
import 'utils.dart';

part '../../gen/core/standard_library.gen.dart';

/// Note: When the signatures (including any annotations) of any of this methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the primitives and performs type checking on arguments).
@register
class StandardLibrary extends SchemeLibrary with _$StandardLibraryMixin {
  
  @primitive Expression apply(Procedure procedure, PairOrEmpty args, Frame env) {
    return schemeApply(procedure, args, env);
  }
  
  @primitive void display(Expression message, Frame env) {
    env.interpreter.logger(new DisplayOutput(message), false);
  }
  
  @primitive Expression error(Expression message) {
    throw new SchemeException(message.toString(), true, message);
  }
  
  @primitive Expression eval(Expression expr, Frame env) {
    return schemeEval(expr, env);
  }
  
  @primitive Expression exit() {
    throw const ExitException();
  }
  
  @primitive Expression load(Expression file, Frame env) {
    throw new UnimplementedError("load has not yet been implemented");
  }
  
  @primitive void newline(Frame env) {
    env.interpreter.logger(new TextMessage(""), true);
  }
  
  @primitive void print(Expression message, Frame env) {
    env.interpreter.logger(message, true);
  }
  
  @primitive @SchemeSymbol("atom?") bool isAtom(Expression val) {
    return val is Boolean || val is Number || val is SchemeSymbol || val.isNil;
  }
  
  @primitive @SchemeSymbol("integer?") bool isInteger(Expression val) => val is Number && val.isInteger;
  @primitive @SchemeSymbol("list?") bool isList(Expression val) => val is PairOrEmpty && val.isWellFormedList();
  @primitive @SchemeSymbol("number?") bool isNumber(Expression val) => val is Number;
  @primitive @SchemeSymbol("null?") bool isNull(Expression val) => val.isNil;
  @primitive @SchemeSymbol("pair?") bool isPair(Expression val) => val is Pair;
  @primitive @SchemeSymbol("procedure?") bool isProcedure(Expression val) => val is Procedure;
  @primitive @SchemeSymbol("promise?") bool isPromise(Expression val) => val is Promise;
  @primitive @SchemeSymbol("string?") bool isString(Expression val) => val is SchemeString;
  @primitive @SchemeSymbol("symbol?") bool isSymbol(Expression val) => val is SchemeSymbol;
  @primitive Expression append(List<Expression> args) {
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
  @primitive Expression car(Pair val) => val.first;
  @primitive Expression cdr(Pair val) => val.second;
  @primitive Pair cons(Expression car, Expression cdr) => new Pair(car, cdr);
  @primitive Number length(PairOrEmpty lst) => new Number.fromInt(lst.length);
  @primitive PairOrEmpty list(List<Expression> args) => new PairOrEmpty.fromIterable(args);
  @primitive @SchemeSymbol("+") Number add(List<Expression> args) => allNumbers(args).fold(Number.ZERO, (a, b) => a + b);
  @primitive @SchemeSymbol("-") @MinArgs(1) Number sub(List<Expression> args) {
    Iterable<Number> numbers = allNumbers(args);
    if (numbers.length == 1) return -(numbers.first);
    return numbers.skip(1).fold(numbers.first, (a, b) => a - b);
  }
  @primitive @SchemeSymbol("*") Number mul(List<Expression> args) => allNumbers(args).fold(Number.ONE, (a, b) => a * b);
  @primitive @SchemeSymbol("/") @MinArgs(1) Number truediv(List<Expression> args) {
    Iterable<Number> numbers = allNumbers(args);
    if (numbers.length == 1) return Number.ONE / (numbers.first);
    return numbers.skip(1).fold(numbers.first, (a, b) => a / b);
  }
  @primitive Number abs(Number arg) => arg < Number.ZERO ? -arg : arg;
  @primitive Number expt(Number base, Number power) {
    if (power.isInteger) {
      Number total = Number.ONE;
      for (Number i = Number.ZERO; i < power; i += Number.ONE) {
        total *= base;
      }
      return total;
    }
    return new Number.fromNum(pow(base.toJS(), power.toJS()));
  }
  @primitive Number modulo(Number a, Number b) => a % b;
  @primitive Number quotient(Number a, Number b) => a ~/ b;
  @primitive Number remainder(Number a, Number b) {
    Number mod = modulo(a, b);
    while ((mod < Number.ZERO && a > Number.ZERO) ||
           (mod > Number.ZERO && a < Number.ZERO)) {
      mod -= a;
    }
    return mod;
  }
  @primitive @SchemeSymbol("eq?") bool isEq(Expression x, Expression y) {
    if (x is Number && y is Number) return x == y;
    if (x is SchemeSymbol && y is SchemeSymbol) return x == y;
    if (x is SchemeString && y is SchemeString) return x == y;
    return identical(x, y);
  }
  @primitive @SchemeSymbol("equal?") bool isEqual(Expression x, Expression y) => x == y;
  @primitive @SchemeSymbol("not") bool not(Expression arg) => !arg.isTruthy;
  @primitive @SchemeSymbol("=") bool eqNumbers(Number x, Number y) => x == y;
  @primitive @SchemeSymbol("<") bool lt(Number x, Number y) => x < y;
  @primitive @SchemeSymbol(">") bool gt(Number x, Number y) => x > y;
  @primitive @SchemeSymbol("<=") bool le(Number x, Number y) => x <= y;
  @primitive @SchemeSymbol(">=") bool ge(Number x, Number y) => x >= y;
  @primitive @SchemeSymbol("even?") bool isEven(Number x) => x % Number.TWO == Number.ZERO;
  @primitive @SchemeSymbol("odd?") bool isOdd(Number x) => x % Number.TWO == Number.ONE;
  @primitive @SchemeSymbol("zero?") bool isZero(Number x) => x == Number.ZERO;
  @primitive Expression force(Promise p) => p.force();
  @primitive @SchemeSymbol("cdr-stream") Expression cdrStream(Pair p) => force(cdr(p));
  @primitive @SchemeSymbol("set-car!")
  @TriggerEventAfter(const SchemeSymbol("pair-mutation"))
  void setCar(Pair p, Expression val) {
    p.first = val;
  }
  @primitive @SchemeSymbol("set-cdr!")
  @TriggerEventAfter(const SchemeSymbol("pair-mutation"))
  void setCdr(Pair p, Expression val) {
    p.second = val;
  }
  @primitive @SchemeSymbol("runtime-type")
  String getRuntimeType(Expression expression) {
    return expression.runtimeType.toString();
  }
}
