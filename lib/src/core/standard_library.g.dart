part of cs61a_scheme.core.standard_library;

// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: unnecessary_this
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: unnecessary_lambdas
abstract class _$StandardLibraryMixin {
  Expression apply(Procedure procedure, PairOrEmpty args, Frame env);
  void display(Expression message, Frame env);
  Expression error(Expression message);
  Expression errorNoTrace(Expression message);
  Expression eval(Expression expr, Frame env);
  Expression exit();
  Expression load(Expression file, Frame env);
  void newline(Frame env);
  void print(Expression message, Frame env);
  bool isAtom(Expression val);
  bool isInteger(Expression val);
  bool isList(Expression val);
  bool isNumber(Expression val);
  bool isNull(Expression val);
  bool isPair(Expression val);
  bool isProcedure(Expression val);
  bool isPromise(Expression val);
  bool isString(Expression val);
  bool isSymbol(Expression val);
  Expression append(List<Expression> args);
  Expression car(Pair val);
  Expression cdr(Pair val);
  Pair cons(Expression car, Expression cdr);
  num length(PairOrEmpty lst);
  PairOrEmpty list(List<Expression> args);
  PairOrEmpty map(Procedure fn, PairOrEmpty lst, Frame env);
  PairOrEmpty filter(Procedure pred, PairOrEmpty lst, Frame env);
  Expression reduce(Procedure combiner, PairOrEmpty lst, Frame env);
  Number add(List<Expression> args);
  Number sub(List<Expression> args);
  Number mul(List<Expression> args);
  Number truediv(List<Expression> args);
  Number abs(Number arg);
  Number expt(Number base, Number power);
  Number modulo(Number a, Number b);
  Number quotient(Number a, Number b);
  Number remainder(Number a, Number b);
  bool isEq(Expression x, Expression y);
  bool isEqual(Expression x, Expression y);
  bool not(Expression arg);
  bool eqNumbers(Number x, Number y);
  bool lt(Number x, Number y);
  bool gt(Number x, Number y);
  bool le(Number x, Number y);
  bool ge(Number x, Number y);
  bool isEven(Number x);
  bool isOdd(Number x);
  bool isZero(Number x);
  Expression force(Promise p);
  Expression cdrStream(Pair p);
  void setCar(Pair p, Expression val);
  void setCdr(Pair p, Expression val);
  Expression callWithCurrentContinuation(Procedure procedure, Frame env);
  String getRuntimeType(Expression expression);
  void importAll(Frame __env) {
    addBuiltin(__env, const SchemeSymbol("apply"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw SchemeException('Argument of invalid type passed to apply.');
      return this.apply(__exprs[0], __exprs[1], __env);
    }, 2);
    addBuiltin(__env, const SchemeSymbol("display"), (__exprs, __env) {
      this.display(__exprs[0], __env);
      return undefined;
    }, 1);
    addBuiltin(__env, const SchemeSymbol("error"), (__exprs, __env) {
      return this.error(__exprs[0]);
    }, 1);
    addBuiltin(__env, const SchemeSymbol('error-notrace'), (__exprs, __env) {
      return this.errorNoTrace(__exprs[0]);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("eval"), (__exprs, __env) {
      return this.eval(__exprs[0], __env);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("exit"), (__exprs, __env) {
      return this.exit();
    }, 0);
    addBuiltin(__env, const SchemeSymbol("load"), (__exprs, __env) {
      return this.load(__exprs[0], __env);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("newline"), (__exprs, __env) {
      this.newline(__env);
      return undefined;
    }, 0);
    addBuiltin(__env, const SchemeSymbol("print"), (__exprs, __env) {
      this.print(__exprs[0], __env);
      return undefined;
    }, 1);
    addBuiltin(__env, const SchemeSymbol("atom?"), (__exprs, __env) {
      return Boolean(this.isAtom(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("integer?"), (__exprs, __env) {
      return Boolean(this.isInteger(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("list?"), (__exprs, __env) {
      return Boolean(this.isList(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("number?"), (__exprs, __env) {
      return Boolean(this.isNumber(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("null?"), (__exprs, __env) {
      return Boolean(this.isNull(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("pair?"), (__exprs, __env) {
      return Boolean(this.isPair(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("procedure?"), (__exprs, __env) {
      return Boolean(this.isProcedure(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("promise?"), (__exprs, __env) {
      return Boolean(this.isPromise(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("string?"), (__exprs, __env) {
      return Boolean(this.isString(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("symbol?"), (__exprs, __env) {
      return Boolean(this.isSymbol(__exprs[0]));
    }, 1);
    addVariableBuiltin(__env, const SchemeSymbol("append"), (__exprs, __env) {
      return this.append(__exprs);
    }, 0, -1);
    addBuiltin(__env, const SchemeSymbol("car"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw SchemeException('Argument of invalid type passed to car.');
      return this.car(__exprs[0]);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("cdr"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw SchemeException('Argument of invalid type passed to cdr.');
      return this.cdr(__exprs[0]);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("cons"), (__exprs, __env) {
      return this.cons(__exprs[0], __exprs[1]);
    }, 2);
    addBuiltin(__env, const SchemeSymbol("length"), (__exprs, __env) {
      if (__exprs[0] is! PairOrEmpty)
        throw SchemeException('Argument of invalid type passed to length.');
      return Number.fromNum(this.length(__exprs[0]));
    }, 1);
    addVariableBuiltin(__env, const SchemeSymbol("list"), (__exprs, __env) {
      return this.list(__exprs);
    }, 0, -1);
    addBuiltin(__env, const SchemeSymbol("map"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw SchemeException('Argument of invalid type passed to map.');
      return this.map(__exprs[0], __exprs[1], __env);
    }, 2);
    addBuiltin(__env, const SchemeSymbol("filter"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw SchemeException('Argument of invalid type passed to filter.');
      return this.filter(__exprs[0], __exprs[1], __env);
    }, 2);
    addBuiltin(__env, const SchemeSymbol("reduce"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw SchemeException('Argument of invalid type passed to reduce.');
      return this.reduce(__exprs[0], __exprs[1], __env);
    }, 2);
    addVariableBuiltin(__env, const SchemeSymbol("+"), (__exprs, __env) {
      return this.add(__exprs);
    }, 0, -1);
    addVariableBuiltin(__env, const SchemeSymbol("-"), (__exprs, __env) {
      return this.sub(__exprs);
    }, 1, -1);
    addVariableBuiltin(__env, const SchemeSymbol("*"), (__exprs, __env) {
      return this.mul(__exprs);
    }, 0, -1);
    addVariableBuiltin(__env, const SchemeSymbol("/"), (__exprs, __env) {
      return this.truediv(__exprs);
    }, 1, -1);
    addBuiltin(__env, const SchemeSymbol("abs"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to abs.');
      return this.abs(__exprs[0]);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("expt"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to expt.');
      return this.expt(__exprs[0], __exprs[1]);
    }, 2);
    addBuiltin(__env, const SchemeSymbol("modulo"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to modulo.');
      return this.modulo(__exprs[0], __exprs[1]);
    }, 2);
    addBuiltin(__env, const SchemeSymbol("quotient"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to quotient.');
      return this.quotient(__exprs[0], __exprs[1]);
    }, 2);
    addBuiltin(__env, const SchemeSymbol("remainder"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to remainder.');
      return this.remainder(__exprs[0], __exprs[1]);
    }, 2);
    addBuiltin(__env, const SchemeSymbol("eq?"), (__exprs, __env) {
      return Boolean(this.isEq(__exprs[0], __exprs[1]));
    }, 2);
    addBuiltin(__env, const SchemeSymbol("equal?"), (__exprs, __env) {
      return Boolean(this.isEqual(__exprs[0], __exprs[1]));
    }, 2);
    addBuiltin(__env, const SchemeSymbol("not"), (__exprs, __env) {
      return Boolean(this.not(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to =.');
      return Boolean(this.eqNumbers(__exprs[0], __exprs[1]));
    }, 2);
    addBuiltin(__env, const SchemeSymbol("<"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to <.');
      return Boolean(this.lt(__exprs[0], __exprs[1]));
    }, 2);
    addBuiltin(__env, const SchemeSymbol(">"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to >.');
      return Boolean(this.gt(__exprs[0], __exprs[1]));
    }, 2);
    addBuiltin(__env, const SchemeSymbol("<="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to <=.');
      return Boolean(this.le(__exprs[0], __exprs[1]));
    }, 2);
    addBuiltin(__env, const SchemeSymbol(">="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to >=.');
      return Boolean(this.ge(__exprs[0], __exprs[1]));
    }, 2);
    addBuiltin(__env, const SchemeSymbol("even?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to even?.');
      return Boolean(this.isEven(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("odd?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to odd?.');
      return Boolean(this.isOdd(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("zero?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to zero?.');
      return Boolean(this.isZero(__exprs[0]));
    }, 1);
    addBuiltin(__env, const SchemeSymbol("force"), (__exprs, __env) {
      if (__exprs[0] is! Promise)
        throw SchemeException('Argument of invalid type passed to force.');
      return this.force(__exprs[0]);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("cdr-stream"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw SchemeException('Argument of invalid type passed to cdr-stream.');
      return this.cdrStream(__exprs[0]);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("set-car!"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw SchemeException('Argument of invalid type passed to set-car!.');
      this.setCar(__exprs[0], __exprs[1]);
      __env.interpreter.triggerEvent(
          const SchemeSymbol("pair-mutation"), [undefined], __env);
      return undefined;
    }, 2);
    addBuiltin(__env, const SchemeSymbol("set-cdr!"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw SchemeException('Argument of invalid type passed to set-cdr!.');
      this.setCdr(__exprs[0], __exprs[1]);
      __env.interpreter.triggerEvent(
          const SchemeSymbol("pair-mutation"), [undefined], __env);
      return undefined;
    }, 2);
    addBuiltin(__env, const SchemeSymbol("call/cc"), (__exprs, __env) {
      if (__exprs[0] is! Procedure)
        throw SchemeException('Argument of invalid type passed to call/cc.');
      return this.callWithCurrentContinuation(__exprs[0], __env);
    }, 1);
    addBuiltin(__env, const SchemeSymbol("runtime-type"), (__exprs, __env) {
      return SchemeString(this.getRuntimeType(__exprs[0]));
    }, 1);
  }
}
