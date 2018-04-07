library builder;

import 'package:dart2_constant/convert.dart' show json;

import 'package:analyzer/analyzer.dart';

/// Generates mixin source code to implement importAll on a SchemeLibrary
/// based on the library's source code.
String generateImportMixin(String sourceCode) {
  CompilationUnit ast = parseCompilationUnit(sourceCode);
  for (CompilationUnitMember decl in ast.declarations) {
    if (decl is ClassDeclaration) {
      for (Annotation annotation in decl.metadata) {
        if (annotation.name.toSource() == "schemelib") {
          return _buildMixin(decl);
        }
      }
    }
  }
  return null;
}

String _buildMixin(ClassDeclaration decl) {
  List<String> primitives = [];
  List<String> abstractMethods = [];
  bool myNeedsTurtle = false;
  for (ClassMember member in decl.members) {
    if (member is MethodDeclaration) {
      String name = member.name.toSource();
      if (!name.startsWith('import') && !name.startsWith('_')) {
        needsTurtle = false;
        abstractMethods.add(_buildAbstract(member));
        primitives.add(_buildPrimitive(member));
        myNeedsTurtle = myNeedsTurtle || needsTurtle;
      }
    }
  }
  needsTurtle = false;
  if (myNeedsTurtle) {
    abstractMethods.add('Turtle get turtle;');
  }
  String mixinName = decl.withClause.mixinTypes[0].name.toSource();
  return """abstract class $mixinName {
  ${abstractMethods.join("\n  ")}
  void importAll(Frame __env) {
    ${primitives.join("\n    ")}
  }
}""";
}

String _buildAbstract(MethodDeclaration method) {
  return "${method.returnType} ${method.name}${method.parameters};";
}

bool needsTurtle = false;

String _buildPrimitive(MethodDeclaration method) {
  String name = json.encode(method.name.toSource().toLowerCase());
  bool setName = false;
  List<String> extraNames = [];
  bool variable = false;
  String minArgs = "0", maxArgs = "-1";
  String returning = 'return';
  String after = ";";
  String op = "";
  String before = "";
  for (Annotation ant in method.metadata) {
    if (ant.name.toSource() == "MinArgs") {
      minArgs = ant.arguments.arguments[0].toSource();
      variable = true;
    } else if (ant.name.toSource() == "MaxArgs") {
      maxArgs = ant.arguments.arguments[0].toSource();
      variable = true;
    } else if (ant.name.toSource() == "SchemeSymbol") {
      if (!setName) {
        name = ant.arguments.arguments[0].toSource().toLowerCase();
        setName = true;
      } else {
        extraNames.add(ant.arguments.arguments[0].toSource().toLowerCase());
      }
    } else if (ant.name.toSource() == "TriggerEventAfter") {
      String symbol = ant.arguments.arguments[0].toSource();
      returning = 'var __value =';
      after += " __env.interpreter.triggerEvent($symbol, [__value], __env);";
    } else if (ant.name.toSource() == "noeval") {
      op = "Operand";
    } else if (ant.name.toSource() == 'turtlestart') {
      needsTurtle = true;
      before += 'turtle.show();';
    }
  }
  String returnType = method.returnType.toSource();
  if (returnType == 'void') {
    returning = 'var __value = undefined; ';
    after += ' return __value;';
  } else if (returnType == 'int') {
    returning += ' new Number.fromInt(';
    after = ')' + after;
  } else if (returnType == 'double') {
    returning += ' new Number.fromDouble(';
    after = ')' + after;
  } else if (returnType == 'num') {
    returning += ' new Number.fromNum(';
    after = ')' + after;
  } else if (returnType == 'String') {
    returning += ' new SchemeString(';
    after = ')' + after;
  } else if (returnType == 'bool') {
    returning += ' new Boolean(';
    after = ')' + after;
  } else if (returnType == 'Future<Expression>') {
    returning += ' new AsyncExpression(';
    after = ')' + after;
  } else if (returnType == 'JsFunction') {
    returning += ' new JsProcedure(';
    after = ')' + after;
  } else if (returnType == 'JsObject') {
    returning += ' new JsExpression(';
    after = ')' + after;
  }
  if (method.parameters.parameters.length > 0) {
    FormalParameter param = method.parameters.parameters[0];
    if (param is SimpleFormalParameter) {
      if (param.type.toSource() == "List<Expression>") {
        variable = true;
      }
    } else {
      throw new Exception("Primitives may not have optional parameters.");
    }
  }
  String symb = "const SchemeSymbol($name)";
  var extraSymbs = extraNames.map((name) => "const SchemeSymbol($name)");
  String extra = "";
  for (String symbol in extraSymbs) {
    extra += '__env.bindings[$symbol] = __env.bindings[$symb];';
    extra += '__env.hidden[$symbol] = true;';
  }
  if (variable) {
    String fn = "this." + method.name.toSource();
    int paramCount = method.parameters.parameters.length;
    if (paramCount != 1 && paramCount != 2) {
      throw new Exception("$fn has an invalid number of parameters!");
    }
    if (after != "") {
      String args = paramCount == 1 ? '__exprs' : '__exprs, __env';
      fn = "(__exprs, __env) {$before$returning $fn($args)$after}";
    } else if (paramCount == 1) {
      fn = "(__exprs, __env) {$before$returning $fn(__exprs)$after}";
    }
    return "addVariable${op}Primitive(__env, $symb, $fn, $minArgs, $maxArgs);$extra";
  } else {
    List<String> types = [];
    for (FormalParameter param in method.parameters.parameters) {
      if (param is SimpleFormalParameter) {
        if (param.type == null) {
          throw new Exception("Primitive parameters must be typed.");
        }
        types.add(param.type.toSource());
      } else {
        throw new Exception("Primitives may not have optional parameters.");
      }
    }
    bool takesFrame = types.length > 0 && types.last == "Frame";
    if (takesFrame) types.removeLast();
    String checks = "";
    var passes = [];
    var pieces = [];
    for (int i = 0; i < types.length; i++) {
      if (types[i] == 'int') {
        pieces.add("(__exprs[$i] is! Integer)");
        passes.add("__exprs[$i].toJS().toInt()");
      } else if (types[i] == 'double') {
        pieces.add("(__exprs[$i] is! Double)");
        passes.add("__exprs[$i].toJS().toDouble()");
      } else if (types[i] == 'num') {
        pieces.add("__exprs[$i] is! Number");
        passes.add("__exprs[$i].toJS()");
      } else if (types[i] == 'bool') {
        pieces.add("__exprs[$i] is! Boolean");
        passes.add("__exprs[$i].isTruthy");
      } else if (types[i] == 'String') {
        pieces.add("__exprs[$i] is! SchemeString");
        passes.add("(__exprs[$i] as SchemeString).value");
      } else {
        pieces.add("__exprs[$i] is! ${types[i]}");
        passes.add("__exprs[$i]");
      }
    }
    if (types.any((type) => type != "Expression")) {
      var decodeName = name.substring(1, name.length - 1);
      var error = "Argument of invalid type passed to ${decodeName}.";
      checks = "if(${pieces.join('||')}) throw new SchemeException('$error');";
    }
    if (takesFrame) passes.add("__env");
    var passStr = passes.join(",");
    var m = "this." + method.name.toSource();
    var fn = "(__exprs, __env){$checks $before $returning $m($passStr)$after }";
    return "add${op}Primitive(__env, $symb, $fn, ${types.length});$extra";
  }
}
