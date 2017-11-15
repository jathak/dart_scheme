library cs61a_scheme.core.procedures;

import 'expressions.dart';
import 'logging.dart';
import 'serialization.dart';

abstract class Procedure extends SelfEvaluating with Stubber {
  SchemeSymbol get name;
  Procedure();
  Expression call(PairOrEmpty operands, Frame env) {
    return env.interpreter.implementation.procedureCall(this, operands, env);
  }
  Expression apply(PairOrEmpty arguments, Frame env);
  @override
  toString() => '#[$name]';
  toJS() => Procedure.jsProcedure(this);
  static dynamic Function(Procedure) jsProcedure = (p) {
    throw new SchemeException("JS interop must be enabled for Procedure.toJS() to work");
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
  Expression get formals;
  PairOrEmpty get body;

  Frame makeCallFrame(PairOrEmpty arguments, Frame env);

  Expression apply(PairOrEmpty arguments, Frame env) {
    Frame frame = makeCallFrame(arguments, env);
    if (name != null) frame.tag = name.toString();
    env.interpreter.triggerEvent(const SchemeSymbol('new-frame'), [], frame);
    var result = env.interpreter.implementation.evalAll(body, frame);
    env.interpreter.triggerEvent(const SchemeSymbol('return'), [result], frame);
    return result;
  }

  @override
  String get stubText => new Pair(name, formals).toString();
}

class LambdaProcedure extends UserDefinedProcedure {
  SchemeSymbol name;
  final Expression formals;
  final PairOrEmpty body;
  final Frame env;

  LambdaProcedure(this.formals, this.body, this.env,
                  [this.name = const SchemeSymbol('λ')]);

  Frame makeCallFrame(PairOrEmpty arguments, Frame _) {
    return env.interpreter.implementation.makeLambdaFrame(this, arguments, env);
  }

  @override
  toString() => new Pair(new SchemeSymbol('lambda'), new Pair(formals, body)).toString();

  @override
  String get stubText {
    var parent = env.id == 0 ? '' : ' [parent=f${env.id}]';
    return "${new Pair(name, formals)}$parent";
  }
}

class MacroProcedure extends LambdaProcedure {
  MacroProcedure(formals, body, env) : super(formals, body, env);

  @override
  Expression call(PairOrEmpty operands, Frame env) {
    return env.interpreter.implementation.macroCall(this, operands, env);
  }

  toString() => new Pair(new SchemeSymbol('#macro'), new Pair(formals, body)).toString();

  @override
  String get stubText => super.stubText + ' (macro)';
}

class MuProcedure extends UserDefinedProcedure {
  SchemeSymbol name;
  final PairOrEmpty formals, body;

  MuProcedure(this.formals, this.body, [this.name = const SchemeSymbol('μ')]);

  Frame makeCallFrame(PairOrEmpty arguments, Frame env) {
    return env.interpreter.implementation.makeMuFrame(this, arguments, env);
  }

  toString() => new Pair(new SchemeSymbol('mu'), new Pair(formals, body)).toString();

  @override
  String get stubText => super.stubText + ' (mu)';
}

class Continuation extends Procedure {
  final SchemeSymbol name = null;
  static int counter = 0;
  final int id;
  Expression result;
  Continuation() : id = counter++;

  Expression apply(PairOrEmpty args, Frame env) {
    return env.interpreter.implementation.continuationApply(this, args, env);
  }

  toString() => "#[continuation$id]";
}
