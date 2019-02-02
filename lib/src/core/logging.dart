library cs61a_scheme.core.logging;

import 'expressions.dart';
import 'frame.dart';
import 'values.dart';

/// Logs [value] somewhere with a new line if [addNewLine] is true.
typedef Logger = void Function(Value value, bool addNewLine);

/// Given two loggers, returns a new one that calls both.
Logger combineLoggers(Logger a, Logger b) => (e, addNewLine) {
      a(e, addNewLine);
      b(e, addNewLine);
    };

/// Scheme value representing a value to be displayed.
///
/// Used by the built-in `display` Scheme procedure.
class DisplayOutput extends Value {
  final Value value;
  const DisplayOutput(this.value);
  toString() => value.display;
  toJS() => value.toJS();
}

/// Scheme value representing text to be outputted.
///
/// Used for logging.
class TextMessage extends Value {
  final String message;
  const TextMessage(this.message);
  toString() => message;
  toJS() => message;
}

/// An exception within Scheme code.
///
/// This exception can be thrown to keep track of a stack trace through Scheme
/// code. While other Dart errors will still be caught by the outer interpreter
/// loop, throwing a [SchemeException] ensures that the logged stack trace is
/// for Scheme, not Dart/JS.
class SchemeException extends Value implements Exception {
  final String message;
  final bool showTrace;
  final Expression context;
  final List<Value> callStack = [];
  SchemeException([this.message, this.showTrace = true, this.context]);

  toString() {
    if (!showTrace || callStack.isEmpty) return 'Error: $message';
    var str = 'Traceback (most recent call last)\n';
    for (int i = 0; i < callStack.length; i++) {
      str += '$i\t${callStack[i]}\n';
    }
    return str + 'Error: $message';
  }

  // Adds [expr] to the stack trace of this exception.
  addCall(Value expr) {
    callStack.insert(0, expr);
  }
}

/// Logs [msg] to the interpreter's logger through a [TextMessage].
logMessage(String msg, Frame env) =>
    env.interpreter.logger(TextMessage(msg), true);

/// Thrown by the built-in `exit` Scheme procedure.
class ExitException implements Exception {
  const ExitException();
}
