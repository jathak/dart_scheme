library cs61a_scheme.web.web_library;

import 'dart:html' as html;
import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

import 'html_ui.dart';
import 'js_interop.dart';
import 'theming.dart';

part '../../gen/web/web_library.gen.dart';

/// Note: When the signatures (including any annotations) of any of this methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the primitives and performs type checking on arguments).
@register
class WebLibrary extends SchemeLibrary with _$WebLibraryMixin {
  final html.Element renderContainer;
  final JsObject jsPlumb;
  final String css;
  final html.Element styleElement;
  
  WebLibrary(this.renderContainer, this.jsPlumb, this.css, this.styleElement) {
    Undefined.jsUndefined = context['undefined'];
    AsyncExpression.makePromise = (expr) {
      return new JsObject(context['Promise'], [
        (resolve, reject) {
          expr.future.then((result) => resolve.apply([result.toJS()]),
                onError: (error) => reject.apply([
                  error is Expression ? error.toJS() : error
                ]));
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
  void closeDiagram(Frame env) {
    env.interpreter.renderer(new TextElement(""));
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

  @primitive @SchemeSymbol("js-object")
  Expression jsObject(List<Expression> expressions) {
    if (expressions[0] is! SchemeSymbol && expressions[0] is! SchemeString) {
      throw new SchemeException("JS constructor name must be a string or symbol");
    }
    var args = expressions.skip(1).map((e) => e.toJS()).toList();
    return jsToScheme(new JsObject(context[expressions.first.display], args));
  }

  @primitive @SchemeSymbol("js-object?")
  bool isJsObject(Expression expression) => expression is JsExpression;

  @primitive @SchemeSymbol("js-procedure?")
  bool isJsProcedure(Expression expression) => expression is JsProcedure;
    
  @primitive
  Color rgb(int r, int g, int b) => new Color(r, g, b);
  
  @primitive
  Color rgba(int r, int g, int b, num a) => new Color(r, g, b, a.toDouble());
  
  @primitive
  Color hex(String hex) => new Color.fromHexString(hex);
  
  @primitive
  Theme theme() => new Theme();
  
  @primitive @SchemeSymbol('theme-set-color!')
  void themeSetColor(Theme theme, SchemeSymbol property, Color color) {
    theme.compiledCss = null;
    theme.colors[property] = color;
  }
  
  @primitive @SchemeSymbol('theme-set-css!')
  void themeSetCss(Theme theme, SchemeSymbol property, SchemeString code) {
    theme.compiledCss = null;
    theme.cssProps[property] = code;
  }
  
  @primitive @SchemeSymbol('compile-theme')
  Theme compileTheme(Theme theme) => theme.compile(css);
  
  @primitive @SchemeSymbol('apply-theme')
  void applyTheme(Theme theme) {
    styleElement.innerHtml = theme.compile(css).compiledCss;
  }
  
}
