library cs61a_scheme.extra.extra_library;

import 'dart:async';

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'async.dart';
import 'diagramming.dart';
import 'logic_library.dart';
import 'operand_procedures.dart';
import 'visualization.dart';

part 'extra_library.g.dart';

/// Note: When the signatures (including any annotations) of any of theses methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the built-ins and performs type checking on arguments).
@schemelib
class ExtraLibrary extends SchemeLibrary with _$ExtraLibraryMixin {
  void importAll(Frame env) {
    super.importAll(env);
    env.interpreter.specialForms[const SchemeSymbol('define-async')] =
        doDefineAsync;
    env.interpreter.specialForms[const SchemeSymbol('lambda-async')] =
        doAsyncLambda;
  }

  @SchemeSymbol("run-async")
  Future<Expression> runAsync(Procedure proc, Frame env) {
    var completer = Completer<Expression>();

    var resolver = (args, env) {
      completer.complete(args[0]);
      return undefined;
    };
    var rejecter = (args, env) {
      completer.completeError(SchemeException("${args[0]}"));
      return undefined;
    };
    var resolve = BuiltinProcedure.fixed(
        const SchemeSymbol("async:resolve"), resolver, 1);
    var reject =
        BuiltinProcedure.fixed(const SchemeSymbol("async:reject"), rejecter, 1);
    var operands = PairOrEmpty.fromIterable([resolve, reject]);
    Future.microtask(() => completeEval(proc.apply(operands, env)));
    return completer.future;
  }

  @SchemeSymbol("run-after")
  Future<Expression> runAfter(Number millis, Procedure proc, Frame env) {
    var duration = Duration(milliseconds: millis.toJS());
    return Future.delayed(duration, () => completeEval(proc.apply(nil, env)));
  }

  @SchemeSymbol("completed?")
  Boolean isCompleted(AsyncExpression expr) =>
      expr.complete ? schemeTrue : schemeFalse;

  /// Creates a diagram of [expression].
  Diagram draw(Expression expression) => Diagram(expression);

  /// Create a diagram of the current environment.
  Diagram diagram(Frame env) => Diagram(env);

  /// Visualizes the execution of a piece of code.
  @noeval
  Visualization visualize(List<Expression> code, Frame env) =>
      Visualization(code, env);

  /// Returns a list of all bindings in the current environment.
  PairOrEmpty bindings(Frame env) =>
      PairOrEmpty.fromIterable(env.bindings.keys);

  /// Triggers an event with a given name (first arg) and arguments.
  @SchemeSymbol('trigger-event')
  @MinArgs(1)
  void triggerEvent(List<Expression> exprs, Frame env) {
    if (exprs.first is! SchemeSymbol) {
      throw SchemeException('${exprs.first} is not a symbol');
    }
    env.interpreter.triggerEvent(exprs[0], exprs.skip(1).toList(), env);
  }

  /// Sets up an listener to call [onEvent] when an event with [id] occurs.
  @SchemeSymbol('listen-for')
  SchemeEventListener listenFor(SchemeSymbol id, Procedure onEvent, Frame env) {
    var callback = (exprs, env) {
      try {
        schemeApply(onEvent, PairOrEmpty.fromIterable(exprs), env);
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        if (e is SchemeException) {
          e.addCall(onEvent);
          var eventPair = Pair(id, PairOrEmpty.fromIterable(exprs));
          e.addCall(TextMessage('<event $eventPair>'));
        }
        env.interpreter.logError(e);
      }
    };
    env.interpreter.listenFor(id, callback);
    return SchemeEventListener(id, callback);
  }

  /// Cancels [listener] from triggering on new events.
  @SchemeSymbol('cancel-listener')
  void cancelListener(SchemeEventListener listener, Frame env) {
    env.interpreter.stopListening(listener.id, listener.callback);
  }

  /// Cancels all listeners for event [id].
  @SchemeSymbol('cancel-all')
  void cancelAll(SchemeSymbol id, Frame env) {
    env.interpreter.stopAllListeners(id);
  }

  /// Constructs a string from the display values of any number of expressions.
  @SchemeSymbol('string-append')
  String stringAppend(List<Expression> exprs) =>
      exprs.map((e) => e.display).join('');

  String serialize(Serializable expr) => Serialization.serializeToJson(expr);

  Expression deserialize(String json) =>
      Serialization.deserializeFromJson(json);

  /// Renders all provided text as a block of Markdown.
  MarkdownWidget formatted(List<Expression> expressions, Frame env) {
    String text = expressions.map((expr) => expr.display).join('');
    return MarkdownWidget(text, inline: true, env: env);
  }

  /// Loads procedures to run Logic code within the interpreter.
  @SchemeSymbol('logic')
  void logicStart(Frame env) {
    env.interpreter.importLibrary(LogicLibrary());
  }

  /// Returns the documentation for [procedure], if it exists.
  Docs docs(Procedure procedure) {
    if (procedure.docs == null) {
      throw SchemeException(
          "No documentation for ${procedure.name} exists", false);
    }
    return procedure.docs;
  }
}
