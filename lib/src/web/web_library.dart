library cs61a_scheme.web.web_library;

import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

import 'js_interop.dart';

part '../../gen/web/web_library.gen.dart';

@register
class WebLibrary extends SchemeLibrary with _$WebLibraryMixin {
  
  void importAll(Frame env) {
    super.importAll(env);
    SchemeSymbol.jsSymbol = (symb) {
      return (context['Symbol'] as JsObject).callMethod("for", [symb.value]);
    };
    Undefined.jsUndefined = context['undefined'];
    AsyncExpression.makePromise = (expr) {
      return new JsObject(context['Promise'], [
        (resolve, reject) {
          expr.future.then((result) => resolve.apply([result.toJS()]),
                onError: (error) => reject.apply([error.toJS()]));
        }
      ]);
    };
  }
  
  @primitive
  static Expression js(List<Expression> exprs) {
    String code = exprs.map((e)=>e.display).join("");
    return jsEval(code);
  }
  
  @primitive @SchemeSymbol("js-context")
  static Expression jsContext() => new JsExpression(context);
  
  @primitive @SchemeSymbol("js-set!")
  static Expression jsSet(JsExpression obj, Expression property, Expression value) {
    if (property is! SchemeSymbol && property is! SchemeString) {
      throw new SchemeException("JS property name must be a string or symbol");
    }
    obj.obj[property.display] = value.toJS();
    return obj;
  }
  
  @primitive @SchemeSymbol("js-ref")
  static Expression jsRef(JsExpression obj, Expression property) {
    if (property is! SchemeSymbol && property is! SchemeString) {
      throw new SchemeException("JS property name must be a string or symbol");
    }
    return jsToScheme(obj.obj[property.display]); 
  }
  
  @primitive @SchemeSymbol("js-call") @MinArgs(2)
  static Expression jsCall(List<Expression> expressions) {
    Expression obj = expressions.removeAt(0);
    Expression method = expressions.removeAt(0);
    if (obj is! JsExpression) throw new Exception("$obj is not a JS object");
    if (method is! SchemeSymbol && method is! SchemeString) {
      throw new SchemeException("JS method name must be a string or symbol");
    }
    JsObject jsObj = (obj as JsExpression).obj;
    var args = expressions.map((e) => e.toJS()).toList();
    return jsToScheme(jsObj.callMethod(method.toString(), args));
  }
  
}
