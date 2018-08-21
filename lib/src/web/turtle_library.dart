library cs61a_scheme.web.turtle_library;

import 'dart:html';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

import 'turtle.dart';

part 'turtle_library.g.dart';

/// Note: When the signatures (including any annotations) of any of this methods
/// change, make sure to `pub run grinder` to rebuild the mixin (which registers
/// the built-ins and performs type checking on arguments).
@schemelib
class TurtleLibrary extends SchemeLibrary with _$TurtleLibraryMixin {
  Turtle turtle;

  TurtleLibrary(CanvasElement element, Interpreter interpreter) {
    turtle = Turtle(element, interpreter);
  }

  /// Moves the turtle forward by [distance] units.
  @turtlestart
  @SchemeSymbol('forward')
  @SchemeSymbol('fd')
  void forward(num distance) => turtle.forward(distance);

  /// Moves the turtle backward by [distance] units.
  @turtlestart
  @SchemeSymbol('backward')
  @SchemeSymbol('back')
  @SchemeSymbol('bk')
  void backward(num distance) => turtle.forward(-distance);

  /// Rotates the turtle counter-clockwise by [angle] degrees.
  @turtlestart
  @SchemeSymbol('left')
  @SchemeSymbol('lt')
  void left(num angle) => turtle.rotate(-angle);

  /// Rotates the turtle clockwise by [angle] degrees.
  @turtlestart
  @SchemeSymbol('right')
  @SchemeSymbol('rt')
  void right(num angle) => turtle.rotate(angle);

  /// Moves the turtle in a circle of some radius (first arg).
  ///
  /// An optional second argument sets the length of the arc in degrees.
  @turtlestart
  @MinArgs(1)
  @MaxArgs(2)
  void circle(List<Expression> exprs) {
    if (exprs[0] is! Number) {
      throw SchemeException('${exprs[0]} is not a number');
    }
    if (exprs.length == 1) {
      turtle.circle(exprs[0].toJS());
      return;
    }
    if (exprs[1] is! Number) {
      throw SchemeException('${exprs[1]} is not a number');
    }
    turtle.circle(exprs[0].toJS(), exprs[1].toJS());
  }

  /// Moves the turtle to position ([x], [y]) in Cartesian coordinates.
  @turtlestart
  @SchemeSymbol('setposition')
  @SchemeSymbol('setpos')
  @SchemeSymbol('goto')
  void setPosition(num x, num y) => turtle.goto(x, y);

  /// Sets the turtle's heading to be [heading] degrees.
  @turtlestart
  @SchemeSymbol('setheading')
  @SchemeSymbol('seth')
  void setHeading(num heading) => turtle.heading = heading;

  /// Raises the pen from the canvas.
  @turtlestart
  @SchemeSymbol('penup')
  @SchemeSymbol('pu')
  void penUp() => turtle.penDown = false;

  /// Lowers the pen onto the canvas.
  @turtlestart
  @SchemeSymbol('pendown')
  @SchemeSymbol('pd')
  void penDown() => turtle.penDown = true;

  /// Clears the current turtle state.
  @turtlestart
  @SchemeSymbol('turtle-clear')
  void turtleClear() => turtle.clear();

  /// Sets the pen color of the turtle.
  @turtlestart
  void color(Expression color) {
    turtle.penColor = Color.fromAnything(color);
  }

  /// Begins outlining a region to be filled in.
  @turtlestart
  @SchemeSymbol('begin_fill')
  @SchemeSymbol('begin-fill')
  void beginFill() => turtle.beginFill();

  /// Fills in the region outlined since begin_fill in the current pen color.
  @turtlestart
  @SchemeSymbol('end_fill')
  @SchemeSymbol('end-fill')
  void endFill() => turtle.endFill();

  void exitonclick(Frame env) {
    var msg = 'Use (turtle-exit) to close turtle view.';
    env.interpreter.logger(TextMessage(msg), true);
  }

  /// Closes the turtle canvas, reseting its state.
  @SchemeSymbol('turtle-exit')
  void exit() => turtle.reset();

  /// Sets the background color of the turtle canvas.
  @turtlestart
  void bgcolor(Expression color) {
    turtle.backgroundColor = Color.fromAnything(color);
  }

  /// Sets the [size] of the turtle's pen.
  @turtlestart
  void pensize(num size) {
    turtle.penSize = size;
  }

  /// Displays information on how to adjust and close the turtle canvas.
  @SchemeSymbol('turtle-help')
  void turtleHelp(Frame env) {
    var cw = turtle.element.style.width;
    var ch = turtle.element.style.height;
    var gw = turtle.gridWidth;
    var gh = turtle.gridHeight;
    env.interpreter.logger(
        TextMessage("Canvas is ${cw}x$ch on a ${gw}x$gh grid\n"
            "(turtle-grid w h) changes the turtle grid (clears drawing)\n"
            "(turtle-canvas w h) changes the canvas size in pixels.\n"
            "(turtle-exit) hides the canvas and clears the drawing."),
        true);
  }

  /// Sets the internal dimensions of the grid the turtle moves/draws on.
  ///
  /// This will clear the current state of the turtle.
  @SchemeSymbol('turtle-grid')
  void setGridSize(int width, int height) {
    turtle.gridWidth = width;
    turtle.gridHeight = height;
    turtle.clear();
  }

  /// Sets the exterior dimensions of the turtle's canvas.
  ///
  /// This does not effect the current state of the turtle.
  @SchemeSymbol('turtle-canvas')
  void setCanvasSize(int width, int height) {
    turtle.elementWidth = width;
    turtle.elementHeight = height;
  }

  /// Draws a box with [color] in the turtle's current pixel size at ([x], [y])
  @turtlestart
  void pixel(num x, num y, Expression color) {
    turtle.drawPixel(x, y, Color.fromAnything(color));
  }

  /// Sets the current pixel size of the turtle
  void pixelsize(int size) {
    turtle.pixelSize = size;
  }

  /// Returns the number of "pixels" in the width of the turtle's grid.
  @SchemeSymbol('screen_width')
  @SchemeSymbol('screen-width')
  num screenWidth() => turtle.gridWidth / turtle.pixelSize;

  /// Returns the number of "pixels" in the height of the turtle's grid.
  @SchemeSymbol('screen_height')
  @SchemeSymbol('screen-height')
  num screenHeight() => turtle.gridHeight / turtle.pixelSize;

  /// This turtle procedure is not supported in the web interpreter.
  @SchemeSymbol('unsupported')
  @SchemeSymbol('speed')
  @SchemeSymbol('showturtle')
  @SchemeSymbol('st')
  @SchemeSymbol('hideturtle')
  @SchemeSymbol('ht')
  void unsupported(List<Expression> exprs, Frame env) {
    env.interpreter
        .logger(const TextMessage('Unsupported turtle command.'), true);
  }
}
