library cs61a_scheme.web.web_library;

import 'dart:async';
import 'dart:html' as html;
import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

import 'imports.dart';
import 'js_interop.dart';

part 'web_library.g.dart';

/// Note: When the signatures (including any annotations) of any of this methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the built-ins and performs type checking on arguments).
@schemelib
class WebLibrary extends SchemeLibrary with _$WebLibraryMixin {
  final JsObject jsPlumb;
  final String css;
  final html.Element styleElement;

  WebLibrary(this.jsPlumb, this.css, this.styleElement) {
    Undefined.jsUndefined = context['undefined'];
    AsyncExpression.makePromise = (expr) => JsObject(context['Promise'], [
          (resolve, reject) {
            expr.future.then((result) => resolve.apply([result.toJS()]),
                onError: (error) =>
                    reject.apply([error is Expression ? error.toJS() : error]));
          }
        ]);
    deserializers['Color'] = const Color(0, 0, 0);
    deserializers['Theme'] = Theme();
  }

  void importAll(Frame env) {
    super.importAll(env);
    Procedure.jsProcedure = (procedure) => SchemeFunction(procedure, env);
  }

  Expression js(List<Expression> exprs) {
    String code = exprs.map((e) => e.display).join("");
    return jsEval(code);
  }

  @SchemeSymbol("js-context")
  Expression jsContext() => JsExpression(context);

  @SchemeSymbol("js-set!")
  Expression jsSet(JsExpression obj, Expression property, Expression value) {
    if (property is! SchemeSymbol && property is! SchemeString) {
      throw SchemeException("JS property name must be a string or symbol");
    }
    obj.obj[property.display] = value.toJS();
    return obj;
  }

  @SchemeSymbol("js-ref")
  Expression jsRef(JsExpression obj, Expression property) {
    if (property is! SchemeSymbol && property is! SchemeString) {
      throw SchemeException("JS property name must be a string or symbol");
    }
    return jsToScheme(obj.obj[property.display]);
  }

  @SchemeSymbol("js-call")
  @MinArgs(2)
  Expression jsCall(List<Expression> expressions) {
    Expression obj = expressions.removeAt(0);
    Expression method = expressions.removeAt(0);
    if (obj is! JsExpression) throw Exception("$obj is not a JS object");
    if (method is! SchemeSymbol && method is! SchemeString) {
      throw SchemeException("JS method name must be a string or symbol");
    }
    JsObject jsObj = (obj as JsExpression).obj;
    var args = expressions.map((e) => e.toJS()).toList();
    return jsToScheme(jsObj.callMethod(method.toString(), args));
  }

  @SchemeSymbol("js-object")
  Expression jsObject(List<Expression> expressions) {
    if (expressions[0] is! SchemeSymbol && expressions[0] is! SchemeString) {
      throw SchemeException("JS constructor name must be a string or symbol");
    }
    var args = expressions.skip(1).map((e) => e.toJS()).toList();
    return jsToScheme(JsObject(context[expressions.first.display], args));
  }

  @SchemeSymbol("js-object?")
  bool isJsObject(Expression expression) => expression is JsExpression;

  @SchemeSymbol("js-procedure?")
  bool isJsProcedure(Expression expression) => expression is JsProcedure;

  Color rgb(int r, int g, int b) => Color(r, g, b);

  Color rgba(int r, int g, int b, num a) => Color(r, g, b, a.toDouble());

  Color hex(String hex) => Color.fromHexString(hex);

  @SchemeSymbol("make-theme")
  Theme makeTheme() => Theme();

  @SchemeSymbol('theme-set-color!')
  void themeSetColor(Theme theme, SchemeSymbol property, Expression color) {
    theme.colors[property] = Color.fromAnything(color);
  }

  @SchemeSymbol('theme-set-css!')
  void themeSetCss(Theme theme, SchemeSymbol property, SchemeString code) {
    theme.cssProps[property] = code;
  }

  @SchemeSymbol('apply-theme')
  void applyThemeBuiltin(Theme theme) => applyTheme(theme, css, styleElement);

  @SchemeSymbol('import')
  Future<Expression> schemeImport(List<Expression> args, Frame env) async {
    if (args[0] is! SchemeSymbol && args[0] is! SchemeString) {
      throw SchemeException("${args[0]} is not a string or symbol");
    }
    List<SchemeSymbol> symbols = [];
    for (Expression arg in args.skip(1)) {
      if (arg is SchemeSymbol) {
        symbols.add(arg);
      } else {
        throw SchemeException("$arg is not a symbol");
      }
    }
    String id = args[0].display;
    return import(id, symbols, env);
  }

  @SchemeSymbol('import-inline')
  Future<Expression> schemeImportInline(Expression id, Frame env) async {
    if (id is! SchemeSymbol && id is! SchemeString) {
      throw SchemeException("$id is not a string or symbol");
    }
    await import(id.display, null, env, true);
    return undefined;
  }

  @SchemeSymbol('lib-ref')
  Expression libraryReference(ImportedLibrary imported, SchemeSymbol id) =>
      imported.reference(id);

  Future<Expression> theme(SchemeSymbol theme, Frame env) async {
    ImportedLibrary lib = await import('scm/theme/$theme', [], env);
    Expression myTheme = lib.reference(const SchemeSymbol('imported-theme'));
    if (myTheme is! Theme) throw SchemeException("No theme exists");
    applyThemeBuiltin(myTheme);
    return undefined;
  }

  @SchemeSymbol("color->css")
  String colorToCss(Color color) => color.toCSS();
}

StreamController<Theme> _controller = StreamController();

applyTheme(Theme theme, String css, html.Element style, [bool notify = true]) {
  style.innerHtml = theme.compile(css);
  if (notify) _controller.add(theme);
}

final Stream<Theme> onThemeChange = _controller.stream.asBroadcastStream();
