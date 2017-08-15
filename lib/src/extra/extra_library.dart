library cs61a_scheme.extra.extra_library;

import 'dart:async';

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'async.dart';
import 'diagramming.dart';
import 'operand_procedures.dart';
import 'visualization.dart' as visualization;

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
  AsyncExpression runAsync(Procedure proc, Frame env) {
    var completer = new Completer();
    
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
    return new AsyncExpression(completer.future);
  }
  
  @primitive @SchemeSymbol("run-after")
  AsyncExpression runAfter(Number millis, Procedure proc, Frame env) {
    var duration = new Duration(milliseconds: millis.toJS());
    var future = new Future.delayed(duration, () => completeEval(proc.apply(nil, env)));
    return new AsyncExpression(future);
  }
  
  @primitive
  Undefined diagram(Frame env) {
    env.interpreter.renderer(new Diagram(env));
    return undefined;
  }
  
  @primitive
  Undefined render(Expression expression, Frame env) {
    if (expression is! UIElement) expression = new Diagram(expression);
    env.interpreter.renderer(expression);
    return undefined;
  }
  
  @primitive @SchemeSymbol('make-diagram')
  Diagram makeDiagram(Expression expression, Frame env) {
    return new Diagram(expression);
  }
    
  @primitive @noeval
  Expression visualize(Expression code, Frame env) {
    return visualization.visualize(code, env);
  }
  
  @primitive @SchemeSymbol('vis-goto')
  Undefined visGoto(Number number) {
    visualization.visGoto(number.toJS());
    return undefined;
  }
  
  @primitive @SchemeSymbol('vis-exit')
  Undefined visExit() {
    visualization.visExit();
    return undefined;
  }
  
  @primitive @SchemeSymbol('vis-first')
  Undefined visFirst() {
    visualization.visFirst();
    return undefined;
  }
  
  @primitive @SchemeSymbol('vis-last')
  Undefined visLast() {
    visualization.visLast();
    return undefined;
  }
  
  @primitive @SchemeSymbol('vis-next')
  Undefined visNext() {
    visualization.visNext();
    return undefined;
  }
  
  @primitive @SchemeSymbol('vis-prev')
  Undefined visPrev() {
    visualization.visPrev();
    return undefined;
  }
  
  @primitive
  PairOrEmpty bindings(Frame env) {
    return new PairOrEmpty.fromIterable(env.bindings.keys);
  }
  
}
