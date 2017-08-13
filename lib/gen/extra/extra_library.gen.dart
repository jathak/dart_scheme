part of cs61a_scheme.extra.extra_library;

abstract class _$ExtraLibraryMixin {
  AsyncExpression runAsync(Procedure proc, Frame env);
  AsyncExpression runAfter(Number millis, Procedure proc, Frame env);
  Undefined diagram(Frame env);
  Undefined draw(Expression expression, Frame env);
  Expression visualize(Expression code, Frame env);
  Undefined visGoto(Number number);
  Undefined visExit();
  Undefined visFirst();
  Undefined visLast();
  Undefined visNext();
  Undefined visPrev();
  PairOrEmpty bindings(Frame env);
  void importAll(Frame __env) {
    addPrimitive(__env, const SchemeSymbol("run-async"), (__exprs, __env) {
      if (__exprs[0] is! Procedure)
        throw new SchemeException(
            'Argument of invalid type passed to run-async.');
      return this.runAsync(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("run-after"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Procedure)
        throw new SchemeException(
            'Argument of invalid type passed to run-after.');
      return this.runAfter(__exprs[0], __exprs[1], __env);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("diagram"), (__exprs, __env) {
      return this.diagram(__env);
    }, 0);
    addPrimitive(__env, const SchemeSymbol("draw"), (__exprs, __env) {
      return this.draw(__exprs[0], __env);
    }, 1);
    addOperandPrimitive(__env, const SchemeSymbol("visualize"),
        (__exprs, __env) {
      return this.visualize(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol('vis-goto'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to vis-goto.');
      return this.visGoto(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol('vis-exit'), (__exprs, __env) {
      return this.visExit();
    }, 0);
    addPrimitive(__env, const SchemeSymbol('vis-first'), (__exprs, __env) {
      return this.visFirst();
    }, 0);
    addPrimitive(__env, const SchemeSymbol('vis-last'), (__exprs, __env) {
      return this.visLast();
    }, 0);
    addPrimitive(__env, const SchemeSymbol('vis-next'), (__exprs, __env) {
      return this.visNext();
    }, 0);
    addPrimitive(__env, const SchemeSymbol('vis-prev'), (__exprs, __env) {
      return this.visPrev();
    }, 0);
    addPrimitive(__env, const SchemeSymbol("bindings"), (__exprs, __env) {
      return this.bindings(__env);
    }, 0);
  }
}
