library cs61a_scheme.core.expressions;

import 'dart:collection' show IterableMixin;
import 'dart:convert' show JSON;

import 'package:rational/bigint.dart';
import 'package:quiver_hashcode/hashcode.dart';

import 'interpreter.dart';
import 'logging.dart';
import 'serialization.dart';
import 'ui.dart';
import 'utils.dart';

abstract class Expression {
  const Expression();
  Expression evaluate(Frame env);
  bool get isTruthy => true;

  /// If true, this expression should be inlined in diagrams.
  /// If false, it should be added to the objects with an arrow to it.
  bool get inlineUI => false;

  /// Constructs a UIElement for this expression, adding elements to the diagram
  /// as necessary.
  UIElement draw(DiagramInterface diagram) => new TextElement(toString());
  bool get isNil => false;
  String get display => toString();

  /// Should return the version of this object that can be passed to JS
  dynamic toJS() => this;

  /// Convenience function since casting as a Pair is very common.
  Pair get pair => this as Pair;
}

abstract class SelfEvaluating extends Expression {
  const SelfEvaluating();
  Expression evaluate(Frame env) => this;
}

class Number extends SelfEvaluating implements Serializable<Number> {
  final inlineUI = true;
  final bool isInteger;
  final double doubleValue;
  final BigInt bigInt;
  const Number.fromDouble(this.doubleValue)
      : isInteger = false,
        bigInt = null;
  const Number.fromBigInt(this.bigInt)
      : isInteger = true,
        doubleValue = null;

  factory Number.fromInt(int value) {
    return new Number.fromBigInt(new BigInt.fromJsInt(value));
  }

  factory Number.fromNum(num value) {
    if (value is int) return new Number.fromInt(value);
    return new Number.fromDouble(value);
  }

  static final ZERO = new Number.fromInt(0);
  static final ONE = new Number.fromInt(1);
  static final TWO = new Number.fromInt(2);

  factory Number.fromString(String numString) {
    try {
      return new Number.fromBigInt(BigInt.parse(numString));
    } catch (e) {
      return new Number.fromDouble(double.parse(numString));
    }
  }

  String toString() => isInteger ? "$bigInt" : "$doubleValue";

  num toJS() => isInteger ? num.parse("$bigInt") : doubleValue;

  Map serialize() => {'type': 'Number', 'data': toString()};

  Number deserialize(Map data) => new Number.fromString(data['data']);

  static Number _operation(Number a, Number b, Function fn) {
    if (a.isInteger && b.isInteger) {
      return new Number.fromBigInt(fn(a.bigInt, b.bigInt));
    } else if (!a.isInteger && !b.isInteger) {
      return new Number.fromDouble(fn(a.doubleValue, b.doubleValue));
    }
    num aNum = a.isInteger ? num.parse("$a") : a.doubleValue;
    num bNum = b.isInteger ? num.parse("$b") : b.doubleValue;
    num result = fn(aNum, bNum);
    if (result is int) return new Number.fromInt(result);
    return new Number.fromDouble(result);
  }

  int compareTo(Number other) {
    if (isInteger && other.isInteger) return bigInt.compareTo(other.bigInt);
    if (!isInteger && !other.isInteger) {
      return doubleValue.compareTo(other.doubleValue);
    }
    num a = this.isInteger ? num.parse("$this") : this.doubleValue;
    num b = other.isInteger ? num.parse("$other") : other.doubleValue;
    return a.compareTo(b);
  }

  operator +(Number other) => _operation(this, other, (a, b) => a + b);
  operator -(Number other) => _operation(this, other, (a, b) => a - b);
  operator -() => isInteger ? new Number.fromBigInt(-bigInt) : new Number.fromDouble(-doubleValue);
  operator /(Number other) {
    if (other == Number.ZERO) throw new SchemeException("cannot divide by zero");
    if (!this.isInteger && !other.isInteger) {
      return new Number.fromDouble(this.doubleValue / other.doubleValue);
    } else if (this.isInteger && other.isInteger) {
      if ((this.bigInt % other.bigInt).is0) return this ~/ other;
    }
    num a = this.isInteger ? num.parse("$this") : this.doubleValue;
    num b = other.isInteger ? num.parse("$other") : other.doubleValue;
    return new Number.fromDouble(a / b);
  }

  operator ~/(Number other) {
    if (other == Number.ZERO) throw new SchemeException("cannot divide by zero");
    return _operation(this, other, (a, b) => a ~/ b);
  }

