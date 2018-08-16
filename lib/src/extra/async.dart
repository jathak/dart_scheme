library cs61a_scheme.extra.async_special_forms;

import 'dart:async';

import 'package:cs61a_scheme/cs61a_scheme.dart';

class AsyncExpression<T extends Expression> extends Expression {
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

  Future<T> _future;
  Future<T> get future => _future;
  bool _complete = false;
  bool get complete => _complete;
  T _result;
  T get result => _result;
  Object jsPromise;

  Expression evaluate(Frame env) {
    if (complete) return result;
    return this;
  }

  AsyncExpression chain(Expression Function(T) fn) =>
      AsyncExpression(_future.then(fn));

  toString() => complete ? "#[async:$result]" : "#[async]";
  toJS() => jsPromise ?? AsyncExpression.makePromise(this);
  static dynamic Function(AsyncExpression) makePromise = (expr) {
    throw UnimplementedError(
        "JS interop must be loaded for AsyncExpression.toJS() to work.");
  };

  @override
  Widget draw(DiagramInterface diagram) =>
      Block.asynch(complete ? diagram.pointTo(result) : TextWidget("async"));
}

class AsyncLambdaProcedure extends LambdaProcedure {
  AsyncLambdaProcedure(formals, body, env) : super(formals, body, env);

  AsyncExpression apply(PairOrEmpty arguments, Frame env) {
    Frame frame = makeCallFrame(arguments, env);
    FutureOr<Expression> expr = env.interpreter.impl.asyncEvalAll(body, frame);
    if (expr is Expression) return expr;
    return AsyncExpression(expr);
  }
}

class SchemeEventListener extends SelfEvaluating {
  final SchemeSymbol id;
  final SchemeBuiltin callback;
  SchemeEventListener(this.id, this.callback);

  toString() => '#[event-listener:$id]';

  toJS() => this;
}

/// define-async special form
Expression doDefineAsync(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.doDefineAsync(expressions, env);

/// lambda-async special form
LambdaProcedure doAsyncLambda(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.doAsyncLambda(expressions, env);

typedef AsyncSpecialForm = Future<Expression> Function(
    PairOrEmpty expressions, Frame env);

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
      return env.interpreter.impl.asyncEvalProcedureCall(first, rest, env);
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

Future<Expression> asyncDefineForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.asyncDefineForm(expressions, env);

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
      return await env.interpreter.impl.asyncCondResult(clause, env, test);
    }
    expressions = expressions.pair.second;
  }
  return undefined;
}

Future<Expression> asyncAndForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.asyncAndForm(expressions, env);

Future<Expression> asyncOrForm(PairOrEmpty expressions, Frame env) =>
    env.interpreter.impl.asyncOrForm(expressions, env);

Future<Expression> asyncLetForm(PairOrEmpty expressions, Frame env) async {
  checkForm(expressions, 2);
  Expression bindings = expressions.pair.first;
  Expression body = expressions.pair.second;
  Frame letEnv = await env.interpreter.impl.asyncLetFrame(bindings, env);
  return await env.interpreter.impl.asyncEvalAll(body, letEnv);
}

Future<Expression> asyncBeginForm(PairOrEmpty expressions, Frame env) async {
  checkForm(expressions, 1);
  return await env.interpreter.impl.asyncEvalAll(expressions, env);
}

Future<Pair<Expression, Promise>> asyncConsStreamForm(
    PairOrEmpty expressions, Frame env) async {
  checkForm(expressions, 2, 2);
  checkForm(expressions.pair.second, 1, 1);
  Promise promise = Promise(expressions.pair.second, env);
  return Pair(await asyncEval(expressions.pair.first, env), promise);
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
