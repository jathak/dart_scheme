library cs61a_scheme.core.expressions;

import 'dart:collection' show IterableMixin, IterableBase;
import 'dart:convert' show json;

import 'package:quiver/core.dart';

import 'interpreter.dart';
import 'logging.dart';
import 'serialization.dart';
import 'utils.dart';
import 'widgets.dart';

/// Base class for all Scheme data types.
///
/// Everything that can be touched by Scheme code should inherit from this.
abstract class Expression {
  const Expression();

  /// Evaluates this expression in [env].
  Expression evaluate(Frame env);

  /// All Scheme expressions are truthy except for the [Boolean] `#f`.
  bool get isTruthy => true;

  /// Determines how this expression is represented in environment diagrams.
  ///
  /// If true, this expression should be inlined in diagrams.
  /// If false, it should be added to the objects with an arrow to it.
  bool get inlineInDiagram => false;

  /// Constructs a [Widget] for this expression.
  ///
  /// The default implementation returns the string representation of this
  /// expression as a [TextWidget]. Some expressions may need to add
  /// additional objects to [diagram].
  Widget draw(DiagramInterface diagram) => TextWidget(toString());

  /// Shorthand for `expr is EmptyList`.
  bool get isNil => false;

  /// Defines how this expression should be displayed.
  ///
  /// Used by the `(display <expr>)` built-in. Defaults to [toString].
  String get display => toString();

  /// Should return a version of this object that can be passed to JS.
  ///
  /// The default implementation just returns the expression itself, so this
  /// should be overridden if passing to JS is intended.
  dynamic toJS() => this;

  /// Convenience function since casting as a Pair is very common.
  Pair get pair => this as Pair;
}

/// An expression that evaluates to itself. Common for literals.
abstract class SelfEvaluating extends Expression {
  const SelfEvaluating();

  /// This expression evaluates to itself.
  Expression evaluate(Frame env) => this;
}

/// A Scheme boolean. There are only two: [schemeTrue] and [schemeFalse].
class Boolean extends SelfEvaluating implements Serializable<Boolean> {
  final bool value;
  const Boolean._internal(this.value);

  /// Returns [schemeTrue] or [schemeFalse] depending on [value].
  ///
  /// Additional [Boolean] expressions will never be created.
  factory Boolean(bool value) => value ? schemeTrue : schemeFalse;

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
  Expression evaluate(Frame env) => env.lookup(this);
  bool get inlineInDiagram => true;
  toString() => value;
  operator ==(other) => other is SchemeSymbol && value == other.value;
  int get hashCode => hash2("SchemeSymbol", value);
  toJS() => value;

  Map serialize() => {'type': 'SchemeSymbol', 'value': value};
  SchemeSymbol deserialize(Map data) => SchemeSymbol.runtime(data['value']);
}

/// A Scheme string.
class SchemeString extends SelfEvaluating
    implements Serializable<SchemeString> {
  final String value;
  const SchemeString(this.value);
  toString() => json.encode(value);
  bool get inlineInDiagram => true;

  get display => value;
  operator ==(other) => other is SchemeString && value == other.value;
  int get hashCode => hash2("SchemeString", value);

  toJS() => value;

  Map serialize() => {'type': 'SchemeString', 'value': value};
  SchemeString deserialize(Map data) => SchemeString(data['value']);
}

class _SchemeListIterator extends Iterator<Expression> {
  Expression current;
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

class _NilIterator extends Iterator<Expression> {
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
abstract class PairOrEmpty extends Expression implements Iterable<Expression> {
  /// Creates a Scheme list from the given Dart iterable.
  factory PairOrEmpty.fromIterable(Iterable<Expression> iterable) {
    PairOrEmpty result = nil;
    for (Expression item in iterable.toList().reversed) {
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
class _EmptyList extends IterableBase<Expression>
    implements SelfEvaluating, PairOrEmpty {
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
  evaluate(Frame env) => this;
  get isTruthy => true;
  get pair => this as Pair;
  toJS() => this;
}

/// The empty Scheme list.
const nil = _EmptyList();

/// A Scheme pair.
///
/// A pair of two expressions. When [second] is either [nil] or another pair,
/// this is a well-formed Scheme list and can be iterated over.
///
/// [first] is the `car`. [second] is the `cdr`.
class Pair<A extends Expression, B extends Expression> extends Expression
    with IterableMixin<Expression>
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

  Iterator<Expression> get iterator => _SchemeListIterator(this);

  Expression evaluate(Frame env) => evalCallExpression(this, env);

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
  static Expression append(List<Expression> args) {
    if (args.isEmpty) return nil;
    List<Expression> lst = [];
    for (Expression arg in args.take(args.length - 1)) {
      if (arg.isNil) continue;
      if (arg is Pair && arg.wellFormed) {
        lst.addAll(arg);
      } else {
        throw SchemeException("Argument is not a well-formed list.");
      }
    }
    PairOrEmpty result = nil;
    Expression lastArg = args.last;
    if (lastArg is PairOrEmpty && lastArg.wellFormed) {
      lst.addAll(lastArg);
    } else {
      result = lastArg;
    }
    for (Expression expr in lst.reversed) {
      result = Pair(expr, result);
    }
    return result;
  }
}

/// Singleton class for [undefined].
class Undefined extends SelfEvaluating {
  const Undefined._internal();
  toString() => "undefined";

  /// If the web library has been loaded, this returns the JS value `undefined`.
  ///
  /// Otherwise, it returns null.
  toJS() => Undefined.jsUndefined;

  /// Initialized to the JS value `undefined` when the web library is loaded.
  static dynamic jsUndefined;
}

/// Represents undefined values in Scheme, like `(if #f 1)`.
const undefined = Undefined._internal();

/// An expression to be evaluated in an environment.
///
/// Used internally for tail-call optimization. Should not be output.
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
      expressions.forEach(e.addCall);
      rethrow;
    }
  }

