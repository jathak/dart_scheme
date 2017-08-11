part of cs61a_scheme.web.web_library;

abstract class _$WebLibraryMixin {
  void importAll(Frame __env) {
    addVariablePrimitive(__env, const SchemeSymbol("js"),
        (__exprs, __env) => WebLibrary.js(__exprs), 0, -1);
    addPrimitive(__env, const SchemeSymbol("js-context"), (__exprs, __env) {
      return WebLibrary.jsContext();
    }, 0);
    addPrimitive(__env, const SchemeSymbol("js-set!"), (__exprs, __env) {
      if (__exprs[0] is! JsExpression ||
          __exprs[1] is! Expression ||
          __exprs[2] is! Expression)
        throw new SchemeException(
            'Argument of invalid type passed to "js-set!".');
      return WebLibrary.jsSet(__exprs[0], __exprs[1], __exprs[2]);
    }, 3);
    addPrimitive(__env, const SchemeSymbol("js-ref"), (__exprs, __env) {
      if (__exprs[0] is! JsExpression || __exprs[1] is! Expression)
        throw new SchemeException(
            'Argument of invalid type passed to "js-ref".');
      return WebLibrary.jsRef(__exprs[0], __exprs[1]);
    }, 2);
    addVariablePrimitive(__env, const SchemeSymbol("js-call"),
        (__exprs, __env) => WebLibrary.jsCall(__exprs), 2, -1);
  }
}
