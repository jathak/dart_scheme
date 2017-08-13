library cs61a_scheme.web.web_library;

import 'dart:html' as html;
import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

import 'html_ui.dart';
import 'js_interop.dart';

part '../../gen/web/web_library.gen.dart';

/// Note: When the signatures (including any annotations) of any of this methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the primitives and performs type checking on arguments).
@register
class WebLibrary extends SchemeLibrary with _$WebLibraryMixin {
  html.Element renderContainer;
  JsObject jsPlumb;
  
  WebLibrary(this.renderContainer, this.jsPlumb) {
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
  
  void importAll(Frame env) {
    super.importAll(env);
    env.interpreter.renderer = new HtmlRenderer(renderContainer, jsPlumb).render;
    Procedure.jsProcedure = (procedure) {
      return new SchemeFunction(procedure, env);
    };
  }
  
  @primitive @SchemeSymbol("close-diagram")
  Undefined closeDiagram(Frame env) {
    env.interpreter.renderer(new TextElement(""));
    return undefined;
  }
  
  @primitive
  Expression js(List<Expression> exprs) {
    String code = exprs.map((e)=>e.display).join("");
    return jsEval(code);
  }
  
  @primitive @SchemeSymbol("js-context")
  Expression jsContext() => new JsExpression(context);
  
  @primitive @SchemeSymbol("js-set!")
  Expression jsSet(JsExpression obj, Expression property, Expression value) {
    if (property is! SchemeSymbol && property is! SchemeString) {
      throw new SchemeException("JS property name must be a string or symbol");
    }
    obj.obj[property.display] = value.toJS();
    return obj;
  }
  
  @primitive @SchemeSymbol("js-ref")
  Expression jsRef(JsExpression obj, Expression property) {
    if (property is! SchemeSymbol && property is! SchemeString) {
      throw new SchemeException("JS property name must be a string or symbol");
    }
    return jsToScheme(obj.obj[property.display]); 
  }
  
  @primitive @SchemeSymbol("js-call") @MinArgs(2)
  Expression jsCall(List<Expression> expressions) {
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
