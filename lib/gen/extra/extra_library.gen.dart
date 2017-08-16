part of cs61a_scheme.extra.extra_library;

abstract class _$ExtraLibraryMixin {
  AsyncExpression runAsync(Procedure proc, Frame env);
  AsyncExpression runAfter(Number millis, Procedure proc, Frame env);
  Boolean isCompleted(AsyncExpression expr);
  Undefined diagram(Frame env);
  Undefined render(Expression expression, Frame env);
  Diagram makeDiagram(Expression expression, Frame env);
  Expression visualize(Expression code, Frame env);
  Undefined visGoto(Number number);
  Undefined visExit();
  Undefined visFirst();
  Undefined visLast();
  Undefined visNext();
  Undefined visPrev();
  PairOrEmpty bindings(Frame env);
  Undefined triggerEvent(SchemeSymbol id, Expression data, Frame env);
  EventListener listenFor(SchemeSymbol id, Procedure onEvent, Frame env);
  AsyncExpression<Undefined> cancelListener(EventListener listener);
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
    addPrimitive(__env, const SchemeSymbol("completed?"), (__exprs, __env) {
      if (__exprs[0] is! AsyncExpression)
        throw new SchemeException(
            'Argument of invalid type passed to completed?.');
      return this.isCompleted(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("diagram"), (__exprs, __env) {
      return this.diagram(__env);
    }, 0);
    addPrimitive(__env, const SchemeSymbol("render"), (__exprs, __env) {
      return this.render(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol('make-diagram'), (__exprs, __env) {
      return this.makeDiagram(__exprs[0], __env);
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
    addPrimitive(__env, const SchemeSymbol('trigger-event'), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol || __exprs[1] is! Expression)
        throw new SchemeException(
            'Argument of invalid type passed to trigger-event.');
      return this.triggerEvent(__exprs[0], __exprs[1], __env);
    }, 2);
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
      return this.cancelListener(__exprs[0]);
    }, 1);
  }
}
