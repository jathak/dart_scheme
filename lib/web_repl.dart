library web_repl;

import 'dart:async';
import 'package:dart2_constant/convert.dart' show json;
import 'dart:html';
import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_web.dart';
import 'package:cs61a_scheme/highlight.dart';

class Repl {
  Element container;
  Element activeLoggingArea;
  Element activePrompt;
  Element activeInput;
  Element status;

  Interpreter interpreter;

  List<String> history = [];
  int historyIndex = -1;

  List<SchemeSymbol> noIndent = [
    const SchemeSymbol("let"),
    const SchemeSymbol("define"),
    const SchemeSymbol("lambda")
  ];

  Repl(this.interpreter, Element parent) {
    if (window.localStorage.containsKey('#repl-history')) {
      var decoded = json.decode(window.localStorage['#repl-history']);
      if (decoded is List) history = decoded.map((item) => '$item').toList();
    }
    addPrimitives();
    container = new PreElement()..classes = ['repl'];
    container.onClick.listen((e) async {
      if (activeInput.contains(e.target)) return;
      await delay(0);
      var selection = window.getSelection();
      if (selection.rangeCount > 0) {
        var range = window.getSelection().getRangeAt(0);
        if (range.startOffset != range.endOffset) return;
      }
      activeInput.focus();
      var range = new Range();
      range.selectNodeContents(activeInput);
      range.collapse(false);
      selection.removeAllRanges();
      selection.addRange(range);
    });
    parent.append(container);
    status = new SpanElement()..classes = ['repl-status'];
    container.append(status);
    buildNewInput();
    interpreter.logger = (Expression logging, [bool newline = true]) {
      var box = new SpanElement();
      activeLoggingArea.append(box);
      logInto(box, logging, newline);
    };
    interpreter.logError = (e) {
      var errorElement = new SpanElement()
        ..text = '$e\n'
        ..classes = ['error'];
      activeLoggingArea.append(errorElement);
      if (e is Error) {
        print('Stack Trace: ${e.stackTrace}');
      }
    };
    window.onKeyDown.listen(onWindowKeyDown);
  }

  bool autodraw = false;

  addPrimitives() {
    var env = interpreter.globalEnv;
    addPrimitive(env, const SchemeSymbol('clear'), (_a, _b) {
      for (Element child in container.children.toList()) {
        if (child == activePrompt) break;
        if (child != status) container.children.remove(child);
      }
      return undefined;
    }, 0);
    addPrimitive(env, const SchemeSymbol('autodraw'), (_a, _b) {
      logText(
          'When interactive output is a pair, it will automatically be drawn.\n'
          '(disable-autodraw) to disable\n');
      autodraw = true;
      return undefined;
    }, 0);
    addPrimitive(env, const SchemeSymbol('disable-autodraw'), (_a, _b) {
      logText('Autodraw disabled\n');
      autodraw = false;
      return undefined;
    }, 0);
  }

  buildNewInput() {
    activeLoggingArea = new SpanElement();
    if (activeInput != null) {
      activeInput.contentEditable = 'false';
      container.append(new SpanElement()..text = '\n');
    }
    container.append(activeLoggingArea);
    activePrompt = new SpanElement()
      ..text = 'scm> '
      ..classes = ['repl-prompt'];
    container.append(activePrompt);
    activeInput = new SpanElement()
      ..classes = ['repl-input']
      ..contentEditable = 'true';
    activeInput.onKeyPress.listen(onInputKeyPress);
    activeInput.onKeyDown.listen(keyListener);
    activeInput.onKeyUp.listen(keyListener);
    container.append(activeInput);
    activeInput.focus();
    updateInputStatus();
    container.scrollTop = container.scrollHeight;
  }

