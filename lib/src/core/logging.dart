library cs61a_scheme.core.logging;

import 'expressions.dart';

typedef void Logger(Expression expr, bool newline);

Logger combineLoggers(Logger a, Logger b) {
  return (Expression e, bool newline) {
    a(e, newline);
    b(e, newline);
  };
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
  final List<Expression> callStack = [];
  SchemeException([this.message = null, this.showTrace = true, this.context]);

  toString() {
    if (!showTrace || callStack.isEmpty) return 'Error: $message';
    var str = 'Traceback (most recent call last)\n';
    for (int i = 0; i < callStack.length; i++) {
      str += '$i\t${callStack[i]}\n';
    }
    return str + 'Error: $message';
  }

  addCall(Expression expr) {
    callStack.insert(0, expr);
  }

  toJS() => this;
}

logMessage(String msg, Frame env) {
  return env.interpreter.logger(new TextMessage(msg), true);
}

class ExitException {
  const ExitException();
}
