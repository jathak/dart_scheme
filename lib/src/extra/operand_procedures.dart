library cs61a_scheme.extra.operand_procedures;

import 'package:cs61a_scheme/cs61a_scheme.dart';

class OperandBuiltinProcedure extends BuiltinProcedure {
  OperandBuiltinProcedure.fixed(SchemeSymbol name, SchemeBuiltin fn, int args)
      : super.fixed(name, fn, args);
  OperandBuiltinProcedure.variable(
      SchemeSymbol name, SchemeBuiltin fn, int minArgs,
      [int maxArgs = -1])
      : super.variable(name, fn, minArgs, maxArgs);

  @override
  Expression call(PairOrEmpty operands, Frame env) => apply(operands, env);
}

addOperandBuiltin(Frame env, SchemeSymbol name, SchemeBuiltin fn, int args) {
  env.define(name, OperandBuiltinProcedure.fixed(name, fn, args), true);
}

addVariableOperandBuiltin(
    Frame env, SchemeSymbol name, SchemeBuiltin fn, int minArgs,
    [int maxArgs = -1]) {
  var p = OperandBuiltinProcedure.variable(name, fn, minArgs, maxArgs);
  env.define(name, p, true);
}
