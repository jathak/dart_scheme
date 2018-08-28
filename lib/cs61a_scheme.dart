/// The core Scheme interpreter.
///
/// This library contains only what is necessary to match the behavior of the
/// Python implementation of 61A Scheme, as well as some additional
/// functionality that classes here depend on (notably, some pieces of the UI
/// framework used for diagramming).
library cs61a_scheme.core;

export 'src/core/documentation.dart';
export 'src/core/expressions.dart';
export 'src/core/frame.dart';
export 'src/core/interpreter.dart';
export 'src/core/logging.dart';
export 'src/core/numbers.dart';
export 'src/core/procedures.dart';
export 'src/core/project_interface.dart';
export 'src/core/reader.dart';
export 'src/core/scheme_library.dart';
export 'src/core/serialization.dart';
export 'src/core/standard_library.dart';
export 'src/core/utils.dart';
export 'src/core/values.dart';
export 'src/core/widgets.dart';
export 'src/core/wrappers.dart';
