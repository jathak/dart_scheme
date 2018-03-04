part of cs61a_scheme.web.web_library;

abstract class _$WebLibraryMixin {
  void closeDiagram(Frame env);
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
  void applyThemePrimitive(Theme theme);
  Future<Expression> schemeImport(List<Expression> args, Frame env);
  Future<Expression> schemeImportInline(Expression id, Frame env);
  Expression libraryReference(ImportedLibrary imported, SchemeSymbol id);
  Future<Expression> theme(SchemeSymbol theme, Frame env);
  String colorToCss(Color color);
  void importAll(Frame __env) {
    addPrimitive(__env, const SchemeSymbol("close-diagram"), (__exprs, __env) {
      var __value = undefined;
      this.closeDiagram(__env);
      return __value;
    }, 0);
    addVariablePrimitive(__env, const SchemeSymbol("js"), (__exprs, __env) {
      return this.js(__exprs);
    }, 0, -1);
    addPrimitive(__env, const SchemeSymbol("js-context"), (__exprs, __env) {
      return this.jsContext();
    }, 0);
    addPrimitive(__env, const SchemeSymbol("js-set!"), (__exprs, __env) {
      if (__exprs[0] is! JsExpression || __exprs[1] is! Expression || __exprs[2] is! Expression)
        throw new SchemeException('Argument of invalid type passed to js-set!.');
      return this.jsSet(__exprs[0], __exprs[1], __exprs[2]);
    }, 3);
    addPrimitive(__env, const SchemeSymbol("js-ref"), (__exprs, __env) {
      if (__exprs[0] is! JsExpression || __exprs[1] is! Expression)
        throw new SchemeException('Argument of invalid type passed to js-ref.');
      return this.jsRef(__exprs[0], __exprs[1]);
    }, 2);
    addVariablePrimitive(__env, const SchemeSymbol("js-call"), (__exprs, __env) {
      return this.jsCall(__exprs);
    }, 2, -1);
    addVariablePrimitive(__env, const SchemeSymbol("js-object"), (__exprs, __env) {
      return this.jsObject(__exprs);
    }, 0, -1);
    addPrimitive(__env, const SchemeSymbol("js-object?"), (__exprs, __env) {
      return new Boolean(this.isJsObject(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("js-procedure?"), (__exprs, __env) {
      return new Boolean(this.isJsProcedure(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("rgb"), (__exprs, __env) {
      if ((__exprs[0] is! Number || !(__exprs[0] as Number).isInteger) ||
          (__exprs[1] is! Number || !(__exprs[1] as Number).isInteger) ||
          (__exprs[2] is! Number || !(__exprs[2] as Number).isInteger))
        throw new SchemeException('Argument of invalid type passed to rgb.');
      return this
          .rgb(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt(), __exprs[2].toJS().toInt());
    }, 3);
    addPrimitive(__env, const SchemeSymbol("rgba"), (__exprs, __env) {
      if ((__exprs[0] is! Number || !(__exprs[0] as Number).isInteger) ||
          (__exprs[1] is! Number || !(__exprs[1] as Number).isInteger) ||
          (__exprs[2] is! Number || !(__exprs[2] as Number).isInteger) ||
          __exprs[3] is! Number)
        throw new SchemeException('Argument of invalid type passed to rgba.');
      return this.rgba(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt(),
          __exprs[2].toJS().toInt(), __exprs[3].toJS());
    }, 4);
    addPrimitive(__env, const SchemeSymbol("hex"), (__exprs, __env) {
      if (__exprs[0] is! SchemeString)
        throw new SchemeException('Argument of invalid type passed to hex.');
      return this.hex((__exprs[0] as SchemeString).value);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("make-theme"), (__exprs, __env) {
      return this.makeTheme();
    }, 0);
    addPrimitive(__env, const SchemeSymbol('theme-set-color!'), (__exprs, __env) {
      if (__exprs[0] is! Theme || __exprs[1] is! SchemeSymbol || __exprs[2] is! Expression)
        throw new SchemeException('Argument of invalid type passed to theme-set-color!.');
      var __value = undefined;
      this.themeSetColor(__exprs[0], __exprs[1], __exprs[2]);
      return __value;
    }, 3);
    addPrimitive(__env, const SchemeSymbol('theme-set-css!'), (__exprs, __env) {
      if (__exprs[0] is! Theme || __exprs[1] is! SchemeSymbol || __exprs[2] is! SchemeString)
        throw new SchemeException('Argument of invalid type passed to theme-set-css!.');
      var __value = undefined;
      this.themeSetCss(__exprs[0], __exprs[1], __exprs[2]);
      return __value;
    }, 3);
    addPrimitive(__env, const SchemeSymbol('apply-theme'), (__exprs, __env) {
      if (__exprs[0] is! Theme)
        throw new SchemeException('Argument of invalid type passed to apply-theme.');
      var __value = undefined;
      this.applyThemePrimitive(__exprs[0]);
      return __value;
    }, 1);
    addVariablePrimitive(__env, const SchemeSymbol('import'), (__exprs, __env) {
      return new AsyncExpression(this.schemeImport(__exprs, __env));
    }, 0, -1);
    addPrimitive(__env, const SchemeSymbol('import-inline'), (__exprs, __env) {
      return new AsyncExpression(this.schemeImportInline(__exprs[0], __env));
    }, 1);
    addPrimitive(__env, const SchemeSymbol('lib-ref'), (__exprs, __env) {
      if (__exprs[0] is! ImportedLibrary || __exprs[1] is! SchemeSymbol)
        throw new SchemeException('Argument of invalid type passed to lib-ref.');
      return this.libraryReference(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("theme"), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol)
        throw new SchemeException('Argument of invalid type passed to theme.');
      return new AsyncExpression(this.theme(__exprs[0], __env));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("color->css"), (__exprs, __env) {
      if (__exprs[0] is! Color)
        throw new SchemeException('Argument of invalid type passed to color->css.');
      return new SchemeString(this.colorToCss(__exprs[0]));
    }, 1);
  }
}
