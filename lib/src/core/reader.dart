library cs61a_scheme.reader;

import 'dart:convert' show json;
import 'dart:math' show min;

import 'expressions.dart';
import 'frame.dart';
import 'interpreter.dart';
import 'language.dart';
import 'logging.dart';
import 'numbers.dart';
import 'values.dart';

/// Reads the first complete Scheme expression from [tokens].
///
/// This function mutates [tokens].
Expression schemeRead(List<Expression> tokens, Interpreter interpreter) {
  var token = tokens.removeAt(0);
  if (token is! SchemeSymbol) return token;
  var value = (token as SchemeSymbol).value;
  const quotes = {
    "'": SchemeSymbol('quote'),
    "`": SchemeSymbol('quasiquote'),
    ",": SchemeSymbol('unquote'),
    ",@": SchemeSymbol('unquote-splicing')
  };
  if (quotes.containsKey(value)) {
    return interpreter.impl.readFromQuote(tokens, quotes[value], interpreter);
  } else if (value == '(') {
    return interpreter.impl.readFromParen(tokens, interpreter);
  } else if (value == '.') {
    if (interpreter.language.dotAsCons) {
      throw SchemeException("Unexpected token: $value");
    } else {
      return Pair(const SchemeSymbol("variadic"),
          Pair(schemeRead(tokens, interpreter), nil));
    }
  }
  return token;
}

Expression readTail(List<Expression> tokens, Interpreter interpreter) {
  Expression first = tokens.first;
  if (first is SchemeSymbol && first.value == ')') {
    return interpreter.impl.readTailAtParen(tokens);
  } else if (interpreter.language.dotAsCons &&
      first is SchemeSymbol &&
      first.value == '.') {
    return interpreter.impl.readTailAtDot(tokens, interpreter);
  } else {
    return interpreter.impl.readTailElse(tokens, interpreter);
  }
}

Set _numeralStarts = Set.from("0123456789+-.".split(""));
Set _symbolChars = Set.from(
        r"!$%&*/:<=>?@^_~abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            .split(""))
    .union(_numeralStarts);
Set _stringDelims = Set.from(['"']);
Set _whitespace = Set.from([' ', '\t', '\n', '\r']);
Set _singleCharTokens = Set.from(['(', ')', '[', ']', "'", '`', '#']);
Set _tokenEnd = _whitespace
    .union(_singleCharTokens)
    .union(_stringDelims)
    .union(Set.from([',', ',@']));
Set _delimiters = _singleCharTokens.union(Set.from(['.', ',', ',@']));

/// Returns whether [s] is a well-formed symbol.
bool validSymbol(String s) {
  if (s.isEmpty) return false;
  for (String c in s.split('')) {
    if (!_symbolChars.contains(c)) return false;
  }
  return true;
}

/// A list [tok, k'], where tok is the next substring of line at or
/// after position k that could be a token (assuming it passes a validity
/// check), and k' is the position in line following that token.  Returns
/// [null, line.length] when there are no more tokens.
List nextCandidateToken(String line, int k) {
  while (k < line.length) {
    String c = line[k];
    if (c == ';') {
      return [null, line.length];
    } else if (_whitespace.contains(c)) {
      k++;
    } else if (c == '#') {
      // bool values #t and #f
      if (line[k + 1] == 't' || line[k + 1] == 'f') {
        return [line.substring(k, k + 2), min(k + 2, line.length)];
      }
      return [c, k + 1];
    } else if (_singleCharTokens.contains(c)) {
      if (c == ']') c = ')';
      if (c == '[') c = '(';
      return [c, k + 1];
    } else if (c == ',') {
      // unquote; check for @
      if (k + 1 < line.length && line[k + 1] == '@') {
        return [',@', k + 2];
      }
      return [c, k + 1];
    } else if (_stringDelims.contains(c)) {
      String str = c;
      k++;
      if (k >= line.length) throw FormatException("Invalid string $str");
      while (line[k] != '"') {
        if (line[k] == "\\") {
          k++;
          if (k >= line.length) throw FormatException("Invalid string $str");
          str += "\\" + line[k];
        } else {
          str += line[k];
        }
        k++;
        if (k >= line.length) throw FormatException("Invalid string $str");
      }
      return [str + '"', k + 1];
    } else {
      int j;
      for (j = k; j < line.length; j++) {
        if (_tokenEnd.contains(line[j])) break;
      }
      return [line.substring(k, j), min(j, line.length)];
    }
  }
  return [null, line.length];
}

Iterable<Expression> tokenizeLine(String line) sync* {
  if (line.startsWith("#lang ")) {
    yield LanguageChange(line.substring(6).trim());
    return;
  }
  var candidate = nextCandidateToken(line, 0);
  String text = candidate[0];
  int i = candidate[1];
  while (text != null) {
    if (_delimiters.contains(text)) {
      yield SchemeSymbol(text);
    } else if (text == '#t' || text.toLowerCase() == 'true') {
      yield schemeTrue;
    } else if (text == '#f' || text.toLowerCase() == 'false') {
      yield schemeFalse;
    } else if (text == 'nil') {
      yield nil;
    } else if (_symbolChars.contains(text[0])) {
      bool number = false;
      if (_numeralStarts.contains(text[0])) {
        try {
          yield Number.fromString(text);
          number = true;
        } on FormatException {
          // pass
        }
      }
      if (!number) {
        if (validSymbol(text)) {
          yield SchemeSymbol.runtime(text);
        } else {
          throw FormatException("invalid numeral or symbol: $text");
        }
      }
    } else if (_stringDelims.contains(text[0])) {
      yield SchemeString(json.decode(text));
    } else {
      throw FormatException("warning: invalid token: $text in $line");
    }
    candidate = nextCandidateToken(line, i);
    text = candidate[0];
    i = candidate[1];
  }
}

Iterable<Expression> tokenizeLines(Iterable<String> input) sync* {
  for (String line in input) {
    yield* tokenizeLine(line);
  }
}
