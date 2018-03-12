part of cs61a_scheme.web.turtle_library;

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
  void help(Frame env);
  void setGridSize(int width, int height);
  void setCanvasSize(int width, int height);
  void pixel(num x, num y, Expression color);
  void pixelsize(int size);
  num screenWidth();
  num screenHeight();
  void unsupported(List<Expression> exprs, Frame env);
  Turtle get turtle;
  void importAll(Frame __env) {
    addPrimitive(__env, const SchemeSymbol('forward'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to forward.');
      turtle.show();
      var __value = undefined;
      this.forward(__exprs[0].toJS());
      return __value;
    }, 1);
    __env.bindings[const SchemeSymbol('fd')] =
        __env.bindings[const SchemeSymbol('forward')];
    __env.hidden[const SchemeSymbol('fd')] = true;
    addPrimitive(__env, const SchemeSymbol('backward'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to backward.');
      turtle.show();
      var __value = undefined;
      this.backward(__exprs[0].toJS());
      return __value;
    }, 1);
    __env.bindings[const SchemeSymbol('back')] =
        __env.bindings[const SchemeSymbol('backward')];
    __env.hidden[const SchemeSymbol('back')] = true;
    __env.bindings[const SchemeSymbol('bk')] =
        __env.bindings[const SchemeSymbol('backward')];
    __env.hidden[const SchemeSymbol('bk')] = true;
    addPrimitive(__env, const SchemeSymbol('left'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to left.');
      turtle.show();
      var __value = undefined;
      this.left(__exprs[0].toJS());
      return __value;
    }, 1);
    __env.bindings[const SchemeSymbol('lt')] =
        __env.bindings[const SchemeSymbol('left')];
    __env.hidden[const SchemeSymbol('lt')] = true;
    addPrimitive(__env, const SchemeSymbol('right'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException('Argument of invalid type passed to right.');
      turtle.show();
      var __value = undefined;
      this.right(__exprs[0].toJS());
      return __value;
    }, 1);
    __env.bindings[const SchemeSymbol('rt')] =
        __env.bindings[const SchemeSymbol('right')];
    __env.hidden[const SchemeSymbol('rt')] = true;
    addVariablePrimitive(__env, const SchemeSymbol("circle"), (__exprs, __env) {
      turtle.show();
      var __value = undefined;
      this.circle(__exprs);
      return __value;
    }, 1, 2);
    addPrimitive(__env, const SchemeSymbol('setposition'), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to setposition.');
      turtle.show();
      var __value = undefined;
      this.setPosition(__exprs[0].toJS(), __exprs[1].toJS());
      return __value;
    }, 2);
    __env.bindings[const SchemeSymbol('setpos')] =
        __env.bindings[const SchemeSymbol('setposition')];
    __env.hidden[const SchemeSymbol('setpos')] = true;
    __env.bindings[const SchemeSymbol('goto')] =
        __env.bindings[const SchemeSymbol('setposition')];
    __env.hidden[const SchemeSymbol('goto')] = true;
    addPrimitive(__env, const SchemeSymbol('setheading'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to setheading.');
      turtle.show();
      var __value = undefined;
      this.setHeading(__exprs[0].toJS());
      return __value;
    }, 1);
    __env.bindings[const SchemeSymbol('seth')] =
        __env.bindings[const SchemeSymbol('setheading')];
    __env.hidden[const SchemeSymbol('seth')] = true;
    addPrimitive(__env, const SchemeSymbol('penup'), (__exprs, __env) {
      turtle.show();
      var __value = undefined;
      this.penUp();
      return __value;
    }, 0);
    __env.bindings[const SchemeSymbol('pu')] =
        __env.bindings[const SchemeSymbol('penup')];
    __env.hidden[const SchemeSymbol('pu')] = true;
    addPrimitive(__env, const SchemeSymbol('pendown'), (__exprs, __env) {
      turtle.show();
      var __value = undefined;
      this.penDown();
      return __value;
    }, 0);
    __env.bindings[const SchemeSymbol('pd')] =
        __env.bindings[const SchemeSymbol('pendown')];
    __env.hidden[const SchemeSymbol('pd')] = true;
    addPrimitive(__env, const SchemeSymbol('turtle-clear'), (__exprs, __env) {
      turtle.show();
      var __value = undefined;
      this.turtleClear();
      return __value;
    }, 0);
    addPrimitive(__env, const SchemeSymbol("color"), (__exprs, __env) {
      turtle.show();
      var __value = undefined;
      this.color(__exprs[0]);
      return __value;
    }, 1);
    addPrimitive(__env, const SchemeSymbol('begin_fill'), (__exprs, __env) {
      turtle.show();
      var __value = undefined;
      this.beginFill();
      return __value;
    }, 0);
    __env.bindings[const SchemeSymbol('begin-fill')] =
        __env.bindings[const SchemeSymbol('begin_fill')];
    __env.hidden[const SchemeSymbol('begin-fill')] = true;
    addPrimitive(__env, const SchemeSymbol('end_fill'), (__exprs, __env) {
      turtle.show();
      var __value = undefined;
      this.endFill();
      return __value;
    }, 0);
    __env.bindings[const SchemeSymbol('end-fill')] =
        __env.bindings[const SchemeSymbol('end_fill')];
    __env.hidden[const SchemeSymbol('end-fill')] = true;
    addPrimitive(__env, const SchemeSymbol("exitonclick"), (__exprs, __env) {
      var __value = undefined;
      this.exitonclick(__env);
      return __value;
    }, 0);
    addPrimitive(__env, const SchemeSymbol('turtle-exit'), (__exprs, __env) {
      var __value = undefined;
      this.exit();
      return __value;
    }, 0);
    addPrimitive(__env, const SchemeSymbol("bgcolor"), (__exprs, __env) {
      turtle.show();
      var __value = undefined;
      this.bgcolor(__exprs[0]);
      return __value;
    }, 1);
    addPrimitive(__env, const SchemeSymbol("pensize"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw new SchemeException(
            'Argument of invalid type passed to pensize.');
      turtle.show();
      var __value = undefined;
      this.pensize(__exprs[0].toJS());
      return __value;
    }, 1);
    addPrimitive(__env, const SchemeSymbol("help"), (__exprs, __env) {
      var __value = undefined;
      this.help(__env);
      return __value;
    }, 0);
    addPrimitive(__env, const SchemeSymbol('turtle-grid'), (__exprs, __env) {
      if ((__exprs[0] is! Integer) || (__exprs[1] is! Integer))
        throw new SchemeException(
            'Argument of invalid type passed to turtle-grid.');
      var __value = undefined;
      this.setGridSize(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt());
      return __value;
    }, 2);
    addPrimitive(__env, const SchemeSymbol('turtle-canvas'), (__exprs, __env) {
      if ((__exprs[0] is! Integer) || (__exprs[1] is! Integer))
        throw new SchemeException(
            'Argument of invalid type passed to turtle-canvas.');
      var __value = undefined;
      this.setCanvasSize(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt());
      return __value;
    }, 2);
    addPrimitive(__env, const SchemeSymbol("pixel"), (__exprs, __env) {
      if (__exprs[0] is! Number ||
          __exprs[1] is! Number ||
          __exprs[2] is! Expression)
        throw new SchemeException('Argument of invalid type passed to pixel.');
      turtle.show();
      var __value = undefined;
      this.pixel(__exprs[0].toJS(), __exprs[1].toJS(), __exprs[2]);
      return __value;
    }, 3);
    addPrimitive(__env, const SchemeSymbol("pixelsize"), (__exprs, __env) {
      if ((__exprs[0] is! Integer))
        throw new SchemeException(
            'Argument of invalid type passed to pixelsize.');
      var __value = undefined;
      this.pixelsize(__exprs[0].toJS().toInt());
      return __value;
    }, 1);
    addPrimitive(__env, const SchemeSymbol('screen_width'), (__exprs, __env) {
      return new Number.fromNum(this.screenWidth());
    }, 0);
    __env.bindings[const SchemeSymbol('screen-width')] =
        __env.bindings[const SchemeSymbol('screen_width')];
    __env.hidden[const SchemeSymbol('screen-width')] = true;
    addPrimitive(__env, const SchemeSymbol('screen_height'), (__exprs, __env) {
      return new Number.fromNum(this.screenHeight());
    }, 0);
    __env.bindings[const SchemeSymbol('screen-height')] =
        __env.bindings[const SchemeSymbol('screen_height')];
    __env.hidden[const SchemeSymbol('screen-height')] = true;
    addVariablePrimitive(__env, const SchemeSymbol('unsupported'),
        (__exprs, __env) {
      var __value = undefined;
      this.unsupported(__exprs, __env);
      return __value;
    }, 0, -1);
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
