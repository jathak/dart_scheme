library cs61a_scheme.web.turtle_library;

import 'dart:html';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

import 'theming.dart';
import 'turtle.dart';

part '../../gen/web/turtle_library.gen.dart';

/// Note: When the signatures (including any annotations) of any of this methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the primitives and performs type checking on arguments).
@register
class TurtleLibrary extends SchemeLibrary with _$TurtleLibraryMixin {
  Turtle turtle;
  
  TurtleLibrary(CanvasElement element, Interpreter interpreter) {
    turtle = new Turtle(element, interpreter);
  }
  
  @primitive @turtlestart
  @SchemeSymbol('forward') @SchemeSymbol('fd')
  void forward(num distance) => turtle.forward(distance);
  
  @primitive @turtlestart
  @SchemeSymbol('backward') @SchemeSymbol('back') @SchemeSymbol('bk')
  void backward(num distance) => turtle.forward(-distance);
  
  @primitive @turtlestart @SchemeSymbol('left') @SchemeSymbol('lt')
  void left(num angle) => turtle.rotate(-angle);
  
  @primitive @turtlestart @SchemeSymbol('right') @SchemeSymbol('rt')
  void right(num angle) => turtle.rotate(angle);
  
  @primitive @turtlestart @MinArgs(1) @MaxArgs(2)
  void circle(List<Expression> exprs) {
    if (exprs[0] is! Number) throw new SchemeException('${exprs[0]} is not a number');
    if (exprs.length == 1) {
      turtle.circle(exprs[0].toJS());
      return;
    }
    if (exprs[1] is! Number) throw new SchemeException('${exprs[1]} is not a number');
    turtle.circle(exprs[0].toJS(), exprs[1].toJS());
  }
  
  @primitive @turtlestart
  @SchemeSymbol('setposition') @SchemeSymbol('setpos') @SchemeSymbol('goto')
  void setPosition(num x, num y) => turtle.goto(x, y);
  
  @primitive @turtlestart
  @SchemeSymbol('setheading') @SchemeSymbol('seth')
  void setHeading(num heading) => turtle.heading = heading;
  
  @primitive @turtlestart @SchemeSymbol('penup') @SchemeSymbol('pu')
  void penUp() => turtle.penDown = false;
  
  @primitive @turtlestart @SchemeSymbol('pendown') @SchemeSymbol('pd')
  void penDown() => turtle.penDown = true;
  
  @primitive @turtlestart @SchemeSymbol('turtle-clear')
  void turtleClear() => turtle.clear();
  
  @primitive @turtlestart
  void color(Expression color) {
    turtle.penColor = new Color.fromAnything(color);
  }
  
  @primitive @turtlestart
  @SchemeSymbol('begin_fill') @SchemeSymbol('begin-fill')
  void beginFill() => turtle.beginFill();
  
  
  @primitive @turtlestart @SchemeSymbol('end_fill') @SchemeSymbol('end-fill')
  void endFill() => turtle.endFill();
  
  @primitive
  void exitonclick(Frame env) {
    var msg = 'Use (turtle-exit) to close turtle view.';
    env.interpreter.logger(new TextMessage(msg), true);
  }
  
  @primitive @SchemeSymbol('turtle-exit')
  void exit() => turtle.reset();
  
  @primitive @turtlestart
  void bgcolor(Expression color) {
    turtle.backgroundColor = new Color.fromAnything(color);
  }
  
  @primitive @turtlestart
  void pensize(num size) {
    turtle.penSize = size;
  }
  
  @primitive
  void help(Frame env) {
    var cw = turtle.element.style.width;
    var ch = turtle.element.style.height;
    var gw = turtle.gridWidth;
    var gh = turtle.gridHeight;
    env.interpreter.logger(new TextMessage(
      "Canvas is ${cw}x${ch} on a ${gw}x${gh} grid\n"
      "(turtle-grid w h) changes the turtle grid (clears drawing)\n"
      "(turtle-canvas w h) changes the canvas size in pixels.\n"
      "(turtle-exit) hides the canvas and clears the drawing."), true);
  }
  
  @primitive @SchemeSymbol('turtle-grid')
  void setGridSize(int width, int height) {
    turtle.gridWidth = width;
    turtle.gridHeight = height;
    turtle.clear();
  }
  
  @primitive @SchemeSymbol('turtle-canvas')
  void setCanvasSize(int width, int height) {
    turtle.elementWidth = width;
    turtle.elementHeight = height;
  }
  
  @primitive
  void pixel(num x, num y, Expression color) {
    
  }
  
  @primitive 
  void pixelsize(int size) {
    turtle.pixelSize = size;
  }
  
  @primitive @SchemeSymbol('screen_width') @SchemeSymbol('screen-width')
  num screenWidth() => turtle.gridWidth / turtle.pixelSize;
  
  @primitive @SchemeSymbol('screen_height') @SchemeSymbol('screen-height')
  num screenHeight() => turtle.gridHeight / turtle.pixelSize;
  
  @primitive @SchemeSymbol('unsupported') @SchemeSymbol('speed')
  @SchemeSymbol('showturtle') @SchemeSymbol('st')
  @SchemeSymbol('hideturtle') @SchemeSymbol('ht') 
  void unsupported(List<Expression> exprs, Frame env) {
    env.interpreter.logger(new TextMessage('Unsupported turtle command.'), true);
  }
}
