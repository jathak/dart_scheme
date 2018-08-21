library cs61a_scheme.core.documentation;

import 'widgets.dart';

class Docs extends Widget {
  final String canonicalName;
  final String comment;
  final bool isSpecialForm;
  final bool isVariableArity;
  final List<Param> params;
  final String returnType;

  Docs(this.canonicalName, this.comment, this.params,
      {this.returnType, this.isSpecialForm = false})
      : isVariableArity = false;

  Docs.variable(this.canonicalName, this.comment,
      {this.returnType, this.isSpecialForm = false})
      : isVariableArity = true,
        params = null;

  toString() => "Docs for $canonicalName:\n$comment";
}

class Param {
  final String type;
  final String name;
  Param(this.type, this.name);
}
