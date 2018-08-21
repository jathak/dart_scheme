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
    addBuiltin(__env, const SchemeSymbol('forward'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to forward.');
      turtle.show();
      this.forward(__exprs[0].toJS());
      return undefined;
    }, 1);
    __env.bindings[const SchemeSymbol('fd')] =
        __env.bindings[const SchemeSymbol('forward')];
    __env.hidden[const SchemeSymbol('fd')] = true;
    addBuiltin(__env, const SchemeSymbol('backward'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to backward.');
      turtle.show();
      this.backward(__exprs[0].toJS());
      return undefined;
    }, 1);
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
    }, 1);
    __env.bindings[const SchemeSymbol('lt')] =
        __env.bindings[const SchemeSymbol('left')];
    __env.hidden[const SchemeSymbol('lt')] = true;
    addBuiltin(__env, const SchemeSymbol('right'), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to right.');
      turtle.show();
      this.right(__exprs[0].toJS());
      return undefined;
    }, 1);
    __env.bindings[const SchemeSymbol('rt')] =
        __env.bindings[const SchemeSymbol('right')];
    __env.hidden[const SchemeSymbol('rt')] = true;
    addVariableBuiltin(__env, const SchemeSymbol("circle"), (__exprs, __env) {
      turtle.show();
      this.circle(__exprs);
      return undefined;
    }, 1, maxArgs: 2);
    addBuiltin(__env, const SchemeSymbol('setposition'), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException(
            'Argument of invalid type passed to setposition.');
      turtle.show();
      this.setPosition(__exprs[0].toJS(), __exprs[1].toJS());
      return undefined;
    }, 2);
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
    }, 1);
    __env.bindings[const SchemeSymbol('seth')] =
        __env.bindings[const SchemeSymbol('setheading')];
    __env.hidden[const SchemeSymbol('seth')] = true;
    addBuiltin(__env, const SchemeSymbol('penup'), (__exprs, __env) {
      turtle.show();
      this.penUp();
      return undefined;
    }, 0);
    __env.bindings[const SchemeSymbol('pu')] =
        __env.bindings[const SchemeSymbol('penup')];
    __env.hidden[const SchemeSymbol('pu')] = true;
    addBuiltin(__env, const SchemeSymbol('pendown'), (__exprs, __env) {
      turtle.show();
      this.penDown();
      return undefined;
    }, 0);
    __env.bindings[const SchemeSymbol('pd')] =
        __env.bindings[const SchemeSymbol('pendown')];
    __env.hidden[const SchemeSymbol('pd')] = true;
    addBuiltin(__env, const SchemeSymbol('turtle-clear'), (__exprs, __env) {
      turtle.show();
      this.turtleClear();
      return undefined;
    }, 0);
    addBuiltin(__env, const SchemeSymbol("color"), (__exprs, __env) {
      turtle.show();
      this.color(__exprs[0]);
      return undefined;
    }, 1);
    addBuiltin(__env, const SchemeSymbol('begin_fill'), (__exprs, __env) {
      turtle.show();
      this.beginFill();
      return undefined;
    }, 0);
    __env.bindings[const SchemeSymbol('begin-fill')] =
        __env.bindings[const SchemeSymbol('begin_fill')];
    __env.hidden[const SchemeSymbol('begin-fill')] = true;
    addBuiltin(__env, const SchemeSymbol('end_fill'), (__exprs, __env) {
      turtle.show();
      this.endFill();
      return undefined;
    }, 0);
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
    }, 0);
    addBuiltin(__env, const SchemeSymbol("bgcolor"), (__exprs, __env) {
      turtle.show();
      this.bgcolor(__exprs[0]);
      return undefined;
    }, 1);
    addBuiltin(__env, const SchemeSymbol("pensize"), (__exprs, __env) {
      if (__exprs[0] is! Number)
        throw SchemeException('Argument of invalid type passed to pensize.');
      turtle.show();
      this.pensize(__exprs[0].toJS());
      return undefined;
    }, 1);
    addBuiltin(__env, const SchemeSymbol("help"), (__exprs, __env) {
      this.help(__env);
      return undefined;
    }, 0);
    addBuiltin(__env, const SchemeSymbol('turtle-grid'), (__exprs, __env) {
      if (__exprs[0] is! Integer || __exprs[1] is! Integer)
        throw SchemeException(
            'Argument of invalid type passed to turtle-grid.');
      this.setGridSize(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt());
      return undefined;
    }, 2);
    addBuiltin(__env, const SchemeSymbol('turtle-canvas'), (__exprs, __env) {
      if (__exprs[0] is! Integer || __exprs[1] is! Integer)
        throw SchemeException(
            'Argument of invalid type passed to turtle-canvas.');
      this.setCanvasSize(__exprs[0].toJS().toInt(), __exprs[1].toJS().toInt());
      return undefined;
    }, 2);
    addBuiltin(__env, const SchemeSymbol("pixel"), (__exprs, __env) {
      if (__exprs[0] is! Number || __exprs[1] is! Number)
        throw SchemeException('Argument of invalid type passed to pixel.');
      turtle.show();
      this.pixel(__exprs[0].toJS(), __exprs[1].toJS(), __exprs[2]);
      return undefined;
    }, 3);
    addBuiltin(__env, const SchemeSymbol("pixelsize"), (__exprs, __env) {
      if (__exprs[0] is! Integer)
        throw SchemeException('Argument of invalid type passed to pixelsize.');
      this.pixelsize(__exprs[0].toJS().toInt());
      return undefined;
    }, 1);
    addBuiltin(__env, const SchemeSymbol('screen_width'), (__exprs, __env) {
      return Number.fromNum(this.screenWidth());
    }, 0);
    __env.bindings[const SchemeSymbol('screen-width')] =
        __env.bindings[const SchemeSymbol('screen_width')];
    __env.hidden[const SchemeSymbol('screen-width')] = true;
    addBuiltin(__env, const SchemeSymbol('screen_height'), (__exprs, __env) {
      return Number.fromNum(this.screenHeight());
    }, 0);
    __env.bindings[const SchemeSymbol('screen-height')] =
        __env.bindings[const SchemeSymbol('screen_height')];
    __env.hidden[const SchemeSymbol('screen-height')] = true;
    addVariableBuiltin(__env, const SchemeSymbol('unsupported'),
        (__exprs, __env) {
      this.unsupported(__exprs, __env);
      return undefined;
    }, 0, maxArgs: -1);
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
