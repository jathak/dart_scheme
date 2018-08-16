part of cs61a_scheme.extra.extra_library;

// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: unnecessary_this
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: unnecessary_lambdas
abstract class _$ExtraLibraryMixin {
  Future<Expression> runAsync(Procedure proc, Frame env);
  Future<Expression> runAfter(Number millis, Procedure proc, Frame env);
  Boolean isCompleted(AsyncExpression expr);
  Diagram draw(Expression expression);
  Diagram diagram(Frame env);
  Visualization visualize(List<Expression> code, Frame env);
  PairOrEmpty bindings(Frame env);
  void triggerEvent(List<Expression> exprs, Frame env);
  SchemeEventListener listenFor(SchemeSymbol id, Procedure onEvent, Frame env);
  void cancelListener(SchemeEventListener listener, Frame env);
  void cancelAll(SchemeSymbol id, Frame env);
  String stringAppend(List<Expression> exprs);
  String serialize(Serializable expr);
  Expression deserialize(String json);
  MarkdownWidget formatted(List<Expression> expressions, Frame env);
  void logicStart(Frame env);
  void importAll(Frame __env) {
    addBuiltin(__env, const SchemeSymbol("run-async"), (__exprs, __env) {
      if (__exprs[0] is! Procedure)
        throw SchemeException('Argument of invalid type passed to run-async.');
      return AsyncExpression(this.runAsync(__exprs[0], __env));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("run-after"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Procedure)
        throw SchemeException('Argument of invalid type passed to run-after.');
      return AsyncExpression(this.runAfter(__exprs[0], __exprs[1], __env));
    }, 2);
    addBuiltin(__env, const SchemeSymbol("completed?"), (__exprs, __env) {
      if (__exprs[0] is! AsyncExpression)
        throw SchemeException('Argument of invalid type passed to completed?.');
      return this.isCompleted(__exprs[0]);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("draw"), (__exprs, __env) {
      return this.draw(__exprs[0]);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("diagram"), (__exprs, __env) {
      return this.diagram(__env);
    }, 0);
    addVariableOperandBuiltin(__env, const SchemeSymbol("visualize"),
        (__exprs, __env) {
      return this.visualize(__exprs, __env);
    }, 0, -1);
    addBuiltin(__env, const SchemeSymbol("bindings"), (__exprs, __env) {
      return this.bindings(__env);
    }, 0);
    addVariableBuiltin(__env, const SchemeSymbol('trigger-event'),
        (__exprs, __env) {
      var __value = undefined;
      this.triggerEvent(__exprs, __env);
      return __value;
    }, 1, -1);
    addBuiltin(__env, const SchemeSymbol('listen-for'), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol || __exprs[1] is! Procedure)
        throw SchemeException('Argument of invalid type passed to listen-for.');
      return this.listenFor(__exprs[0], __exprs[1], __env);
    }, 2);
    addBuiltin(__env, const SchemeSymbol('cancel-listener'), (__exprs, __env) {
      if (__exprs[0] is! SchemeEventListener)
        throw SchemeException(
            'Argument of invalid type passed to cancel-listener.');
      var __value = undefined;
      this.cancelListener(__exprs[0], __env);
      return __value;
    }, 1);
    addBuiltin(__env, const SchemeSymbol('cancel-all'), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol)
        throw SchemeException('Argument of invalid type passed to cancel-all.');
      var __value = undefined;
      this.cancelAll(__exprs[0], __env);
      return __value;
    }, 1);
    addVariableBuiltin(__env, const SchemeSymbol('string-append'),
        (__exprs, __env) {
      return SchemeString(this.stringAppend(__exprs));
    }, 0, -1);
    addBuiltin(__env, const SchemeSymbol("serialize"), (__exprs, __env) {
      if (__exprs[0] is! Serializable)
        throw SchemeException('Argument of invalid type passed to serialize.');
      return SchemeString(this.serialize(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("deserialize"), (__exprs, __env) {
      if (__exprs[0] is! SchemeString)
        throw SchemeException(
            'Argument of invalid type passed to deserialize.');
      return this.deserialize((__exprs[0] as SchemeString).value);
    }, 1);
    addVariableBuiltin(__env, const SchemeSymbol("formatted"),
        (__exprs, __env) {
      return this.formatted(__exprs, __env);
    }, 0, -1);
    addBuiltin(__env, const SchemeSymbol('logic'), (__exprs, __env) {
      var __value = undefined;
      this.logicStart(__env);
      return __value;
    }, 0);
  }
}
