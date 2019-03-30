import 'expressions.dart';
import 'interpreter.dart';
import 'logging.dart';
import 'special_forms.dart';
import 'values.dart';

abstract class Language {
  static const String id = null;
  const Language();

  Map<SchemeSymbol, SpecialForm> get specialForms => {
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

  T validateCdr<T extends Value>(T cdr, {String errorMessage}) => cdr;

  Expression readTail(List<Expression> tokens, Interpreter interpreter) {
    Expression first = tokens.first;
    if (first is SchemeSymbol && first.value == ')') {
      return interpreter.impl.readTailAtParen(tokens);
    } else {
      return interpreter.impl.readTailElse(tokens, interpreter);
    }
  }
}

class Fa18Language extends Language {
  static const id = "61a-scheme/fa18";
  static const instance = Fa18Language._();
  const Fa18Language._();
  toString() => id;

  @override
  Expression readTail(List<Expression> tokens, Interpreter interpreter) {
    Expression first = tokens.first;
    if (first is SchemeSymbol && first.value == '.') {
      return interpreter.impl.readTailAtDot(tokens, interpreter);
    }
    return super.readTail(tokens, interpreter);
  }
}

class Sp19Language extends Language {
  static const id = "61a-scheme/sp19";
  static const instance = Sp19Language._();
  const Sp19Language._();
  toString() => id;

  @override
  Map<SchemeSymbol, SpecialForm> get specialForms =>
      super.specialForms..[const SchemeSymbol('variadic')] = doVariadicForm;

  @override
  T validateCdr<T extends Value>(T cdr,
      {errorMessage: "The cdr of a list must be another list"}) {
    while (cdr is Pair) {
      cdr = (cdr as Pair).second;
    }
    if (cdr != nil && cdr is! Promise) {
      throw SchemeException(errorMessage);
    }
    return cdr;
  }
}

const languages = {
  'default': Sp19Language.instance,
  '61a-scheme': Sp19Language.instance,
  Sp19Language.id: Sp19Language.instance,
  Fa18Language.id: Fa18Language.instance
};
