library cs61a_scheme.core.standard_library;

import 'dart:math' show pow;

import 'documentation.dart';
import 'expressions.dart';
import 'frame.dart';
import 'logging.dart';
import 'numbers.dart';
import 'procedures.dart';
import 'scheme_library.dart';
import 'utils.dart';
import 'values.dart';
import 'wrappers.dart';

part 'standard_library.g.dart';

/// Note: When the signatures (including any annotations) of any of these methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the built-ins and performs type checking on arguments).
@schemelib
class StandardLibrary extends SchemeLibrary with _$StandardLibraryMixin {
  /// Applies [procedure] to the given [args]
  Value apply(Procedure procedure, SchemeList args, Frame env) =>
      schemeApply(procedure, args, env);

  /// Displays [message] without a line break at the end
  void display(Value message, Frame env) {
    env.interpreter.logger(DisplayOutput(message), false);
  }

  /// Raises an error with the given [message].
  void error(Value message) {
    throw SchemeException(message.toString(), true, message);
  }

  /// Raises an error with the given [message] and no traceback.
  @SchemeSymbol('error-notrace')
  void errorNoTrace(Value message) {
    throw SchemeException(message.toString(), false, message);
  }

  /// Evaluates [expr] in the current environment
  Value eval(Expression expr, Frame env) => schemeEval(expr, env);

  /// Exits the interpreter (behavior may vary)
  void exit() {
    throw const ExitException();
  }

  void load(Value file, Frame env) {
    throw UnimplementedError("load has not yet been implemented");
  }

  /// Displays a line break
  void newline(Frame env) {
    env.interpreter.logger(const TextMessage(""), true);
  }

  /// Logs [message] to the interpreter.
  void print(Value message, Frame env) {
    env.interpreter.logger(message, true);
  }

  /// Returns true if [val] is an atomic expression.
  @SchemeSymbol("atom?")
  bool isAtom(Value val) =>
      val is Boolean || val is Number || val is SchemeSymbol || val.isNil;

  /// Returns true if [val] is an integer.
  @SchemeSymbol("integer?")
  bool isInteger(Value val) => val is Integer;

  /// Returns true if [val] is a well-formed list.
  @SchemeSymbol("list?")
  bool isList(Value val) => val is PairOrEmpty && val.wellFormed;

  /// Returns true if [val] is an number.
  @SchemeSymbol("number?")
  bool isNumber(Value val) => val is Number;

  /// Returns true if [val] is the empty list.
  @SchemeSymbol("null?")
  bool isNull(Value val) => val.isNil;

  /// Returns true if [val] is a pair.
  @SchemeSymbol("pair?")
  bool isPair(Value val) => val is Pair;

  /// Returns true if [val] is a procedure.
  @SchemeSymbol("procedure?")
  bool isProcedure(Value val) => val is Procedure;

  /// Returns true if [val] is a promise.
  @SchemeSymbol("promise?")
  bool isPromise(Value val) => val is Promise;

  /// Returns true if [val] is a string.
  @SchemeSymbol("string?")
  bool isString(Value val) => val is SchemeString;

  /// Returns true if [val] is a symbol.
  @SchemeSymbol("symbol?")
  bool isSymbol(Value val) => val is SchemeSymbol;

  /// Appends zero or more lists together into a single list.
  Value append(List<Value> args) => Pair.append(args);

  /// Gets the first item in [val].
  Value car(Pair val) => val.first;

  /// Gets the second item in [val] (typically the rest of a well-formed list).
  Value cdr(Pair val) => val.second;

  /// Constructs a pair from values [car] and [cdr].
  Pair cons(Value car, Value cdr) {
    // Added if statement to disallow malformed lists
    if (!(cdr is PairOrEmpty && cdr.wellFormed)) {
      throw SchemeException("The cdr of a list must be another pair or nil");
    }
    return Pair(car, cdr);
  }

  /// Finds the length of a well-formed Scheme list.
  num length(PairOrEmpty lst) => lst.lengthOrCycle;

  /// Constructs a list from zero or more arguments.
  SchemeList list(List<Value> args) => SchemeList.fromIterable(args);

  /// Constructs a new list from calling [fn] on each item in [lst].
  SchemeList map(Procedure fn, SchemeList lst, Frame env) =>
      SchemeList.fromIterable(lst.map(
          (item) => completeEval(fn.apply(SchemeList(Pair(item, nil)), env))));

  /// Constructs a new list of all items in [lst] that return true when passed
  /// to [pred].
  SchemeList filter(Procedure pred, SchemeList lst, Frame env) =>
      SchemeList.fromIterable(lst.where((item) =>
          completeEval(pred.apply(SchemeList(Pair(item, nil)), env)).isTruthy));

  /// Reduces [lst] into a single expression by combining items with [combiner].
  Value reduce(Procedure combiner, SchemeList lst, Frame env) =>
      lst.reduce((a, b) => combiner.apply(list([a, b]), env));

