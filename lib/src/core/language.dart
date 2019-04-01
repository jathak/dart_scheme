import 'expressions.dart';
import 'frame.dart';
import 'logging.dart';
import 'values.dart';

/// The Language class is used to provide alternate semantics for certain Scheme
/// features.
abstract class Language {
  static const String id = null;
  const Language();

  /// If true, interpret `.` by traditional Lisp semantics (used in 61A
  /// through Fa18) where it's used as a separator between the car and the cdr
  /// in a pair literal. If false, interpret it as shorthand for the `variadic`
  /// special form.
  bool get dotAsCons;

  /// By default, this does nothing. If a language wishes to apply some
  /// additional rules to cdrs, error if they are not followed. Otherwise, just
  /// return the cdr.
  T validateCdr<T extends Value>(T cdr, {String errorMessage}) => cdr;
}

/// A special expression used by the tokenizer to indicate a language change
/// directive.
class LanguageChange extends Expression {
  String languageId;
  LanguageChange(this.languageId);

  /// When this is evaluated, it changes the current interpreter's language to
  /// the one with id [languageId].
  evaluate(Frame env) {
    if (!languages.containsKey(languageId)) {
      throw SchemeException('Unknown language "$languageId"');
    } else {
      env.interpreter.language = languages[languageId];
      return undefined;
    }
  }
}

/// The default Scheme semantics through Fa18. Treats `.` as cons.
class Fa18Language extends Language {
  static const id = "61a-scheme/fa18";
  static const instance = Fa18Language._();
  const Fa18Language._();
  toString() => id;

  final bool dotAsCons = true;
}

/// New Scheme semantics adopted in Sp19. Mandates that all cdrs are either
/// pairs, lists, or promises.
class Sp19Language extends Language {
  static const id = "61a-scheme/sp19";
  static const instance = Sp19Language._();
  const Sp19Language._();
  toString() => id;

  final bool dotAsCons = false;

  @override
  T validateCdr<T extends Value>(T cdr,
      {errorMessage = "The cdr of a list must be another list"}) {
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

/// A mapping from ids to languages. Some languages may have multiple aliases.
const languages = {
  'default': Sp19Language.instance,
  '61a-scheme': Sp19Language.instance,
  Sp19Language.id: Sp19Language.instance,
  Fa18Language.id: Fa18Language.instance
};
