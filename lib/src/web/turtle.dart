library cs61a_scheme.web_turtle;

import 'dart:html';
import 'dart:math' as Math;

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'theming.dart';

class Turtle {
  CanvasElement element;
  CanvasRenderingContext2D context;
  int _gridWidth = 1000;
  int _gridHeight = 1000;
  int get gridWidth => _gridWidth;
  int get gridHeight => _gridHeight;
  void set gridWidth(width) {
    element.width = width;
    _gridWidth = width;
  }

  void set gridHeight(height) {
    element.height = height;
    _gridHeight = height;
  }

  int _elementWidth = 500;
  int _elementHeight = 500;
  int get elementWidth => _elementWidth;
  int get elementHeight => _elementHeight;
  void set elementWidth(width) {
    _elementWidth = width;
    element.style.width = '${width}px';
  }

  void set elementHeight(height) {
    _elementHeight = height;
    element.style.height = '${height}px';
  }

  num heading = 0;
  num x = 0;
  num y = 0;
  int pixelSize = 1;
  int penSize = 1;
  bool penDown = false;
  bool filling = false;

  Turtle(this.element, Interpreter inter) {
    context = element.context2D;
    context.imageSmoothingEnabled = false;
    backgroundColor = Color.white;
    penColor = Color.black;
    context.lineWidth = 2;
    clear();
    var mouseEvents = {
      const SchemeSymbol('turtle-click'): element.onClick,
      const SchemeSymbol('turtle-mouse-down'): element.onMouseDown,
      const SchemeSymbol('turtle-mouse-enter'): element.onMouseEnter,
      const SchemeSymbol('turtle-mouse-leave'): element.onMouseLeave,
      const SchemeSymbol('turtle-mouse-move'): element.onMouseMove,
      const SchemeSymbol('turtle-mouse-over'): element.onMouseOver,
      const SchemeSymbol('turtle-mouse-out'): element.onMouseOut,
      const SchemeSymbol('turtle-mouse-up'): element.onMouseUp
    };
    for (var event in mouseEvents.keys) {
      mouseEvents[event].listen((e) {
        var turtlePoint = clickPointToTurtlePoint(e.offset.x, e.offset.y);
        inter.triggerEvent(event, turtlePoint, inter.globalEnv);
        e.preventDefault();
      });
    }
    var touchEvents = {
      const SchemeSymbol('turtle-mouse-down'): element.onTouchStart,
      const SchemeSymbol('turtle-mouse-enter'): element.onTouchEnter,
      const SchemeSymbol('turtle-mouse-leave'): element.onTouchLeave,
      const SchemeSymbol('turtle-mouse-move'): element.onTouchMove,
      const SchemeSymbol('turtle-mouse-up'): element.onTouchEnd
    };
    for (var event in touchEvents.keys) {
      touchEvents[event].listen((e) {
        if (e.changedTouches.length != 1) return;
        var client = e.changedTouches[0].client;
        var turtlePoint = clickPointToTurtlePoint(client.x, client.y);
        inter.triggerEvent(event, turtlePoint, inter.globalEnv);
        e.preventDefault();
      });
    }
  }

  clickPointToTurtlePoint(num x, num y) {
    var ratioX = gridWidth / elementWidth;
    var ratioY = gridHeight / elementHeight;
    var tx = new Number.fromNum(x * ratioX - (gridWidth / 2));
    var ty = new Number.fromNum((gridHeight / 2) - y * ratioY);
    ;
    return [tx, ty];
  }

  void set backgroundColor(Color color) {
    element.style.background = color.toCSS();
  }

  Color _penColor;
  Color get penColor => _penColor;
  void set penColor(Color color) {
    _penColor = color;
    context.setFillColorRgb(color.red, color.green, color.blue, color.alpha);
    context.setStrokeColorRgb(0, 0, 0, 0);
  }

