library cs61a_scheme.core.logging;

import 'expressions.dart';

typedef void Logger(Expression expr, bool newline);

Logger combineLoggers(Logger a, Logger b) {
  return (Expression e, bool newline) { a(e, newline); b(e, newline); };
}

class DisplayOutput extends SelfEvaluating {
  final Expression expression;
  const DisplayOutput(this.expression);
  toString() => expression.display;
  toJS() => expression.toJS();
}

class TextMessage extends SelfEvaluating {
  final String message;
  const TextMessage(this.message);
  toString() => message;
  toJS() => message;
}

class SchemeException extends SelfEvaluating {
  final String message;
  final bool showTrace;
  final Expression context;
  const SchemeException([this.message = null, this.showTrace = true, this.context]);
  
  toString() => "SchemeException: $message";
  toJS() => this;
}

logMessage(String msg, Frame env) {
  return env.interpreter.logger(new TextMessage(msg), true);
}

class ExitException {
  const ExitException();
}