  runActiveCode() async {
    var code = activeInput.text;
    addToHistory(code);
    buildNewInput();
    var tokens = tokenizeLines(code.split("\n")).toList();
    var loggingArea = activeLoggingArea;
    while (tokens.isNotEmpty) {
      Expression result;
      try {
        Expression expr = schemeRead(tokens, interpreter.impl);
        result = schemeEval(expr, interpreter.globalEnv);
        if (result is! Undefined) {
          var box = new SpanElement();
          loggingArea.append(box);
          await logInto(box, result, true);
        }
      } on SchemeException catch (e) {
        loggingArea.append(new SpanElement()
          ..text = '$e\n'
          ..classes = ['error']);
      } on ExitException {
        interpreter.onExit();
        return;
      } catch (e) {
        loggingArea.append(new SpanElement()
          ..text = '$e\n'
          ..classes = ['error']);
        if (e is Error) {
          print('Stack Trace: ${e.stackTrace}');
        }
      } finally {
        if (autodraw && result is Pair) {
          var box = new SpanElement();
          loggingArea.append(box);
          logInto(box, new Diagram(result), true);
        }
      }
    }
    container.scrollTop = container.scrollHeight;
  }

  addToHistory(String code) {
    historyIndex = -1;
    if (history.isNotEmpty && code == history[0]) return;
    history.insert(0, code);
    var subset = history.take(100).toList();
    window.localStorage['#repl-history'] = json.encode(subset);
  }

  historyUp() {
    if (historyIndex < history.length - 1) {
      replaceInput(history[++historyIndex]);
    }
  }

  historyDown() {
    if (historyIndex > 0) {
      replaceInput(history[--historyIndex]);
    } else {
      historyIndex = -1;
      replaceInput("");
    }
  }

  onWindowKeyDown(KeyboardEvent event) {
    if (activeInput.text.trim().contains('\n') && !event.ctrlKey) return;
    if (event.keyCode == KeyCode.UP) {
      historyUp();
      return;
    }
    if (event.keyCode == KeyCode.DOWN) {
      historyDown();
      return;
    }
  }

  keyListener(KeyboardEvent event) async {
    int code = event.keyCode;
    if (code == KeyCode.BACKSPACE) {
      //this should be changed to call highlightSaveCursor
      //once the bug with newlines is fixed
      await delay(0);
      updateInputStatus();
    } else if (event.ctrlKey && (code == KeyCode.V || code == KeyCode.X)) {
      await delay(0);
      updateInputStatus();
      highlightSaveCursor(activeInput);
    }
  }

  onInputKeyPress(KeyboardEvent event) async {
    Element input = activeInput;
    int missingParens = updateInputStatus();
    if ((missingParens ?? -1) > 0 &&
        event.shiftKey &&
        event.keyCode == KeyCode.ENTER) {
      event.preventDefault();
      activeInput.text =
          activeInput.text.trimRight() + ')' * missingParens + '\n';
      runActiveCode();
      await delay(100);
      input.innerHtml = highlight(input.text);
    } else if ((missingParens ?? -1) == 0 && event.keyCode == KeyCode.ENTER) {
      event.preventDefault();
      activeInput.text = activeInput.text.trimRight() + '\n';
      runActiveCode();
      await delay(100);
      input.innerHtml = highlight(input.text);
    } else if ((missingParens ?? 0) > 0 &&
        KeyCode.ENTER == event.keyCode &&
        endOfLine()) {
      event.preventDefault();
      int cursor = currPosition();
      String newInput = input.text;
      String first = newInput.substring(0, cursor) + "\n";
      String second = "";
      if (cursor != newInput.length) {
        second = newInput.substring(cursor);
      }
      int spaces = countSpace(newInput);
      input.text = first + " " * spaces + second;
      highlightCustomCursor(input, cursor + spaces + 1);
    } else {
      await delay(5);
      highlightSaveCursor(input);
    }
    updateInputStatus();
  }

  int updateInputStatus() {
    int missingParens = countParens(activeInput.text);
    if (missingParens == null) {
      status.classes = ['repl-status', 'error'];
      status.text = 'Invalid syntax!';
    } else if (missingParens < 0) {
      status.classes = ['repl-status', 'error'];
      status.text = 'Too many parens!';
    } else if (missingParens > 0) {
      status.classes = ['repl-status'];
      var s = missingParens == 1 ? '' : 's';
      status.text = '$missingParens missing paren$s';
    } else if (missingParens == 0) {
      status.classes = ['repl-status'];
      status.text = "";
    }
    return missingParens;
  }

