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
  final Function startEditor;

  WebLibrary(this.jsPlumb, this.css, this.styleElement, this.startEditor) {
    Undefined.jsUndefined = context['undefined'];
    AsyncValue.makePromise = (expr) => JsObject(context['Promise'], [
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
    Procedure.jsProcedure =
        (procedure) => procedureToJsFunction(procedure, env);
  }

  /// Evaluates a piece of JavaScript code and returns the result.
  ///
  /// Compatible types will automatically be converted between the languages.
  Value js(List<Value> exprs) {
    String code = exprs.map((e) => e.display).join("");
    return jsEval(code);
  }

  /// Returns the global JavaScript context.
  ///
  /// In a browser, this is the window object.
  @SchemeSymbol("js-context")
  JsValue jsContext() => JsValue(context);

  /// Sets [property] of [obj] to be [value].
  @SchemeSymbol("js-set!")
  Value jsSet(JsValue obj, Value property, Value value) {
    if (property is! SchemeSymbol && property is! SchemeString) {
      throw SchemeException("JS property name must be a string or symbol");
    }
    obj.obj[property.display] = value.toJS();
    return obj;
  }

  /// Returns [property] of [obj].
  @SchemeSymbol("js-ref")
  Value jsRef(JsValue obj, Value property) {
    if (property is! SchemeSymbol && property is! SchemeString) {
      throw SchemeException("JS property name must be a string or symbol");
    }
    return jsToScheme(obj.obj[property.display]);
  }

  /// Calls a method (second arg) on a JS object (first arg) with some args.
  @SchemeSymbol("js-call")
  @MinArgs(2)
  Value jsCall(List<Value> vals) {
    Expression obj = vals.removeAt(0);
    Expression method = vals.removeAt(0);
    if (obj is! JsValue) throw Exception("$obj is not a JS object");
    if (method is! SchemeSymbol && method is! SchemeString) {
      throw SchemeException("JS method name must be a string or symbol");
    }
    JsObject jsObj = (obj as JsValue).obj;
    var args = vals.map((e) => e.toJS()).toList();
    return jsToScheme(jsObj.callMethod(method.toString(), args));
  }

  /// Constructs a new JS object of a type (first arg) with some arguments.
  @SchemeSymbol("js-object")
  Value jsObject(List<Value> vals) {
    if (vals[0] is! SchemeSymbol && vals[0] is! SchemeString) {
      throw SchemeException("JS constructor name must be a string or symbol");
    }
    var args = vals.skip(1).map((e) => e.toJS()).toList();
    return jsToScheme(JsObject(context[vals.first.display], args));
  }

  /// Returns true if [value] is a JS object.
  @SchemeSymbol("js-object?")
  bool isJsObject(Value value) => value is JsValue;

  /// Returns true if [value] is a JS function.
  @SchemeSymbol("js-procedure?")
  bool isJsProcedure(Value value) => value is JsProcedure;

  /// Constructs a color from values [r], [g], and [b].
  Color rgb(int r, int g, int b) => Color(r, g, b);

  /// Constructs a color from values [r], [g], [b], and [a].
  Color rgba(int r, int g, int b, num a) => Color(r, g, b, a.toDouble());

  /// Constructs a color from [hex].
  Color hex(String hex) => Color.fromHexString(hex);

  /// Creates a new theme.
  @SchemeSymbol("make-theme")
  Theme makeTheme() => Theme();

  /// For [theme], sets the color for [property] to be [color].
  @SchemeSymbol('theme-set-color!')
  void themeSetColor(Theme theme, SchemeSymbol property, Value color) {
    theme.colors[property] = Color.fromAnything(color);
  }

  /// For [theme], sets the extra CSS for [property] to be [code].
  @SchemeSymbol('theme-set-css!')
  void themeSetCss(Theme theme, SchemeSymbol property, SchemeString code) {
    theme.cssProps[property] = code;
  }

  /// Applies [theme] to the current interface.
  @SchemeSymbol('apply-theme')
  void applyThemeBuiltin(Theme theme) => applyTheme(theme, css, styleElement);

  /// Imports a library (first arg) as a module (returned asynchronously)
  ///
  /// Remaining args should be symbols in the library to be bound directly.
  @SchemeSymbol('import')
  Future<Value> schemeImport(List<Value> args, Frame env) async {
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

  /// Imports a library at [id] directly into the current environment.
  @SchemeSymbol('import-inline')
  Future<Value> schemeImportInline(Value id, Frame env) async {
    if (id is! SchemeSymbol && id is! SchemeString) {
      throw SchemeException("$id is not a string or symbol");
    }
    await import(id.display, null, env, true);
    return undefined;
  }

  /// References an [id] bound within [imported].
  @SchemeSymbol('lib-ref')
  Value libraryReference(ImportedLibrary imported, SchemeSymbol id) =>
      imported.reference(id);

  /// Loads and applies a [theme].
  Future<Value> theme(SchemeSymbol theme, Frame env) async {
    ImportedLibrary lib = await import('scm/theme/$theme', [], env);
    // For old-style themes
    try {
      applyThemeBuiltin(
          lib.reference(const SchemeSymbol('imported-theme')) as Theme);
    } on SchemeException catch (e) {
      // Ignore
    }
    return undefined;
  }

  /// Converts [color] to a string of CSS.
  @SchemeSymbol("color->css")
  String colorToCss(Color color) => color.toCSS();

  /// Launch the editor.
  ///
  /// Note: This is still a work in progress. Don't use for important work!
  void editor(Frame env) {
    startEditor(env.interpreter.clone());
  }
}

StreamController<Theme> _controller = StreamController();

applyTheme(Theme theme, String css, html.Element style, [bool notify = true]) {
  style.innerHtml = theme.compile(css);
  if (notify) _controller.add(theme);
}

final Stream<Theme> onThemeChange = _controller.stream.asBroadcastStream();
