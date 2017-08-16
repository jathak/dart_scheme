part of cs61a_scheme.core.standard_library;

abstract class _$StandardLibraryMixin {
  Expression apply(Procedure procedure, PairOrEmpty args, Frame env);
  Undefined display(Expression message, Frame env);
  Expression error(Expression message);
  Expression eval(Expression expr, Frame env);
  Expression exit();
  Expression load(Expression file, Frame env);
  Undefined newline(Frame env);
  Undefined print(Expression message, Frame env);
  Boolean isAtom(Expression val);
  Boolean isInteger(Expression val);
  Boolean isList(Expression val);
  Boolean isNumber(Expression val);
  Boolean isNull(Expression val);
  Boolean isPair(Expression val);
  Boolean isProcedure(Expression val);
  Boolean isPromise(Expression val);
  Boolean isString(Expression val);
  Boolean isSymbol(Expression val);
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
  Boolean isEq(Expression x, Expression y);
  Boolean isEqual(Expression x, Expression y);
  Boolean not(Expression arg);
  Boolean eqNumbers(Number x, Number y);
  Boolean lt(Number x, Number y);
  Boolean gt(Number x, Number y);
  Boolean le(Number x, Number y);
  Boolean ge(Number x, Number y);
  Boolean isEven(Number x);
  Boolean isOdd(Number x);
  Boolean isZero(Number x);
  Expression force(Promise p);
  Expression cdrStream(Pair p);
  Undefined setCar(Pair p, Expression val);
  Undefined setCdr(Pair p, Expression val);
  SchemeString getRuntimeType(Expression expression);
  void importAll(Frame __env) {
    addPrimitive(__env, const SchemeSymbol("apply"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw new SchemeException('Argument of invalid type passed to apply.');
      return this.apply(__exprs[0], __exprs[1], __env);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("display"), (__exprs, __env) {
      return this.display(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("error"), (__exprs, __env) {
      return this.error(__exprs[0]);
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
      return this.newline(__env);
    }, 0);
    addPrimitive(__env, const SchemeSymbol("print"), (__exprs, __env) {
      return this.print(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("atom?"), (__exprs, __env) {
      return this.isAtom(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("integer?"), (__exprs, __env) {
      return this.isInteger(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("list?"), (__exprs, __env) {
      return this.isList(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("number?"), (__exprs, __env) {
      return this.isNumber(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("null?"), (__exprs, __env) {
      return this.isNull(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("pair?"), (__exprs, __env) {
      return this.isPair(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("procedure?"), (__exprs, __env) {
      return this.isProcedure(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("promise?"), (__exprs, __env) {
      return this.isPromise(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("string?"), (__exprs, __env) {
      return this.isString(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("symbol?"), (__exprs, __env) {
      return this.isSymbol(__exprs[0]);
    }, 1);
    addVariablePrimitive(__env, const SchemeSymbol("append"),
        (__exprs, __env) => this.append(__exprs), 0, -1);
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
    addVariablePrimitive(__env, const SchemeSymbol("list"),
        (__exprs, __env) => this.list(__exprs), 0, -1);
    addVariablePrimitive(__env, const SchemeSymbol("+"),
        (__exprs, __env) => this.add(__exprs), 0, -1);
    addVariablePrimitive(__env, const SchemeSymbol("-"),
        (__exprs, __env) => this.sub(__exprs), 1, -1);
    addVariablePrimitive(__env, const SchemeSymbol("*"),
        (__exprs, __env) => this.mul(__exprs), 0, -1);
    addVariablePrimitive(__env, const SchemeSymbol("/"),
        (__exprs, __env) => this.truediv(__exprs), 1, -1);
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
      return this.isEq(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("equal?"), (__exprs, __env) {
      return this.isEqual(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("not"), (__exprs, __env) {
      return this.not(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to =.');
      return this.eqNumbers(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("<"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to <.');
      return this.lt(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol(">"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to >.');
      return this.gt(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("<="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to <=.');
      return this.le(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol(">="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to >=.');
      return this.ge(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("even?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to even?.');
      return this.isEven(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("odd?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to odd?.');
      return this.isOdd(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("zero?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to zero?.');
      return this.isZero(__exprs[0]);
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
      var __value = this.setCar(__exprs[0], __exprs[1]);
      __env.interpreter.triggerEvent(
          const SchemeSymbol("pair-mutation"), new Pair(__value, __env));
      return __value;
    }, 2);
    addPrimitive(__env, const SchemeSymbol("set-cdr!"), (__exprs, __env) {
      if (__exprs[0] is! Pair || __exprs[1] is! Expression)
        throw new SchemeException(
            'Argument of invalid type passed to set-cdr!.');
      var __value = this.setCdr(__exprs[0], __exprs[1]);
      __env.interpreter.triggerEvent(
          const SchemeSymbol("pair-mutation"), new Pair(__value, __env));
      return __value;
    }, 2);
    addPrimitive(__env, const SchemeSymbol("runtime-type"), (__exprs, __env) {
      return this.getRuntimeType(__exprs[0]);
    }, 1);
  }
}
