/// This implements the necessary tracing into the Scheme backend that can be
/// serialized and sent to Semaphore. Semaphore depends on this library, so it
/// will be able to use these classes, but it does not depend on the private
/// implementation library, so it can't actually run the traces itself.
///
/// Pyagram should use the same format when serializing traces for Semaphore.
library cs61a_scheme.extra.flag_diagrams;

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'diagramming.dart';

class FlagTrace {
  List<FlagStep> steps = [];
  String code;
  FlagTrace(this.code);
}

class FlagTraceBuilder {
  FlagTrace trace;
  FlagTraceBuilder(List<Expression> code, Frame env) {
    trace = new FlagTrace(code.join('\n'));

    Interpreter inter = env.interpreter;

    inter.listenFor(const SchemeSymbol('define'), _makeStep);
    inter.listenFor(const SchemeSymbol('set!'), _makeStep);
    inter.listenFor(const SchemeSymbol('pair-mutation'), _makeStep);
    inter.listenFor(const SchemeSymbol('new-frame'), _makeStep);
    inter.listenFor(const SchemeSymbol('return'), _makeReturnStep);

    bool oldStatus = env.interpreter.tailCallOptimized;
    env.interpreter.tailCallOptimized = false;
    _makeStep([], env);
    for (Expression expr in code) {
      schemeEval(expr, env);
    }
    _makeStep([], env);
    env.interpreter.tailCallOptimized = oldStatus;

    inter.stopListening(const SchemeSymbol('define'), _makeStep);
    inter.stopListening(const SchemeSymbol('set!'), _makeStep);
    inter.stopListening(const SchemeSymbol('pair-mutation'), _makeStep);
    inter.stopListening(const SchemeSymbol('new-frame'), _makeStep);
    inter.stopListening(const SchemeSymbol('return'), _makeReturnStep);
  }

  void _addFrames(Frame myEnv, [Expression returnValue = null]) {
    if (myEnv.tag == '#imported') return;
    if (frameReturnValues.containsKey(myEnv)) {
      frameReturnValues[myEnv] = returnValue;
      return;
    }
    frameReturnValues[myEnv] = returnValue;
    for (SchemeSymbol binding in myEnv.bindings.keys) {
      Expression value = myEnv.bindings[binding];
      if (value is LambdaProcedure) {
        _addFrames(value.env);
      }
    }
    if (myEnv.parent != null) _addFrames(myEnv.parent);
  }

  void _addDiagram(Frame active) {
    List<Frame> frames = frameReturnValues.keys.toList()..sort((a, b) {
      return a.id - b.id;
    });
    List<Pair<Frame, Expression>> passing = frames.map((frame) {
      return new Pair(frame, frameReturnValues[frame]);
    }).toList();
    diagrams.add(new Diagram.allFrames(passing, active));
  }

  Undefined _makeVisualizeStep(List<Expression> exprs, Frame env) {
    _addFrames(env);
    _addDiagram(env);
    return undefined;
  }

  Undefined _makeVisualizeReturnStep(List<Expression> exprs, Frame env) {
    if (exprs.length != 1) {
      throw new SchemeException("Invalid event $exprs trigged during visualization");
    }
    Expression returnValue = exprs[0];
    _addFrames(env, returnValue);
    _addDiagram(env);
    return undefined;
  }
}

class FlagStep {
  Diagram diagram;
  Flag flag;
  FlagStep(this.diagram, this.flag);
}

class Flag {
  String callExpression;
  List<Flag> operands = [];
  int frameId;
  List<Flag> body = [];
  Flag(this.callExpression, this.frameId);
}
