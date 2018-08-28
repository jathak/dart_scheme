library cs61a_scheme.core.expressions;

import 'dart:collection' show IterableMixin, IterableBase;
import 'dart:convert' show json;

import 'package:quiver/core.dart';

import 'frame.dart';
import 'logging.dart';
import 'serialization.dart';
import 'utils.dart';
import 'values.dart';
import 'widgets.dart';

/// Base class for all Scheme values that can be evaluated.
abstract class Expression extends Value {
  const Expression();

  /// Evaluates this expression in [env].
  Value evaluate(Frame env);
}

/// A Scheme boolean. There are only two: [schemeTrue] and [schemeFalse].
class Boolean extends Expression implements Serializable<Boolean> {
  final bool value;
  const Boolean._internal(this.value);

  /// Returns [schemeTrue] or [schemeFalse] depending on [value].
  ///
  /// Additional [Boolean] expressions will never be created.
  factory Boolean(bool value) => value ? schemeTrue : schemeFalse;

  Value evaluate(Frame env) => this;

  bool get isTruthy => value;
  bool get inlineInDiagram => true;
  toString() => value ? "#t" : "#f";

  /// The underlying Dart bool is passed to JS.
  bool toJS() => value;

  Map serialize() => {'type': 'Boolean', 'value': isTruthy};
  Boolean deserialize(Map data) => Boolean(data['value']);
}

/// `#t` in Scheme.
const schemeTrue = Boolean._internal(true);

/// `#f` in Scheme. This is the only false-y expression.
const schemeFalse = Boolean._internal(false);

/// A Scheme identifier.
///
/// These should be case insensitive. When calling the unnamed constructor to
/// create a constant instance, a lowercase string should be passed to maintain
/// this. Use the [SchemeSymbol.runtime] constructor when passing in non-constant
/// strings.
class SchemeSymbol extends Expression implements Serializable<SchemeSymbol> {
  final String value;

  const SchemeSymbol(this.value);
  SchemeSymbol.runtime(String value) : this.value = value.toLowerCase();
  Value evaluate(Frame env) => env.lookup(this);
  bool get inlineInDiagram => true;
  toString() => value;
  operator ==(other) => other is SchemeSymbol && value == other.value;
  int get hashCode => hash2("SchemeSymbol", value);
  toJS() => value;

  Map serialize() => {'type': 'SchemeSymbol', 'value': value};
  SchemeSymbol deserialize(Map data) => SchemeSymbol.runtime(data['value']);
}

/// A Scheme string.
class SchemeString extends Expression implements Serializable<SchemeString> {
  final String value;
  const SchemeString(this.value);

  Value evaluate(Frame env) => this;

  toString() => json.encode(value);
  bool get inlineInDiagram => true;

  get display => value;
  operator ==(other) => other is SchemeString && value == other.value;
  int get hashCode => hash2("SchemeString", value);

  toJS() => value;

  Map serialize() => {'type': 'SchemeString', 'value': value};
  SchemeString deserialize(Map data) => SchemeString(data['value']);
}

