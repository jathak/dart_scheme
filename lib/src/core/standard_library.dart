library cs61a_scheme.core.standard_library;

import 'dart:math' show pow;

import 'expressions.dart';
import 'logging.dart';
import 'numbers.dart';
import 'procedures.dart';
import 'scheme_library.dart';
import 'utils.dart';

part 'standard_library.g.dart';

/// Note: When the signatures (including any annotations) of any of these methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the primitives and performs type checking on arguments).
@schemelib
class StandardLibrary extends SchemeLibrary with _$StandardLibraryMixin {
  Expression apply(Procedure procedure, PairOrEmpty args, Frame env) {
    return schemeApply(procedure, args, env);
  }

  void display(Expression message, Frame env) {
    env.interpreter.logger(new DisplayOutput(message), false);
  }

  Expression error(Expression message) {
    throw new SchemeException(message.toString(), true, message);
  }

  @SchemeSymbol('error-notrace')
  Expression errorNoTrace(Expression message) {
    throw new SchemeException(message.toString(), false, message);
  }

  Expression eval(Expression expr, Frame env) {
    return schemeEval(expr, env);
  }

  Expression exit() {
    throw const ExitException();
  }

  Expression load(Expression file, Frame env) {
    throw new UnimplementedError("load has not yet been implemented");
  }

  void newline(Frame env) {
    env.interpreter.logger(new TextMessage(""), true);
  }

  void print(Expression message, Frame env) {
    env.interpreter.logger(message, true);
  }

  @SchemeSymbol("atom?")
  bool isAtom(Expression val) {
    return val is Boolean || val is Number || val is SchemeSymbol || val.isNil;
  }

  @SchemeSymbol("integer?")
  bool isInteger(Expression val) => val is Integer;

  @SchemeSymbol("list?")
  bool isList(Expression val) => val is PairOrEmpty && val.wellFormed;

  @SchemeSymbol("number?")
  bool isNumber(Expression val) => val is Number;

  @SchemeSymbol("null?")
  bool isNull(Expression val) => val.isNil;

  @SchemeSymbol("pair?")
  bool isPair(Expression val) => val is Pair;

  @SchemeSymbol("procedure?")
  bool isProcedure(Expression val) => val is Procedure;

  @SchemeSymbol("promise?")
  bool isPromise(Expression val) => val is Promise;

  @SchemeSymbol("string?")
  bool isString(Expression val) => val is SchemeString;

  @SchemeSymbol("symbol?")
  bool isSymbol(Expression val) => val is SchemeSymbol;

  Expression append(List<Expression> args) => Pair.append(args);

  Expression car(Pair val) => val.first;

  Expression cdr(Pair val) => val.second;

  Pair cons(Expression car, Expression cdr) => new Pair(car, cdr);

  num length(PairOrEmpty lst) => lst.lengthOrCycle;

  PairOrEmpty list(List<Expression> args) => new PairOrEmpty.fromIterable(args);

  PairOrEmpty map(Procedure fn, PairOrEmpty lst, Frame env) {
    return new PairOrEmpty.fromIterable(lst.map((item) {
      return completeEval(fn.apply(new Pair(item, nil), env));
    }));
  }

  PairOrEmpty filter(Procedure pred, PairOrEmpty lst, Frame env) {
    return new PairOrEmpty.fromIterable(lst.where((item) {
      return completeEval(pred.apply(new Pair(item, nil), env)).isTruthy;
    }));
  }

  Expression reduce(Procedure combiner, PairOrEmpty lst, Frame env) {
    return lst.reduce((a, b) => combiner.apply(list([a, b]), env));
  }

  @SchemeSymbol("+")
  Number add(List<Expression> args) =>
      allNumbers(args).fold(Number.zero, (a, b) => a + b);

  @SchemeSymbol("-")
  @MinArgs(1)
  Number sub(List<Expression> args) {
    Iterable<Number> numbers = allNumbers(args);
    if (numbers.length == 1) return -(numbers.first);
    return numbers.skip(1).fold(numbers.first, (a, b) => a - b);
  }

  @SchemeSymbol("*")
  Number mul(List<Expression> args) =>
      allNumbers(args).fold(Number.one, (a, b) => a * b);

  @SchemeSymbol("/")
  @MinArgs(1)
  Number truediv(List<Expression> args) {
    Iterable<Number> numbers = allNumbers(args);
    if (numbers.length == 1) return Number.one / (numbers.first);
    return numbers.skip(1).fold(numbers.first, (a, b) => a / b);
  }

  Number abs(Number arg) => arg < Number.zero ? -arg : arg;

  Number expt(Number base, Number power) {
    if (power is Integer) {
      Number total = Number.one;
      for (Number i = Number.zero; i < power; i += Number.one) {
        total *= base;
      }
      return total;
    }
    return new Number.fromNum(pow(base.toJS(), power.toJS()));
  }

  Number modulo(Number a, Number b) => a % b;

  Number quotient(Number a, Number b) => a ~/ b;

  Number remainder(Number a, Number b) {
    Number mod = modulo(a, b);
    while ((mod < Number.zero && a > Number.zero) ||
        (mod > Number.zero && a < Number.zero)) {
      mod -= a;
    }
    return mod;
  }

  @SchemeSymbol("eq?")
  bool isEq(Expression x, Expression y) {
    if (x is Number && y is Number) return x == y;
    if (x is SchemeSymbol && y is SchemeSymbol) return x == y;
    if (x is SchemeString && y is SchemeString) return x == y;
    return identical(x, y);
  }

  @SchemeSymbol("equal?")
  bool isEqual(Expression x, Expression y) => x == y;

  @SchemeSymbol("not")
  bool not(Expression arg) => !arg.isTruthy;

  @SchemeSymbol("=")
  bool eqNumbers(Number x, Number y) => x == y;

  @SchemeSymbol("<")
  bool lt(Number x, Number y) => x < y;

  @SchemeSymbol(">")
  bool gt(Number x, Number y) => x > y;

  @SchemeSymbol("<=")
  bool le(Number x, Number y) => x <= y;

  @SchemeSymbol(">=")
  bool ge(Number x, Number y) => x >= y;

  @SchemeSymbol("even?")
  bool isEven(Number x) => x % Number.two == Number.zero;

  @SchemeSymbol("odd?")
  bool isOdd(Number x) => x % Number.two == Number.one;

  @SchemeSymbol("zero?")
  bool isZero(Number x) => x == Number.zero;

  Expression force(Promise p) => p.force();

  @SchemeSymbol("cdr-stream")
  Expression cdrStream(Pair p) => force(cdr(p));

  @SchemeSymbol("set-car!")
  @TriggerEventAfter(const SchemeSymbol("pair-mutation"))
  void setCar(Pair p, Expression val) {
    p.first = val;
  }

  @SchemeSymbol("set-cdr!")
  @TriggerEventAfter(const SchemeSymbol("pair-mutation"))
  void setCdr(Pair p, Expression val) {
    p.second = val;
  }

  @SchemeSymbol("call/cc")
  Expression callWithCurrentContinuation(Procedure procedure, Frame env) =>
      env.interpreter.impl.callWithCurrentContinuation(procedure, env);

  @SchemeSymbol("runtime-type")
  String getRuntimeType(Expression expression) {
    return expression.runtimeType.toString();
  }
}
