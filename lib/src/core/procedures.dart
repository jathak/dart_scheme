library cs61a_scheme.core.procedures;

import 'expressions.dart';
import 'logging.dart';
import 'ui.dart';

/// Base class for all Scheme procedures.
///
/// A Scheme procedure is analagous to a Dart or JS function and call be called
/// with 0 or more arguments through a call expression.
abstract class Procedure extends SelfEvaluating {
  /// Intrinsic name of this procedure. `null` if none.
  SchemeSymbol get name;
  Procedure();

  /// Calls the procedure in [env] with a list of unevaluated [operands].
  Expression call(PairOrEmpty operands, Frame env) {
    return env.interpreter.impl.procedureCall(this, operands, env);
  }

  /// Applies the procedure in [env] to a list of [arguments].
  ///
  /// Arguments are typically evaluated, except in the case of [MacroProcedure]
  /// or [OperandPrimitiveProcedure].
  Expression apply(PairOrEmpty arguments, Frame env);
  @override
  toString() => '#[$name]';

  /// Returns a Dart/JS function wrapper around this procedure if the web
  /// library has been loaded, or errors otherwise.
  toJS() => Procedure.jsProcedure(this);

  /// Initialized to a function that wraps this procedure into a Dart function.
  ///
  /// That function can then be converted to a JS function when passed to JS.
  /// Errors if web library has not been loaded.
  static dynamic Function(Procedure) jsProcedure = (p) {
    throw new SchemeException(
        "JS interop must be enabled for Procedure.toJS() to work");
  };
}

/// Used for defining built-in Scheme procedures.
typedef Expression SchemePrimitive(List<Expression> args, Frame env);

/// A built-in Scheme procedure.
///
/// The constructors here should typically not be called directly. Use
/// [addPrimitive] or [addVariablePrimitive] instead, or, even better, create
/// a [SchemeLibrary] to create a collection with automatic type checking and
/// conversion.
class PrimitiveProcedure extends Procedure {
  /// The intrinsic name of this built-in procedure.
  final SchemeSymbol name;

  /// Underlying Dart function that is called when this procedure is called.
  final SchemePrimitive fn;

  /// True if this procedure takes a fixed number of arguments.
  final bool fixedArgs;

  /// Minimum and maximum number of arguments accepted by this procedure.
  ///
  /// These should be equal if [fixedArgs] is true. If [maxArgs] is -1, there
  /// is no maximum number of arguments that can be passed to this procedure.
  final int minArgs, maxArgs;

  /// Creates a new procedure [name] that calls [fn] and takes [args] args.
  PrimitiveProcedure.fixed(this.name, this.fn, int args)
      : fixedArgs = true,
        minArgs = args,
        maxArgs = args;

  /// Creates a new procedure [name] that calls [fn] and takes between [minArgs]
  /// and [maxArgs] arguments.
  PrimitiveProcedure.variable(this.name, this.fn, this.minArgs,
      [this.maxArgs = -1])
      : fixedArgs = false;

  Expression apply(PairOrEmpty arguments, Frame env) {
    return env.interpreter.impl.primitiveApply(this, arguments, env);
  }
}

/// A [Procedure] that was defined by the user within Scheme code.
abstract class UserDefinedProcedure extends Procedure {
  /// Formal parameters of this procedure.
  ///
  /// Should typically be a well-formed Scheme list of [SchemeSymbol], but may
  /// be dotted or a single [SchemeSymbol] if the procedure takes in a variable
  /// number of arguments.
  Expression get formals;

  /// Scheme list of expressions in the body of this procedure.
  PairOrEmpty get body;

  /// Creates a new frame to evaluate the body in when this procedure is called.
  Frame makeCallFrame(PairOrEmpty arguments, Frame env);

  Expression call(PairOrEmpty operands, Frame env) {
    env.interpreter.triggerEvent(const SchemeSymbol('pre-user-call'), [], env);
    return super.call(operands, env);
  }

