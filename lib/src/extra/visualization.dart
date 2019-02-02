library cs61a_scheme.extra.visualization;

import 'dart:async';
import 'dart:collection' show LinkedHashMap;

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'diagramming.dart';

class Button extends Widget {
  void Function() click;
  Widget inside;
  Button(this.inside, this.click);
  Button.forEvent(
      this.inside, SchemeSymbol id, List<Expression> data, Frame env) {
    click = () {
      env.interpreter.triggerEvent(id, data, env);
    };
  }
}

class Visualization extends Widget {
  Frame env;
  List<Expression> code;
  List<Diagram> diagrams = [];
  Map<Frame, Value> frameReturnValues = Map.identity();
  int current = 0;

  List<Widget> buttonRow;
  Value result;

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
    for (var expr in code) {
      schemeEval(expr, env);
    }
    _makeVisualizeStep([], env);
    env.interpreter.tailCallOptimized = oldStatus;

    inter.stopListening(const SchemeSymbol('define'), _makeVisualizeStep);
    inter.stopListening(const SchemeSymbol('set!'), _makeVisualizeStep);
    inter.stopListening(
        const SchemeSymbol('pair-mutation'), _makeVisualizeStep);
    inter.stopListening(const SchemeSymbol('new-frame'), _makeVisualizeStep);
    inter.stopListening(const SchemeSymbol('return'), _makeVisualizeReturnStep);

    _init();
  }

  Diagram get currentDiagram => diagrams[current];

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
      buttonRow[2] = TextWidget("${current + 1}/${diagrams.length}");
      update();
    }

    Button first = Button(TextWidget("<<"), () => goto(0));
    Button prev = Button(TextWidget("<"), () => goto(current - 1));
    TextWidget status = TextWidget("${current + 1}/${diagrams.length}");
    Button next = Button(TextWidget(">"), () => goto(current + 1));
    Button last = Button(TextWidget(">>"), () => goto(-1));
    Button animate = Button(TextWidget("Animate"), () async {
      if (animating) {
        animating = false;
        return;
      }
      animating = true;
      await Future.delayed(Duration(seconds: 1));
      while (animating && current < diagrams.length - 1) {
        goto(current + 1, true);
        await Future.delayed(Duration(seconds: 1));
      }
    });
    buttonRow = [first, prev, status, next, last, animate];
  }

  void _addFrames(Frame myEnv, [Expression returnValue]) {
    if (myEnv.tag == '#imported') return;
    if (frameReturnValues.containsKey(myEnv)) {
      frameReturnValues[myEnv] = returnValue;
      return;
    }
    frameReturnValues[myEnv] = returnValue;
    for (SchemeSymbol binding in myEnv.bindings.keys) {
      Value value = myEnv.bindings[binding];
      if (value is LambdaProcedure) {
        _addFrames(value.env);
      }
    }
    if (myEnv.parent != null) _addFrames(myEnv.parent);
  }

  void _addDiagram(Frame active) {
    var ordered = LinkedHashMap.identity();
    for (var frame in frameReturnValues.keys.toList()
      ..sort((a, b) => a.id - b.id)) {
      ordered[frame] = frameReturnValues[frame];
    }
    diagrams.add(Diagram.allFrames(ordered, active));
  }

  Undefined _makeVisualizeStep(List<Value> exprs, Frame env) {
    _addFrames(env);
    _addDiagram(env);
    return undefined;
  }

  Undefined _makeVisualizeReturnStep(List<Value> exprs, Frame env) {
    if (exprs.length != 1) {
      throw SchemeException(
          "Invalid event $exprs trigged during visualization");
    }
    Value returnValue = exprs[0];
    _addFrames(env, returnValue);
    _addDiagram(env);
    return undefined;
  }
}