class _SchemeListIterator extends Iterator<Value> {
  Value current;
  Pair pair;
  _SchemeListIterator(this.pair) {
    if (!pair.wellFormed) throw TypeError();
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

class _NilIterator extends Iterator<Value> {
  get current => null;
  moveNext() => false;
}

/// Implemented by both [Pair] and the empty list, [nil].
///
/// Since many pieces of the interpreter take in expressions that could either
/// be a pair or the empty list, we need some way to define the type. Since Dart
/// doesn't have union types, we instead use this interface.
///
/// Iterating over this class will fail if [wellFormed] is false.
abstract class PairOrEmpty extends Expression implements Iterable<Value> {
  /// Creates a Scheme list from the given Dart iterable.
  factory PairOrEmpty.fromIterable(Iterable<Value> iterable) {
    PairOrEmpty result = nil;
    for (Value item in iterable.toList().reversed) {
      result = Pair(item, result);
    }
    return result;
  }

  /// Returns true iff this is a well-formed Scheme list.
  bool get wellFormed;

  /// See [wellFormed].
  @deprecated
  bool isWellFormedList() => wellFormed;

  num get lengthOrCycle;
}

/// Singleton class for the empty Scheme list, [nil].
///
/// This can't use [IterableMixin] because we need it to have a constant
/// constructor, so we have to implement all the [Iterable] methods ourselves.
class _EmptyList extends IterableBase<Value>
    implements Expression, PairOrEmpty {
  const _EmptyList();
  bool get inlineInDiagram => true;
  bool get wellFormed => true;
  @deprecated
  bool isWellFormedList() => true;
  bool get isNil => true;
  toString() => "()";
  get iterator => _NilIterator();

  num get lengthOrCycle => 0;

  get display => toString();
  draw(DiagramInterface diagram) => TextWidget('()');
  Value evaluate(Frame env) => this;
  get isTruthy => true;
  get pair => this as Pair;
  toJS() => this;
}

/// The empty Scheme list.
const nil = _EmptyList();

/// A Scheme pair.
///
/// A pair of two values. When [second] is either [nil] or another pair,
/// this is a well-formed Scheme list and can be iterated over.
///
/// [first] is the `car`. [second] is the `cdr`.
class Pair<A extends Value, B extends Value> extends Expression
    with IterableMixin<Value>
    implements PairOrEmpty {
  A first;
  B second;

  /// Creates a new [Pair] from [first] and [second].
  Pair(this.first, this.second);

  /// This is a well-formed list if [second] is also a well-formed list.
  bool get wellFormed =>
      second is PairOrEmpty && (second as PairOrEmpty).wellFormed;
  @deprecated
  bool isWellFormedList() => wellFormed;

  /// If the Scheme list contains a cycle, returns infinity.
  ///
  /// Returns [length] for well-formed lists and errors otherwise.
  num get lengthOrCycle {
    Expression slow = this;
    Expression fast = this;
    int length = 0;
    while (fast is Pair && fast.second is Pair) {
      slow = slow.pair.second;
      fast = fast.pair.second.pair.second;
      length += 2;
      if (identical(slow, fast)) return double.infinity;
    }
    if (!wellFormed) throw SchemeException("Malformed list");
    return length + (fast is Pair ? 1 : 0);
  }

  Iterator<Value> get iterator => _SchemeListIterator(this);

  Value evaluate(Frame env) => evalCallExpression(this, env);

  @override
  Widget draw(DiagramInterface diagram) {
    int parentRow = diagram.currentRow;
    Widget right = diagram.pointTo(second);
    Widget left = diagram.pointTo(first, parentRow);
    return BlockGrid.pair(Block.pair(left), Block.pair(right));
  }

  /// We use a recursive approach here to ensure that lists with cycles
  /// cause a stack overflow instead of looping forever.
  _internalString(bool inCdr) {
    String rest;
    if (identical(second, nil)) {
      rest = "";
    } else if (second is Pair) {
      rest = " " + second.pair._internalString(true);
    } else {
      rest = " . $second";
    }
    String core = '$first$rest';
    return inCdr ? core : '($core)';
  }

  /// When the pair structure contains a cycle, this will hit a recursion limit.
  toString() => _internalString(false);

  operator ==(x) => x is Pair && first == x.first && second == x.second;
  int get hashCode => hash2(first, second);

  /// Typically takes in some number of Scheme lists and returns a new Scheme
  /// list of all of them appended together.
  ///
  /// The last argument can be any expression. If it is not a Scheme list, the
  /// resulting appended list will be dotted with it.
  static Expression append(List<Value> args) {
    if (args.isEmpty) return nil;
    List<Value> lst = [];
    for (Value arg in args.take(args.length - 1)) {
      if (arg.isNil) continue;
      if (arg is Pair && arg.wellFormed) {
        lst.addAll(arg);
      } else {
        throw SchemeException("Argument is not a well-formed list.");
      }
    }
    PairOrEmpty result = nil;
    Value lastArg = args.last;
    if (lastArg is PairOrEmpty && lastArg.wellFormed) {
      lst.addAll(lastArg);
    } else {
      result = lastArg;
    }
    for (Value val in lst.reversed) {
      result = Pair(val, result);
    }
    return result;
  }
}
