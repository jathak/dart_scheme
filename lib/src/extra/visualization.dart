library cs61a_scheme.extra.visualization;

import 'dart:async';

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'diagramming.dart';

class Button extends UIElement {
  void Function() click;
  UIElement inside;
  Button(this.inside, this.click);
  Button.forEvent(this.inside, SchemeSymbol id, Expression data, Frame env) {
    click = () {
      env.interpreter.triggerEvent(id, data);
    };
  }
}

class Visualization extends UIElement {
  Frame env;
  Expression code;
  List<Diagram> diagrams = [];
  Map<Frame, Expression> frameReturnValues = new Map.identity();
  int current = 0;
  
  Diagram get currentDiagram => diagrams[current];
  List<UIElement> buttonRow;
  Expression result;
  
  Visualization(this.code, this.env) {
    Interpreter inter = env.interpreter;
    
    inter.blockOnEvent(const SchemeSymbol('define'), _makeVisualizeStep);
    inter.blockOnEvent(const SchemeSymbol('set!'), _makeVisualizeStep);
    inter.blockOnEvent(const SchemeSymbol('pair-mutation'), _makeVisualizeStep);
    inter.blockOnEvent(const SchemeSymbol('new-frame'), _makeVisualizeStep);
    inter.blockOnEvent(const SchemeSymbol('return'), _makeVisualizeReturnStep);
    
    bool oldStatus = env.interpreter.tailCallOptimized;
    env.interpreter.tailCallOptimized = false;
    _makeVisualizeStep(new Pair(nil, env));
    Expression result = schemeEval(code, env);
    _makeVisualizeStep(new Pair(result, env));
    env.interpreter.tailCallOptimized = oldStatus;
    
    inter.stopBlockingOnEvent(const SchemeSymbol('define'), _makeVisualizeStep);
    inter.stopBlockingOnEvent(const SchemeSymbol('set!'), _makeVisualizeStep);
    inter.stopBlockingOnEvent(const SchemeSymbol('pair-mutation'), _makeVisualizeStep);
    inter.stopBlockingOnEvent(const SchemeSymbol('new-frame'), _makeVisualizeStep);
    inter.stopBlockingOnEvent(const SchemeSymbol('return'), _makeVisualizeReturnStep);
    bool animating = false;
    goto(int index, [bool keepAnimating = false]) {
      if (!keepAnimating) animating = false;
      if (index < 0) index = diagrams.length - 1;
      if (index >= diagrams.length - 1) {
        index = diagrams.length - 1;
        animating = false;
      }
      current = index;
      buttonRow[2] = new TextElement("${current+1}/${diagrams.length}");
      update();
    }
    Button first = new Button(new TextElement("<<"), () => goto(0));
    Button prev = new Button(new TextElement("<"), () => goto(current - 1));
    TextElement status = new TextElement("${current+1}/${diagrams.length}");
    Button next = new Button(new TextElement(">"), () => goto(current + 1));
    Button last = new Button(new TextElement(">>"), () => goto(-1));
    Button animate = new Button(new TextElement("Animate"), () async {
      if (animating) {
        animating = false;
        return;
      }
      animating = true;
      await new Future.delayed(new Duration(seconds: 1));
      while (animating) {
        goto(current + 1, true);
        await new Future.delayed(new Duration(seconds: 1));
      }
    });
    buttonRow = [first, prev, status, next, last, animate];
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
  
  void _makeVisualizeStep(Expression expr) {
    if (expr is! Pair || expr.pair.second is! Frame) {
      throw new SchemeException("Invalid event $expr trigged during visualization");
    }
    Frame myEnv = expr.pair.second as Frame;
    _addFrames(myEnv);
    _addDiagram(myEnv);
  }
  
  void _makeVisualizeReturnStep(Expression expr) {
    if (expr is! Pair || expr.pair.second is! Frame) {
      throw new SchemeException("Invalid event $expr trigged during visualization");
    }
    Expression returnValue = expr.pair.first;
    Frame myEnv = expr.pair.second as Frame;
    _addFrames(myEnv, returnValue);
    _addDiagram(myEnv);
  }
}
