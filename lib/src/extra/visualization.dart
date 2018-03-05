library cs61a_scheme.extra.visualization;

import 'dart:async';

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'diagramming.dart';
import 'flag_trace.dart';

class Button extends UIElement {
  void Function() click;
  UIElement inside;
  Button(this.inside, this.click);
  Button.forEvent(this.inside, SchemeSymbol id, List<Expression> data, Frame env) {
    click = () {
      env.interpreter.triggerEvent(id, data, env);
    };
  }
  serialize() => throw new UnsupportedError('Buttons cannot be serialized');
  deserialize(data) => null;
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

    inter.listenFor(const SchemeSymbol('define'), _makeVisualizeStep);
    inter.listenFor(const SchemeSymbol('set!'), _makeVisualizeStep);
    inter.listenFor(const SchemeSymbol('pair-mutation'), _makeVisualizeStep);
    inter.listenFor(const SchemeSymbol('new-frame'), _makeVisualizeStep);
    inter.listenFor(const SchemeSymbol('return'), _makeVisualizeReturnStep);

    bool oldStatus = env.interpreter.tailCallOptimized;
    env.interpreter.tailCallOptimized = false;
    _makeVisualizeStep([], env);
    schemeEval(code, env);
    _makeVisualizeStep([], env);
    env.interpreter.tailCallOptimized = oldStatus;

    inter.stopListening(const SchemeSymbol('define'), _makeVisualizeStep);
    inter.stopListening(const SchemeSymbol('set!'), _makeVisualizeStep);
    inter.stopListening(const SchemeSymbol('pair-mutation'), _makeVisualizeStep);
    inter.stopListening(const SchemeSymbol('new-frame'), _makeVisualizeStep);
    inter.stopListening(const SchemeSymbol('return'), _makeVisualizeReturnStep);

    _init();
  }

  Visualization.fromTrace(FlagTrace trace) {
    diagrams = trace.steps.map((step) => step.diagram).toList();
    _init();
  }

  _init() {
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
    List<Frame> frames = frameReturnValues.keys.toList()..sort((a, b) => a.id - b.id);
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

  serialize() => throw new UnsupportedError('Visualizations cannot be serialized');
  deserialize(data) => null;
}
