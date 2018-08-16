library cs61a_scheme.extra.diagramming;

import 'package:cs61a_scheme/cs61a_scheme.dart';

class Arrow extends SelfEvaluating {
  final Anchor start, end;
  Arrow(this.start, this.end);
  toString() => "#Arrow($start->$end)";
}

class Binding extends Widget {
  final SchemeSymbol symbol;
  final Widget value;
  final bool isReturn;
  Binding(this.symbol, this.value, [this.isReturn = false]);
}

class Row extends Widget {
  final List<Widget> elements;
  Row(this.elements);
  toString() => elements.toString();
}

class FrameElement extends Widget {
  int id;
  String tag;
  int parentId;
  bool fromMacro;
  bool active = false;
  List<Binding> bindings = [];
  FrameElement(Frame frame, Diagram diagram, [Expression returnValue]) {
    id = frame.id;
    parentId = frame.parent?.id;
    fromMacro = frame.fromMacro;
    tag = frame.tag;
    for (SchemeSymbol key in frame.bindings.keys) {
      if (frame.hidden[key]) continue;
      bindings.add(Binding(key, diagram.bindingTo(frame.bindings[key])));
    }
    if (returnValue != null) {
      var symb = const SchemeSymbol('return');
      bindings.add(Binding(symb, diagram.bindingTo(returnValue), true));
    }
  }
}

class Diagram extends DiagramInterface {
  List<FrameElement> frames = [];
  List<Row> rows = [Row([])];
  List<Arrow> arrows = [];
  Diagram(Expression expression) {
    if (expression is Frame) {
      drawEnvironment(expression);
      frames.last.active = true;
    } else {
      rows[0].elements.insert(0, _build(expression));
    }
    _finish();
  }

  Diagram.allFrames(List<Pair<Frame, Expression>> framePairs, Frame active) {
    for (Pair<Frame, Expression> framePair in framePairs) {
      frames.add(FrameElement(framePair.first, this, framePair.second)
        ..active = identical(framePair.first, active));
    }
    _finish();
  }

  int get currentRow => rows.length - 1;
  final Map<int, int> _rowHowMany = {};
  final Map<int, int> _rowParent = {};

  _finish() {
    for (int row in _rowHowMany.keys.toList()..sort()) {
      int missing = rows[_rowParent[row]].elements.length - _rowHowMany[row];
      for (var el in rows[_rowParent[row]].elements.take(missing)) {
        if (el is BlockGrid) {
          rows[row].elements.insert(0, el.spacer ? el : el.toSpacer());
        }
      }
    }
    for (Pair<Anchor, Expression> item in _incompleteArrows) {
      arrows.add(Arrow(item.first, _known[item.second].anchor(Direction.left)));
    }
    _known.clear();
    _incompleteArrows.clear();
  }

  final Map<Expression, Widget> _known = Map.identity();
  final List<Pair<Anchor, Expression>> _incompleteArrows = [];

  Anchor _handleExisting(Expression expression) {
    Anchor anchor = Anchor();
    Widget element = _known[expression];
    if (element == null) {
      _incompleteArrows.add(Pair(anchor, expression));
    } else {
      arrows.add(Arrow(anchor, element.anchor(Direction.left)));
    }
    return anchor;
  }

  Widget _build(Expression expression) {
    _known[expression] = null;
    Widget element = expression.draw(this);
    _known[expression] = element;
    return element;
  }

  Widget bindingTo(Expression expression) {
    if (expression.inlineInDiagram) return expression.draw(this);
    if (_known.containsKey(expression)) return _handleExisting(expression);
    if (rows.last.elements.isNotEmpty) rows.add(Row([]));
    int myRow = rows.length - 1;
    Widget element = _build(expression);
    rows[myRow].elements.insert(0, element);
    Anchor anchor = Anchor();
    arrows.add(Arrow(anchor, element.anchor(Direction.left)));
    return anchor;
  }

  Widget pointTo(Expression expression, [int parentRow]) {
    if (expression == nil) return Strike();
    if (expression.inlineInDiagram) return expression.draw(this);
    if (_known.containsKey(expression)) return _handleExisting(expression);
    if (parentRow != null) rows.add(Row([]));
    int myRow = rows.length - 1;
    Widget element = _build(expression);
    rows[myRow].elements.insert(0, element);
    if (parentRow != null) {
      _rowParent[myRow] = parentRow;
      _rowHowMany[myRow] = rows[parentRow].elements.length + 1;
    }
    Anchor anchor = Anchor();
    Direction dir = parentRow != null ? Direction.top : Direction.left;
    Widget anchoring = element;
    if (element is BlockGrid) anchoring = element.rowAt(0).first;
    arrows.add(Arrow(anchor, anchoring.anchor(dir)));
    return anchor;
  }

  drawEnvironment(Frame env) {
    if (env.parent != null) drawEnvironment(env.parent);
    frames.add(FrameElement(env, this));
  }
}