  replaceInput(String text) async {
    await highlightAtEnd(activeInput, text);
    updateInputStatus();
  }

  countParens(String text) {
    var tokens;
    try {
      tokens = tokenizeLines(text.split('\n')).toList();
    } on FormatException {
      return null;
    }
    int left = tokens.fold(0, (val, token) {
      return val + (token == const SchemeSymbol('(') ? 1 : 0);
    });
    int right = tokens.fold(0, (val, token) {
      return val + (token == const SchemeSymbol(')') ? 1 : 0);
    });
    return left - right;
  }

  logInto(Element element, Expression logging, [bool newline = true]) {
    if (logging is AsyncExpression) {
      var box = new SpanElement()
        ..text = '$logging\n'
        ..classes = ['repl-async'];
      element.append(box);
      return logging.future.then((Expression expr) {
        box.classes = ['repl-log'];
        logInto(box, expr is Undefined ? null : expr);
        return null;
      });
    } else if (logging == null) {
      element.text = '';
    } else if (logging is UIElement) {
      element.classes.add('render');
      var renderer = new HtmlRenderer(element, context['jsPlumb']);
      renderer.render(logging);
      logging.onUpdate.listen(([_]) async {
        await delay(0);
        if (logging is Visualization &&
            element.offsetHeight > window.innerHeight) {
          container.scrollTop = container.scrollHeight;
          var frame = element.querySelector('.current-frame');
          frame.scrollIntoView(ScrollAlignment.CENTER);
        } else {
          container.scrollTop = container.scrollHeight;
        }
      });
    } else {
      element.text = logging.toString() + (newline ? '\n' : '');
    }
    container.scrollTop = container.scrollHeight;
    return null;
  }

  logElement(Element element) {
    activeLoggingArea.append(element);
    container.scrollTop = container.scrollHeight;
  }

  logText(String text) {
    activeLoggingArea.appendText(text);
    container.scrollTop = container.scrollHeight;
  }

  Future delay(int milliseconds) {
    return new Future.delayed(new Duration(milliseconds: milliseconds));
  }

  ///Returns how many spaces the next line must be indented based
  ///on the line with the last open parentheses
  int countSpace(String inputText) {
    List<String> splitLines = inputText.split("\n");
    String refLine;
    int totalMissingCount = 0;
    for (refLine in splitLines.reversed) {
      totalMissingCount += countParens(refLine);
      //find the first line where there exists an open parens
      //with no closed parens
      if (totalMissingCount >= 1) break;
    }
    int strIndex = refLine.indexOf("(");
    while (strIndex < (refLine.length - 1)) {
      int nextClose = refLine.indexOf(")", strIndex + 1);
      int nextOpen = refLine.indexOf("(", strIndex + 1);
      //find the location of the open parens that
      //corresponds to the missing closed parnes
      if (totalMissingCount > 1) {
        totalMissingCount -= 1;
      } else if (nextOpen == -1 || nextOpen < nextClose) {
        Iterable<Expression> tokens = tokenizeLine(refLine.substring(strIndex));
        Expression symbol = tokens.elementAt(1);
        //decide whether to align with subexpressions if they exist
        //otherwise indent by two spaces
        if (symbol == const SchemeSymbol("(")) {
          return strIndex + 1;
        } else if (noIndent.contains(symbol)) {
          return strIndex + 2;
        } else if (tokens.length > 2) {
          return refLine.indexOf(tokens.elementAt(2).toString(), strIndex + 1);
        } else if (nextOpen == -1) {
          return strIndex + 2;
        }
      } else if (nextClose == -1) {
        return strIndex + 2;
      }
      strIndex = nextOpen;
    }
    return strIndex + 2;
  }

  ///determines whether the cursor is at the end of a line in the inp
  bool endOfLine() {
    String input = activeInput.text;
    int cursor = currPosition();
    return cursor == input.length || input[cursor] == "\n";
  }

  ///returns the location in the input string where the cursor is
  int currPosition() {
    return findPosition(activeInput, window.getSelection().getRangeAt(0));
  }
}
