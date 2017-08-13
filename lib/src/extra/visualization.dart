library cs61a_scheme.extra.visualization;

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'diagramming.dart';

void Function() visExit = () => null;
void Function(int) visGoto = (int x) => null;
visFirst() => visGoto(1);
void Function() visLast = () => null;
void Function() visNext = () => null;
void Function() visPrev = () => null;

Expression visualize(Expression code, Frame env) {
  Interpreter inter = env.interpreter;
  List<Diagram> diagrams = [];

  Map<Frame, Expression> frameReturnValues = {};
  addFrames(Frame myEnv, [Expression returnValue = null]) {
    if (!frameReturnValues.containsKey(myEnv)) {
      frameReturnValues[myEnv] = returnValue;
    } else if (frameReturnValues[myEnv] == null) {
      frameReturnValues[myEnv] = returnValue;
    }
    if (myEnv.parent != null) addFrames(myEnv.parent);
  }
  addDiagram(Frame active) {
    List<Frame> frames = frameReturnValues.keys.toList()..sort((a, b) {
      return a.id - b.id;
    });
    List<Pair<Frame, Expression>> passing = frames.map((frame) {
      return new Pair(frame, frameReturnValues[frame]);
    }).toList();
    diagrams.add(new Diagram.allFrames(passing, active));
  }
  void makeVisualizeStep(Expression expr) {
    if (expr is! Pair || expr.pair.second is! Frame) {
      throw new SchemeException("Invalid event $expr trigged during visualization");
    }
    Frame myEnv = expr.pair.second as Frame;
    addFrames(myEnv);
    addDiagram(myEnv);
  };
  void makeVisualizeReturnStep(Expression expr) {
    if (expr is! Pair || expr.pair.second is! Frame) {
      throw new SchemeException("Invalid event $expr trigged during visualization");
    }
    Expression returnValue = expr.pair.first;
    Frame myEnv = expr.pair.second as Frame;
    addFrames(myEnv, returnValue);
    addDiagram(myEnv);
  }
  inter.blockOnEvent(const SchemeSymbol('define'), makeVisualizeStep);
  inter.blockOnEvent(const SchemeSymbol('set!'), makeVisualizeStep);
  inter.blockOnEvent(const SchemeSymbol('pair-mutation'), makeVisualizeStep);
  inter.blockOnEvent(const SchemeSymbol('new-frame'), makeVisualizeStep);
  inter.blockOnEvent(const SchemeSymbol('return'), makeVisualizeReturnStep);
  
  bool oldStatus = env.interpreter.tailCallOptimized;
  env.interpreter.tailCallOptimized = false;
  makeVisualizeStep(new Pair(nil, env));
  Expression result = schemeEval(code, env);
  makeVisualizeStep(new Pair(result, env));
  env.interpreter.tailCallOptimized = oldStatus;
  
  int current = 0;
  drawCurrent() {
    env.interpreter.renderer(diagrams[current]);
    logMessage("Step ${current+1}/${diagrams.length}.", env);
  }
  visGoto = (int frame) {
    current = frame - 1;
    if (current < 0) current = 0;
    if (current >= diagrams.length) current = diagrams.length - 1;
    drawCurrent();
  };
  visExit = () {
    visGoto = (int n) => null;
    visExit = () => null;
    diagrams.clear();
    env.interpreter.renderer(new TextElement(""));
  };
  visLast = () => visGoto(diagrams.length);
  visNext = () => visGoto(current + 2);
  visPrev = () => visGoto(current);
  drawCurrent();
  logMessage("(vis-next), (vis-prev), (vis-first), (vis-last), (vis-goto n) "
             "(vis-exit)", env);
  return result;
} 
