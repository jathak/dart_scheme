part of cs61a_scheme.extra.logic_library;

abstract class _$LogicLibraryMixin {
  void fact(List<Expression> exprs, Frame env);
  void query(List<Expression> exprs, Frame env);
  void queryOne(List<Expression> exprs, Frame env);
  String prolog(Frame env);
  void importAll(Frame __env) {
    addVariableOperandPrimitive(__env, const SchemeSymbol('fact'),
        (__exprs, __env) {
      var __value = undefined;
      this.fact(__exprs, __env);
      return __value;
    }, 0, -1);
    __env.bindings[const SchemeSymbol('!')] =
        __env.bindings[const SchemeSymbol('fact')];
    __env.hidden[const SchemeSymbol('!')] = true;
    addVariableOperandPrimitive(__env, const SchemeSymbol('query'),
        (__exprs, __env) {
      var __value = undefined;
      this.query(__exprs, __env);
      return __value;
    }, 0, -1);
    __env.bindings[const SchemeSymbol('?')] =
        __env.bindings[const SchemeSymbol('query')];
    __env.hidden[const SchemeSymbol('?')] = true;
    addVariableOperandPrimitive(__env, const SchemeSymbol('query-one'),
        (__exprs, __env) {
      var __value = undefined;
      this.queryOne(__exprs, __env);
      return __value;
    }, 0, -1);
    addPrimitive(__env, const SchemeSymbol('prolog'), (__exprs, __env) {
      return new SchemeString(this.prolog(__env));
    }, 0);
  }
}
