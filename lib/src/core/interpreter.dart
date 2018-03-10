library cs61a_scheme.core.interpreter;

import 'expressions.dart';
import 'logging.dart';
import 'reader.dart';
import 'procedures.dart';
import 'project_interface.dart';
import 'scheme_library.dart';
import 'special_forms.dart';
import 'standard_library.dart';
import 'ui.dart';
import 'utils.dart' show schemeEval;

class Interpreter {
  final ProjectInterface impl;
  @deprecated
  ProjectInterface get implementation => impl;
  Frame globalEnv;
  bool tailCallOptimized = true;
  Renderer renderer = (UIElement) => null;
  Logger _logger = (Expression e, bool newline) => null;
  Logger get logger => _logger;
  void set logger(Logger logger) => _logger = logger;
  void Function() onExit = () => null;
  int frameCounter = 0;

  void Function(dynamic) logError;

  Map<SchemeSymbol, List<SchemePrimitive>> _eventListeners = {};

  void triggerEvent(SchemeSymbol id, List<Expression> data, Frame env) {
    if (_eventListeners.containsKey(id)) {
      for (var blocker in _eventListeners[id]) blocker(data.toList(), env);
    }
  }

  void listenFor(SchemeSymbol id, SchemePrimitive callback) {
    _eventListeners.putIfAbsent(id, () => []).add(callback);
  }

  bool stopListening(SchemeSymbol id, SchemePrimitive callback) {
    if (_eventListeners.containsKey(id)) {
      return _eventListeners[id].remove(callback);
    }
    return false;
  }

  stopAllListeners(SchemeSymbol id) {
    _eventListeners[id].clear();
  }

  Interpreter(this.impl) {
    globalEnv = new Frame(null, this);
    logError = (error) {
      if (error is Expression) {
        logger(error, true);
      } else {
        logger(new TextMessage(error.toString()), true);
      }
    };
    new StandardLibrary().importAll(globalEnv);
  }

  List<Expression> _tokens = [];

  importLibrary(SchemeLibrary library) => library.importAll(globalEnv);

  run(String code) {
    _tokens.addAll(tokenizeLines(code.split("\n")));
    while (_tokens.isNotEmpty) {
      try {
        Expression expr = schemeRead(_tokens, impl);
        Expression result = schemeEval(expr, globalEnv);
        if (!identical(result, undefined)) logger(result, true);
      } on SchemeException catch (e) {
        logger(e, true);
      } on ExitException {
        onExit();
        return;
      }
    }
  }

  void addLogger(Logger logger) => _logger = combineLoggers(_logger, logger);

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
    const SchemeSymbol('unquote-splicing'): doUnquoteForm
  };
}
