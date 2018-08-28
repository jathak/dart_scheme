library cs61a_scheme.core.frame;

import 'expressions.dart';
import 'interpreter.dart';
import 'logging.dart';
import 'values.dart';

/// A Scheme environment.
///
/// This consists of a set of [bindings] between [SchemeSymbol] identifiers and
/// [Value] values, as well as a [parent]. When looking up a symbol, the
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
class Frame {
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
  Map<SchemeSymbol, Value> bindings = {};

  /// Stores whether a given symbol should be hidden from environment diagrams.
  Map<SchemeSymbol, bool> hidden = {};

  /// Creates a new frame with the next sequential id.
  Frame(this.parent, this.interpreter) : id = interpreter.frameCounter++;

  /// Creates a new binding between [symbol] and [value] in this frame.
  ///
  /// If hide is true, this binding will be hidden from environment diagrams.
  void define(SchemeSymbol symbol, Value value, [bool hide = false]) {
    interpreter.impl.defineInFrame(symbol, value, this);
    hidden[symbol] = hide;
  }

  /// Looks up the given symbol in this or a parent frame.
  Value lookup(SchemeSymbol symbol) =>
      interpreter.impl.lookupInFrame(symbol, this);

  /// Changes an existing binding to a new value in this or a parent frame.
  ///
  /// If the symbol is not bound, throws a [SchemeException].
  void update(SchemeSymbol symbol, Value value) {
    if (bindings.containsKey(symbol)) {
      bindings[symbol] = value;
      return;
    }
    if (parent == null) throw SchemeException("$symbol is not bound");
    parent.update(symbol, value);
  }

  /// Creates a frame with this as its parent and all [formals] bound to [vals].
  Frame makeChildFrame(Expression formals, Value vals) =>
      interpreter.impl.makeChildOf(formals, vals, this);
}
