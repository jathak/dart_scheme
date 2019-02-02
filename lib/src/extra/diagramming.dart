library cs61a_scheme.extra.diagramming;

import 'dart:collection' show LinkedHashMap;

import 'package:cs61a_scheme/cs61a_scheme.dart';

class Arrow extends Value {
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
  FrameElement(Frame frame, Diagram diagram, [Value returnValue]) {
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
  Diagram(Object obj) {
    if (obj is Frame) {
      drawEnvironment(obj);
      frames.last.active = true;
    } else if (obj is Value) {
      rows[0].elements.insert(0, _build(obj));
    } else {
      throw SchemeException('Cannot diagram $obj');
    }
    _finish();
  }

  Diagram.allFrames(LinkedHashMap<Frame, Value> frameRets, Frame active) {
    for (Frame frame in frameRets.keys) {
      frames.add(FrameElement(frame, this, frameRets[frame])
        ..active = identical(frame, active));
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
    for (Pair<Anchor, Value> item in _incompleteArrows) {
      arrows.add(Arrow(item.first, _known[item.second].anchor(Direction.left)));
    }
    _known.clear();
    _incompleteArrows.clear();
  }

  final Map<Value, Widget> _known = Map.identity();
  final List<Pair<Anchor, Value>> _incompleteArrows = [];

  Anchor _handleExisting(Value value) {
    Anchor anchor = Anchor();
    Widget element = _known[value];
    if (element == null) {
      _incompleteArrows.add(Pair(anchor, value));
    } else {
      arrows.add(Arrow(anchor, element.anchor(Direction.left)));
    }
    return anchor;
  }

  Widget _build(Value value) {
    _known[value] = null;
    Widget element = value.draw(this);
    _known[value] = element;
    return element;
  }

  Widget bindingTo(Value value) {
    if (value.inlineInDiagram) return value.draw(this);
    if (_known.containsKey(value)) return _handleExisting(value);
    if (rows.last.elements.isNotEmpty) rows.add(Row([]));
    int myRow = rows.length - 1;
    Widget element = _build(value);
    rows[myRow].elements.insert(0, element);
    Anchor anchor = Anchor();
    arrows.add(Arrow(anchor, element.anchor(Direction.left)));
    return anchor;
  }

  Widget pointTo(Value value, [int parentRow]) {
    if (value == nil) return Strike();
    if (value.inlineInDiagram) return value.draw(this);
    if (_known.containsKey(value)) return _handleExisting(value);
    if (parentRow != null) rows.add(Row([]));
    int myRow = rows.length - 1;
    Widget element = _build(value);
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
