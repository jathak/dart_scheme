library cs61a_scheme.web.theming;

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

class Color extends SelfEvaluating {
  int red, green, blue;
  double alpha = 1.0;
  
  Color(this.red, this.green, this.blue, [this.alpha = 1.0]);
  
  Color.fromHexString(String str) {
    str = str.toLowerCase();
    if (str.startsWith("#")) str = str.substring(1);
    if (str.length == 3) {
      str = str[0]*2 + str[1]*2 + str[2]*2;
    }
    if (str.length != 6) {
      throw new SchemeException("#$str is not a valid color");
    }
    red = _toInt(str[0])*16 + _toInt(str[1]);
    green = _toInt(str[2])*16 + _toInt(str[3]);
    blue = _toInt(str[4])*16 + _toInt(str[5]);
  }
  
  int _toInt(String hexChar) {
    switch (hexChar) {
      case '0': return 0;
      case '1': return 1;
      case '2': return 2;
      case '3': return 3;
      case '4': return 4;
      case '5': return 5;
      case '6': return 6;
      case '7': return 7;
      case '8': return 8;
      case '9': return 9;
      case 'a': return 10;
      case 'b': return 11;
      case 'c': return 12;
      case 'd': return 13;
      case 'e': return 14;
      case 'f': return 15;
      default: throw new SchemeException("$hexChar is not a valid hexadecimal");
    }
  }
  
  toJS() => this;
  
  String toString() {
    if (alpha == 1.0) return '(rgb $red $green $blue)';
    return '(rgba $red $green $blue $alpha)';
  }
  
  String toCSS() => 'rgba($red, $green, $blue, $alpha)';
}

class Theme extends SelfEvaluating {
  Map<SchemeSymbol, Color> colors;
  Map<SchemeSymbol, SchemeString> cssProps;
  String compiledCss;
  
  Theme() : colors = {}, cssProps = {};
  Theme._compiled(this.compiledCss);
  
  toString() => '#theme';
  
  Theme compile(String css) {
    if (compiledCss != null) return this;
    for (SchemeSymbol symbol in colors.keys) {
      css = embedColor(css, symbol, colors[symbol]);
    }
    for (SchemeSymbol symbol in cssProps.keys) {
      css = embedCss(css, symbol, cssProps[symbol]);
    }
    return new Theme._compiled(css);
  }
  
  String embedColor(String css, SchemeSymbol symbol, Color color) {
    var symbReg = new RegExp(r'[-[\]{}()*+?.,\\^$|#\s]');
    var val = symbol.value.replaceAllMapped(symbReg, (m) => '\\${m[0]}');
    // /*!COLOR|<css-prop>|<scheme-prop>*/<default-code>/*!END*/
    var expr = r'/\*!COLOR\|(color|background)\|' + val + r'\*/[^/]*/\*!END\*/';
    var regex = new RegExp(expr, multiLine: true);
    return css.replaceAllMapped(regex, (m) => '${m[1]}: ${color.toCSS()};');
  }
  
  String embedCss(String css, SchemeSymbol symbol, SchemeString code) {
    var symbReg = new RegExp(r'[-[\]{}()*+?.,\\^$|#\s]');
    var val = symbol.value.replaceAllMapped(symbReg, (m) => '\\${m[0]}');
    // /*!CSS|<scheme-prop>*/<default-code>/*!END*/
    var expr = r'/\*!CSS\|' + val + r'\*/[^/]*/\*!END\*/';
    var regex = new RegExp(expr, multiLine: true);
    return css.replaceAll(regex, code.value);
  }
  
  toJS() => this;
}
