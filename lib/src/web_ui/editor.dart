library web_ui.editor;

import 'dart:convert' show json;
import 'dart:html';
import 'dart:math';

import 'package:cs61a_scheme/cs61a_scheme_web.dart';

import 'code_input.dart';

/// A tabbed editor.
class Editor {
  /// The element that this editor is contained in.
  Element container;

  /// The sidebar element for this editor.
  Element sidebar;

  /// The tab element for this editor.
  Element tabs;

  /// The element that contains the tabs and visible buffer.
  Element content;

  /// The list of buffers open in this editor.
  List<Buffer> buffers;

  /// This editor's global interpreter.
  Interpreter interpreter;

  Map<String, Docs> docs;

  /// The index of the tab that is currently active.
  int activeTab;

  /// Loads an editor attached to [interpreter] into [container].
  Editor(this.interpreter, this.container) {
    docs = allDocumentedForms(interpreter.globalEnv);
    buffers = [];
    sidebar = DivElement()..classes = ['sidebar'];
    container.append(sidebar);
    var toggle = DivElement()..classes = ['sidebar-toggle'];
    toggle.onClick.listen((e) {
      if (sidebar.classes.contains('collapsed')) {
        sidebar.classes.remove('collapsed');
      } else {
        sidebar.classes.add('collapsed');
      }
      saveState();
    });
    container.append(toggle);
    content = DivElement()..classes = ['content'];
    tabs = DivElement()..classes = ['tabs'];
    content.append(tabs);
    tabs.append(DivElement()
      ..classes = ['new-tab']
      ..text = '+'
      ..onClick.listen((event) {
        newTab();
      }));
    container.append(content);
    if (window.localStorage.containsKey('#editor-state')) {
      restoreState(json.decode(window.localStorage['#editor-state']));
    } else {
      newTab();
    }
  }

  /// Opens a new tab with [text].
  ///
  /// This will become the active tab if [active] is true.
  newTab({String text = "", bool active = true}) {
    var buffer = Buffer.text(text, this)..attachTab(tabs);
    buffer.input.enableAutocomplete();
    buffers.add(buffer);
    if (active) replaceBuffer(buffer);
    buffer.input.parenListener = (_) => saveState();
  }

  /// Closes [buffer].
  ///
  /// If this was the last buffer in the editor, closes the editor.
  closeTab(Buffer buffer) {
    bool active = buffer.tab.classes.contains('tab-active');
    int index = buffers.indexOf(buffer);
    buffers.remove(buffer);
    buffer.tab.remove();
    if (buffers.isEmpty) {
      closeEditor();
    } else if (active) {
      replaceBuffer(buffers[max(index - 1, 0)]);
    }
    saveState();
  }

  closeEditor() {
    container.remove();
  }

  /// Makes [buffer] the active tab.
  replaceBuffer(Buffer buffer) {
    for (var child in tabs.children) {
      child.classes.remove('tab-active');
    }
    buffer.tab.classes.add('tab-active');
    if (content.children.length > 1) {
      content.lastChild.remove();
    }
    content.append(buffer.element);
    activeTab = buffers.indexOf(buffer);
    buffer.input.highlight(saveCursor: true);
    saveState();
  }

  /// Saves the state of the editor.
  saveState() {
    if (buffers.isEmpty) {
      window.localStorage.remove('#editor-state');
      return;
    }
    var state = {
      'sidebar-collapsed': sidebar.classes.contains('collapsed'),
      'tabs': buffers.map((b) => b.serialize()).toList(),
      'activeTab': activeTab
    };
    window.localStorage['#editor-state'] = json.encode(state);
  }

  /// Restores a previously saved editor state.
  restoreState(Map state) {
    if (state['sidebar-collapsed']) {
      sidebar.classes.add('collapsed');
    }
    for (var tab in state['tabs']) {
      buffers.add(Buffer.deserialize(tab, this)..attachTab(tabs));
    }
    for (var buffer in buffers) {
      buffer.input.parenListener = (_) => saveState();
    }
    replaceBuffer(buffers[state['activeTab']]);
  }
}

/// An editor window built on [CodeInput].
class Buffer {
  /// The editor this buffer is attached to.
  final Editor editor;

  /// The DOM element for thsi buffer.
  Element element;

  /// The input field for this buffer.
  CodeInput input;

  /// The DOM element this buffer's tab (if any) is stored in.
  Element tab;

  /// The title of this buffer if any.
  String title;

  /// Creates a new buffer with [text] attached to [editor].
  Buffer.text(String text, this.editor) {
    element = DivElement()..classes = ['buffer'];
    var inputElement = DivElement()..classes = ['input-wrapper'];
    element.append(inputElement);
    input = CodeInput(inputElement, null, editor.docs);
    input.text = text;
  }

  /// Deserializes a previously serialized buffer.
  Buffer.deserialize(Map serialized, this.editor) {
    element = DivElement()..classes = ['buffer'];
    var inputElement = DivElement()..classes = ['input-wrapper'];
    element.append(inputElement);
    input = CodeInput(inputElement, null, editor.docs);
    input.text = serialized['text'];
    title = serialized['title'];
  }

  /// Constructs a tab that's associated with this buffer.
  attachTab(Element tabContainer) {
    tab = Element.div()..classes = ['tab'];
    var tabTitle = Element.span()..text = title ?? 'Untitled';
    var tabClose = Element.div()
      ..classes = ['tab-close']
      ..text = '×';
    /*var tabIndicator = Element.div()
      ..classes = ['tab-indicator']
      ..text = ' ';*/
    tab.append(tabTitle);
    tab.append(tabClose);
    //tab.append(tabIndicator);
    tab.onClick.listen((e) {
      if (e.target != tabClose) editor.replaceBuffer(this);
    });
    tabClose.onClick.listen((e) {
      editor.closeTab(this);
    });
    tabContainer.append(tab);
  }

  /// Serializes this buffer.
  serialize() => {'title': title, 'text': input.text};
}
