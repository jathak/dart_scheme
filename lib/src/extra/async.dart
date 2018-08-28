library cs61a_scheme.extra.async_special_forms;

import 'dart:async';

import 'package:cs61a_scheme/cs61a_scheme.dart';

class AsyncValue<T extends Value> extends Value {
  AsyncValue(Future<T> future) {
    _future = future.then((e) async {
      while (e is AsyncValue) {
        e = await (e as AsyncValue).future;
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

  AsyncValue chain(Expression Function(T) fn) => AsyncValue(_future.then(fn));

  toString() => complete ? "#[async:$result]" : "#[async]";
  toJS() => jsPromise ?? AsyncValue.makePromise(this);
  static dynamic Function(AsyncValue) makePromise = (expr) {
    throw UnimplementedError(
        "JS interop must be loaded for AsyncExpression.toJS() to work.");
  };

  @override
  Widget draw(DiagramInterface diagram) =>
      Block.asynch(complete ? diagram.pointTo(result) : TextWidget("async"));
}

class AsyncLambdaProcedure extends LambdaProcedure {
  AsyncLambdaProcedure(formals, body, env) : super(formals, body, env);

  AsyncValue apply(SchemeList arguments, Frame env) {
    Frame frame = makeCallFrame(arguments, env);
    FutureOr<Value> value = env.interpreter.impl.asyncEvalAll(body, frame);
    if (value is Value) return value;
    return AsyncValue(value);
  }
}

class SchemeEventListener extends Value {
  final SchemeSymbol id;
  final SchemeBuiltin callback;
  SchemeEventListener(this.id, this.callback);

  toString() => '#[event-listener:$id]';

  toJS() => this;
}

/// define-async special form
Expression doDefineAsync(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.doDefineAsync(expressions, env);

/// lambda-async special form
LambdaProcedure doAsyncLambda(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.doAsyncLambda(expressions, env);

typedef AsyncSpecialForm = Future<Value> Function(
    SchemeList<Expression> expressions, Frame env);

FutureOr<Value> asyncEval(Expression expr, Frame env) {
  if (expr is Pair) {
    var first = expr.first;
    var rest = SchemeList<Expression>.fromValue(expr.second);
    if (first == const SchemeSymbol("await")) {
      checkForm(rest, 1, 1);
      FutureOr<Value> result = asyncEval(rest.first, env);
      if (result is AsyncValue) {
        return result.future;
      } else if (result is Future<AsyncValue>) {
        return result.then((expr) => expr.future);
      } else {
        return result;
      }
    } else if (asyncSpecialForms.containsKey(first)) {
      return asyncSpecialForms[first](rest, env);
    } else if (env.interpreter.specialForms.containsKey(first)) {
      return env.interpreter.specialForms[first](rest, env);
    } else {
      return env.interpreter.impl
          .asyncEvalProcedureCall(first, expr.second, env);
    }
  } else {
    return schemeEval(expr, env);
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

Future<Value> asyncDefineForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.asyncDefineForm(expressions, env);

Future<Value> asyncIfForm(SchemeList<Expression> expressions, Frame env) async {
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

Future<Value> asyncCondForm(
    SchemeList<Expression> expressions, Frame env) async {
  for (Expression clauseExpr in expressions) {
    var clause = SchemeList<Expression>(clauseExpr);
    checkForm(clause, 1);
    Value test;
    if ((clause.first as SchemeSymbol).value == 'else') {
      test = schemeTrue;
    } else {
      test = await asyncEval(clause.first, env);
    }
    if (test.isTruthy) {
      return await env.interpreter.impl.asyncCondResult(clause, env, test);
    }
  }
  return undefined;
}

Future<Value> asyncAndForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.asyncAndForm(expressions, env);

Future<Value> asyncOrForm(SchemeList<Expression> expressions, Frame env) =>
    env.interpreter.impl.asyncOrForm(expressions, env);

Future<Value> asyncLetForm(
    SchemeList<Expression> expressions, Frame env) async {
  checkForm(expressions, 2);
  var bindings = SchemeList<Expression>(expressions.first);
  var body = expressions.rest;
  Frame letEnv = await env.interpreter.impl.asyncLetFrame(bindings, env);
  return await env.interpreter.impl.asyncEvalAll(body, letEnv);
}

Future<Value> asyncBeginForm(
    SchemeList<Expression> expressions, Frame env) async {
  checkForm(expressions, 1);
  return await env.interpreter.impl.asyncEvalAll(expressions, env);
}

Future<Pair<Value, Promise>> asyncConsStreamForm(
    SchemeList<Expression> expressions, Frame env) async {
  checkForm(expressions, 2, 2);
  Promise promise = Promise(expressions.skip(1).first, env);
  return Pair(await asyncEval(expressions.first, env), promise);
}

/*Expression doSetForm(SchemeList<Expression> expressions, Frame env) {
  throw new UnimplementedError("Special form not yet implemented.");
}

Expression doQuasiquoteForm(SchemeList<Expression> expressions, Frame env) {
  throw new UnimplementedError("Special form not yet implemented.");
}

Expression doUnquoteForm(SchemeList<Expression> expressions, Frame env) {
  throw new UnimplementedError("Special form not yet implemented.");
}

Expression doUnquoteSplicingForm(SchemeList<Expression> expressions, Frame env){
  throw new UnimplementedError("Special form not yet implemented.");
}*/
