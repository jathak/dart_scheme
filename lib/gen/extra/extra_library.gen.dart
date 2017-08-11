part of cs61a_scheme.extra.extra_library;

abstract class _$ExtraLibraryMixin {
  void importAll(Frame __env) {
    addPrimitive(__env, const SchemeSymbol("run-async"), (__exprs, __env) {
      if (__exprs[0] is! Procedure)
        throw new SchemeException(
            'Argument of invalid type passed to "run-async".');
      return ExtraLibrary.runAsync(__exprs[0], __env);
    }, 1);
    addPrimitive(__env, const SchemeSymbol("run-after"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Procedure)
        throw new SchemeException(
            'Argument of invalid type passed to "run-after".');
      return ExtraLibrary.runAfter(__exprs[0], __exprs[1], __env);
    }, 2);
  }
}
