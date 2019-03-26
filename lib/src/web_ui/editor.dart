library web_ui.editor;

import 'dart:html';

import 'package:cs61a_scheme/cs61a_scheme_web.dart';

import 'code_input.dart';

class Editor {
  /// The element that this editor is contained in.
  Element container;

  /// The sidebar element for this editor.
  Element sidebar;

  /// The tab element for this editor.
  Element tabs;

  /// The list of buffers open in this editor.
  List<Buffer> buffers;

  /// This editor's global interpreter.
  Interpreter interpreter;

  Map<String, Docs> _docs;

  Editor(this.interpreter, this.container) {
    _docs = allDocumentedForms(interpreter.globalEnv);
    buffers = [Buffer.empty(_docs)];
    sidebar = DivElement()..classes = ['sidebar'];
    container.append(sidebar);
    var content = DivElement()..classes = ['content'];
    tabs = DivElement()..classes = ['tabs'];
    content.append(tabs);
    content.append(buffers.first.element);
    container.append(content);
    buffers.first.input.enableAutocomplete();
  }
}

class Buffer {
  Element element;
  String text;
  CodeInput input;
  Buffer.empty(Map<String, Docs> docs) {
    element = DivElement()..classes = ['buffer'];
    text = "(define (fact n))";
    input = CodeInput(element, null, docs, parenListener: onParenStatus);
    input.text = text;
  }

  onParenStatus(int parens) {
    // TODO
  }
}
