part of cs61a_scheme.web.turtle_library;

// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: unnecessary_this
// ignore_for_file: prefer_expression_function_bodies
// ignore_for_file: unnecessary_lambdas
abstract class _$TurtleLibraryMixin {
  void forward(num distance);
  void backward(num distance);
  void left(num angle);
  void right(num angle);
  void circle(List<Expression> exprs);
  void setPosition(num x, num y);
  void setHeading(num heading);
  void penUp();
  void penDown();
  void turtleClear();
  void color(Expression color);
  void beginFill();
  void endFill();
  void exitonclick(Frame env);
  void exit();
  void bgcolor(Expression color);
  void pensize(num size);
  void turtleHelp(Frame env);
  void setGridSize(int width, int height);
  void setCanvasSize(int width, int height);
  void pixel(num x, num y, Expression color);
  void pixelsize(int size);
  num screenWidth();
  num screenHeight();
  void unsupported(List<Expression> exprs, Frame env);
  Turtle get turtle;
  void importAll(Frame __env) {
    addBuiltin(__env, const SchemeSymbol('forward'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to forward.');
      turtle.show();
      this.forward(__exprs[0].toJS());
      return undefined;
    }, 1,
        docs: Docs('forward', "Moves the turtle forward by [distance] units.\n",
            [Param("num", "distance")]));
    __env.bindings[const SchemeSymbol('fd')] =
        __env.bindings[const SchemeSymbol('forward')];
    __env.hidden[const SchemeSymbol('fd')] = true;
    addBuiltin(__env, const SchemeSymbol('backward'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to backward.');
      turtle.show();
      this.backward(__exprs[0].toJS());
      return undefined;
    }, 1,
        docs: Docs(
            'backward',
            "Moves the turtle backward by [distance] units.\n",
            [Param("num", "distance")]));
    __env.bindings[const SchemeSymbol('back')] =
        __env.bindings[const SchemeSymbol('backward')];
    __env.hidden[const SchemeSymbol('back')] = true;
    __env.bindings[const SchemeSymbol('bk')] =
        __env.bindings[const SchemeSymbol('backward')];
    __env.hidden[const SchemeSymbol('bk')] = true;
    addBuiltin(__env, const SchemeSymbol('left'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to left.');
      turtle.show();
      this.left(__exprs[0].toJS());
      return undefined;
    }, 1,
        docs: Docs(
            'left',
            "Rotates the turtle counter-clockwise by [angle] degrees.\n",
            [Param("num", "angle")]));
    __env.bindings[const SchemeSymbol('lt')] =
        __env.bindings[const SchemeSymbol('left')];
    __env.hidden[const SchemeSymbol('lt')] = true;
    addBuiltin(__env, const SchemeSymbol('right'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to right.');
      turtle.show();
      this.right(__exprs[0].toJS());
      return undefined;
    }, 1,
        docs: Docs(
            'right',
            "Rotates the turtle clockwise by [angle] degrees.\n",
            [Param("num", "angle")]));
    __env.bindings[const SchemeSymbol('rt')] =
        __env.bindings[const SchemeSymbol('right')];
    __env.hidden[const SchemeSymbol('rt')] = true;
    addVariableBuiltin(__env, const SchemeSymbol("circle"), (__exprs, __env) {
      turtle.show();
      this.circle(__exprs);
      return undefined;
    }, 1,
        maxArgs: 2,
        docs: Docs.variable("circle",
            "Moves the turtle in a circle of some radius (first arg).\n\nAn optional second argument sets the length of the arc in degrees.\n"));
    addBuiltin(__env, const SchemeSymbol('setposition'), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException(
            'Argument of invalid type passed to setposition.');
      turtle.show();
      this.setPosition(__exprs[0].toJS(), __exprs[1].toJS());
      return undefined;
    }, 2,
        docs: Docs(
            'setposition',
            "Moves the turtle to position ([x], [y]) in Cartesian coordinates.\n",
            [Param("num", "x"), Param("num", "y")]));
    __env.bindings[const SchemeSymbol('setpos')] =
        __env.bindings[const SchemeSymbol('setposition')];
    __env.hidden[const SchemeSymbol('setpos')] = true;
    __env.bindings[const SchemeSymbol('goto')] =
        __env.bindings[const SchemeSymbol('setposition')];
    __env.hidden[const SchemeSymbol('goto')] = true;
    addBuiltin(__env, const SchemeSymbol('setheading'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to setheading.');
      turtle.show();
      this.setHeading(__exprs[0].toJS());
      return undefined;
    }, 1,
        docs: Docs(
            'setheading',
            "Sets the turtle's heading to be [heading] degrees.\n",
            [Param("num", "heading")]));
    __env.bindings[const SchemeSymbol('seth')] =
        __env.bindings[const SchemeSymbol('setheading')];
    __env.hidden[const SchemeSymbol('seth')] = true;
    addBuiltin(__env, const SchemeSymbol('penup'), (__exprs, __env) {
      turtle.show();
      this.penUp();
      return undefined;
    }, 0, docs: Docs('penup', "Raises the pen from the canvas.\n", []));
    __env.bindings[const SchemeSymbol('pu')] =
        __env.bindings[const SchemeSymbol('penup')];
    __env.hidden[const SchemeSymbol('pu')] = true;
    addBuiltin(__env, const SchemeSymbol('pendown'), (__exprs, __env) {
      turtle.show();
      this.penDown();
      return undefined;
    }, 0, docs: Docs('pendown', "Lowers the pen onto the canvas.\n", []));
    __env.bindings[const SchemeSymbol('pd')] =
        __env.bindings[const SchemeSymbol('pendown')];
    __env.hidden[const SchemeSymbol('pd')] = true;
    addBuiltin(__env, const SchemeSymbol('turtle-clear'), (__exprs, __env) {
      turtle.show();
      this.turtleClear();
      return undefined;
    }, 0, docs: Docs('turtle-clear', "Clears the current turtle state.\n", []));
    addBuiltin(__env, const SchemeSymbol("color"), (__exprs, __env) {
      turtle.show();
      this.color(__exprs[0]);
      return undefined;
    }, 1,
        docs: Docs("color", "Sets the pen color of the turtle.\n",
            [Param(null, "color")]));
    addBuiltin(__env, const SchemeSymbol('begin_fill'), (__exprs, __env) {
      turtle.show();
      this.beginFill();
      return undefined;
    }, 0,
        docs: Docs(
            'begin_fill', "Begins outlining a region to be filled in.\n", []));
    __env.bindings[const SchemeSymbol('begin-fill')] =
        __env.bindings[const SchemeSymbol('begin_fill')];
    __env.hidden[const SchemeSymbol('begin-fill')] = true;
    addBuiltin(__env, const SchemeSymbol('end_fill'), (__exprs, __env) {
      turtle.show();
      this.endFill();
      return undefined;
    }, 0,
        docs: Docs(
            'end_fill',
            "Fills in the region outlined since begin_fill in the current pen color.\n",
            []));
    __env.bindings[const SchemeSymbol('end-fill')] =
        __env.bindings[const SchemeSymbol('end_fill')];
    __env.hidden[const SchemeSymbol('end-fill')] = true;
    addBuiltin(__env, const SchemeSymbol("exitonclick"), (__exprs, __env) {
      this.exitonclick(__env);
      return undefined;
    }, 0);
    addBuiltin(__env, const SchemeSymbol('turtle-exit'), (__exprs, __env) {
      this.exit();
      return undefined;
    }, 0,
        docs: Docs('turtle-exit',
            "Closes the turtle canvas, reseting its state.\n", []));
    addBuiltin(__env, const SchemeSymbol("bgcolor"), (__exprs, __env) {
      turtle.show();
      this.bgcolor(__exprs[0]);
      return undefined;
    }, 1,
        docs: Docs(
            "bgcolor",
            "Sets the background color of the turtle canvas.\n",
            [Param(null, "color")]));
    addBuiltin(__env, const SchemeSymbol("pensize"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to pensize.');
      turtle.show();
      this.pensize(__exprs[0].toJS());
      return undefined;
    }, 1,
        docs: Docs("pensize", "Sets the [size] of the turtle's pen.\n",
            [Param("num", "size")]));
    addBuiltin(__env, const SchemeSymbol('turtle-help'), (__exprs, __env) {
      this.turtleHelp(__env);
      return undefined;
    }, 0,
        docs: Docs(
            'turtle-help',
            "Displays information on how to adjust and close the turtle canvas.\n",
            []));
    addBuiltin(__env, const SchemeSymbol('turtle-grid'), (__exprs, __env) {
      if (__exprs[0] is! Integer || __exprs[1] is! Integer)
        throw SchemeException(
            'Argument of invalid type passed to turtle-grid.');
      this.setGridSize(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt());
      return undefined;
    }, 2,
        docs: Docs(
            'turtle-grid',
            "Sets the internal dimensions of the grid the turtle moves/draws on.\n\nThis will clear the current state of the turtle.\n",
            [Param("int", "width"), Param("int", "height")]));
    addBuiltin(__env, const SchemeSymbol('turtle-canvas'), (__exprs, __env) {
      if (__exprs[0] is! Integer || __exprs[1] is! Integer)
        throw SchemeException(
            'Argument of invalid type passed to turtle-canvas.');
      this.setCanvasSize(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt());
      return undefined;
    }, 2,
        docs: Docs(
            'turtle-canvas',
            "Sets the exterior dimensions of the turtle's canvas.\n\nThis does not effect the current state of the turtle.\n",
            [Param("int", "width"), Param("int", "height")]));
    addBuiltin(__env, const SchemeSymbol("pixel"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to pixel.');
      turtle.show();
      this.pixel(__exprs[0].toJS(), __exprs[1].toJS(), __exprs[2]);
      return undefined;
    }, 3,
        docs: Docs(
            "pixel",
            "Draws a box with [color] in the turtle's current pixel size at ([x], [y])\n",
            [Param("num", "x"), Param("num", "y"), Param(null, "color")]));
    addBuiltin(__env, const SchemeSymbol("pixelsize"), (__exprs, __env) {
      if (__exprs[0] is! Integer)
        throw SchemeException('Argument of invalid type passed to pixelsize.');
      this.pixelsize(__exprs[0].toJS().toInt());
      return undefined;
    }, 1,
        docs: Docs("pixelsize", "Sets the current pixel size of the turtle\n",
            [Param("int", "size")]));
    addBuiltin(__env, const SchemeSymbol('screen_width'), (__exprs, __env) {
      return Number.fromNum(this.screenWidth());
    }, 0,
        docs: Docs(
            'screen_width',
            "Returns the number of \"pixels\" in the width of the turtle's grid.\n",
            [],
            returnType: "num"));
    __env.bindings[const SchemeSymbol('screen-width')] =
        __env.bindings[const SchemeSymbol('screen_width')];
    __env.hidden[const SchemeSymbol('screen-width')] = true;
    addBuiltin(__env, const SchemeSymbol('screen_height'), (__exprs, __env) {
      return Number.fromNum(this.screenHeight());
    }, 0,
        docs: Docs(
            'screen_height',
            "Returns the number of \"pixels\" in the height of the turtle's grid.\n",
            [],
            returnType: "num"));
    __env.bindings[const SchemeSymbol('screen-height')] =
        __env.bindings[const SchemeSymbol('screen_height')];
    __env.hidden[const SchemeSymbol('screen-height')] = true;
    addVariableBuiltin(__env, const SchemeSymbol('unsupported'),
        (__exprs, __env) {
      this.unsupported(__exprs, __env);
      return undefined;
    }, 0,
        maxArgs: -1,
        docs: Docs.variable('unsupported',
            "This turtle procedure is not supported in the web interpreter.\n"));
    __env.bindings[const SchemeSymbol('speed')] =
        __env.bindings[const SchemeSymbol('unsupported')];
    __env.hidden[const SchemeSymbol('speed')] = true;
    __env.bindings[const SchemeSymbol('showturtle')] =
        __env.bindings[const SchemeSymbol('unsupported')];
    __env.hidden[const SchemeSymbol('showturtle')] = true;
    __env.bindings[const SchemeSymbol('st')] =
        __env.bindings[const SchemeSymbol('unsupported')];
    __env.hidden[const SchemeSymbol('st')] = true;
    __env.bindings[const SchemeSymbol('hideturtle')] =
        __env.bindings[const SchemeSymbol('unsupported')];
    __env.hidden[const SchemeSymbol('hideturtle')] = true;
    __env.bindings[const SchemeSymbol('ht')] =
        __env.bindings[const SchemeSymbol('unsupported')];
    __env.hidden[const SchemeSymbol('ht')] = true;
  }
}
