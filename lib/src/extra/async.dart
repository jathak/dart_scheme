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

@deprecated
FutureOr<Value> asyncEval(Expression expr, Frame env) => null;
