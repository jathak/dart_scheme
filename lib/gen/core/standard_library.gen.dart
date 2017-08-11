part of cs61a_scheme.core.standard_library;

abstract class _$StandardLibraryMixin {
  void importAll(Frame __env) {
    addPrimitive(__env, const SchemeSymbol("apply"), (__exprs, __env) {
      if (__exprs[0] is! Procedure || __exprs[1] is! PairOrEmpty)
        throw new SchemeException(
            'Argument of invalid type passed to "apply".');
      return StandardLibrary.apply(__exprs[0], __exprs[1], __env);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("display"), (__exprs, __env) {
      return StandardLibrary.display(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("error"), (__exprs, __env) {
      return StandardLibrary.error(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("eval"), (__exprs, __env) {
      return StandardLibrary.eval(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("exit"), (__exprs, __env) {
      return StandardLibrary.exit();
    }, 0);
    addPrimitive(__env, const SchemeSymbol("load"), (__exprs, __env) {
      return StandardLibrary.load(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("newline"), (__exprs, __env) {
      return StandardLibrary.newline(__env);
    }, 0);
    addPrimitive(__env, const SchemeSymbol("print"), (__exprs, __env) {
      return StandardLibrary.print(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("atom?"), (__exprs, __env) {
      return StandardLibrary.isAtom(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("integer?"), (__exprs, __env) {
      return StandardLibrary.isInteger(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("list?"), (__exprs, __env) {
      return StandardLibrary.isList(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("number?"), (__exprs, __env) {
      return StandardLibrary.isNumber(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("null?"), (__exprs, __env) {
      return StandardLibrary.isNull(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("pair?"), (__exprs, __env) {
      return StandardLibrary.isPair(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("procedure?"), (__exprs, __env) {
      return StandardLibrary.isProcedure(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("promise?"), (__exprs, __env) {
      return StandardLibrary.isPromise(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("string?"), (__exprs, __env) {
      return StandardLibrary.isString(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("symbol?"), (__exprs, __env) {
      return StandardLibrary.isSymbol(__exprs[0]);
    }, 1);
    addVariablePrimitive(__env, const SchemeSymbol("append"),
        (__exprs, __env) => StandardLibrary.append(__exprs), 0, -1);
    addPrimitive(__env, const SchemeSymbol("car"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw new SchemeException('Argument of invalid type passed to "car".');
      return StandardLibrary.car(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("cdr"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw new SchemeException('Argument of invalid type passed to "cdr".');
      return StandardLibrary.cdr(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("cons"), (__exprs, __env) {
      return StandardLibrary.cons(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("length"), (__exprs, __env) {
      if (__exprs[0] is! PairOrEmpty)
        throw new SchemeException(
            'Argument of invalid type passed to "length".');
      return StandardLibrary.length(__exprs[0]);
    }, 1);
    addVariablePrimitive(__env, const SchemeSymbol("list"),
        (__exprs, __env) => StandardLibrary.list(__exprs), 0, -1);
    addVariablePrimitive(__env, const SchemeSymbol("+"),
        (__exprs, __env) => StandardLibrary.add(__exprs), 0, -1);
    addVariablePrimitive(__env, const SchemeSymbol("-"),
        (__exprs, __env) => StandardLibrary.sub(__exprs), 1, -1);
    addVariablePrimitive(__env, const SchemeSymbol("*"),
        (__exprs, __env) => StandardLibrary.mul(__exprs), 0, -1);
    addVariablePrimitive(__env, const SchemeSymbol("/"),
        (__exprs, __env) => StandardLibrary.truediv(__exprs), 1, -1);
    addPrimitive(__env, const SchemeSymbol("abs"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to "abs".');
      return StandardLibrary.abs(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("expt"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to "expt".');
      return StandardLibrary.expt(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("modulo"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to "modulo".');
      return StandardLibrary.modulo(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("quotient"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to "quotient".');
      return StandardLibrary.quotient(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("remainder"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to "remainder".');
      return StandardLibrary.remainder(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("eq?"), (__exprs, __env) {
      return StandardLibrary.isEq(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("equal?"), (__exprs, __env) {
      return StandardLibrary.isEqual(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("not"), (__exprs, __env) {
      return StandardLibrary.not(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to "=".');
      return StandardLibrary.eqNumbers(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("<"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to "<".');
      return StandardLibrary.lt(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol(">"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to ">".');
      return StandardLibrary.gt(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("<="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to "<=".');
      return StandardLibrary.le(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol(">="), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException('Argument of invalid type passed to ">=".');
      return StandardLibrary.ge(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("even?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to "even?".');
      return StandardLibrary.isEven(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("odd?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to "odd?".');
      return StandardLibrary.isOdd(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("zero?"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to "zero?".');
      return StandardLibrary.isZero(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("force"), (__exprs, __env) {
      if (__exprs[0] is! Promise)
        throw new SchemeException(
            'Argument of invalid type passed to "force".');
      return StandardLibrary.force(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("cdr-stream"), (__exprs, __env) {
      if (__exprs[0] is! Pair)
        throw new SchemeException(
            'Argument of invalid type passed to "cdr-stream".');
      return StandardLibrary.cdrStream(__exprs[0]);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("set-car!"), (__exprs, __env) {
      if (__exprs[0] is! Pair || __exprs[1] is! Expression)
        throw new SchemeException(
            'Argument of invalid type passed to "set-car!".');
      return StandardLibrary.setCar(__exprs[0], __exprs[1]);
    }, 2);
    addPrimitive(__env, const SchemeSymbol("set-cdr!"), (__exprs, __env) {
      if (__exprs[0] is! Pair || __exprs[1] is! Expression)
        throw new SchemeException(
            'Argument of invalid type passed to "set-cdr!".');
      return StandardLibrary.setCdr(__exprs[0], __exprs[1]);
    }, 2);
  }
}