  Expression apply(PairOrEmpty arguments, Frame env) {
    Frame frame = makeCallFrame(arguments, env);
    if (name != null) frame.tag = name.toString();
    env.interpreter.triggerEvent(const SchemeSymbol('new-frame'), [], frame);
    var result = env.interpreter.impl.evalAll(body, frame);
    env.interpreter.triggerEvent(const SchemeSymbol('return'), [result], frame);
    return result;
  }

  @override
  UIElement draw(diag) => new TextElement(new Pair(name, formals).toString());
}

/// A [UserDefinedProcedure] with lexical scope and normal operand evaluation.
///
/// Created with the `lambda` special form or with the `define` shorthand.
class LambdaProcedure extends UserDefinedProcedure {
  /// Intrinsic name of this procedure.
  ///
  /// When created with `lambda`, this will be `"λ"`.
  /// When created with `(define (fn ...) ...)`, this will be `"fn"`.
  SchemeSymbol name;
  final Expression formals;
  final PairOrEmpty body;

  /// The frame this lambda was defined in.
  ///
  /// Used as the parent of call frames.
  final Frame env;

  LambdaProcedure(this.formals, this.body, this.env,
      [this.name = const SchemeSymbol('λ')]);

  /// Creates a call frame based on [env], the frame this lambda was defined in.
  Frame makeCallFrame(PairOrEmpty arguments, Frame _) {
    return env.interpreter.impl.makeLambdaFrame(this, arguments, env);
  }

  @override
  toString() =>
      new Pair(new SchemeSymbol('lambda'), new Pair(formals, body)).toString();

  @override
  UIElement draw(diag) {
    var parent = env.id == 0 ? '' : ' [parent=f${env.id}]';
    var msg = "${new Pair(name, formals)}$parent";
    return new TextElement(msg);
  }
}

/// A [LambdaProcedure] that takes in unevaluated operands and then evaluates
/// its return value in the calling environment.
///
/// Used to create macros, which allows Scheme code to define new special forms.
class MacroProcedure extends LambdaProcedure {
  MacroProcedure(formals, body, env) : super(formals, body, env);

  /// Instead of evaluated the operands, they are passed directly to [apply].
  @override
  Expression call(PairOrEmpty operands, Frame env) {
    return env.interpreter.impl.macroCall(this, operands, env);
  }

  toString() =>
      new Pair(new SchemeSymbol('#macro'), new Pair(formals, body)).toString();
}

/// A [UserDefinedProcedure] with dynamic scope and normal operand evaluation.
///
/// Dynamic scope means that, when this procedure is called, the parent of the
/// call frame will be the frame it was called in, rather than the frame it was
/// defined in.
class MuProcedure extends UserDefinedProcedure {
  SchemeSymbol name;
  final PairOrEmpty formals, body;

  MuProcedure(this.formals, this.body, [this.name = const SchemeSymbol('μ')]);

  /// Creates a call frame based on [env], the frame this mu was called in.
  Frame makeCallFrame(PairOrEmpty arguments, Frame env) {
    return env.interpreter.impl.makeMuFrame(this, arguments, env);
  }

  toString() =>
      new Pair(new SchemeSymbol('mu'), new Pair(formals, body)).toString();
}

/// An approximation of a first-class continuation.
///
/// Unlike true continuations, this is built on top of exceptions, so it may
/// only be called once.
///
/// For more information on continuations see [the Wikipedia page][wiki].
///
/// [wiki]: https://en.wikipedia.org/wiki/Continuation
class Continuation extends Procedure {
  final SchemeSymbol name = null;
  static int counter = 0;
  final int id;
  Expression result;
  Continuation() : id = counter++;

  Expression apply(PairOrEmpty args, Frame env) {
    return env.interpreter.impl.continuationApply(this, args, env);
  }

  toString() => "#[continuation$id]";
}
