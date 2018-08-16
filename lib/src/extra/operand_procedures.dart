library cs61a_scheme.extra.operand_procedures;

import 'package:cs61a_scheme/cs61a_scheme.dart';

class OperandPrimitiveProcedure extends PrimitiveProcedure {
  OperandPrimitiveProcedure.fixed(
      SchemeSymbol name, SchemePrimitive fn, int args)
      : super.fixed(name, fn, args);
  OperandPrimitiveProcedure.variable(
      SchemeSymbol name, SchemePrimitive fn, int minArgs,
      [int maxArgs = -1])
      : super.variable(name, fn, minArgs, maxArgs);

  @override
  Expression call(PairOrEmpty operands, Frame env) => apply(operands, env);
}

addOperandPrimitive(
    Frame env, SchemeSymbol name, SchemePrimitive fn, int args) {
  env.define(name, OperandPrimitiveProcedure.fixed(name, fn, args), true);
}

addVariableOperandPrimitive(
    Frame env, SchemeSymbol name, SchemePrimitive fn, int minArgs,
    [int maxArgs = -1]) {
  var p = OperandPrimitiveProcedure.variable(name, fn, minArgs, maxArgs);
  env.define(name, p, true);
}
