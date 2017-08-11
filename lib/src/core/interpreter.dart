library cs61a_scheme.core.interpreter;

import 'expressions.dart';
import 'logging.dart';
import 'reader.dart';
import 'project_interface.dart';
import 'scheme_library.dart';
import 'special_forms.dart';
import 'standard_library.dart';
import 'utils.dart' show schemeEval;

class Interpreter {
  final ProjectInterface implementation;
  Frame globalEnv;
  bool tailCallOptimized = true;
  Logger _logger = (Expression e, bool newline) => null;
  Logger get logger => _logger;
  void set logger(Logger logger) => _logger = logger;
  void Function() onExit = () => null;
  
  Interpreter(this.implementation) {
    globalEnv = new Frame(null, this);
    new StandardLibrary().importAll(globalEnv);
  }
  
  List<Expression> _tokens = [];
  
  importLibrary(SchemeLibrary library) => library.importAll(globalEnv);
  
  run(String code) {
    _tokens.addAll(tokenizeLines(code.split("\n")));
    while (_tokens.isNotEmpty) {
      try {
        Expression expr = schemeRead(_tokens, implementation);
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
    const SchemeSymbol('define') : doDefineForm,
    const SchemeSymbol('if') : doIfForm,
    const SchemeSymbol('cond') : doCondForm,
    const SchemeSymbol('and') : doAndForm,
    const SchemeSymbol('or') : doOrForm,
    const SchemeSymbol('let') : doLetForm,
    const SchemeSymbol('begin') : doBeginForm,
    const SchemeSymbol('lambda') : doLambdaForm,
    const SchemeSymbol('mu') : doMuForm,
    const SchemeSymbol('quote') : doQuoteForm,
    const SchemeSymbol('delay') : doDelayForm,
    const SchemeSymbol('cons-stream') : doConsStreamForm,
    const SchemeSymbol('define-macro') : doDefineMacroForm,
    const SchemeSymbol('set!') : doSetForm,
    const SchemeSymbol('quasiquote') : doQuasiquoteForm,
    const SchemeSymbol('unquote') : doUnquoteForm,
    const SchemeSymbol('unquote-splicing') : doUnquoteSplicingForm
  };
}

Expression evalCallExpression(Pair expr, Frame env) {
  if (!expr.isWellFormedList()) {
    throw new SchemeException("Malformed list: $expr");
  }
  Expression first = expr.first;
  Expression rest = expr.second;
  if (first is SchemeSymbol && env.interpreter.specialForms.containsKey(first)) {
    return env.interpreter.specialForms[first](rest, env);
  }
  return env.interpreter.implementation.evalProcedureCall(first, rest, env);
}