  operator *(Number other) => _operation(this, other, (a, b) => a * b);
  operator %(Number other) => _operation(this, other, (a, b) => a % b);
  operator <(Number other) => compareTo(other) < 0;
  operator <=(Number other) => compareTo(other) <= 0;
  operator >(Number other) => compareTo(other) > 0;
  operator >=(Number other) => compareTo(other) >= 0;
  operator ==(dynamic other) {
    if (other is int) return this == new Number.fromInt(other);
    if (other is double) return this == new Number.fromDouble(other);
    if (other is Number) return compareTo(other) == 0;
    return false;
  }

  @override
  int get hashCode => hash3(isInteger, doubleValue, bigInt);
}

class Boolean extends SelfEvaluating implements Serializable<Boolean> {
  final inlineUI = true;
  final bool value;
  const Boolean._internal(this.value);
  bool get isTruthy => value;
  toString() => value ? "#t" : "#f";
  bool toJS() => value;
  operator ==(other) => other is Boolean && value == other.value;
  int get hashCode => value.hashCode;
  factory Boolean(bool value) => value ? schemeTrue : schemeFalse;

  Map serialize() => {'type': 'Boolean', 'value': isTruthy};
  Boolean deserialize(Map data) => new Boolean(data['value']);
}

const schemeTrue = const Boolean._internal(true);
const schemeFalse = const Boolean._internal(false);

class SchemeSymbol extends Expression implements Serializable<SchemeSymbol> {
  final inlineUI = true;
  final String value;
  // Constant constructor must already use a lowercase String.
  const SchemeSymbol(this.value);
  SchemeSymbol.runtime(String value) : this.value = value.toLowerCase();
  Expression evaluate(Frame env) => env.lookup(this);
  toString() => value;
  operator ==(other) => other is SchemeSymbol && value == other.value;
  int get hashCode => hash2("SchemeSymbol", value);
  toJS() => value;

  Map serialize() => {'type': 'SchemeSymbol', 'value': value};
  SchemeSymbol deserialize(Map data) => new SchemeSymbol(data['value']);
}

class SchemeString extends SelfEvaluating implements Serializable<SchemeString> {
  final inlineUI = true;
  final String value;
  const SchemeString(this.value);
  toString() => JSON.encode(value);
  get display => value;
  operator ==(other) => other is SchemeString && value == other.value;
  int get hashCode => hash2("SchemeString", value);

  toJS() => value;

  Map serialize() => {'type': 'SchemeString', 'value': value};
  SchemeString deserialize(Map data) => new SchemeString(data['value']);
}

class _SchemeListIterator extends Iterator<Expression> {
  Expression current;
  Pair pair;
  _SchemeListIterator(Pair start) {
    pair = start;
    if (!pair.isWellFormedList()) throw new TypeError();
  }
  bool moveNext() {
    if (pair != null) {
      current = pair.first;
      pair = pair.second is Pair ? pair.second : null;
      return true;
    }
    return false;
  }
}

class _NilIterator extends Iterator<Expression> {
  get current => null;
  moveNext() => false;
}

abstract class PairOrEmpty extends Expression with IterableMixin<Expression> {
  bool isWellFormedList();
  factory PairOrEmpty.fromIterable(Iterable<Expression> iterable) {
    PairOrEmpty result = nil;
    for (Expression item in iterable.toList().reversed) {
      result = new Pair(item, result);
    }
    return result;
  }
  int get length;
}

class EmptyList extends SelfEvaluating implements PairOrEmpty {
  final inlineUI = true;
  const EmptyList._internal();
  bool isWellFormedList() => true;
  bool get isNil => true;
  toString() => "()";

  // Dummy properties to ensure this works as an iterator
  get first => throw new StateError("empty list");
  final isEmpty = true;
  final isNotEmpty = false;
  get iterator => new _NilIterator();
  get last => throw new StateError("empty list");
  final int length = 0;
  get single => throw new StateError("empty list");
  any(f) => false;
  contains(e) => false;
  every(f) => true;
  elementAt(f) => throw new StateError("empty list");
  expand<T>(f) => <T>[];
  firstWhere(test, {orElse = null}) =>
      orElse == null ? throw new StateError("empty list") : orElse();
  fold<T>(init, combine) => init;
  forEach(f) => null;
  join([sep]) => "";
  lastWhere(test, {orElse = null}) => firstWhere(test, orElse: orElse);
  List<T> map<T>(Function fn) => [];
  reduce(comb) => throw new StateError("empty list");
  singleWhere(test) => throw new StateError("empty list");
  skip(c) => this;
  skipWhile(test) => this;
  take(c) => this;
  takeWhile(c) => this;
  toList({bool growable: false}) => growable ? [] : new List(0);
  toSet() => new Set();
  where(t) => this;
}

