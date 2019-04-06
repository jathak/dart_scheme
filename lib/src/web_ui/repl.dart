library web_ui.repl;

import 'dart:convert' show json;
import 'dart:html';

import 'package:cs61a_scheme/cs61a_scheme_web.dart';

import 'code_input.dart';

class Repl {
  Element container;
  Element activeLoggingArea;
  Element activePrompt;
  Element status;

  CodeInput activeInput;

  Interpreter interpreter;

  List<String> history = [];
  int historyIndex = -1;

  final String prompt;
  Repl(this.interpreter, Element parent, {this.prompt = 'scm> '}) {
    if (window.localStorage.containsKey('#repl-history')) {
      var decoded = json.decode(window.localStorage['#repl-history']);
      if (decoded is List) history = decoded.map((item) => '$item').toList();
    }
    addBuiltins();
    container = DivElement()..classes = ['repl'];
    container.onClick.listen((e) async {
      await delay(100);
      if (window.getSelection().rangeCount == 0 ||
          window.getSelection().getRangeAt(0).collapsed) {
        activeInput.element.focus();
        await activeInput.highlight(atEnd: true);
      }
    });
    parent.append(container);
    status = SpanElement()..classes = ['repl-status'];
    container.append(status);
    buildNewInput();
    if (window.localStorage.containsKey('#autocomplete')) {
      String val = window.localStorage['#autocomplete'];
      if (val == 'enabled') {
        activeInput.enableAutocomplete();
      }
    }
    interpreter.logger = (logging, [newline = true]) {
      var box = SpanElement();
      activeLoggingArea.append(box);
      logInto(box, logging, newline);
    };
    interpreter.logError = (e) {
      var errorElement = SpanElement()
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

  addBuiltins() {
    var env = interpreter.globalEnv;
    addBuiltin(env, const SchemeSymbol('clear'), (_a, _b) {
      for (Element child in container.children.toList()) {
        if (child == activePrompt) break;
        if (child != status) container.children.remove(child);
      }

      return undefined;
    }, 0);
    addBuiltin(env, const SchemeSymbol('autodraw'), (_a, _b) {
      logText(
          'When interactive output is a pair, it will automatically be drawn.\n'
          '(disable-autodraw) to disable\n');
      autodraw = true;
      return undefined;
    }, 0);
    addBuiltin(env, const SchemeSymbol('disable-autodraw'), (_a, _b) {
      logText('Autodraw disabled\n');
      autodraw = false;
      return undefined;
    }, 0);
    addBuiltin(env, const SchemeSymbol('autocomplete'), (_a, _b) {
      logText('While typing, will display a list of possible procedures.\n'
          '(disable-autocomplete) to disable\n');
      activeInput.enableAutocomplete();
      window.localStorage['#autocomplete'] = 'enabled';
      return undefined;
    }, 0);
    addBuiltin(env, const SchemeSymbol('disable-autocomplete'), (_a, _b) {
      logText('Autocomplete disabled\n');
      activeInput.disableAutocomplete();
      window.localStorage['#autocomplete'] = 'disabled';
      return undefined;
    }, 0);
  }

  buildNewInput() {
    activeLoggingArea = SpanElement();
    container.append(activeLoggingArea);
    if (activeInput != null) activeLoggingArea.text = "\n";
    activeInput?.deactivate();
    activePrompt = SpanElement()
      ..text = prompt
      ..classes = ['repl-prompt'];
    container.append(activePrompt);
    activeInput = CodeInput(
        container, runCode, allDocumentedForms(interpreter.globalEnv),
        parenListener: updateParenStatus);
    container.scrollTop = container.scrollHeight;
  }

  runCode(String code) async {
    addToHistory(code);
    buildNewInput();
    var tokens = tokenizeLines(code.split("\n")).toList();
    var loggingArea = activeLoggingArea;
    while (tokens.isNotEmpty) {
      Value result;
      try {
        Expression expr = schemeRead(tokens, interpreter);
        result = schemeEval(expr, interpreter.globalEnv);
        if (result is! Undefined) {
          var box = SpanElement();
          loggingArea.append(box);
          await logInto(box, result, true);
        }
      } on SchemeException catch (e) {
        loggingArea.append(SpanElement()
          ..text = '$e\n'
          ..classes = ['error']);
      } on ExitException {
        interpreter.onExit();
        return;
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        loggingArea.append(SpanElement()
          ..text = '$e\n'
          ..classes = ['error']);
        if (e is Error) {
          print('Stack Trace: ${e.stackTrace}');
        }
      } finally {
        if (autodraw && result is Pair) {
          var box = SpanElement();
          loggingArea.append(box);
          logInto(box, Diagram(result), true);
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
      activeInput.text = history[++historyIndex];
    }
  }

  historyDown() {
    if (historyIndex > 0) {
      activeInput.text = history[--historyIndex];
    } else {
      historyIndex = -1;
      activeInput.text = "";
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

  updateParenStatus(int missingParens) {
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
    if (interpreter.language != languages['default']) {
      var extra = "#lang ${interpreter.language}";
      if (status.text.trim() == "") {
        status.text = extra;
      } else {
        status.text += " - $extra";
      }
    }
  }

  logInto(Element element, Value logging, [bool newline = true]) {
    if (logging is AsyncValue) {
      var box = SpanElement()
        ..text = '$logging\n'
        ..classes = ['repl-async'];
      element.append(box);
      return logging.future.then((expr) {
        box.classes = ['repl-log'];
        logInto(box, expr is Undefined ? null : expr);
        return null;
      });
    } else if (logging is Pair && !autodraw) {
      var pairBox = SpanElement()..classes = ['mouseover-wrapper'];
      pairBox.text = logging.toString() + (newline ? '\n' : '');
      var diagram = Diagram(logging);
      var diagramBox = SpanElement();
      var refresher = render(diagram, diagramBox);
      pairBox.append(diagramBox);
      element.append(pairBox);
      pairBox.onMouseOver.listen((e) {
        refresher();
      });
      pairBox.onClick.listen((e) {
        pairBox.classes = [];
        refresher();
      });
    } else if (logging == null) {
      element.text = '';
    } else if (logging is Widget) {
      element.classes.add('render');
      render(logging, element);
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
}
