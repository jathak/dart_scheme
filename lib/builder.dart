library builder;

import 'dart:convert' show JSON;

import 'package:analyzer/analyzer.dart';

/// Generates mixin source code to implement importAll on a SchemeLibrary
/// based on the library's source code.
String generateImportMixin(String sourceCode) {
  CompilationUnit ast = parseCompilationUnit(sourceCode);
  for (CompilationUnitMember decl in ast.declarations) {
    if (decl is ClassDeclaration) {
      for (Annotation annotation in decl.metadata) {
        if (annotation.name.toSource() == "register") {
          return _buildMixin(decl);
        }
      }
    }
  }
  return null;
}

String _buildMixin(ClassDeclaration decl) {
  String className = decl.name.toSource();
  List<String> primitives = [];
  for (ClassMember member in decl.members) {
    if (member is MethodDeclaration) {
      for (Annotation annotation in member.metadata) {
        if (annotation.name.toSource() == "primitive") {
          primitives.add(_buildPrimitive(className, member));
        }
      }
    }
  }
  String mixinName = decl.withClause.mixinTypes[0].name.toSource();
  return """abstract class $mixinName {
  void importAll(Frame __env) {
    ${primitives.join("\n  ")}
  }
}""";
}

String _buildPrimitive(String className, MethodDeclaration method) {
  String name = JSON.encode(method.name.toSource().toLowerCase());
  bool variable = false;
  String minArgs = "0", maxArgs = "-1";
  for (Annotation ant in method.metadata) {
    if (ant.name.toSource() == "MinArgs") {
      minArgs = ant.arguments.arguments[0].toSource();
      variable = true;
    } else if (ant.name.toSource() == "MaxArgs") {
      maxArgs = ant.arguments.arguments[0].toSource();
      variable = true;
    } else if (ant.name.toSource() == "SchemeSymbol") {
      name = ant.arguments.arguments[0].toSource().toLowerCase();
    }
  }
  if (method.parameters.parameters.length > 0) {
    FormalParameter param = method.parameters.parameters[0];
    if (param is SimpleFormalParameter) {
      if (param.type.toSource() == "List<Expression>") {
        variable = true;
      }
    } else throw new Exception("Primitives may not have optional parameters.");
  }
  String symb = "const SchemeSymbol($name)";
  if (variable) {
    String fn = className + "." + method.name.toSource();
    if (method.parameters.parameters.length == 1) {
      fn = "(__exprs, __env) => $fn(__exprs)";
    } else if (method.parameters.parameters.length != 2) {
      throw new Exception("$fn has an invalid number of parameters!");
    }
    return "addVariablePrimitive(__env, $symb, $fn, $minArgs, $maxArgs);";
  } else {
    List<String> types = [];
    for (FormalParameter param in method.parameters.parameters) {
      if (param is SimpleFormalParameter) {
        if (param.type == null) {
          throw new Exception("Primitive parameters must be typed.");
        }
        types.add(param.type.toSource());
      } else throw new Exception("Primitives may not have optional parameters.");
    }
    bool takesFrame = types.length > 0 && types.last == "Frame";
    if (takesFrame) types.removeLast();
    String checks = "";
    var passes = [];
    var pieces = [];
    for (int i = 0; i < types.length; i++) {
      pieces.add("__exprs[$i] is! ${types[i]}");
      passes.add("__exprs[$i]");
    }
    if (types.any((type) => type != "Expression")) {
      var error = "Argument of invalid type passed to $name.";
      checks = "if(${pieces.join('||')}) throw new SchemeException('$error');";
    }
    if (takesFrame) passes.add("__env");
    var passStr = passes.join(",");
    String m = className + "." + method.name.toSource();
    String fn = "(__exprs, __env) { $checks return $m($passStr); }";
    return "addPrimitive(__env, $symb, $fn, ${types.length});";
  }
}
