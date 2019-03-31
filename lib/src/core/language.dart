import 'expressions.dart';
import 'frame.dart';
import 'logging.dart';
import 'values.dart';

abstract class Language {
  static const String id = null;
  const Language();

  bool get dotAsCons;

  T validateCdr<T extends Value>(T cdr, {String errorMessage}) => cdr;
}

class LanguageChange extends Expression {
  String languageId;
  LanguageChange(this.languageId);

  evaluate(Frame env) {
    if (!languages.containsKey(languageId)) {
      throw SchemeException('Unknown language "$languageId"');
    } else {
      env.interpreter.language = languages[languageId];
      return undefined;
    }
  }
}

class Fa18Language extends Language {
  static const id = "61a-scheme/fa18";
  static const instance = Fa18Language._();
  const Fa18Language._();
  toString() => id;

  final bool dotAsCons = true;
}

class Sp19Language extends Language {
  static const id = "61a-scheme/sp19";
  static const instance = Sp19Language._();
  const Sp19Language._();
  toString() => id;

  final bool dotAsCons = false;

  @override
  T validateCdr<T extends Value>(T cdr,
      {errorMessage: "The cdr of a list must be another list"}) {
    Value checkCdr = cdr;
    while (checkCdr is Pair) {
      checkCdr = (checkCdr as Pair).second;
    }
    if (checkCdr != nil && checkCdr is! Promise) {
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
