part of cs61a_scheme.extra.extra_library;

// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: unnecessary_this
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: unnecessary_lambdas
abstract class _$ExtraLibraryMixin {
  Future<Value> runAsync(Procedure proc, Frame env);
  Future<Value> runAfter(Number millis, Procedure proc, Frame env);
  Boolean isCompleted(AsyncValue expr);
  Diagram draw(Value value);
  Diagram diagram(Frame env);
  Visualization visualize(List<Expression> code, Frame env);
  SchemeList bindings(Frame env);
  void triggerEvent(List<Value> args, Frame env);
  SchemeEventListener listenFor(SchemeSymbol id, Procedure onEvent, Frame env);
  void cancelListener(SchemeEventListener listener, Frame env);
  void cancelAll(SchemeSymbol id, Frame env);
  String stringAppend(List<Value> values);
  String serialize(Serializable expr);
  Expression deserialize(String json);
  MarkdownWidget formatted(List<Value> values, Frame env);
  void logicStart(Frame env);
  Docs docs(SchemeSymbol topic, Frame env);
  void allDocs(Frame env);
  void importAll(Frame __env) {
    addBuiltin(__env, const SchemeSymbol("run-async"), (__exprs, __env) {
      if (__exprs[0] is! Procedure)
        throw SchemeException('Argument of invalid type passed to run-async.');
      return AsyncValue(this.runAsync(__exprs[0], __env));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("run-after"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Procedure)
        throw SchemeException('Argument of invalid type passed to run-after.');
      return AsyncValue(this.runAfter(__exprs[0], __exprs[1], __env));
    }, 2);
    addBuiltin(__env, const SchemeSymbol("completed?"), (__exprs, __env) {
      if (__exprs[0] is! AsyncValue)
        throw SchemeException('Argument of invalid type passed to completed?.');
      return this.isCompleted(__exprs[0]);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("draw"), (__exprs, __env) {
      return this.draw(__exprs[0]);
    }, 1,
        docs: Docs("draw", "Creates a diagram of [value].\n",
            [Param("value", "value")]));
    addBuiltin(__env, const SchemeSymbol("diagram"), (__exprs, __env) {
      return this.diagram(__env);
    }, 0,
        docs: Docs(
            "diagram", "Create a diagram of the current environment.\n", []));
    addVariableOperandBuiltin(__env, const SchemeSymbol("visualize"),
        (__exprs, __env) {
      if (__exprs.any((x) => x is! Expression))
        throw SchemeException('Argument of invalid type passed to visualize.');
      return this.visualize(__exprs.cast<Expression>(), __env);
    }, 0,
        maxArgs: -1,
        docs: Docs.variable(
            "visualize", "Visualizes the execution of a piece of code.\n"));
    addBuiltin(__env, const SchemeSymbol("bindings"), (__exprs, __env) {
      return (this.bindings(__env)).list;
    }, 0,
        docs: Docs("bindings",
            "Returns a list of all bindings in the current environment.\n", [],
            returnType: "list"));
    addVariableBuiltin(__env, const SchemeSymbol('trigger-event'),
        (__exprs, __env) {
      this.triggerEvent(__exprs, __env);
      return undefined;
    }, 1,
        maxArgs: -1,
        docs: Docs.variable('trigger-event',
            "Triggers an event with a given name (first arg) and arguments.\n"));
    addBuiltin(__env, const SchemeSymbol('listen-for'), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol || __exprs[1] is! Procedure)
        throw SchemeException('Argument of invalid type passed to listen-for.');
      return this.listenFor(__exprs[0], __exprs[1], __env);
    }, 2,
        docs: Docs(
            'listen-for',
            "Sets up an listener to call [onEvent] when an event with [id] occurs.\n",
            [Param("symbol", "id"), Param("procedure", "onEvent")],
            returnType: "event listener"));
    addBuiltin(__env, const SchemeSymbol('cancel-listener'), (__exprs, __env) {
      if (__exprs[0] is! SchemeEventListener)
        throw SchemeException(
            'Argument of invalid type passed to cancel-listener.');
      this.cancelListener(__exprs[0], __env);
      return undefined;
    }, 1,
        docs: Docs(
            'cancel-listener',
            "Cancels [listener] from triggering on new events.\n",
            [Param("event listener", "listener")]));
    addBuiltin(__env, const SchemeSymbol('cancel-all'), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol)
        throw SchemeException('Argument of invalid type passed to cancel-all.');
      this.cancelAll(__exprs[0], __env);
      return undefined;
    }, 1,
        docs: Docs('cancel-all', "Cancels all listeners for event [id].\n",
            [Param("symbol", "id")]));
    addVariableBuiltin(__env, const SchemeSymbol('string-append'),
        (__exprs, __env) {
      return SchemeString(this.stringAppend(__exprs));
    }, 0,
        maxArgs: -1,
        docs: Docs.variable('string-append',
            "Constructs a string from the display values of any number of values.\n",
            returnType: "string"));
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
    addVariableBuiltin(
        __env, const SchemeSymbol("formatted"), this.formatted, 0,
        maxArgs: -1,
        docs: Docs.variable("formatted",
            "Renders all provided text as a block of Markdown.\n"));
    addBuiltin(__env, const SchemeSymbol('logic'), (__exprs, __env) {
      this.logicStart(__env);
      return undefined;
    }, 0,
        docs: Docs(
            'logic',
            "Loads procedures to run Logic code within the interpreter.\n",
            []));
    addOperandBuiltin(__env, const SchemeSymbol("docs"), (__exprs, __env) {
      if (__exprs[0] is! SchemeSymbol)
        throw SchemeException('Argument of invalid type passed to docs.');
      return this.docs(__exprs[0], __env);
    }, 1,
        docs: Docs(
            "docs",
            "Returns the documentation for [topic], if it exists.\n",
            [Param("symbol", "topic")]));
    addBuiltin(__env, const SchemeSymbol('all-docs'), (__exprs, __env) {
      this.allDocs(__env);
      return undefined;
    }, 0,
        docs: Docs('all-docs',
            "Logs all documentation available to the interpreter.\n", []));
  }
}