  num get realHeading => (heading - 90) / 180 * Math.PI;
  num get realX => x + (gridWidth / 2);
  num get realY => (gridHeight / 2) - y;
  void set realX(num realX) => x = realX - (gridWidth / 2);
  void set realY(num realY) => y = (gridHeight / 2) - realY;

  void show() {
    element.style.display = 'block';
  }

  void hide() {
    element.style.display = 'none';
  }

  void clear() {
    context.clearRect(0, 0, gridWidth, gridHeight);
  }

  void reset() {
    clear();
    hide();
    gridWidth = 1000;
    gridHeight = 1000;
    heading = 0;
    x = 0;
    y = 0;
    penSize = 1;
    pixelSize = 1;
    moves.clear();
    filling = false;
  }

  List moves = [];

  void beginFill() {
    filling = true;
    moves.clear();
    moves.add([realX, realY]);
  }

  void endFill() {
    filling = false;
    context.beginPath();
    context.moveTo(moves[0][0], moves[0][1]);
    for (var m in moves) {
      if (m.length == 5) {
        context.ellipse(m[0], m[1], m[2], m[2], 0, 0, m[3], m[4]);
      } else {
        context.lineTo(m[0], m[1]);
      }
    }
    context.lineTo(moves[0][0], moves[0][1]);
    context.closePath();
    context.fill('evenodd');
    moves.clear();
  }

  static List<num> getPointTo(num ang, num forward, num x, num y) {
    return [x + forward * Math.cos(ang), y + forward * Math.sin(ang)];
  }

  point(n) => getPointTo(realHeading, n, realX, realY);

  circle(num radius, [num arc = 360]) {
    num rad = radius.abs();
    var cpoint = getPointTo(realHeading - Math.PI / 2, radius, realX, realY);
    num cx = cpoint[0];
    num cy = cpoint[1];
    num initX = realX;
    num initY = realY;

    if (radius < 0) arc = -arc;
    bool reverse = arc < 0;
    arc = arc.abs();

    num circleStart = realHeading + Math.PI / 2;
    for (num i = 0; i <= arc; i += 60 / rad) {
      num radians = Math.PI * i / 180;
      if (reverse) radians = -radians;
      var point = getPointTo(circleStart - radians, radius, cx, cy);
      drawLine(point, true);
      realX = point[0];
      realY = point[1];
    }
    if (arc == 360) {
      drawLine([initX, initY]);
      realX = initX;
      realY = initY;
    } else {
      heading += reverse ? arc : -arc;
    }
  }

  drawLine(point, [bool circle = false]) {
    if (filling) moves.add(point);
    if (!penDown || penSize == 0) return;
    num a = penSize / 2;
    _draw(a, a, point);
    _draw(a, -a, point);
    _draw(-a, a, point);
    _draw(-a, -a, point);
  }

  _draw(a, b, point) {
    context.beginPath();
    context.moveTo(realX + a, realY + b);
    context.lineTo(point[0] + a, point[1] + b);
    context.lineTo(point[0] - a, point[1] - b);
    context.lineTo(realX - a, realY - b);
    context.lineTo(realX + a, realY + b);
    context.closePath();
    context.fill();
  }

  goto(num nx, num ny) {
    drawLine([nx + (gridWidth / 2), (gridHeight / 2) - ny]);
    x = nx;
    y = ny;
  }

  forward(n) {
    var p = point(n);
    drawLine(p);
    realX = p[0];
    realY = p[1];
  }

  rotate(n) {
    heading += n;
  }

  drawPixel(num x, num y, Color color) {
    num realX = x * pixelSize;
    num realY = y * pixelSize;
    num offsetX = realX + pixelSize;
    num offsetY = realY + pixelSize;

    context.setFillColorRgb(color.red, color.blue, color.green);
    context.beginPath();
    context.moveTo(realX, realY);
    context.lineTo(realX, offsetY);
    context.lineTo(offsetX, offsetY);
    context.lineTo(offsetX, realY);
    context.lineTo(realX, realY);
    context.closePath();
    context.fill();
    context.setFillColorRgb(penColor.red, penColor.blue, penColor.green);
  }
}