  toJS() => throw StateError("Thunks should not be passed to JS");
  toString() => 'Thunk($expr in f${env.id})';
}

/// A Scheme promise, used for Scheme streams.
///
/// A Scheme promise is a delayed expression that will be evaluated when forced.
/// Once forced, the result is cached and returned directly when forced again.
///
/// Scheme promises are primarily used for created Scheme streams. A Scheme
/// stream is the lazy equivalent of a Scheme list and is defined as a pair
/// whose cdr is a promise that evaluates to another stream or the empty list.
///
/// It is semantically different from a JS Promise, which is equivalent to a
/// Dart [Future]. The Scheme equivalent of [Future] is [AsyncExpression].
///
/// A Scheme stream is semantically different from a Dart Stream, which is an
/// asynchronous sequence. A Scheme stream is analogous to a lazily-computed
/// iterable built on a linked list.
class Promise extends SelfEvaluating {
  Expression expr;
  final Frame env;
  bool _evaluated = false;
  Promise(this.expr, this.env);

  /// Evaluates the promise, or returns the result if already evaluated.
  Expression force() {
    if (!_evaluated) {
      expr = schemeEval(expr, env);
      _evaluated = true;
    }
    return expr;
  }

  toString() => "#[promise (${_evaluated ? '' : 'not '}forced)]";
  @override

  /// Promises are represented in diagrams as a circle with ⋯ inside prior to
  /// forcing, and the evaluated result afterwards.
  Widget draw(DiagramInterface diagram) {
    var inside = _evaluated ? diagram.pointTo(expr) : TextWidget("⋯");
    return Block.promise(inside);
  }
}

/// A Scheme environment.
///
/// This consists of a set of [bindings] between [SchemeSymbol] identifiers and
/// [Expression] values, as well as a [parent]. When looking up a symbol, the
/// current bindings map is checked first, before recursively checking the
/// parent frame.
///
/// This also maintains a reference to the [Interpreter] it is part of, which
/// allows any function that takes in a [Frame] to access core interpreter
/// functionality (like logging and the project implementation).
///
/// Within an interpreter, there is a single global frame with [id] equal to 0
/// and [parent] equal to null. All frames should inherit from the global frame
/// either directly or through a chain of parent frames.
class Frame extends SelfEvaluating {
  /// The parent of this frame. This is null for the global frame.
  Frame parent;

  /// The interpreter this frame is part of.
  Interpreter interpreter;

  /// Optional human-readable name for this frame.
  ///
  /// Set to the intrinsic name of the called function when this frame was
  /// created through a procedure call.
  String tag;

  /// Unique identifier for this frame in the interpreter.
  ///
  /// The global frame has id 0. All other frame are numbered sequentially.
  int id;

  /// True if this frame was created by a MacroProcedure.
  bool fromMacro = false;

  /// Mapping of symbols to values.
  Map<SchemeSymbol, Expression> bindings = {};

  /// Stores whether a given symbol should be hidden from environment diagrams.
  Map<SchemeSymbol, bool> hidden = {};

  /// Creates a new frame with the next sequential id.
  Frame(this.parent, this.interpreter) : id = interpreter.frameCounter++;

  /// Creates a new binding between [symbol] and [value] in this frame.
  ///
  /// If hide is true, this binding will be hidden from environment diagrams.
  void define(SchemeSymbol symbol, Expression value, [bool hide = false]) {
    interpreter.impl.defineInFrame(symbol, value, this);
    hidden[symbol] = hide;
  }

  /// Looks up the given symbol in this or a parent frame.
  Expression lookup(SchemeSymbol symbol) =>
      interpreter.impl.lookupInFrame(symbol, this);

  /// Changes an existing binding to a new value in this or a parent frame.
  ///
  /// If the symbol is not bound, throws a [SchemeException].
  void update(SchemeSymbol symbol, Expression value) {
    if (bindings.containsKey(symbol)) {
      bindings[symbol] = value;
      return;
    }
    if (parent == null) throw SchemeException("$symbol is not bound");
    parent.update(symbol, value);
  }

  /// Creates a frame with this as its parent and all [formals] bound to [vals].
  Frame makeChildFrame(Expression formals, Expression vals) =>
      interpreter.impl.makeChildOf(formals, vals, this);
}
