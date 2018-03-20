library cs61a_scheme.web.theming;

import 'dart:async';
import 'dart:html';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

StreamController<Theme> _controller = new StreamController();

applyTheme(Theme theme, String css, Element style, [bool notify = true]) {
  style.innerHtml = theme.compile(css);
  if (notify) _controller.add(theme);
}

final Stream<Theme> onThemeChange = _controller.stream.asBroadcastStream();

class Theme extends SelfEvaluating implements Serializable<Theme> {
  Map<SchemeSymbol, Color> colors = {};
  Map<SchemeSymbol, SchemeString> cssProps = {};

  Theme();

  toString() => '#theme';

  String compile(String css) {
    for (SchemeSymbol symbol in colors.keys) {
      css = embedColor(css, symbol, colors[symbol]);
    }
    for (SchemeSymbol symbol in cssProps.keys) {
      css = embedCss(css, symbol, cssProps[symbol]);
    }
    return css;
  }

  String embedColor(String css, SchemeSymbol symbol, Color color) {
    var symbReg = new RegExp(r'[-[\]{}()*+?.,\\^$|#\s]');
    var val = symbol.value.replaceAllMapped(symbReg, (m) => '\\${m[0]}');
    // /*!COLOR|<css-prop>|<scheme-prop>*/<default-code>/*!END*/
    var expr = r'/\*!COLOR\|([a-z\-]*)\|' + val + r'\*/[^/]*/\*!END\*/';
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

  serialize() {
    var colorMap = {};
    for (SchemeSymbol key in colors.keys) {
      colorMap[key.value] = colors[key].serialize();
    }
    var cssMap = {};
    for (SchemeSymbol key in cssProps.keys) {
      cssMap[key.value] = cssProps[key].serialize();
    }
    return {'type': 'Theme', 'colors': colorMap, 'css': cssMap};
  }

  Theme deserialize(Map data) {
    Theme theme = new Theme();
    var colorMap = data['colors'];
    for (String key in colorMap.keys) {
      theme.colors[new SchemeSymbol(key)] =
          Serialization.deserialize(colorMap[key]);
    }
    var cssMap = data['css'];
    for (String key in cssMap.keys) {
      theme.cssProps[new SchemeSymbol(key)] =
          Serialization.deserialize(cssMap[key]);
    }
    return theme;
  }
}

class Color extends SelfEvaluating implements Serializable<Color> {
  final int red, green, blue;
  final double alpha;

  const Color(this.red, this.green, this.blue, [this.alpha = 1.0]);

  static const white = const Color(255, 255, 255);
  static const black = const Color(0, 0, 0);
  static const transparent = const Color(0, 0, 0, 0.0);

  factory Color.fromHexString(String str) {
    str = str.toLowerCase();
    if (str.startsWith("#")) str = str.substring(1);
    if (str.length == 3) {
      str = str[0] * 2 + str[1] * 2 + str[2] * 2;
    }
    if (str.length != 6) {
      throw new SchemeException("#$str is not a valid color");
    }
    int red = _toInt(str[0]) * 16 + _toInt(str[1]);
    int green = _toInt(str[2]) * 16 + _toInt(str[3]);
    int blue = _toInt(str[4]) * 16 + _toInt(str[5]);
    return new Color(red, green, blue);
  }

  factory Color.fromString(String str) {
    if (Color.names.containsKey(str)) str = Color.names[str];
    return new Color.fromHexString(str);
  }

  factory Color.fromAnything(dynamic expr) {
    if (expr is Color) return expr;
    if (expr is SchemeString) return new Color.fromString(expr.value);
    if (expr is SchemeSymbol) return new Color.fromString(expr.value);
    if (expr is String) return new Color.fromString(expr);
    throw new SchemeException('Could not interpret $expr as a color.');
  }

  static int _toInt(String hexChar) {
    switch (hexChar) {
      case '0':
        return 0;
      case '1':
        return 1;
      case '2':
        return 2;
      case '3':
        return 3;
      case '4':
        return 4;
      case '5':
        return 5;
      case '6':
        return 6;
      case '7':
        return 7;
      case '8':
        return 8;
      case '9':
        return 9;
      case 'a':
        return 10;
      case 'b':
        return 11;
      case 'c':
        return 12;
      case 'd':
        return 13;
      case 'e':
        return 14;
      case 'f':
        return 15;
      default:
        throw new SchemeException("$hexChar is not a valid hexadecimal");
    }
  }

  serialize() => {
        'type': 'Color',
        'red': red,
        'green': green,
        'blue': blue,
        'alpha': alpha
      };

  deserialize(Map data) {
    return new Color(data['red'], data['green'], data['blue'], data['alpha']);
  }

  String toString() {
    if (alpha == 1.0) return '(rgb $red $green $blue)';
    return '(rgba $red $green $blue $alpha)';
  }

  String toCSS() => 'rgba($red, $green, $blue, $alpha)';

