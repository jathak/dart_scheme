part of cs61a_scheme.core.standard_library;

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
  Number length(PairOrEmpty lst);
  PairOrEmpty list(List<Expression> args);
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
  String getRuntimeType(Expression expression);
  void importAll(Frame __env) {
    addPrimitive(__env, const SchemeSymbol("apply"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw new SchemeException('Argument of invalid type passed to apply.');
      return this.apply(__exprs[0], __exprs[1], __env);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("display"), (__exprs, __env) {
      var __value = undefined;
      this.display(__exprs[0], __env);
      return __value;
    }, 1);
    addPrimitive(__env, const SchemeSymbol("error"), (__exprs, __env) {
      return this.error(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol('error-notrace'), (__exprs, __env) {
      return this.errorNoTrace(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("eval"), (__exprs, __env) {
      return this.eval(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("exit"), (__exprs, __env) {
      return this.exit();
    }, 0);
    addPrimitive(__env, const SchemeSymbol("load"), (__exprs, __env) {
      return this.load(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("newline"), (__exprs, __env) {
      var __value = undefined;
      this.newline(__env);
      return __value;
    }, 0);
    addPrimitive(__env, const SchemeSymbol("print"), (__exprs, __env) {
      var __value = undefined;
      this.print(__exprs[0], __env);
      return __value;
    }, 1);
    addPrimitive(__env, const SchemeSymbol("atom?"), (__exprs, __env) {
      return new Boolean(this.isAtom(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("integer?"), (__exprs, __env) {
      return new Boolean(this.isInteger(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("list?"), (__exprs, __env) {
      return new Boolean(this.isList(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("number?"), (__exprs, __env) {
      return new Boolean(this.isNumber(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("null?"), (__exprs, __env) {
      return new Boolean(this.isNull(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("pair?"), (__exprs, __env) {
      return new Boolean(this.isPair(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("procedure?"), (__exprs, __env) {
      return new Boolean(this.isProcedure(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("promise?"), (__exprs, __env) {
      return new Boolean(this.isPromise(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("string?"), (__exprs, __env) {
      return new Boolean(this.isString(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("symbol?"), (__exprs, __env) {
      return new Boolean(this.isSymbol(__exprs[0]));
    }, 1);
    addVariablePrimitive(__env, const SchemeSymbol("append"), (__exprs, __env) {
      return this.append(__exprs);
    }, 0, -1);
    addPrimitive(__env, const SchemeSymbol("car"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw new SchemeException('Argument of invalid type passed to car.');
      return this.car(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("cdr"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw new SchemeException('Argument of invalid type passed to cdr.');
      return this.cdr(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("cons"), (__exprs, __env) {
      return this.cons(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("length"), (__exprs, __env) {
      if (__exprs[0] is! PairOrEmpty)
        throw new SchemeException('Argument of invalid type passed to length.');
      return this.length(__exprs[0]);
    }, 1);
    addVariablePrimitive(__env, const SchemeSymbol("list"), (__exprs, __env) {
      return this.list(__exprs);
    }, 0, -1);
    addVariablePrimitive(__env, const SchemeSymbol("+"), (__exprs, __env) {
      return this.add(__exprs);
    }, 0, -1);
    addVariablePrimitive(__env, const SchemeSymbol("-"), (__exprs, __env) {
      return this.sub(__exprs);
    }, 1, -1);
    addVariablePrimitive(__env, const SchemeSymbol("*"), (__exprs, __env) {
      return this.mul(__exprs);
    }, 0, -1);
    addVariablePrimitive(__env, const SchemeSymbol("/"), (__exprs, __env) {
      return this.truediv(__exprs);
    }, 1, -1);
    addPrimitive(__env, const SchemeSymbol("abs"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to abs.');
      return this.abs(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("expt"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to expt.');
      return this.expt(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("modulo"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to modulo.');
      return this.modulo(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("quotient"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to quotient.');
      return this.quotient(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("remainder"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to remainder.');
      return this.remainder(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("eq?"), (__exprs, __env) {
      return new Boolean(this.isEq(__exprs[0], __exprs[1]));
    }, 2);
    addPrimitive(__env, const SchemeSymbol("equal?"), (__exprs, __env) {
      return new Boolean(this.isEqual(__exprs[0], __exprs[1]));
    }, 2);
    addPrimitive(__env, const SchemeSymbol("not"), (__exprs, __env) {
      return new Boolean(this.not(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to =.');
      return new Boolean(this.eqNumbers(__exprs[0], __exprs[1]));
    }, 2);
    addPrimitive(__env, const SchemeSymbol("<"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to <.');
      return new Boolean(this.lt(__exprs[0], __exprs[1]));
    }, 2);
    addPrimitive(__env, const SchemeSymbol(">"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to >.');
      return new Boolean(this.gt(__exprs[0], __exprs[1]));
    }, 2);
    addPrimitive(__env, const SchemeSymbol("<="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to <=.');
      return new Boolean(this.le(__exprs[0], __exprs[1]));
    }, 2);
    addPrimitive(__env, const SchemeSymbol(">="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to >=.');
      return new Boolean(this.ge(__exprs[0], __exprs[1]));
    }, 2);
    addPrimitive(__env, const SchemeSymbol("even?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to even?.');
      return new Boolean(this.isEven(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("odd?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to odd?.');
      return new Boolean(this.isOdd(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("zero?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to zero?.');
      return new Boolean(this.isZero(__exprs[0]));
    }, 1);
    addPrimitive(__env, const SchemeSymbol("force"), (__exprs, __env) {
      if (__exprs[0] is! Promise)
        throw new SchemeException('Argument of invalid type passed to force.');
      return this.force(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("cdr-stream"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw new SchemeException(
            'Argument of invalid type passed to cdr-stream.');
      return this.cdrStream(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("set-car!"), (__exprs, __env) {
      if (__exprs[0] is! Pair || __exprs[1] is! Expression)
        throw new SchemeException(
            'Argument of invalid type passed to set-car!.');
      var __value = undefined;
      this.setCar(__exprs[0], __exprs[1]);
      __env.interpreter
          .triggerEvent(const SchemeSymbol("pair-mutation"), [__value], __env);
      return __value;
    }, 2);
    addPrimitive(__env, const SchemeSymbol("set-cdr!"), (__exprs, __env) {
      if (__exprs[0] is! Pair || __exprs[1] is! Expression)
        throw new SchemeException(
            'Argument of invalid type passed to set-cdr!.');
      var __value = undefined;
      this.setCdr(__exprs[0], __exprs[1]);
      __env.interpreter
          .triggerEvent(const SchemeSymbol("pair-mutation"), [__value], __env);
      return __value;
    }, 2);
    addPrimitive(__env, const SchemeSymbol("runtime-type"), (__exprs, __env) {
      return new SchemeString(this.getRuntimeType(__exprs[0]));
    }, 1);
  }
}
