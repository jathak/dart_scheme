library cs61a_scheme.core.scheme_library;

import 'expressions.dart';

/// A SchemeLibrary is an interface for loading Dart functions (or other values
/// originating from Dart code) into a Scheme environment. importAll should bind
/// all of the library's names in the provided environment.
/// The other import functions load one or more of the bindings by first
/// importing all bindings into a child of the provided environment and then
/// copying the selected names over.
/// 
/// For easy use with libraries of simple Dart functions, see the
/// @register annotation.
abstract class SchemeLibrary {
  /// Loads all bindings. Either use @register override manually.
  void importAll(Frame env) {
    throw new UnimplementedError();
  }
  
  /// Loads only the single named binding into env.
  void importSingle(Frame env, SchemeSymbol name) {
    import(env, [name]);
  }
  
  /// Loads only the listed bindings into env.
  void import(Frame env, Iterable<SchemeSymbol> names) {
    Frame inner = new Frame(env, env.interpreter);
    importAll(inner);
    for (var name in names) {
      if (inner.bindings.containsKey(name)) {
        env.define(name, inner.bindings[name]);
      }
    }
  }
}


/// Annotation on a SchemeLibrary to generate importAll.
/// importAll should not be overriden in user code.
const _Register register = const _Register();
class _Register { const _Register(); }

/// Annotation on each primitive procedure to register.
const _Primitive primitive = const _Primitive();
class _Primitive { const _Primitive(); }

/// Annotation to make a SpecialFormPrimitiveProcedure
/// This procedure is defined in the extra library, so don't use this inside
/// the core library.
const _NoEval noeval = const _NoEval();
class _NoEval { const _NoEval(); }

/// Annotation to specify a name other than the function name for the
/// Scheme binding.

/// Annotation to specify MinArgs when primitive takes a list.
/// If not set, defaults to 0 (no minimum)
class MinArgs {
  final int value;
  const MinArgs(this.value);
}

/// Annotation to specify MaxArgs when primitive takes a list.
/// If not set, defaults to -1 (no maximum)
class MaxArgs {
  final int value;
  const MaxArgs(this.value);
}

/// Annotation to trigger event after evaluation, passing a pair of the
/// return value and the current environment.
class TriggerEventAfter {
  final SchemeSymbol id;
  const TriggerEventAfter(this.id);
}
