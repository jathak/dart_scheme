part of cs61a_scheme.web.web_library;

// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: unnecessary_this
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: unnecessary_lambdas
abstract class _$WebLibraryMixin {
  Value js(List<Value> exprs);
  JsValue jsContext();
  Value jsSet(JsValue obj, Value property, Value value);
  Value jsRef(JsValue obj, Value property);
  Value jsCall(List<Value> vals);
  Value jsObject(List<Value> vals);
  bool isJsObject(Value value);
  bool isJsProcedure(Value value);
  Color rgb(int r, int g, int b);
  Color rgba(int r, int g, int b, num a);
  Color hex(String hex);
  Theme makeTheme();
  void themeSetColor(Theme theme, SchemeSymbol property, Value color);
  void themeSetCss(Theme theme, SchemeSymbol property, SchemeString code);
  void applyThemeBuiltin(Theme theme);
  Future<Value> schemeImport(List<Value> args, Frame env);
  Future<Value> schemeImportInline(Value id, Frame env);
  Value libraryReference(ImportedLibrary imported, SchemeSymbol id);
  Future<Value> theme(SchemeSymbol theme, Frame env);
  String colorToCss(Color color);
  void editor(Frame env);
  void importAll(Frame __env) {
    addVariableBuiltin(__env, const SchemeSymbol("js"), (__exprs, __env) {
      return this.js(__exprs);
    }, 0,
        maxArgs: -1,
        docs: Docs.variable("js",
            "Evaluates a piece of JavaScript code and returns the result.\n\nCompatible types will automatically be converted between the languages.\n",
            returnType: "value"));
    addBuiltin(__env, const SchemeSymbol("js-context"), (__exprs, __env) {
      return this.jsContext();
    }, 0,
        docs: Docs(
            "js-context",
            "Returns the global JavaScript context.\n\nIn a browser, this is the window object.\n",
            [],
            returnType: "js object"));
    addBuiltin(__env, const SchemeSymbol("js-set!"), (__exprs, __env) {
      if (__exprs[0] is! JsValue)
        throw SchemeException('Argument of invalid type passed to js-set!.');
      return this.jsSet(__exprs[0], __exprs[1], __exprs[2]);
    }, 3,
        docs: Docs(
            "js-set!",
            "Sets [property] of [obj] to be [value].\n",
            [
              Param("js object", "obj"),
              Param("value", "property"),
              Param("value", "value")
            ],
            returnType: "value"));
    addBuiltin(__env, const SchemeSymbol("js-ref"), (__exprs, __env) {
      if (__exprs[0] is! JsValue)
        throw SchemeException('Argument of invalid type passed to js-ref.');
      return this.jsRef(__exprs[0], __exprs[1]);
    }, 2,
        docs: Docs("js-ref", "Returns [property] of [obj].\n",
            [Param("js object", "obj"), Param("value", "property")],
            returnType: "value"));
    addVariableBuiltin(__env, const SchemeSymbol("js-call"), (__exprs, __env) {
      return this.jsCall(__exprs);
    }, 2,
        maxArgs: -1,
        docs: Docs.variable("js-call",
            "Calls a method (second arg) on a JS object (first arg) with some args.\n",
            returnType: "value"));
    addVariableBuiltin(__env, const SchemeSymbol("js-object"),
        (__exprs, __env) {
      return this.jsObject(__exprs);
    }, 0,
        maxArgs: -1,
        docs: Docs.variable("js-object",
            "Constructs a new JS object of a type (first arg) with some arguments.\n",
            returnType: "value"));
    addBuiltin(__env, const SchemeSymbol("js-object?"), (__exprs, __env) {
      return Boolean(this.isJsObject(__exprs[0]));
    }, 1,
        docs: Docs("js-object?", "Returns true if [value] is a JS object.\n",
            [Param("value", "value")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("js-procedure?"), (__exprs, __env) {
      return Boolean(this.isJsProcedure(__exprs[0]));
    }, 1,
        docs: Docs(
            "js-procedure?",
            "Returns true if [value] is a JS function.\n",
            [Param("value", "value")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("rgb"), (__exprs, __env) {
      if (__exprs[0] is! Integer ||
          __exprs[1] is! Integer ||
          __exprs[2] is! Integer)
        throw SchemeException('Argument of invalid type passed to rgb.');
      return this.rgb(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt(),
          __exprs[2].toJS().toInt());
    }, 3,
        docs: Docs("rgb", "Constructs a color from values [r], [g], and [b].\n",
            [Param("int", "r"), Param("int", "g"), Param("int", "b")],
            returnType: "color"));
    addBuiltin(__env, const SchemeSymbol("rgba"), (__exprs, __env) {
      if (__exprs[0] is! Integer ||
          __exprs[1] is! Integer ||
          __exprs[2] is! Integer ||
          __exprs[3] is! Number)
        throw SchemeException('Argument of invalid type passed to rgba.');
      return this.rgba(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt(),
          __exprs[2].toJS().toInt(), __exprs[3].toJS());
    }, 4,
        docs: Docs(
            "rgba",
            "Constructs a color from values [r], [g], [b], and [a].\n",
            [
              Param("int", "r"),
              Param("int", "g"),
              Param("int", "b"),
              Param("num", "a")
            ],
            returnType: "color"));
    addBuiltin(__env, const SchemeSymbol("hex"), (__exprs, __env) {
      if (__exprs[0] is! SchemeString)
        throw SchemeException('Argument of invalid type passed to hex.');
      return this.hex((__exprs[0] as SchemeString).value);
    }, 1,
        docs: Docs(
            "hex", "Constructs a color from [hex].\n", [Param("string", "hex")],
            returnType: "color"));
    addBuiltin(__env, const SchemeSymbol("make-theme"), (__exprs, __env) {
      return this.makeTheme();
    }, 0, docs: Docs("make-theme", "Creates a new theme.\n", []));
    addBuiltin(__env, const SchemeSymbol('theme-set-color!'), (__exprs, __env) {
      if (__exprs[0] is! Theme || __exprs[1] is! SchemeSymbol)
        throw SchemeException(
            'Argument of invalid type passed to theme-set-color!.');
      this.themeSetColor(__exprs[0], __exprs[1], __exprs[2]);
      return undefined;
    }, 3,
        docs: Docs('theme-set-color!',
            "For [theme], sets the color for [property] to be [color].\n", [
          Param(null, "theme"),
          Param("symbol", "property"),
          Param("value", "color")
        ]));
    addBuiltin(__env, const SchemeSymbol('theme-set-css!'), (__exprs, __env) {
      if (__exprs[0] is! Theme ||
          __exprs[1] is! SchemeSymbol ||
          __exprs[2] is! SchemeString)
        throw SchemeException(
            'Argument of invalid type passed to theme-set-css!.');
      this.themeSetCss(__exprs[0], __exprs[1], __exprs[2]);
      return undefined;
    }, 3,
        docs: Docs('theme-set-css!',
            "For [theme], sets the extra CSS for [property] to be [code].\n", [
          Param(null, "theme"),
          Param("symbol", "property"),
          Param("string", "code")
        ]));
    addBuiltin(__env, const SchemeSymbol('apply-theme'), (__exprs, __env) {
      if (__exprs[0] is! Theme)
        throw SchemeException(
            'Argument of invalid type passed to apply-theme.');
      this.applyThemeBuiltin(__exprs[0]);
      return undefined;
    }, 1,
        docs: Docs('apply-theme', "Applies [theme] to the current interface.\n",
            [Param(null, "theme")]));
    addVariableBuiltin(__env, const SchemeSymbol('import'), (__exprs, __env) {
      return AsyncValue(this.schemeImport(__exprs, __env));
    }, 0,
        maxArgs: -1,
        docs: Docs.variable('import',
            "Imports a library (first arg) as a module (returned asynchronously)\n\nRemaining args should be symbols in the library to be bound directly.\n"));
    addBuiltin(__env, const SchemeSymbol('import-inline'), (__exprs, __env) {
      return AsyncValue(this.schemeImportInline(__exprs[0], __env));
    }, 1,
        docs: Docs(
            'import-inline',
            "Imports a library at [id] directly into the current environment.\n",
            [Param("value", "id")]));
    addBuiltin(__env, const SchemeSymbol('lib-ref'), (__exprs, __env) {
      if (__exprs[0] is! ImportedLibrary || __exprs[1] is! SchemeSymbol)
        throw SchemeException('Argument of invalid type passed to lib-ref.');
      return this.libraryReference(__exprs[0], __exprs[1]);
    }, 2,
        docs: Docs('lib-ref', "References an [id] bound within [imported].\n",
            [Param("library", "imported"), Param("symbol", "id")],
            returnType: "value"));
    addBuiltin(__env, const SchemeSymbol("theme"), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol)
        throw SchemeException('Argument of invalid type passed to theme.');
      return AsyncValue(this.theme(__exprs[0], __env));
    }, 1,
        docs: Docs("theme", "Loads and applies a [theme].\n",
            [Param("symbol", "theme")]));
    addBuiltin(__env, const SchemeSymbol("color->css"), (__exprs, __env) {
      if (__exprs[0] is! Color)
        throw SchemeException('Argument of invalid type passed to color->css.');
      return SchemeString(this.colorToCss(__exprs[0]));
    }, 1,
        docs: Docs("color->css", "Converts [color] to a string of CSS.\n",
            [Param("color", "color")],
            returnType: "string"));
    addBuiltin(__env, const SchemeSymbol("editor"), (__exprs, __env) {
      this.editor(__env);
      return undefined;
    }, 0,
        docs: Docs(
            "editor",
            "Launch the editor.\n\nNote: This is still a work in progress. Don't use for important work!\n",
            []));
  }
}
