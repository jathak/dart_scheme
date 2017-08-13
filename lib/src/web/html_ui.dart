library cs61a_scheme.web.html_ui;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

class HtmlRenderer {
  Element container;
  JsObject jsPlumb;
  Iterable connections;
  
  HtmlRenderer(this.container, this.jsPlumb);
  
  void render(UIElement element) {
    connections = null;
    trueAnchorIds = {};
    anchorDirections = {};
    Element el = convert(element);
    container.text = "";
    container.append(el);
    refreshConnections();
  }
  
  void refreshConnections() {
    if (connections == null) return;
    var base = new JsObject.jsify({
      'endpoint': ['Dot', {'radius': 3}],
      'connector': 'StateMachine',
      'overlays': [['Arrow',
        {'length': 10, 'width': 7, 'foldback': 0.55, 'location': 1}]],
      'paintStyle': {'strokeStyle': '#bebebe', 'lineWidth': 1},
      'endpointStyles': [
        {'fillStyle': '#bebebe'}, {'fillStyle': 'transparent'},
      ]
    });
    jsPlumb?.callMethod('reset');
    jsPlumb?.callMethod('setContainer', ['diagramTable']);
    jsPlumb?.callMethod('setDraggable', [false]);
    for (var c in connections) {
      jsPlumb?.callMethod('connect', [new JsObject.jsify(c), base]);
    }
    jsPlumb?.callMethod('repaintEverything');
    new Future.delayed(const Duration(milliseconds: 50), () {
      jsPlumb?.callMethod('repaintEverything');
    });
  }
  
  Map<int, String> trueAnchorIds = {};
  Map<int, Direction> anchorDirections = {};
  
  Element convert(UIElement element) {
    Element node = _convertRaw(element);
    if (element.spacer) node.style.visibility = 'hidden';
    for (Direction dir in element.anchoredDirections) {
      int id = element.anchor(dir).id;
      anchorDirections[id] = dir;
      node.id = 'anchoredElement$id';
      trueAnchorIds[id] = node.id;
    }
    return node;
  }

  Element _convertRaw(UIElement element) {
    if (element is Diagram) return convertDiagram(element);
    if (element is FrameElement) return convertFrameElement(element);
    if (element is Row) return convertRow(element);
    if (element is TextElement) return convertTextElement(element);
    if (element is Block) return convertBlock(element);
    if (element is BlockGrid) return convertBlockGrid(element);
    if (element is Anchor) return convertAnchor(element);
    if (element is Binding) return convertBinding(element);
    throw new SchemeException("Cannot render $element");
  }

  Element convertDiagram(Diagram diagram) {
    DivElement wrapper = new DivElement();
    wrapper.appendHtml("""
      <table id='diagramTable' class='diagramTable'>
        <tr class='diagramInnerWrapper'>
          <td class='diagramFrames'></td>
          <td class='diagramObjects'></td>
        </tr>
      </table>""");
    Element frames = wrapper.querySelector(".diagramFrames");
    Element objects = wrapper.querySelector(".diagramObjects");
    for (FrameElement frame in diagram.frames) {
      frames.append(convert(frame));
    }
    for (UIElement row in diagram.rows) {
      objects.append(convert(row));
    }
    connections = diagram.arrows.map(makeConnection);
    return wrapper;
  }

  Element convertFrameElement(FrameElement frame) {
    DivElement div = new DivElement()..className = 'frame';
    div.id = 'frame${frame.id}';
    if (frame.active) div.classes.add('current');
    DivElement header = new DivElement();
    String name = frame.id == 0 ? 'Global frame' : 'f${frame.id}';
    header.innerHtml = '<b>$name</b>&nbsp;${frame.tag ?? ''}';
    div.append(header);
    for (Binding binding in frame.bindings) {
      div.append(convert(binding));
    }
    return div;
  }
  
  Element convertBinding(Binding binding) {
    DivElement div = new DivElement()..className = 'binding';
    div.innerHtml = '${binding.symbol}&nbsp;';
    SpanElement span = new SpanElement()..className = 'alignRight';
    div.append(span);
    span.append(convert(binding.value));
    return div;
  }
  
  Element convertRow(Row row) {
    DivElement div = new DivElement()..className = 'diagramRow';
    for (UIElement element in row.elements) {
      div.append(convert(element));
    }
    return div;
  }
  
  Element convertTextElement(TextElement text) {
    return new SpanElement()..text = text.text;
  }
  
  Element convertBlock(Block block) {
    DivElement div = new DivElement();
    div.className = 'block block_' + block.type.id;
    div.append(convert(block.inside));
    return div;
  }
  
  Element convertBlockGrid(BlockGrid blockGrid) {
    if (blockGrid.rowCount != 1) {
      throw new SchemeException("Multiple BlockGrid rows not yet implemented");
    }
    DivElement div = new DivElement();
    div.className = 'blockGrid';
    for (Block block in blockGrid.rowAt(0)) {
      div.append(convert(block));
    }
    return div;
  }
  
  Element convertAnchor(Anchor anchor) {
    return new SpanElement()..id = 'anchor${anchor.id}'..innerHtml = '&nbsp;';
  }
  
  List<num> _anchorForDirection(Direction dir) {
    if (dir == Direction.left) return [0, 0.5, 1, 0, 0, 0];
    if (dir == Direction.topLeft) return [0, 0, 1, 0, 0, 0];
    if (dir == Direction.top) return [0.5, 0, 1, 0, 0, 0];
    if (dir == Direction.bottomLeft) return [0, 1, 1, 0, 0, 0];
    if (dir == Direction.bottom) return [0.5, 1, 1, 0, 0, 0];
    if (dir == Direction.right) return [1, 0.5, 1, 0, 0, 0];
    if (dir == Direction.topRight) return [1, 0, 1, 0, 0, 0];
    if (dir == Direction.bottomRight) return [1, 1, 1, 0, 0, 0];
    return null;
  }
  
  makeConnection(Arrow arrow) {
    String startId = 'anchor${arrow.start.id}';
    String endId = 'anchor${arrow.end.id}';
    var leftAnchor = [0.5, 0.5, 1, 0, 0, 0];
    var rightAnchor = [0.5, 0.5, 1, 0, 0, 0];
    if (trueAnchorIds.containsKey(arrow.start.id)) {
      startId = trueAnchorIds[arrow.start.id];
      leftAnchor = _anchorForDirection(anchorDirections[arrow.start.id]);
    }
    if (trueAnchorIds.containsKey(arrow.end.id)) {
      endId = trueAnchorIds[arrow.end.id];
      rightAnchor = _anchorForDirection(anchorDirections[arrow.end.id]);
    }
    var connection = {
      'source': startId,
      'target': endId,
      'anchors': [leftAnchor, rightAnchor],
    };
    return connection;
  }
}
