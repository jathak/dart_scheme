# cs61a_scheme

An implementation of [61A Scheme][spec] in Dart, designed for use both in the
Dart VM and on the web.

This will eventually be used as the backend for [scheme.cs61a.org][web].
For now, builds using this interpreter will be posted [here][debug].

This implementation is **not** complete. You must implement
`ProjectInterface` (in `lib/src/core/project_interface.dart`). You can skip
implementing certain optional pieces of the interpreter by adding the other
classes in that file as mixins. If you are a Berkeley student, distributing an
implementation of `ProjectInterface` constitutes academic dishonesty as
described in our [course policies][policy], as the implementation is close
enough the the Scheme project's to be considered distribution of solutions,
despite the change of language from Python to Dart.

Official CS 61A projects can use our private staff implementation of 
`ProjectInterface` by adding the following to the `pubspec.yaml`:

    dependencies:
        dart_scheme_impl:
            git: git@github.com:Cal-CS-61A-Staff/dart_scheme_impl.git

For your project to build, you'll need to have SSH keys attached to your
GitHub account and access to the repo.

[spec]: https://cs61a.org/articles/scheme-spec.html
[web]: https://scheme.cs61a.org
[debug]: https://scheme.jathak.xyz