  static const Map<String, String> names = const {
    "aliceblue": "f0f8ff",
    "antiquewhite": "faebd7",
    "aqua": "00ffff",
    "aquamarine": "7fffd4",
    "azure": "f0ffff",
    "beige": "f5f5dc",
    "bisque": "ffe4c4",
    "black": "000000",
    "blanchedalmond": "ffebcd",
    "blue": "0000ff",
    "blueviolet": "8a2be2",
    "brown": "a52a2a",
    "burlywood": "deb887",
    "cadetblue": "5f9ea0",
    "chartreuse": "7fff00",
    "chocolate": "d2691e",
    "coral": "ff7f50",
    "cornflowerblue": "6495ed",
    "cornsilk": "fff8dc",
    "crimson": "dc143c",
    "cyan": "00ffff",
    "darkblue": "00008b",
    "darkcyan": "008b8b",
    "darkgoldenrod": "b8860b",
    "darkgray": "a9a9a9",
    "darkgreen": "006400",
    "darkkhaki": "bdb76b",
    "darkmagenta": "8b008b",
    "darkolivegreen": "556b2f",
    "darkorange": "ff8c00",
    "darkorchid": "9932cc",
    "darkred": "8b0000",
    "darksalmon": "e9967a",
    "darkseagreen": "8fbc8f",
    "darkslateblue": "483d8b",
    "darkslategray": "2f4f4f",
    "darkturquoise": "00ced1",
    "darkviolet": "9400d3",
    "deeppink": "ff1493",
    "deepskyblue": "00bfff",
    "dimgray": "696969",
    "dodgerblue": "1e90ff",
    "firebrick": "b22222",
    "floralwhite": "fffaf0",
    "forestgreen": "228b22",
    "fuchsia": "ff00ff",
    "gainsboro": "dcdcdc",
    "ghostwhite": "f8f8ff",
    "gold": "ffd700",
    "goldenrod": "daa520",
    "gray": "808080",
    "green": "008000",
    "greenyellow": "adff2f",
    "honeydew": "f0fff0",
    "hotpink": "ff69b4",
    "indianred": "cd5c5c",
    "indigo": "4b0082",
    "ivory": "fffff0",
    "khaki": "f0e68c",
    "lavender": "e6e6fa",
    "lavenderblush": "fff0f5",
    "lawngreen": "7cfc00",
    "lemonchiffon": "fffacd",
    "lightblue": "add8e6",
    "lightcoral": "f08080",
    "lightcyan": "e0ffff",
    "lightgoldenrodyellow": "fafad2",
    "lightgrey": "d3d3d3",
    "lightgreen": "90ee90",
    "lightpink": "ffb6c1",
    "lightsalmon": "ffa07a",
    "lightseagreen": "20b2aa",
    "lightskyblue": "87cefa",
    "lightslategray": "778899",
    "lightsteelblue": "b0c4de",
    "lightyellow": "ffffe0",
    "lime": "00ff00",
    "limegreen": "32cd32",
    "linen": "faf0e6",
    "magenta": "ff00ff",
    "maroon": "800000",
    "mediumaquamarine": "66cdaa",
    "mediumblue": "0000cd",
    "mediumorchid": "ba55d3",
    "mediumpurple": "9370d8",
    "mediumseagreen": "3cb371",
    "mediumslateblue": "7b68ee",
    "mediumspringgreen": "00fa9a",
    "mediumturquoise": "48d1cc",
    "mediumvioletred": "c71585",
    "midnightblue": "191970",
    "mintcream": "f5fffa",
    "mistyrose": "ffe4e1",
    "moccasin": "ffe4b5",
    "navajowhite": "ffdead",
    "navy": "000080",
    "oldlace": "fdf5e6",
    "olive": "808000",
    "olivedrab": "6b8e23",
    "orange": "ffa500",
    "orangered": "ff4500",
    "orchid": "da70d6",
    "palegoldenrod": "eee8aa",
    "palegreen": "98fb98",
    "paleturquoise": "afeeee",
    "palevioletred": "d87093",
    "papayawhip": "ffefd5",
    "peachpuff": "ffdab9",
    "peru": "cd853f",
    "pink": "ffc0cb",
    "plum": "dda0dd",
    "powderblue": "b0e0e6",
    "purple": "800080",
    "red": "ff0000",
    "rosybrown": "bc8f8f",
    "royalblue": "4169e1",
    "saddlebrown": "8b4513",
    "salmon": "fa8072",
    "sandybrown": "f4a460",
    "seagreen": "2e8b57",
    "seashell": "fff5ee",
    "sienna": "a0522d",
    "silver": "c0c0c0",
    "skyblue": "87ceeb",
    "slateblue": "6a5acd",
    "slategray": "708090",
    "snow": "fffafa",
    "springgreen": "00ff7f",
    "steelblue": "4682b4",
    "tan": "d2b48c",
    "teal": "008080",
    "thistle": "d8bfd8",
    "tomato": "ff6347",
    "turquoise": "40e0d0",
    "violet": "ee82ee",
    "wheat": "f5deb3",
    "white": "ffffff",
    "whitesmoke": "f5f5f5",
    "yellow": "ffff00",
    "yellowgreen": "9acd32"
  };
}
