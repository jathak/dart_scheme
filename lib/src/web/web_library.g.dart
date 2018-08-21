part of cs61a_scheme.web.web_library;

// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: unnecessary_this
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: unnecessary_lambdas
abstract class _$WebLibraryMixin {
  Expression js(List<Expression> exprs);
  Expression jsContext();
  Expression jsSet(JsExpression obj, Expression property, Expression value);
  Expression jsRef(JsExpression obj, Expression property);
  Expression jsCall(List<Expression> expressions);
  Expression jsObject(List<Expression> expressions);
  bool isJsObject(Expression expression);
  bool isJsProcedure(Expression expression);
  Color rgb(int r, int g, int b);
  Color rgba(int r, int g, int b, num a);
  Color hex(String hex);
  Theme makeTheme();
  void themeSetColor(Theme theme, SchemeSymbol property, Expression color);
  void themeSetCss(Theme theme, SchemeSymbol property, SchemeString code);
  void applyThemeBuiltin(Theme theme);
  Future<Expression> schemeImport(List<Expression> args, Frame env);
  Future<Expression> schemeImportInline(Expression id, Frame env);
  Expression libraryReference(ImportedLibrary imported, SchemeSymbol id);
  Future<Expression> theme(SchemeSymbol theme, Frame env);
  String colorToCss(Color color);
  void importAll(Frame __env) {
    addVariableBuiltin(__env, const SchemeSymbol("js"), (__exprs, __env) {
      return this.js(__exprs);
    }, 0, maxArgs: -1);
    addBuiltin(__env, const SchemeSymbol("js-context"), (__exprs, __env) {
      return this.jsContext();
    }, 0);
    addBuiltin(__env, const SchemeSymbol("js-set!"), (__exprs, __env) {
      if (__exprs[0] is! JsExpression)
        throw SchemeException('Argument of invalid type passed to js-set!.');
      return this.jsSet(__exprs[0], __exprs[1], __exprs[2]);
    }, 3);
    addBuiltin(__env, const SchemeSymbol("js-ref"), (__exprs, __env) {
      if (__exprs[0] is! JsExpression)
        throw SchemeException('Argument of invalid type passed to js-ref.');
      return this.jsRef(__exprs[0], __exprs[1]);
    }, 2);
    addVariableBuiltin(__env, const SchemeSymbol("js-call"), (__exprs, __env) {
      return this.jsCall(__exprs);
    }, 2, maxArgs: -1);
    addVariableBuiltin(__env, const SchemeSymbol("js-object"),
        (__exprs, __env) {
      return this.jsObject(__exprs);
    }, 0, maxArgs: -1);
    addBuiltin(__env, const SchemeSymbol("js-object?"), (__exprs, __env) {
      return Boolean(this.isJsObject(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("js-procedure?"), (__exprs, __env) {
      return Boolean(this.isJsProcedure(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("rgb"), (__exprs, __env) {
      if (__exprs[0] is! Integer ||
          __exprs[1] is! Integer ||
          __exprs[2] is! Integer)
        throw SchemeException('Argument of invalid type passed to rgb.');
      return this.rgb(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt(),
          __exprs[2].toJS().toInt());
    }, 3);
    addBuiltin(__env, const SchemeSymbol("rgba"), (__exprs, __env) {
      if (__exprs[0] is! Integer ||
          __exprs[1] is! Integer ||
          __exprs[2] is! Integer ||
          __exprs[3] is! Number)
        throw SchemeException('Argument of invalid type passed to rgba.');
      return this.rgba(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt(),
          __exprs[2].toJS().toInt(), __exprs[3].toJS());
    }, 4);
    addBuiltin(__env, const SchemeSymbol("hex"), (__exprs, __env) {
      if (__exprs[0] is! SchemeString)
        throw SchemeException('Argument of invalid type passed to hex.');
      return this.hex((__exprs[0] as SchemeString).value);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("make-theme"), (__exprs, __env) {
      return this.makeTheme();
    }, 0);
    addBuiltin(__env, const SchemeSymbol('theme-set-color!'), (__exprs, __env) {
      if (__exprs[0] is! Theme || __exprs[1] is! SchemeSymbol)
        throw SchemeException(
            'Argument of invalid type passed to theme-set-color!.');
      this.themeSetColor(__exprs[0], __exprs[1], __exprs[2]);
      return undefined;
    }, 3);
    addBuiltin(__env, const SchemeSymbol('theme-set-css!'), (__exprs, __env) {
      if (__exprs[0] is! Theme ||
          __exprs[1] is! SchemeSymbol ||
          __exprs[2] is! SchemeString)
        throw SchemeException(
            'Argument of invalid type passed to theme-set-css!.');
      this.themeSetCss(__exprs[0], __exprs[1], __exprs[2]);
      return undefined;
    }, 3);
    addBuiltin(__env, const SchemeSymbol('apply-theme'), (__exprs, __env) {
      if (__exprs[0] is! Theme)
        throw SchemeException(
            'Argument of invalid type passed to apply-theme.');
      this.applyThemeBuiltin(__exprs[0]);
      return undefined;
    }, 1);
    addVariableBuiltin(__env, const SchemeSymbol('import'), (__exprs, __env) {
      return AsyncExpression(this.schemeImport(__exprs, __env));
    }, 0, maxArgs: -1);
    addBuiltin(__env, const SchemeSymbol('import-inline'), (__exprs, __env) {
      return AsyncExpression(this.schemeImportInline(__exprs[0], __env));
    }, 1);
    addBuiltin(__env, const SchemeSymbol('lib-ref'), (__exprs, __env) {
      if (__exprs[0] is! ImportedLibrary || __exprs[1] is! SchemeSymbol)
        throw SchemeException('Argument of invalid type passed to lib-ref.');
      return this.libraryReference(__exprs[0], __exprs[1]);
    }, 2);
    addBuiltin(__env, const SchemeSymbol("theme"), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol)
        throw SchemeException('Argument of invalid type passed to theme.');
      return AsyncExpression(this.theme(__exprs[0], __env));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("color->css"), (__exprs, __env) {
      if (__exprs[0] is! Color)
        throw SchemeException('Argument of invalid type passed to color->css.');
      return SchemeString(this.colorToCss(__exprs[0]));
    }, 1);
  }
}
