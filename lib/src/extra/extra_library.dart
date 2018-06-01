library cs61a_scheme.extra.extra_library;

import 'dart:async';

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'async.dart';
import 'diagramming.dart';
import 'flag_trace.dart';
import 'logic_library.dart';
import 'operand_procedures.dart';
import 'visualization.dart';

part 'extra_library.g.dart';

/// Note: When the signatures (including any annotations) of any of theses methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the primitives and performs type checking on arguments).
@schemelib
class ExtraLibrary extends SchemeLibrary with _$ExtraLibraryMixin {
  ExtraLibrary() {
    initTraceDeserializers();
  }

  void importAll(Frame env) {
    super.importAll(env);
    env.interpreter.specialForms[const SchemeSymbol('define-async')] =
        doDefineAsync;
    env.interpreter.specialForms[const SchemeSymbol('lambda-async')] =
        doAsyncLambda;
  }

  @SchemeSymbol("run-async")
  Future<Expression> runAsync(Procedure proc, Frame env) {
    var completer = new Completer<Expression>();

    var resolver = (List<Expression> args, Frame env) {
      completer.complete(args[0]);
      return undefined;
    };
    var rejecter = (List<Expression> args, Frame env) {
      completer.completeError(new SchemeException("${args[0]}"));
      return undefined;
    };
    var resolve = new PrimitiveProcedure.fixed(
        const SchemeSymbol("async:resolve"), resolver, 1);
    var reject = new PrimitiveProcedure.fixed(
        const SchemeSymbol("async:reject"), rejecter, 1);
    var operands = new PairOrEmpty.fromIterable([resolve, reject]);
    new Future.microtask(() => completeEval(proc.apply(operands, env)));
    return completer.future;
  }

  @SchemeSymbol("run-after")
  Future<Expression> runAfter(Number millis, Procedure proc, Frame env) {
    var duration = new Duration(milliseconds: millis.toJS());
    return new Future.delayed(
        duration, () => completeEval(proc.apply(nil, env)));
  }

  @SchemeSymbol("completed?")
  Boolean isCompleted(AsyncExpression expr) =>
      expr.complete ? schemeTrue : schemeFalse;

  Diagram draw(Expression expression) {
    return new Diagram(expression);
  }

  Diagram diagram(Frame env) {
    return new Diagram(env);
  }

  @noeval
  Visualization visualize(Expression code, Frame env) {
    return new Visualization(code, env);
  }

  PairOrEmpty bindings(Frame env) {
    return new PairOrEmpty.fromIterable(env.bindings.keys);
  }

  @SchemeSymbol('trigger-event')
  @MinArgs(1)
  void triggerEvent(List<Expression> exprs, Frame env) {
    if (exprs.first is! SchemeSymbol) {
      throw new SchemeException('${exprs.first} is not a symbol');
    }
    env.interpreter.triggerEvent(exprs[0], exprs.skip(1).toList(), env);
  }

  @SchemeSymbol('listen-for')
  SchemeEventListener listenFor(SchemeSymbol id, Procedure onEvent, Frame env) {
    var callback = (List<Expression> exprs, Frame env) {
      try {
        schemeApply(onEvent, new PairOrEmpty.fromIterable(exprs), env);
      } catch (e) {
        if (e is SchemeException) {
          e.addCall(onEvent);
          var eventPair = new Pair(id, new PairOrEmpty.fromIterable(exprs));
          e.addCall(new TextMessage('<event ${eventPair}>'));
        }
        env.interpreter.logError(e);
      }
    };
    env.interpreter.listenFor(id, callback);
    return new SchemeEventListener(id, callback);
  }

  @SchemeSymbol('cancel-listener')
  void cancelListener(SchemeEventListener listener, Frame env) {
    env.interpreter.stopListening(listener.id, listener.callback);
  }

  @SchemeSymbol('cancel-all')
  void cancelAll(SchemeSymbol id, Frame env) {
    env.interpreter.stopAllListeners(id);
  }

  @SchemeSymbol('string-append')
  String stringAppend(List<Expression> exprs) {
    return exprs.map((e) => e.display).join('');
  }

  @noeval
  FlagTrace trace(Expression code, Frame env) {
    return new FlagTraceBuilder(code, env).trace;
  }

  @SchemeSymbol('trace->visualization')
  Visualization traceToVisualization(FlagTrace trace) {
    return new Visualization.fromTrace(trace);
  }

  String serialize(Serializable expr) {
    return Serialization.serializeToJson(expr);
  }

  Expression deserialize(String json) {
    return Serialization.deserializeFromJson(json);
  }

  MarkdownWidget formatted(List<Expression> expressions, Frame env) {
    String text = expressions.map((expr) => expr.display).join('');
    return new MarkdownWidget(text, inline: true, env: env);
  }

  @SchemeSymbol('logic')
  void logicStart(Frame env) {
    env.interpreter.importLibrary(new LogicLibrary());
  }
}
