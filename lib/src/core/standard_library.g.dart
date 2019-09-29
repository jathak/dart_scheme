part of cs61a_scheme.core.standard_library;

// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: unnecessary_this
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: unnecessary_lambdas
abstract class _$StandardLibraryMixin {
  Value apply(Procedure procedure, SchemeList args, Frame env);
  void display(Value message, Frame env);
  void error(Value message);
  void errorNoTrace(Value message);
  Value eval(Expression expr, Frame env);
  void exit();
  void load(Value file, Frame env);
  void newline(Frame env);
  void print(Value message, Frame env);
  bool isAtom(Value val);
  bool isInteger(Value val);
  bool isList(Value val);
  bool isNumber(Value val);
  bool isNull(Value val);
  bool isPair(Value val);
  bool isProcedure(Value val);
  bool isPromise(Value val);
  bool isString(Value val);
  bool isSymbol(Value val);
  Value append(List<Value> args);
  Value car(Pair val);
  Value cdr(Pair val);
  Pair cons(Value car, Value cdr, Frame env);
  num length(PairOrEmpty lst);
  SchemeList list(List<Value> args);
  SchemeList map(Procedure fn, SchemeList lst, Frame env);
  SchemeList filter(Procedure pred, SchemeList lst, Frame env);
  Value reduce(Procedure combiner, SchemeList lst, Frame env);
  Number add(List<Number> nums);
  Number sub(List<Number> nums);
  Number mul(List<Number> nums);
  Number truediv(List<Number> nums);
  Number abs(Number arg);
  Number expt(Number base, Number power);
  Number modulo(Number a, Number b);
  Number quotient(Number a, Number b);
  Number remainder(Number a, Number b);
  bool isEq(Value x, Value y);
  bool isEqual(Value x, Value y);
  bool not(Value arg);
  bool eqNumbers(Number x, Number y);
  bool lt(Number x, Number y);
  bool gt(Number x, Number y);
  bool le(Number x, Number y);
  bool ge(Number x, Number y);
  bool isEven(Number x);
  bool isOdd(Number x);
  bool isZero(Number x);
  Expression force(Promise promise);
  Expression cdrStream(Pair stream);
  void setCar(Pair pair, Value val);
  void setCdr(Pair pair, Value val, Frame env);
  String getRuntimeType(Expression expression);
  void importAll(Frame __env) {
    addBuiltin(__env, const SchemeSymbol("apply"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw SchemeException('Argument of invalid type passed to apply.');
      return this.apply(__exprs[0], SchemeList(__exprs[1]), __env);
    }, 2,
        docs: Docs("apply", "Applies [procedure] to the given [args]\n",
            [Param("procedure", "procedure"), Param("list", "args")],
            returnType: "value"));
    addBuiltin(__env, const SchemeSymbol("display"), (__exprs, __env) {
      this.display(__exprs[0], __env);
      return undefined;
    }, 1,
        docs: Docs(
            "display",
            "Displays [message] without a line break at the end\n",
            [Param("value", "message")]));
    addBuiltin(__env, const SchemeSymbol("error"), (__exprs, __env) {
      this.error(__exprs[0]);
      return undefined;
    }, 1,
        docs: Docs("error", "Raises an error with the given [message].\n",
            [Param("value", "message")]));
    addBuiltin(__env, const SchemeSymbol('error-notrace'), (__exprs, __env) {
      this.errorNoTrace(__exprs[0]);
      return undefined;
    }, 1,
        docs: Docs(
            'error-notrace',
            "Raises an error with the given [message] and no traceback.\n",
            [Param("value", "message")]));
    addBuiltin(__env, const SchemeSymbol("eval"), (__exprs, __env) {
      if (__exprs[0] is! Expression)
        throw SchemeException('Argument of invalid type passed to eval.');
      return this.eval(__exprs[0], __env);
    }, 1,
        docs: Docs("eval", "Evaluates [expr] in the current environment\n",
            [Param("expression", "expr")],
            returnType: "value"));
    addBuiltin(__env, const SchemeSymbol("exit"), (__exprs, __env) {
      this.exit();
      return undefined;
    }, 0,
        docs: Docs("exit", "Exits the interpreter (behavior may vary)\n", []));
    addBuiltin(__env, const SchemeSymbol("load"), (__exprs, __env) {
      this.load(__exprs[0], __env);
      return undefined;
    }, 1);
    addBuiltin(__env, const SchemeSymbol("newline"), (__exprs, __env) {
      this.newline(__env);
      return undefined;
    }, 0, docs: Docs("newline", "Displays a line break\n", []));
    addBuiltin(__env, const SchemeSymbol("print"), (__exprs, __env) {
      this.print(__exprs[0], __env);
      return undefined;
    }, 1,
        docs: Docs("print", "Logs [message] to the interpreter.\n",
            [Param("value", "message")]));
    addBuiltin(__env, const SchemeSymbol("atom?"), (__exprs, __env) {
      return Boolean(this.isAtom(__exprs[0]));
    }, 1,
        docs: Docs("atom?", "Returns true if [val] is an atomic expression.\n",
            [Param("value", "val")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("integer?"), (__exprs, __env) {
      return Boolean(this.isInteger(__exprs[0]));
    }, 1,
        docs: Docs("integer?", "Returns true if [val] is an integer.\n",
            [Param("value", "val")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("list?"), (__exprs, __env) {
      return Boolean(this.isList(__exprs[0]));
    }, 1,
        docs: Docs("list?", "Returns true if [val] is a well-formed list.\n",
            [Param("value", "val")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("number?"), (__exprs, __env) {
      return Boolean(this.isNumber(__exprs[0]));
    }, 1,
        docs: Docs("number?", "Returns true if [val] is an number.\n",
            [Param("value", "val")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("null?"), (__exprs, __env) {
      return Boolean(this.isNull(__exprs[0]));
    }, 1,
        docs: Docs("null?", "Returns true if [val] is the empty list.\n",
            [Param("value", "val")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("pair?"), (__exprs, __env) {
      return Boolean(this.isPair(__exprs[0]));
    }, 1,
        docs: Docs("pair?", "Returns true if [val] is a pair.\n",
            [Param("value", "val")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("procedure?"), (__exprs, __env) {
      return Boolean(this.isProcedure(__exprs[0]));
    }, 1,
        docs: Docs("procedure?", "Returns true if [val] is a procedure.\n",
            [Param("value", "val")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("promise?"), (__exprs, __env) {
      return Boolean(this.isPromise(__exprs[0]));
    }, 1,
        docs: Docs("promise?", "Returns true if [val] is a promise.\n",
            [Param("value", "val")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("string?"), (__exprs, __env) {
      return Boolean(this.isString(__exprs[0]));
    }, 1,
        docs: Docs("string?", "Returns true if [val] is a string.\n",
            [Param("value", "val")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("symbol?"), (__exprs, __env) {
      return Boolean(this.isSymbol(__exprs[0]));
    }, 1,
        docs: Docs("symbol?", "Returns true if [val] is a symbol.\n",
            [Param("value", "val")],
            returnType: "bool"));
    addVariableBuiltin(__env, const SchemeSymbol("append"), (__exprs, __env) {
      return this.append(__exprs);
    }, 0,
        maxArgs: -1,
        docs: Docs.variable("append",
            "Appends zero or more lists together into a single list.\n",
            returnType: "value"));
    addBuiltin(__env, const SchemeSymbol("car"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw SchemeException('Argument of invalid type passed to car.');
      return this.car(__exprs[0]);
    }, 1,
        docs: Docs(
            "car", "Gets the first item in [val].\n", [Param("pair", "val")],
            returnType: "value"));
    addBuiltin(__env, const SchemeSymbol("cdr"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw SchemeException('Argument of invalid type passed to cdr.');
      return this.cdr(__exprs[0]);
    }, 1,
        docs: Docs(
            "cdr",
            "Gets the second item in [val] (typically the rest of a well-formed list).\n",
            [Param("pair", "val")],
            returnType: "value"));
    addBuiltin(__env, const SchemeSymbol("cons"), (__exprs, __env) {
      return this.cons(__exprs[0], __exprs[1], __env);
    }, 2,
        docs: Docs("cons", "Constructs a pair from values [car] and [cdr].\n",
            [Param("value", "car"), Param("value", "cdr")],
            returnType: "pair"));
    addBuiltin(__env, const SchemeSymbol("length"), (__exprs, __env) {
      if (__exprs[0] is! PairOrEmpty)
        throw SchemeException('Argument of invalid type passed to length.');
      return Number.fromNum(this.length(__exprs[0]));
    }, 1,
        docs: Docs("length", "Finds the length of a well-formed Scheme list.\n",
            [Param(null, "lst")],
            returnType: "num"));
    addVariableBuiltin(__env, const SchemeSymbol("list"), (__exprs, __env) {
      return (this.list(__exprs)).list;
    }, 0,
        maxArgs: -1,
        docs: Docs.variable(
            "list", "Constructs a list from zero or more arguments.\n",
            returnType: "list"));
    addBuiltin(__env, const SchemeSymbol("map"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw SchemeException('Argument of invalid type passed to map.');
      return (this.map(__exprs[0], SchemeList(__exprs[1]), __env)).list;
    }, 2,
        docs: Docs(
            "map",
            "Constructs a new list from calling [fn] on each item in [lst].\n",
            [Param("procedure", "fn"), Param("list", "lst")],
            returnType: "list"));
    addBuiltin(__env, const SchemeSymbol("filter"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw SchemeException('Argument of invalid type passed to filter.');
      return (this.filter(__exprs[0], SchemeList(__exprs[1]), __env)).list;
    }, 2,
        docs: Docs(
            "filter",
            "Constructs a new list of all items in [lst] that return true when passed\nto [pred].\n",
            [Param("procedure", "pred"), Param("list", "lst")],
            returnType: "list"));
    addBuiltin(__env, const SchemeSymbol("reduce"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw SchemeException('Argument of invalid type passed to reduce.');
      return this.reduce(__exprs[0], SchemeList(__exprs[1]), __env);
    }, 2,
        docs: Docs(
            "reduce",
            "Reduces [lst] into a single expression by combining items with [combiner].\n",
            [Param("procedure", "combiner"), Param("list", "lst")],
            returnType: "value"));
    addVariableBuiltin(__env, const SchemeSymbol("+"), (__exprs, __env) {
      if (__exprs.any((x) => x is! Number))
        throw SchemeException('Argument of invalid type passed to +.');
      return this.add(__exprs.cast<Number>());
    }, 0,
        maxArgs: -1,
        docs: Docs.variable("+", "Adds 0 or more numbers together.\n",
            returnType: "num"));
    addVariableBuiltin(__env, const SchemeSymbol("-"), (__exprs, __env) {
      if (__exprs.any((x) => x is! Number))
        throw SchemeException('Argument of invalid type passed to -.');
      return this.sub(__exprs.cast<Number>());
    }, 1,
        maxArgs: -1,
        docs: Docs.variable("-",
            "If called with one number, negates it.\nOtherwise, subtracts the sum of all remaining arguments from the first.\n",
            returnType: "num"));
    addVariableBuiltin(__env, const SchemeSymbol("*"), (__exprs, __env) {
      if (__exprs.any((x) => x is! Number))
        throw SchemeException('Argument of invalid type passed to *.');
      return this.mul(__exprs.cast<Number>());
    }, 0,
        maxArgs: -1,
        docs: Docs.variable("*", "Multiples 0 or more numbers together.\n",
            returnType: "num"));
    addVariableBuiltin(__env, const SchemeSymbol("/"), (__exprs, __env) {
      if (__exprs.any((x) => x is! Number))
        throw SchemeException('Argument of invalid type passed to /.');
      return this.truediv(__exprs.cast<Number>());
    }, 1,
        maxArgs: -1,
        docs: Docs.variable("/",
            "If called with one number, finds its reciprocal.\nOtherwise, divides the first argument by the product of the rest.\n",
            returnType: "num"));
    addBuiltin(__env, const SchemeSymbol("abs"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to abs.');
      return this.abs(__exprs[0]);
    }, 1,
        docs: Docs("abs", "Finds the absolute value of [arg].\n",
            [Param("num", "arg")],
            returnType: "num"));
    addBuiltin(__env, const SchemeSymbol("expt"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to expt.');
      return this.expt(__exprs[0], __exprs[1]);
    }, 2,
        docs: Docs("expt", "Raises [base] to [power].\n",
            [Param("num", "base"), Param("num", "power")],
            returnType: "num"));
    addBuiltin(__env, const SchemeSymbol("modulo"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to modulo.');
      return this.modulo(__exprs[0], __exprs[1]);
    }, 2,
        docs: Docs(
            "modulo", "Finds a % b.\n", [Param("num", "a"), Param("num", "b")],
            returnType: "num"));
    addBuiltin(__env, const SchemeSymbol("quotient"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to quotient.');
      return this.quotient(__exprs[0], __exprs[1]);
    }, 2,
        docs: Docs(
            "quotient",
            "Divides [a] by [b] using truncating division.\n",
            [Param("num", "a"), Param("num", "b")],
            returnType: "num"));
    addBuiltin(__env, const SchemeSymbol("remainder"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to remainder.');
      return this.remainder(__exprs[0], __exprs[1]);
    }, 2,
        docs: Docs(
            "remainder",
            "Finds the remainder when dividing [a] by [b].\n",
            [Param("num", "a"), Param("num", "b")],
            returnType: "num"));
    addBuiltin(__env, const SchemeSymbol("eq?"), (__exprs, __env) {
      return Boolean(this.isEq(__exprs[0], __exprs[1]));
    }, 2,
        docs: Docs(
            "eq?",
            "Determines if [x] and [y] are the same object.\n\nFor the purposes of this procedure, equivalent numbers, symbols, and\nstrings are considered the same object.\n",
            [Param("value", "x"), Param("value", "y")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("equal?"), (__exprs, __env) {
      return Boolean(this.isEqual(__exprs[0], __exprs[1]));
    }, 2,
        docs: Docs(
            "equal?",
            "Determines if [x] and [y] hold equivalent values.\n",
            [Param("value", "x"), Param("value", "y")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("not"), (__exprs, __env) {
      return Boolean(this.not(__exprs[0]));
    }, 1,
        docs: Docs("not", "Negates the truthiness of [arg].\n",
            [Param("value", "arg")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to =.');
      return Boolean(this.eqNumbers(__exprs[0], __exprs[1]));
    }, 2,
        docs: Docs("=", "Compares [x] and [y] for equality.\n",
            [Param("num", "x"), Param("num", "y")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("<"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to <.');
      return Boolean(this.lt(__exprs[0], __exprs[1]));
    }, 2,
        docs: Docs("<", "Returns true if [x] is less than [y].\n",
            [Param("num", "x"), Param("num", "y")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol(">"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to >.');
      return Boolean(this.gt(__exprs[0], __exprs[1]));
    }, 2,
        docs: Docs(">", "Returns true if [x] is greater than [y].\n",
            [Param("num", "x"), Param("num", "y")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("<="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to <=.');
      return Boolean(this.le(__exprs[0], __exprs[1]));
    }, 2,
        docs: Docs("<=", "Returns true if [x] is less than or equal to [y].\n",
            [Param("num", "x"), Param("num", "y")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol(">="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to >=.');
      return Boolean(this.ge(__exprs[0], __exprs[1]));
    }, 2,
        docs: Docs(
            ">=",
            "Returns true if [x] is greater than or equal to [y].\n",
            [Param("num", "x"), Param("num", "y")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("even?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to even?.');
      return Boolean(this.isEven(__exprs[0]));
    }, 1,
        docs: Docs(
            "even?", "Returns true if [x] is even.\n", [Param("num", "x")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("odd?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to odd?.');
      return Boolean(this.isOdd(__exprs[0]));
    }, 1,
        docs: Docs("odd?", "Returns true if [x] is odd.\n", [Param("num", "x")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("zero?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to zero?.');
      return Boolean(this.isZero(__exprs[0]));
    }, 1,
        docs: Docs(
            "zero?", "Returns true if [x] is zero.\n", [Param("num", "x")],
            returnType: "bool"));
    addBuiltin(__env, const SchemeSymbol("force"), (__exprs, __env) {
      if (__exprs[0] is! Promise)
        throw SchemeException('Argument of invalid type passed to force.');
      return this.force(__exprs[0]);
    }, 1,
        docs: Docs("force", "Forces [promise], evaluating it if necessary.\n",
            [Param(null, "promise")],
            returnType: "expression"));
    addBuiltin(__env, const SchemeSymbol("cdr-stream"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw SchemeException('Argument of invalid type passed to cdr-stream.');
      return this.cdrStream(__exprs[0]);
    }, 1,
        docs: Docs(
            "cdr-stream",
            "Finds the rest of [stream].\n\nEquivalent to (force (cdr [stream]))\n",
            [Param("pair", "stream")],
            returnType: "expression"));
    addBuiltin(__env, const SchemeSymbol("set-car!"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw SchemeException('Argument of invalid type passed to set-car!.');
      this.setCar(__exprs[0], __exprs[1]);
      __env.interpreter.triggerEvent(
          const SchemeSymbol("pair-mutation"), [undefined], __env);
      return undefined;
    }, 2,
        docs: Docs("set-car!", "Mutates the car of [pair] to be [val].\n",
            [Param("pair", "pair"), Param("value", "val")]));
    addBuiltin(__env, const SchemeSymbol("set-cdr!"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw SchemeException('Argument of invalid type passed to set-cdr!.');
      this.setCdr(__exprs[0], __exprs[1], __env);
      __env.interpreter.triggerEvent(
          const SchemeSymbol("pair-mutation"), [undefined], __env);
      return undefined;
    }, 2,
        docs: Docs("set-cdr!", "Mutates the cdr of [pair] to be [val].\n",
            [Param("pair", "pair"), Param("value", "val")]));
    addBuiltin(__env, const SchemeSymbol("runtime-type"), (__exprs, __env) {
      if (__exprs[0] is! Expression)
        throw SchemeException(
            'Argument of invalid type passed to runtime-type.');
      return SchemeString(this.getRuntimeType(__exprs[0]));
    }, 1);
  }
}
