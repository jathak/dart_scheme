library cs61a_scheme.core.values;

import 'expressions.dart';
import 'frame.dart';
import 'logging.dart';
import 'utils.dart';
import 'widgets.dart';

/// Base class for all Scheme data types.
///
/// Everything that can be touched by Scheme code should inherit from this.
abstract class Value {
  const Value();

  /// All Scheme expressions are truthy except for the [Boolean] `#f`.
  bool get isTruthy => true;

  /// Determines how this expression is represented in environment diagrams.
  ///
  /// If true, this expression should be inlined in diagrams.
  /// If false, it should be added to the objects with an arrow to it.
  bool get inlineInDiagram => false;

  /// Constructs a [Widget] for this value.
  ///
  /// The default implementation returns the string representation of this value
  /// as a [TextWidget]. Some values may need to add objects to [diagram].
  Widget draw(DiagramInterface diagram) => TextWidget(toString());

  /// Shorthand for `expr is EmptyList`.
  bool get isNil => false;

  /// Defines how this expression should be displayed.
  ///
  /// Used by the `(display <expr>)` built-in. Defaults to [toString].
  String get display => toString();

  /// Should return a version of this object that can be passed to JS.
  ///
  /// The default implementation just returns the value itself, so this
  /// should be overridden if passing to JS is intended.
  dynamic toJS() => this;

  /// Convenience function since casting as a Pair is very common.
  Pair get pair => this as Pair;
}

/// Singleton class for [undefined].
class Undefined extends Value {
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
class Thunk extends Value {
  final Expression expr;
  final Frame env;
  const Thunk(this.expr, this.env);
  Expression evaluate(Frame _) {
    List<Expression> expressions = [];
    try {
      Value result = this;
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
class Promise extends Value {
  Expression expr;
  final Frame env;
  bool _evaluated = false;
  Promise(this.expr, this.env);

  /// Evaluates the promise, or returns the result if already evaluated.
  Expression force() {
    if (!_evaluated) {
      expr = schemeEval(expr, env);
      // Added to disallow malformed lists/streams
      if (!(expr is PairOrEmpty &&
          ((expr as PairOrEmpty).wellFormed || expr.pair.second is Promise))) {
        throw SchemeException("A promise must contain a pair or nil");
      }
      _evaluated = true;
    }
    return expr;
  }

  toString() => "#[promise (${_evaluated ? '' : 'not '}forced)]";

  /// Promises are represented in diagrams as a circle with ⋯ inside prior to
  /// forcing, and the evaluated result afterwards.
  Widget draw(DiagramInterface diagram) {
    var inside = _evaluated ? diagram.pointTo(expr) : TextWidget("⋯");
    return Block.promise(inside);
  }
}
