part of cs61a_scheme.extra.logic_library;

// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: unnecessary_this
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: unnecessary_lambdas
abstract class _$LogicLibraryMixin {
  void fact(List<Expression> exprs);
  void query(List<Expression> exprs, Frame env);
  void queryOne(List<Expression> exprs, Frame env);
  String prolog();
  void importAll(Frame __env) {
    addVariableOperandBuiltin(__env, const SchemeSymbol('fact'),
        (__exprs, __env) {
      this.fact(__exprs);
      return undefined;
    }, 0, maxArgs: -1);
    __env.bindings[const SchemeSymbol('!')] =
        __env.bindings[const SchemeSymbol('fact')];
    __env.hidden[const SchemeSymbol('!')] = true;
    addVariableOperandBuiltin(__env, const SchemeSymbol('query'),
        (__exprs, __env) {
      this.query(__exprs, __env);
      return undefined;
    }, 0, maxArgs: -1);
    __env.bindings[const SchemeSymbol('?')] =
        __env.bindings[const SchemeSymbol('query')];
    __env.hidden[const SchemeSymbol('?')] = true;
    addVariableOperandBuiltin(__env, const SchemeSymbol('query-one'),
        (__exprs, __env) {
      this.queryOne(__exprs, __env);
      return undefined;
    }, 0, maxArgs: -1);
    addBuiltin(__env, const SchemeSymbol('prolog'), (__exprs, __env) {
      return SchemeString(this.prolog());
    }, 0);
  }
}
