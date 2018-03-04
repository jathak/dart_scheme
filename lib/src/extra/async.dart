library cs61a_scheme.extra.async_special_forms;

import 'dart:async';

import 'package:cs61a_scheme/cs61a_scheme.dart';

class AsyncExpression<T extends Expression> extends Expression {
  Future<T> _future;
  Future<T> get future => _future;
  bool _complete = false;
  bool get complete => _complete;
  T _result;
  T get result => _result;
  Object jsPromise = null;

  AsyncExpression(Future<T> future) {
    _future = future.then((e) async {
      while (e is AsyncExpression) {
        e = await (e as AsyncExpression).future;
      }
      _result = e;
      _complete = true;
      return e;
    });
  }

  Expression evaluate(Frame env) {
    if (complete) return result;
    return this;
  }

  AsyncExpression chain(Expression Function(T) fn) {
    return new AsyncExpression(_future.then(fn));
  }

  toString() => complete ? "#[async:$result]" : "#[async]";
  toJS() => jsPromise ?? AsyncExpression.makePromise(this);
  static dynamic Function(AsyncExpression) makePromise = (expr) {
    throw new UnimplementedError("JS interop must be loaded for AsyncExpression.toJS() to work.");
  };

  @override
  UIElement draw(DiagramInterface diagram) {
    UIElement inside = complete ? diagram.pointTo(result) : new TextElement("async");
    return new Block.async(inside);
  }
}

class AsyncLambdaProcedure extends LambdaProcedure {
  AsyncLambdaProcedure(formals, body, env) : super(formals, body, env);

  AsyncExpression apply(PairOrEmpty arguments, Frame env) {
    Frame frame = makeCallFrame(arguments, env);
    FutureOr<Expression> expr = env.interpreter.implementation.asyncEvalAll(body, frame);
    if (expr is Expression) return expr;
    return new AsyncExpression(expr);
  }
}

class EventListener extends SelfEvaluating {
  final SchemeSymbol id;
  final SchemePrimitive callback;
  EventListener(this.id, this.callback);

  toString() => '#[event-listener:$id]';

  toJS() => this;
}

/// define-async special form
Expression doDefineAsync(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.doDefineAsync(expressions, env);
}

/// lambda-async special form
LambdaProcedure doAsyncLambda(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.doAsyncLambda(expressions, env);
}

typedef Future<Expression> AsyncSpecialForm(PairOrEmpty expressions, Frame env);

FutureOr<Expression> asyncEval(Expression exprs, Frame env) {
  if (exprs is Pair) {
    Expression first = exprs.first, rest = exprs.second;
    if (first == const SchemeSymbol("await")) {
      checkForm(rest, 1, 1);
      FutureOr<Expression> result = asyncEval(rest.pair.first, env);
      if (result is AsyncExpression) {
        return result.future;
      } else if (result is Future<AsyncExpression>) {
        return result.then((expr) => expr.future);
      } else {
        return result;
      }
    } else if (asyncSpecialForms.containsKey(first)) {
      return asyncSpecialForms[first](rest, env);
    } else if (env.interpreter.specialForms.containsKey(first)) {
      return env.interpreter.specialForms[first](rest, env);
    } else {
      return env.interpreter.implementation.asyncEvalProcedureCall(first, rest, env);
    }
  } else {
    return schemeEval(exprs, env);
  }
}

Map<SchemeSymbol, AsyncSpecialForm> asyncSpecialForms = {
  const SchemeSymbol('define'): asyncDefineForm,
  const SchemeSymbol('if'): asyncIfForm,
  const SchemeSymbol('cond'): asyncCondForm,
  const SchemeSymbol('and'): asyncAndForm,
  const SchemeSymbol('or'): asyncOrForm,
  const SchemeSymbol('let'): asyncLetForm,
  const SchemeSymbol('begin'): asyncBeginForm,
  const SchemeSymbol('cons-stream'): asyncConsStreamForm,
  /*const SchemeSymbol('set!') : asyncSetForm,
  const SchemeSymbol('quasiquote') : asyncQuasiquoteForm,
  const SchemeSymbol('unquote') : asyncUnquoteForm,
  const SchemeSymbol('unquote-splicing') : asyncUnquoteSplicingForm*/
};

Future<Expression> asyncDefineForm(PairOrEmpty expressions, Frame env) async {
  return env.interpreter.implementation.asyncDefineForm(expressions, env);
}

Future<Expression> asyncIfForm(PairOrEmpty expressions, Frame env) async {
  checkForm(expressions, 2, 3);
  Expression predicate = expressions.first;
  if ((await asyncEval(predicate, env)).isTruthy) {
    Expression consequent = expressions.elementAt(1);
    return await asyncEval(consequent, env);
  } else if (expressions.length == 3) {
    Expression alternative = expressions.last;
    return await asyncEval(alternative, env);
  }
  return undefined;
}

Future<Expression> asyncCondForm(PairOrEmpty expressions, Frame env) async {
  while (!expressions.isNil) {
    Expression clause = expressions.pair.first;
    checkForm(clause, 1);
    Expression test;
    if ((clause.pair.first as SchemeSymbol).value == 'else') {
      test = schemeTrue;
    } else {
      test = await asyncEval(clause.pair.first, env);
    }
    if (test.isTruthy) {
      return await env.interpreter.implementation.asyncCondResult(clause, env, test);
    }
    expressions = expressions.pair.second;
  }
  return undefined;
}

Future<Expression> asyncAndForm(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.asyncAndForm(expressions, env);
}

Future<Expression> asyncOrForm(PairOrEmpty expressions, Frame env) {
  return env.interpreter.implementation.asyncOrForm(expressions, env);
}

Future<Expression> asyncLetForm(PairOrEmpty expressions, Frame env) async {
  checkForm(expressions, 2);
  Expression bindings = expressions.pair.first;
  Expression body = expressions.pair.second;
  Frame letEnv = await env.interpreter.implementation.asyncLetFrame(bindings, env);
  return await env.interpreter.implementation.asyncEvalAll(body, letEnv);
}

Future<Expression> asyncBeginForm(PairOrEmpty expressions, Frame env) async {
  checkForm(expressions, 1);
  return await env.interpreter.implementation.asyncEvalAll(expressions, env);
}

Future<Pair<Expression, Promise>> asyncConsStreamForm(PairOrEmpty expressions, Frame env) async {
  checkForm(expressions, 2, 2);
  checkForm(expressions.pair.second, 1, 1);
  Promise promise = new Promise(expressions.pair.second, env);
  return new Pair(await asyncEval(expressions.pair.first, env), promise);
}

/*Expression doSetForm(PairOrEmpty expressions, Frame env) {
  throw new UnimplementedError("Special form not yet implemented.");
}

Expression doQuasiquoteForm(PairOrEmpty expressions, Frame env) {
  throw new UnimplementedError("Special form not yet implemented.");
}

Expression doUnquoteForm(PairOrEmpty expressions, Frame env) {
  throw new UnimplementedError("Special form not yet implemented.");
}

Expression doUnquoteSplicingForm(PairOrEmpty expressions, Frame env) {
  throw new UnimplementedError("Special form not yet implemented.");
}*/
