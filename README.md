# cs61a_scheme [![Build Status](https://travis-ci.org/Cal-CS-61A-Staff/dart_scheme.svg?branch=master)](https://travis-ci.org/Cal-CS-61A-Staff/dart_scheme)

An implementation of [61A Scheme][spec] in Dart, designed for use both in the
Dart VM and on the web.

This is used as the backend for [scheme.cs61a.org][web]. The frontend code for
that is available [here][frontend].

## Interpreter Libraries

This package includes three interpreter libraries: core, extra, and web.

The core library includes only enough functionality to match the Python
implementation (plus a few pieces of UI code). The extra library includes
everything in the core library, plus asynchronous expressions, diagramming,
visualization, and tracing. The web library includes everything in the extra
library, plus a renderer for diagrams, JS interop, themes, turtle graphics, and
support for importing files from a URL.

You can import an interpreter library with one of the following lines:

```dart
import 'package:cs61a_scheme/cs61a_scheme.dart';
import 'package:cs61a_scheme/cs61a_scheme_extra.dart';
import 'package:cs61a_scheme/cs61a_scheme_web.dart';
```

You only need to import one. The web library depends on `dart:html`, but the
other two can be used in both the browser and the Dart VM.

## Project Implementation

This implementation is **not** complete. You must implement
`ProjectInterface` (in `lib/src/core/project_interface.dart`). You can skip
implementing certain optional pieces of the interpreter by adding the other
classes in that file as mixins.

61A staff members can use our private staff implementation of `ProjectInterface`
in the dart_scheme_impl repo of our org. A skeleton of this implementation is
available publicly [here][skeleton]. We ask that you do not distribute the
source code for a `ProjectInterface` implementation.

Additionally, if you are a Berkeley student, **publicly distributing an
implementation of `ProjectInterface` constitutes academic dishonesty as
described in our [course policies][policy]**, as the implementation is close
enough to the Scheme project's to be considered distribution of solutions,
despite the change of language from Python to Dart. This applies even if you are
not currently taking 61A.

## Contributing

See [CONTRIBUTING.md][] for instructions.




[policy]: https://cs61a.org/articles/about.html#academic-honesty
[frontend]: https://github.com/Cal-CS-61A-Staff/scheme_web_interpreter
[spec]: https://cs61a.org/articles/scheme-spec.html
[web]: https://scheme.cs61a.org
[skeleton]: https://github.com/jathak/scheme_impl_skeleton
[CONTRIBUTING.md]: https://github.com/Cal-CS-61A-Staff/dart_scheme/blob/master/CONTRIBUTING.md
