library cs61a_scheme.extra.extra_library;

import 'dart:async';

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'async.dart';

part '../../gen/extra/extra_library.gen.dart';

@register
class ExtraLibrary extends SchemeLibrary with _$ExtraLibraryMixin {
  void importAll(Frame env) {
    super.importAll(env);
    env.interpreter.specialForms[const SchemeSymbol('define-async')] = doDefineAsync;
    env.interpreter.specialForms[const SchemeSymbol('lambda-async')] = doAsyncLambda;
  }
  
  @primitive @SchemeSymbol("run-async")
  static AsyncExpression runAsync(Procedure proc, Frame env) {
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
  static AsyncExpression runAfter(Number millis, Procedure proc, Frame env) {
    var duration = new Duration(milliseconds: millis.toJS());
    var future = new Future.delayed(duration, () => completeEval(proc.apply(nil, env)));
    return new AsyncExpression(future);
  }
}