const nil = const EmptyList._internal();

class Pair<A extends Expression, B extends Expression> extends Expression
    with IterableMixin<Expression>
    implements PairOrEmpty {
  A first;
  B second;
  Pair(this.first, this.second);

  bool isWellFormedList() {
    PairOrEmpty current = this;
    while (!current.isNil) {
      if (current.pair.second is! PairOrEmpty) {
        return false;
      }
      current = current.pair.second;
    }
    return true;
  }

  Iterator<Expression> get iterator => new _SchemeListIterator(this);

  Expression evaluate(Frame env) => evalCallExpression(this, env);

  @override
  UIElement draw(DiagramInterface diagram) {
    int parentRow = diagram.currentRow;
    UIElement right = diagram.pointTo(second);
    UIElement left = diagram.pointTo(first, parentRow);
    return new BlockGrid.pair(new Block.pair(left), new Block.pair(right));
  }

  toString() {
    String result = "($first";
    Expression current = second;
    while (current is Pair) {
      Pair pair = current as Pair;
      result += " ${pair.first}";
      current = pair.second;
    }
    if (!identical(current, nil)) result += " . $current";
    return result + ")";
  }

  operator ==(other) => other is Pair && first == other.first && second == other.second;
  int get hashCode => hash2(first, second);

  static Expression append(List<Expression> args) {
    if (args.isEmpty) return nil;
    List<Expression> lst = [];
    for (Expression arg in args.take(args.length - 1)) {
      if (arg.isNil) continue;
      if (arg is Pair && arg.isWellFormedList()) {
        lst.addAll(arg);
      } else {
        throw new SchemeException("Argument is not a well-formed list.");
      }
    }
    Expression result = nil;
    Expression lastArg = args.last;
    if (lastArg is PairOrEmpty && lastArg.isWellFormedList()) {
      lst.addAll(lastArg);
    } else {
      result = lastArg;
    }
    for (Expression expr in lst.reversed) {
      result = new Pair(expr, result);
    }
    return result;
  }
}

class Undefined extends SelfEvaluating {
  const Undefined._internal();
  bool get isNil => false;
  toString() => "undefined";
  toJS() => Undefined.jsUndefined;
  static var jsUndefined = null;
}

const undefined = const Undefined._internal();

class Thunk extends Expression {
  final Expression expr;
  final Frame env;
  const Thunk(this.expr, this.env);
  Expression evaluate(Frame _) {
    List<Expression> expressions = [];
    try {
      Expression result = this;
      while (result is Thunk) {
        Thunk thunk = result as Thunk;
        expressions.insert(0, thunk.expr);
        result = thunk.expr.evaluate(thunk.env);
      }
      return result;
    } on SchemeException catch (e) {
      for (Expression expr in expressions) {
        e.addCall(expr);
      }
      rethrow;
    }
  }

  toJS() => throw new StateError("Thunks should not be passed to JS");
  toString() => 'Thunk($expr in f${env.id})';
}

class Promise extends SelfEvaluating {
  Expression expr;
  final Frame env;
  bool _evaluated = false;
  Promise(this.expr, this.env);
  Expression force() {
    if (!_evaluated) {
      expr = schemeEval(expr, env);
      _evaluated = true;
    }
    return expr;
  }

  toJS() => this;
  toString() => "#[promise (${_evaluated ? '' : 'not '}forced)]";
  @override
  UIElement draw(DiagramInterface diagram) {
    var inside = _evaluated ? diagram.pointTo(expr) : new TextElement("⋯");
    return new Block.promise(inside);
  }
}

class Frame extends SelfEvaluating {
  Frame parent;
  Interpreter interpreter;
  String tag;
  int id;
  Map<SchemeSymbol, Expression> bindings = {};
  Map<SchemeSymbol, bool> hidden = {};
  Frame(this.parent, this.interpreter) : id = interpreter.frameCounter++;
  void define(SchemeSymbol symbol, Expression value, [bool hide = false]) {
    interpreter.implementation.defineInFrame(symbol, value, this);
    hidden[symbol] = hide;
  }

  Expression lookup(SchemeSymbol symbol) {
    return interpreter.implementation.lookupInFrame(symbol, this);
  }

  void update(SchemeSymbol symbol, Expression value) {
    if (bindings.containsKey(symbol)) {
      bindings[symbol] = value;
      return;
    }
    if (parent == null) throw new SchemeException("$symbol is not bound");
    parent.update(symbol, value);
  }

  Frame makeChildFrame(Expression formals, Expression vals) {
    return interpreter.implementation.makeChildOf(formals, vals, this);
  }

  toJS() => this;
}
