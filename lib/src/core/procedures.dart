library cs61a_scheme.core.procedures;

import 'expressions.dart';

abstract class Procedure extends SelfEvaluating {
  SchemeSymbol get name => null;
  const Procedure();
  Expression call(PairOrEmpty operands, Frame env) {
    return env.interpreter.implementation.procedureCall(this, operands, env);
  }
  Expression apply(PairOrEmpty arguments, Frame env);
  toString() => '#[$name]';
  toJS() => Procedure.jsProcedure(this);
  static dynamic Function(Procedure) jsProcedure = (p) {
    throw new UnimplementedError("JS interop must be enabled for Procedure.toJS() to work");
  };
}

typedef Expression SchemePrimitive(List<Expression> args, Frame env);

class PrimitiveProcedure extends Procedure {
  final SchemeSymbol name;
  final SchemePrimitive fn;
  final bool fixedArgs;
  final int minArgs, maxArgs;
  PrimitiveProcedure.fixed(this.name, this.fn, int args)
    : fixedArgs = true, minArgs = args, maxArgs = args;
  PrimitiveProcedure.variable(this.name, this.fn, this.minArgs, [this.maxArgs=-1])
    : fixedArgs = false;
  
  Expression apply(PairOrEmpty arguments, Frame env) {
    return env.interpreter.implementation.primitiveApply(this, arguments, env);
  }
}

abstract class UserDefinedProcedure extends Procedure {
  PairOrEmpty get body;
  
  Frame makeCallFrame(PairOrEmpty arguments, Frame env);
  
  Expression apply(PairOrEmpty arguments, Frame env) {
    Frame frame = makeCallFrame(arguments, env);
    return env.interpreter.implementation.evalAll(body, frame);
  }
}

class LambdaProcedure extends UserDefinedProcedure {
  SchemeSymbol name = const SchemeSymbol('λ');
  PairOrEmpty formals, body;
  Frame env;
  
  LambdaProcedure(this.formals, this.body, this.env);
  
  Frame makeCallFrame(PairOrEmpty arguments, Frame env) {
    return env.interpreter.implementation.makeLambdaFrame(this, arguments, env);
  }
  
  toString() => new Pair(new SchemeSymbol('lambda'), new Pair(formals, body)).toString();
}

class MacroProcedure extends LambdaProcedure {
  MacroProcedure(formals, body, env) : super(formals, body, env);
  
  @override
  Expression call(PairOrEmpty operands, Frame env) {
    return env.interpreter.implementation.macroCall(this, operands, env);
  }
  
  toString() => new Pair(new SchemeSymbol('#macro'), new Pair(formals, body)).toString();
}

class MuProcedure extends UserDefinedProcedure {
  SchemeSymbol name = const SchemeSymbol('μ');
  PairOrEmpty formals, body;
  
  MuProcedure(this.formals, this.body);
  
  Frame makeCallFrame(PairOrEmpty arguments, Frame env) {
    return env.interpreter.implementation.makeMuFrame(this, arguments, env);
  }
  
  toString() => new Pair(new SchemeSymbol('mu'), new Pair(formals, body)).toString();
}

class Continuation extends Procedure {
  static int counter = 0;
  int id;
  Expression result;
  Continuation() {
    id = counter++;
  }
  
  Expression apply(PairOrEmpty args, Frame env) {
    return env.interpreter.implementation.continuationApply(this, args, env);
  }
  
  toString() => "#[continuation$id]";
}
