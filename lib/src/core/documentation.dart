library cs61a_scheme.core.documentation;

import 'widgets.dart';

part 'documentation.g.dart';

class Docs extends Widget {
  final String canonicalName;
  final String comment;
  final bool isVariableArity;
  final List<Param> params;
  final String returnType;
  final bool isMarkdown;

  Docs(this.canonicalName, this.comment, this.params, {this.returnType})
      : isVariableArity = false,
        isMarkdown = false;

  Docs.variable(this.canonicalName, this.comment, {this.returnType})
      : isVariableArity = true,
        params = null,
        isMarkdown = false;

  Docs.markdown(this.comment)
      : isMarkdown = true,
        canonicalName = null,
        isVariableArity = null,
        returnType = null,
        params = null;

  toString() => "Docs for $canonicalName:\n$comment";
}

class Param {
  final String type;
  final String name;
  Param(this.type, this.name);
}
