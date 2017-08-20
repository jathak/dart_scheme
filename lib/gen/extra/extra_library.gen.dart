part of cs61a_scheme.extra.extra_library;

abstract class _$ExtraLibraryMixin {
  Future<Expression> runAsync(Procedure proc, Frame env);
  Future<Expression> runAfter(Number millis, Procedure proc, Frame env);
  Boolean isCompleted(AsyncExpression expr);
  void render(UIElement ui, Frame env);
  Diagram draw(Expression expression);
  Diagram diagram(Frame env);
  Visualization visualize(Expression code, Frame env);
  PairOrEmpty bindings(Frame env);
  void triggerEvent(List<Expression> exprs, Frame env);
  EventListener listenFor(SchemeSymbol id, Procedure onEvent, Frame env);
  void cancelListener(EventListener listener, Frame env);
  String stringAppend(List<Expression> exprs);
  void importAll(Frame __env) {
    addPrimitive(__env, const SchemeSymbol("run-async"), (__exprs, __env) {
      if (__exprs[0] is! Procedure)
        throw new SchemeException(
            'Argument of invalid type passed to run-async.');
      return new AsyncExpression(this.runAsync(__exprs[0], __env));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("run-after"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Procedure)
        throw new SchemeException(
            'Argument of invalid type passed to run-after.');
      return new AsyncExpression(this.runAfter(__exprs[0], __exprs[1], __env));
    }, 2);
    addPrimitive(__env, const SchemeSymbol("completed?"), (__exprs, __env) {
      if (__exprs[0] is! AsyncExpression)
        throw new SchemeException(
            'Argument of invalid type passed to completed?.');
      return this.isCompleted(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("render"), (__exprs, __env) {
      if (__exprs[0] is! UIElement)
        throw new SchemeException('Argument of invalid type passed to render.');
      var __value = undefined;
      this.render(__exprs[0], __env);
      return __value;
    }, 1);
    addPrimitive(__env, const SchemeSymbol("draw"), (__exprs, __env) {
      return this.draw(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("diagram"), (__exprs, __env) {
      return this.diagram(__env);
    }, 0);
    addOperandPrimitive(__env, const SchemeSymbol("visualize"),
        (__exprs, __env) {
      return this.visualize(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("bindings"), (__exprs, __env) {
      return this.bindings(__env);
    }, 0);
    addVariablePrimitive(__env, const SchemeSymbol('trigger-event'),
        (__exprs, __env) {
      var __value = undefined;
      this.triggerEvent(__exprs, __env);
      return __value;
    }, 1, -1);
    addPrimitive(__env, const SchemeSymbol('listen-for'), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol || __exprs[1] is! Procedure)
        throw new SchemeException(
            'Argument of invalid type passed to listen-for.');
      return this.listenFor(__exprs[0], __exprs[1], __env);
    }, 2);
    addPrimitive(__env, const SchemeSymbol('cancel-listener'),
        (__exprs, __env) {
      if (__exprs[0] is! EventListener)
        throw new SchemeException(
            'Argument of invalid type passed to cancel-listener.');
      var __value = undefined;
      this.cancelListener(__exprs[0], __env);
      return __value;
    }, 1);
    addVariablePrimitive(__env, const SchemeSymbol('string-append'),
        (__exprs, __env) {
      return new SchemeString(this.stringAppend(__exprs));
    }, 0, -1);
  }
}
