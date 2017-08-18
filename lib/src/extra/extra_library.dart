library cs61a_scheme.extra.extra_library;

import 'dart:async';

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'async.dart';
import 'diagramming.dart';
import 'operand_procedures.dart';
import 'visualization.dart';

part '../../gen/extra/extra_library.gen.dart';

/// Note: When the signatures (including any annotations) of any of this methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the primitives and performs type checking on arguments).
@register
class ExtraLibrary extends SchemeLibrary with _$ExtraLibraryMixin {
  void importAll(Frame env) {
    super.importAll(env);
    env.interpreter.specialForms[const SchemeSymbol('define-async')] = doDefineAsync;
    env.interpreter.specialForms[const SchemeSymbol('lambda-async')] = doAsyncLambda;
  }
  
  @primitive @SchemeSymbol("run-async")
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
    var resolve = new PrimitiveProcedure.fixed(const SchemeSymbol("async:resolve"), resolver, 1);
    var reject = new PrimitiveProcedure.fixed(const SchemeSymbol("async:reject"), rejecter, 1);
    var operands = new PairOrEmpty.fromIterable([resolve, reject]);
    new Future.microtask(() => completeEval(proc.apply(operands, env)));
    return completer.future;
  }
  
  @primitive @SchemeSymbol("run-after")
  Future<Expression> runAfter(Number millis, Procedure proc, Frame env) {
    var duration = new Duration(milliseconds: millis.toJS());
    return new Future.delayed(duration, () => completeEval(proc.apply(nil, env)));
  }
  
  @primitive @SchemeSymbol("completed?")
  Boolean isCompleted(AsyncExpression expr) =>
    expr.complete ? schemeTrue : schemeFalse;
  
  @primitive
  void render(UIElement ui, Frame env) {
    env.interpreter.renderer(ui);
  }
  
  @primitive
  Diagram draw(Expression expression) {
    return new Diagram(expression);
  }
  
  @primitive
  Diagram diagram(Frame env) {
    return new Diagram(env);
  }
    
  @primitive @noeval
  Visualization visualize(Expression code, Frame env) {
    return new Visualization(code, env);
  }
  
  @primitive
  PairOrEmpty bindings(Frame env) {
    return new PairOrEmpty.fromIterable(env.bindings.keys);
  }
  
  @primitive @SchemeSymbol('trigger-event')
  void triggerEvent(SchemeSymbol id, Expression data, Frame env) {
    env.interpreter.triggerEvent(id, data);
  }

  @primitive @SchemeSymbol('listen-for')
  EventListener listenFor(SchemeSymbol id, Procedure onEvent, Frame env) {
    return new EventListener(id, env.interpreter.events(id).listen((value) {
      onEvent.apply(new Pair(value, nil), env);
    }));
  }

  @primitive @SchemeSymbol('cancel-listener')
  AsyncExpression<Undefined> cancelListener(EventListener listener) {
    return new AsyncExpression(listener.subscription.cancel().then((e) {
      return undefined;
    }));
  }
  
  @primitive @SchemeSymbol('string-append')
  String stringAppend(List<Expression> exprs) {
    return exprs.map((e) => e.display).join('');
  }

}
