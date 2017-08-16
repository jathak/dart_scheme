library cs61a_scheme.web.js_interop;

import 'dart:async';
import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

class JsProcedure extends Procedure {
  final JsFunction fn;
  JsProcedure(this.fn);
  Expression apply(PairOrEmpty args, Frame env) {
    var result = fn.apply(args.map((arg) => arg.toJS()).toList());
    return jsToScheme(result);
  }
  
  toJS() => fn;
}

class JsExpression extends SelfEvaluating {
  final JsObject obj;
  JsExpression(this.obj);
  toString() {
    var objString = obj.toString();
    if (objString.length > 20) objString.substring(0, 17) + "...";
    return "#[js:$objString]";
  }
  toJS() => obj;
}

class NativeExpression extends SelfEvaluating {
  final Object obj;
  NativeExpression(this.obj);
  toString() {
    var objString = obj.toString();
    if (objString.length > 20) objString.substring(0, 17) + "...";
    return "#[native:$objString]";
  }
  toJS() => obj;
}

Expression jsToScheme(obj) {
  if (obj is Expression) return obj;
  if (obj is double) return new Number.fromDouble(obj);
  if (obj is int) return new Number.fromInteger(obj);
  if (obj is bool) return obj ? schemeTrue : schemeFalse;
  if (obj is String) return new SchemeString(obj);
  if (obj is SchemeFunction) return obj.procedure;
  if (obj is JsFunction) return new JsProcedure(obj);
  if (obj is JsObject) return jsObjectToScheme(obj);
  if (obj == null) return undefined;
  if (obj == context['undefined']) return undefined;
  return new NativeExpression(obj);
}

Expression jsObjectToScheme(JsObject obj) {
  var type = context['Object']['prototype']['toString'].callMethod('call', [obj]);
  if (type == '[object Promise]') {
    var completer = new Completer();
    obj.callMethod('then', [
      completer.complete,
      completer.completeError
    ]);
    var future = completer.future.then((result)=>jsToScheme(result));
    return new AsyncExpression(future)..jsPromise = obj;
  }
  return new JsExpression(obj);
}

Expression jsEval(String code) {
  try {
    return jsToScheme(context.callMethod("eval", [code]));
  } catch (e) {
    if (e is SchemeException) rethrow;
    throw new SchemeException("$e");
  }
}

class SchemeFunction implements Function {
  Procedure procedure;
  Frame env;
  SchemeFunction(this.procedure, this.env);
  call() => schemeApply(procedure, nil, null).toJS();
  noSuchMethod(Invocation invocation) {
    if (invocation.memberName == new Symbol("call")) {
      var args = invocation.positionalArguments.map((arg) => jsToScheme(arg));
      print(invocation.positionalArguments);
      return schemeApply(procedure, new PairOrEmpty.fromIterable(args), env).toJS();
    }
    throw new SchemeException("Something has gone horrible wrong with wrapped procedures");
  }
}
