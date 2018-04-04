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
  SchemeEventListener listenFor(SchemeSymbol id, Procedure onEvent, Frame env);
  void cancelListener(SchemeEventListener listener, Frame env);
  void cancelAll(SchemeSymbol id, Frame env);
  String stringAppend(List<Expression> exprs);
  FlagTrace trace(Expression code, Frame env);
  Visualization traceToVisualization(FlagTrace trace);
  String serialize(Serializable expr);
  Expression deserialize(String json);
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
      if (__exprs[0] is! SchemeEventListener)
        throw new SchemeException(
            'Argument of invalid type passed to cancel-listener.');
      var __value = undefined;
      this.cancelListener(__exprs[0], __env);
      return __value;
    }, 1);
    addPrimitive(__env, const SchemeSymbol('cancel-all'), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol)
        throw new SchemeException(
            'Argument of invalid type passed to cancel-all.');
      var __value = undefined;
      this.cancelAll(__exprs[0], __env);
      return __value;
    }, 1);
    addVariablePrimitive(__env, const SchemeSymbol('string-append'),
        (__exprs, __env) {
      return new SchemeString(this.stringAppend(__exprs));
    }, 0, -1);
    addOperandPrimitive(__env, const SchemeSymbol("trace"), (__exprs, __env) {
      return this.trace(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol('trace->visualization'),
        (__exprs, __env) {
      if (__exprs[0] is! FlagTrace)
        throw new SchemeException(
            'Argument of invalid type passed to trace->visualization.');
      return this.traceToVisualization(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("serialize"), (__exprs, __env) {
      if (__exprs[0] is! Serializable)
        throw new SchemeException(
            'Argument of invalid type passed to serialize.');
      return new SchemeString(this.serialize(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("deserialize"), (__exprs, __env) {
      if (__exprs[0] is! SchemeString)
        throw new SchemeException(
            'Argument of invalid type passed to deserialize.');
      return this.deserialize((__exprs[0] as SchemeString).value);
    }, 1);
  }
}