  /// Adds 0 or more numbers together.
  @SchemeSymbol("+")
  Number add(List<Number> nums) => nums.fold(Number.zero, (a, b) => a + b);

  /// If called with one number, negates it.
  /// Otherwise, subtracts the sum of all remaining arguments from the first.
  @SchemeSymbol("-")
  @MinArgs(1)
  Number sub(List<Number> nums) => nums.length == 1
      ? -nums.first
      : nums.skip(1).fold(nums.first, (a, b) => a - b);

  /// Multiples 0 or more numbers together.
  @SchemeSymbol("*")
  Number mul(List<Number> nums) => nums.fold(Number.one, (a, b) => a * b);

  /// If called with one number, finds its reciprocal.
  /// Otherwise, divides the first argument by the product of the rest.
  @SchemeSymbol("/")
  @MinArgs(1)
  Number truediv(List<Number> nums) => nums.length == 1
      ? Number.one / nums.first
      : nums.skip(1).fold(nums.first, (a, b) => a / b);

  /// Finds the absolute value of [arg].
  Number abs(Number arg) => arg < Number.zero ? -arg : arg;

  /// Raises [base] to [power].
  Number expt(Number base, Number power) {
    if (power is Integer) {
      Number total = Number.one;
      for (Number i = Number.zero; i < power; i += Number.one) {
        total *= base;
      }
      return total;
    }
    return Number.fromNum(pow(base.toJS(), power.toJS()));
  }

  /// Finds a % b.
  Number modulo(Number a, Number b) => a % b;

  /// Divides [a] by [b] using truncating division.
  Number quotient(Number a, Number b) => a ~/ b;

  /// Finds the remainder when dividing [a] by [b].
  Number remainder(Number a, Number b) {
    Number mod = modulo(a, b);
    while (mod > Number.zero && a < Number.zero) {
      mod -= abs(b);
    }
    return mod;
  }

  /// Determines if [x] and [y] are the same object.
  ///
  /// For the purposes of this procedure, equivalent numbers, symbols, and
  /// strings are considered the same object.
  @SchemeSymbol("eq?")
  bool isEq(Value x, Value y) {
    if (x is Number && y is Number) return x == y;
    if (x is SchemeSymbol && y is SchemeSymbol) return x == y;
    if (x is SchemeString && y is SchemeString) return x == y;
    return identical(x, y);
  }

  /// Determines if [x] and [y] hold equivalent values.
  @SchemeSymbol("equal?")
  bool isEqual(Value x, Value y) => x == y;

  /// Negates the truthiness of [arg].
  @SchemeSymbol("not")
  bool not(Value arg) => !arg.isTruthy;

  /// Compares [x] and [y] for equality.
  @SchemeSymbol("=")
  bool eqNumbers(Number x, Number y) => x == y;

  /// Returns true if [x] is less than [y].
  @SchemeSymbol("<")
  bool lt(Number x, Number y) => x < y;

  /// Returns true if [x] is greater than [y].
  @SchemeSymbol(">")
  bool gt(Number x, Number y) => x > y;

  /// Returns true if [x] is less than or equal to [y].
  @SchemeSymbol("<=")
  bool le(Number x, Number y) => x <= y;

  /// Returns true if [x] is greater than or equal to [y].
  @SchemeSymbol(">=")
  bool ge(Number x, Number y) => x >= y;

  /// Returns true if [x] is even.
  @SchemeSymbol("even?")
  bool isEven(Number x) => x % Number.two == Number.zero;

  /// Returns true if [x] is odd.
  @SchemeSymbol("odd?")
  bool isOdd(Number x) => x % Number.two == Number.one;

  /// Returns true if [x] is zero.
  @SchemeSymbol("zero?")
  bool isZero(Number x) => x == Number.zero;

  /// Forces [promise], evaluating it if necessary.
  Expression force(Promise promise) => promise.force();

  /// Finds the rest of [stream].
  ///
  /// Equivalent to (force (cdr [stream]))
  @SchemeSymbol("cdr-stream")
  Expression cdrStream(Pair stream) => force(cdr(stream));

  /// Mutates the car of [pair] to be [val].
  @SchemeSymbol("set-car!")
  @TriggerEventAfter(const SchemeSymbol("pair-mutation"))
  void setCar(Pair pair, Value val) {
    pair.first = val;
  }

  /// Mutates the cdr of [pair] to be [val].
  @SchemeSymbol("set-cdr!")
  @TriggerEventAfter(const SchemeSymbol("pair-mutation"))
  void setCdr(Pair pair, Value val) {
    // Added if statement to disallow malformed lists
    if (!(val is PairOrEmpty && val.wellFormed)) {
      throw SchemeException("The cdr of a list must be another pair or nil");
    }
    pair.second = val;
  }

  @SchemeSymbol("runtime-type")
  String getRuntimeType(Expression expression) =>
      expression.runtimeType.toString();
}
