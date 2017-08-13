library cs61a_scheme.extra.diagramming;

import 'package:cs61a_scheme/cs61a_scheme.dart';

class Arrow extends UIElement {
  final Anchor start, end;
  Arrow(this.start, this.end);
  toString() => "#Arrow($start->$end)";
}

class Binding extends UIElement {
  final SchemeSymbol symbol;
  final UIElement value;
  Binding(this.symbol, this.value);
}

class Row extends UIElement {
  final List<UIElement> elements;
  Row(this.elements);
  toString() => elements.toString();
}

class FrameElement extends UIElement {
  int id;
  String tag;
  bool active = false;
  List<Binding> bindings = [];
  FrameElement(Frame frame, Diagram diagram, [Expression returnValue]) {
    id = frame.id;
    tag = frame.tag;
    for (SchemeSymbol key in frame.bindings.keys) {
      if (frame.hidden[key]) continue;
      bindings.add(new Binding(key, diagram.bindingTo(frame.bindings[key])));
    }
    if (returnValue != null) {
      var symb = const SchemeSymbol('return');
      bindings.add(new Binding(symb, diagram.bindingTo(returnValue)));
    }
  }
}

class Diagram extends DiagramInterface {
  List<FrameElement> frames = [];
  List<Row> rows = [new Row([])];
  List<Arrow> arrows = [];
  Diagram(Expression expression) {
    if (expression is Frame) {
      drawEnvironment(expression);
      frames.last.active = true;
    } else {
      rows[0].elements.insert(0, expression.draw(this));
    }
    _finish();
  }
  
  _finish() {
    for (int row in _rowHowMany.keys.toList()..sort()) {
      int missing = rows[row - 1].elements.length - _rowHowMany[row];
      rows[row - 1].elements.take(missing).forEach((e) {
        if (e is BlockGrid) {
          rows[row].elements.insert(0, e.spacer ? e : e.toSpacer());
        }
      });
    }
    _known.clear();
  }
  
  Map<Expression, UIElement> _known = new Map.identity();
  
  Diagram.allFrames(List<Pair<Frame, Expression>> framePairs, Frame active) {
    for (Pair<Frame, Expression> framePair in framePairs) {
      frames.add(new FrameElement(framePair.first, this, framePair.second)
        ..active = identical(framePair.first, active));
    }
    _finish();
  }
  
  Map<int, int> _rowHowMany = {};
  
  UIElement bindingTo(Expression expression) {
    if (expression.inlineUI) return expression.draw(this);
    if (_known.containsKey(expression)) {
      Anchor anchor = new Anchor();
      arrows.add(new Arrow(anchor, _known[expression].anchor(Direction.left)));
      return anchor;
    }
    if (rows.last.elements.isNotEmpty) rows.add(new Row([]));
    int myRow = rows.length - 1;
    UIElement element = expression.draw(this);
    _known[expression] = element;
    rows[myRow].elements.insert(0, element);
    Anchor anchor = new Anchor();
    arrows.add(new Arrow(anchor, element.anchor(Direction.left)));
    return anchor;
  }
  
  UIElement pointTo(Expression expression, [bool newRow = false]) {
    if (expression.inlineUI) return expression.draw(this);
    if (_known.containsKey(expression)) {
      Anchor anchor = new Anchor();
      arrows.add(new Arrow(anchor, _known[expression].anchor(Direction.left)));
      return anchor;
    }
    if (newRow) rows.add(new Row([]));
    int myRow = rows.length - 1;
    UIElement element = expression.draw(this);
    _known[expression] = element;
    rows[myRow].elements.insert(0, element);
    if (newRow) {
      _rowHowMany[myRow] = rows[myRow - 1].elements.length + 1;
    }
    Anchor anchor = new Anchor();
    Direction dir = newRow ? Direction.top : Direction.left;
    UIElement anchoring = element;
    if (element is BlockGrid) anchoring = element.rowAt(0).first;
    arrows.add(new Arrow(anchor, anchoring.anchor(dir)));
    return anchor;
  }
  
  drawEnvironment(Frame env) {
    if (env.parent != null) drawEnvironment(env.parent);
    frames.add(new FrameElement(env, this));
  }
}
