library cs61a_scheme.web.imports;

import 'dart:async';
import 'dart:html' as html;

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

class ImportedLibrary extends SelfEvaluating {
  Frame env;
  String code;

  ImportedLibrary._internal();

  _init(String code, Frame containing) async {
    this.code = code;
    env = containing;
    List<Expression> tokens = tokenizeLines(code.split('\n')).toList();
    while (tokens.isNotEmpty) {
      Expression expr = schemeRead(tokens, env.interpreter.implementation);
      Expression result = schemeEval(expr, env);
      if (result is AsyncExpression) {
        await result.future;
      }
    }
  }

  static Future<ImportedLibrary> load(String code, Frame parent) async {
    ImportedLibrary library = new ImportedLibrary._internal();
    await library._init(code, new Frame(parent, parent.interpreter));
    library.env.tag = '#imported';
    return library;
  }

  static Future<ImportedLibrary> loadInline(String code, Frame env) async {
    ImportedLibrary library = new ImportedLibrary._internal();
    await library._init(code, env);
    return library;
  }

  Expression reference(SchemeSymbol symbol) {
    if (!env.bindings.containsKey(symbol)) {
      throw new SchemeException("Cannot find $symbol in library");
    }
    return env.bindings[symbol];
  }

  void extract(SchemeSymbol symbol, Frame parent, [bool hide = true]) {
    parent.define(symbol, reference(symbol));
  }

  toJS() => this;
  toString() => '#imported-library';
}

Future<ImportedLibrary> import(String id, List<SchemeSymbol> imports, Frame env,
    [bool inline = false]) async {
  String code;
  if (id.startsWith('scm/')) {
    code = await html.HttpRequest.getString('$id.scm');
  } else if (id.startsWith('http://') || id.startsWith('https://')) {
    code = await html.HttpRequest.getString(id);
  } else if (id.endsWith('.scm')) {
    code = await html.HttpRequest.getString('http://$id');
  } else {
    html.Storage storage = html.window.localStorage;
    if (!storage.containsKey('scm-file://$id')) {
      throw new SchemeException("User file '$id' does not exist!");
    }
    code = storage['scm-file://$id'];
  }
  ImportedLibrary lib;
  if (inline) {
    lib = await ImportedLibrary.loadInline(code, env);
  } else {
    lib = await ImportedLibrary.load(code, env);
    for (SchemeSymbol import in imports) {
      lib.extract(import, env);
    }
  }
  return lib;
}
