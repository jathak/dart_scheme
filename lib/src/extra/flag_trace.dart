/// This implements the necessary tracing into the Scheme backend that can be
/// serialized and sent to Semaphore. Semaphore depends on this library, so it
/// will be able to use these classes, but it does not depend on the private
/// implementation library, so it can't actually run the traces itself.
///
/// Pyagram should use the same format when serializing traces for Semaphore.
library cs61a_scheme.extra.flag_diagrams;

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'diagramming.dart';

class FlagTrace extends SelfEvaluating implements Serializable<FlagTrace> {
  List<FlagStep> steps = [];
  String code;
  String language;
  FlagTrace(this.code, [this.language = 'scheme']);

  Map serialize() => {
        'type': 'FlagTrace',
        'code': code,
        'language': language,
        'steps': steps.map((s) => s.serialize()).toList()
      };

  FlagTrace deserialize(Map data) {
    var trace = new FlagTrace(data['code'], data['language']);
    trace.steps = data['steps'].map(Serialization.deserialize).toList();
    return trace;
  }
}

class FlagStep extends SelfEvaluating implements Serializable<FlagStep> {
  Diagram diagram;
  List<Flag> flags;
  FlagStep(this.diagram, this.flags);

  Map serialize() => {
        'type': 'FlagStep',
        'diagram': diagram.serialize(),
        'flags': flags.map((f) => f.serialize()).toList()
      };

  FlagStep deserialize(Map data) => new FlagStep(Serialization.deserialize(data['diagram']),
      data['flags'].map(Serialization.deserialize).toList());
}

class Flag extends SelfEvaluating implements Serializable<Flag> {
  String callExpression;
  List<Flag> operands = [];
  int frameId;
  List<Flag> body = [];
  Flag(this.callExpression, this.frameId);

  Map serialize() => {
        'type': 'Flag',
        'callExpression': callExpression,
        'operands': operands.map((f) => f.serialize()).toList(),
        'frameId': frameId,
        'body': body.map((f) => f.serialize()).toList()
      };

  Flag deserialize(Map data) {
    var flag = new Flag(data['callExpression'], data['frameId']);
    flag.operands = data['operands'].map(Serialization.deserialize).toList();
    flag.body = data['body'].map(Serialization.deserialize).toList();
    return flag;
  }

  Flag clone() => new Flag(callExpression, frameId)
    ..operands = operands.map((f) => f.clone()).toList()
    ..body = body.map((f) => f.clone()).toList();
}

class FlagTraceBuilder {
  FlagTrace trace;
  Map<Frame, Expression> _frameReturnValues = new Map.identity();
  List<Flag> _sourceFlags = [];
  // Boolean should true if adding operands, false if adding to body.
  List<Pair<Flag, Boolean>> _flagStack = [];
  String _potentialCallExpr = null;

  FlagTraceBuilder(Expression code, Frame env) {
    Interpreter inter = env.interpreter;

    trace = new FlagTrace('$code');

    inter.listenFor(const SchemeSymbol('define'), _step);
    inter.listenFor(const SchemeSymbol('set!'), _step);
    inter.listenFor(const SchemeSymbol('pair-mutation'), _step);
    inter.listenFor(const SchemeSymbol('new-frame'), _frameStep);
    inter.listenFor(const SchemeSymbol('pre-user-call'), _userCall);
    inter.listenFor(const SchemeSymbol('call-expression'), _callExpr);
    inter.listenFor(const SchemeSymbol('return'), _returnStep);

    bool oldStatus = env.interpreter.tailCallOptimized;
    env.interpreter.tailCallOptimized = false;
    _step([], env);
    schemeEval(code, env);
    _step([], env);
    env.interpreter.tailCallOptimized = oldStatus;

    inter.stopListening(const SchemeSymbol('define'), _step);
    inter.stopListening(const SchemeSymbol('set!'), _step);
    inter.stopListening(const SchemeSymbol('pair-mutation'), _step);
    inter.stopListening(const SchemeSymbol('new-frame'), _frameStep);
    inter.stopListening(const SchemeSymbol('pre-user-call'), _userCall);
    inter.stopListening(const SchemeSymbol('call-expression'), _callExpr);
    inter.stopListening(const SchemeSymbol('return'), _returnStep);
  }

  Undefined _step(List<Expression> exprs, Frame env) {
    _addFrames(env);
    Diagram diagram = _makeDiagram(env);
    trace.steps.add(new FlagStep(diagram, _cloneSource()));
    return undefined;
  }

  Undefined _returnStep(List<Expression> exprs, Frame env) {
    if (exprs.length != 1) {
      throw new SchemeException("Invalid event $exprs trigged during tracing");
    } else if (_flagStack.isEmpty) {
      throw new SchemeException("Frame returned without flag on stack");
    }
    _flagStack.removeLast();
    Expression returnValue = exprs[0];
    _addFrames(env, returnValue);
    Diagram diagram = _makeDiagram(env);
    trace.steps.add(new FlagStep(diagram, _cloneSource()));
    return undefined;
  }

  Undefined _frameStep(List<Expression> exprs, Frame env) {
    if (_flagStack.isEmpty) {
      throw new SchemeException("New frame created without flag on stack");
    }
    _flagStack.last.first.frameId = env.id;
    _flagStack.last.second = schemeFalse;
    _addFrames(env);
    Diagram diagram = _makeDiagram(env);
    trace.steps.add(new FlagStep(diagram, _cloneSource()));
    return undefined;
  }

  Undefined _callExpr(List<Expression> exprs, Frame env) {
    if (exprs.length != 1) {
      throw new SchemeException("Invalid event $exprs trigged during tracing");
    }
    _potentialCallExpr = exprs[0].toString();
    return undefined;
  }

  Undefined _userCall(List<Expression> exprs, Frame env) {
    Flag flag = new Flag(_potentialCallExpr, null);
    if (_flagStack.isEmpty) {
      _sourceFlags.add(flag);
    } else {
      Flag container = _flagStack.last.first;
      bool inOperands = _flagStack.last.second.isTruthy;
      if (inOperands) {
        container.operands.add(flag);
      } else {
        container.body.add(flag);
      }
    }
    _flagStack.add(new Pair(flag, schemeTrue));
    return undefined;
  }

  List<Flag> _cloneSource() => _sourceFlags.map((f) => f.clone()).toList();

  void _addFrames(Frame myEnv, [Expression returnValue = null]) {
    if (myEnv.tag == '#imported') return;
    if (_frameReturnValues.containsKey(myEnv)) {
      _frameReturnValues[myEnv] = returnValue;
      return;
    }
    _frameReturnValues[myEnv] = returnValue;
    for (SchemeSymbol binding in myEnv.bindings.keys) {
      Expression value = myEnv.bindings[binding];
      if (value is LambdaProcedure) {
        _addFrames(value.env);
      }
    }
    if (myEnv.parent != null) _addFrames(myEnv.parent);
  }

  Diagram _makeDiagram(Frame active) {
    List<Frame> frames = _frameReturnValues.keys.toList()..sort((a, b) => a.id - b.id);
    List<Pair<Frame, Expression>> passing = frames.map((frame) {
      return new Pair(frame, _frameReturnValues[frame]);
    }).toList();
    return new Diagram.allFrames(passing, active);
  }
}
