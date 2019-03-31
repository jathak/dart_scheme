library cs61a_scheme.core.interpreter;

import 'dart:collection';

import 'expressions.dart';
import 'frame.dart';
import 'language.dart';
import 'logging.dart';
import 'procedures.dart';
import 'project_interface.dart';
import 'reader.dart';
import 'scheme_library.dart';
import 'special_forms.dart';
import 'standard_library.dart';
import 'utils.dart' show schemeEval;
import 'values.dart';

class Interpreter {
  final ProjectInterface impl;
  Language language = languages['default'];
  Frame globalEnv;
  bool tailCallOptimized = true;
  Logger logger = (e, newline) => null;
  void Function() onExit = () => null;
  int frameCounter = 0;

  Interpreter(this.impl) {
    globalEnv = Frame(null, this);
    logError = (error) {
      if (error is Expression) {
        logger(error, true);
      } else {
        logger(TextMessage(error.toString()), true);
      }
    };
    StandardLibrary().importAll(globalEnv);
  }

  @deprecated
  ProjectInterface get implementation => impl;

  void Function(Object) logError;

  final Map<SchemeSymbol, List<SchemeBuiltin>> _eventListeners = {};

  void triggerEvent(SchemeSymbol id, List<Value> data, Frame env) {
    if (_eventListeners.containsKey(id)) {
      for (var blocker in _eventListeners[id]) {
        blocker(data.toList(), env);
      }
    }
  }

  void listenFor(SchemeSymbol id, SchemeBuiltin callback) {
    _eventListeners.putIfAbsent(id, () => []).add(callback);
  }

  bool stopListening(SchemeSymbol id, SchemeBuiltin callback) {
    if (_eventListeners.containsKey(id)) {
      return _eventListeners[id].remove(callback);
    }
    return false;
  }

  stopAllListeners(SchemeSymbol id) {
    _eventListeners[id].clear();
  }

  final List<Expression> _tokens = [];

  importLibrary(SchemeLibrary library) => library.importAll(globalEnv);

  run(String code) {
    var lines = code.split("\n");
    _tokens.addAll(tokenizeLines(lines));
    while (_tokens.isNotEmpty) {
      try {
        Expression expr = schemeRead(_tokens, this);
        Value result = schemeEval(expr, globalEnv);
        if (!identical(result, undefined)) logger(result, true);
      } on SchemeException catch (e) {
        logger(e, true);
      } on ExitException {
        onExit();
        return;
      }
    }
  }

  void addLogger(Logger newLog) => logger = combineLoggers(logger, newLog);

  void logText(String text) => logger(TextMessage(text), true);

  Map<SchemeSymbol, SpecialForm> specialForms = {
    const SchemeSymbol('define'): doDefineForm,
    const SchemeSymbol('if'): doIfForm,
    const SchemeSymbol('cond'): doCondForm,
    const SchemeSymbol('and'): doAndForm,
    const SchemeSymbol('or'): doOrForm,
    const SchemeSymbol('let'): doLetForm,
    const SchemeSymbol('begin'): doBeginForm,
    const SchemeSymbol('lambda'): doLambdaForm,
    const SchemeSymbol('mu'): doMuForm,
    const SchemeSymbol('quote'): doQuoteForm,
    const SchemeSymbol('delay'): doDelayForm,
    const SchemeSymbol('cons-stream'): doConsStreamForm,
    const SchemeSymbol('define-macro'): doDefineMacroForm,
    const SchemeSymbol('set!'): doSetForm,
    const SchemeSymbol('quasiquote'): doQuasiquoteForm,
    const SchemeSymbol('unquote'): doUnquoteForm,
    const SchemeSymbol('unquote-splicing'): doUnquoteForm,
    const SchemeSymbol('variadic'): doVariadicForm
  };
}
