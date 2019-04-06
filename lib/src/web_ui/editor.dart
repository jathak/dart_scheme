library web_ui.editor;

import 'dart:convert' show json;
import 'dart:html';
import 'dart:math';

import 'package:cs61a_scheme/cs61a_scheme_web.dart';

import 'code_input.dart';
import 'repl.dart';

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

  /// Height of the drawer when visible.
  int drawerHeight = 350;

  /// Width of the sidebar when visible.
  int sidebarWidth = 300;

  /// Loads an editor attached to [interpreter] into [container].
  Editor(this.interpreter, this.container) {
    docs = allDocumentedForms(interpreter.globalEnv);
    buffers = [];
    sidebar = DivElement()..classes = ['sidebar'];
    var toggle = DivElement()..classes = ['sidebar-toggle'];
    var sidebarAdjust = DivElement()..classes = ['sidebar-adjust'];
    toggle.onClick.listen((e) {
      if (sidebar.classes.contains('collapsed')) {
        sidebar.classes.remove('collapsed');
      } else {
        sidebar.classes.add('collapsed');
      }
      saveState();
    });
    container.append(toggle);
    container.append(sidebar);
    sidebarAdjust.onMouseDown.listen((e) {
      var oldWidth = sidebarWidth;
      if (sidebar.classes.contains('collapsed')) {
        sidebar.style.width = '0';
        sidebar.classes.remove('collapsed');
      }
      var listeners = [
        container.onMouseMove.listen((e) {
          sidebarWidth = e.client.x - toggle.clientWidth;
          sidebar.style.width = '${sidebarWidth}px';
        })
      ];
      var cancelAll = (e) {
        for (var listener in listeners) {
          listener.cancel();
        }
        if (sidebarWidth < 20) {
          sidebarWidth = oldWidth;
          sidebar.style.width = '${sidebarWidth}px';
          sidebar.classes.add('collapsed');
        }
        saveState();
      };
      listeners.add(container.onMouseUp.listen(cancelAll));
      listeners.add(container.onMouseLeave.listen(cancelAll));
    });
    container.append(sidebarAdjust);
    content = DivElement()..classes = ['content'];
    tabs = DivElement()..classes = ['tabs'];
    content.append(tabs);
    tabs.append(DivElement()
      ..classes = ['new-tab']
      ..text = '＋'
      ..onClick.listen((event) {
        newTab();
      }));
    container.append(content);
    setupSidebar();
    setupKeyboardShortcuts();
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

  /// Closes this editor.
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
      'activeTab': activeTab,
      'drawerHeight': drawerHeight,
      'sidebarWidth': sidebarWidth,
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
    drawerHeight = state['drawerHeight'] ?? 350;
    sidebarWidth = state['sidebarWidth'] ?? 300;
    sidebar.style.width = '${sidebarWidth}px';
    replaceBuffer(buffers[state['activeTab']]);
  }

  /// Sets up the sidebar with sections for user files and themes and sample
  /// files and themes.
  setupSidebar() {
    sidebar.append(DivElement()
      ..classes = ['sidebar-header']
      ..text = 'My Files');
    var myFiles = DivElement()..classes = ['sidebar-section'];
    sidebar.append(myFiles);
    sidebar.append(DivElement()
      ..classes = ['sidebar-header']
      ..text = 'My Themes');
    var myThemes = DivElement()..classes = ['sidebar-section'];
    sidebar.append(myThemes);
    sidebar.append(DivElement()
      ..classes = ['sidebar-header']
      ..text = 'Sample Apps');
    var sampleApps = DivElement()..classes = ['sidebar-section'];
    addSampleApp(sampleApps, "chess");
    addSampleApp(sampleApps, "drawing");
    sidebar.append(sampleApps);
    sidebar.append(DivElement()
      ..classes = ['sidebar-header']
      ..text = 'Sample Themes');
    var sampleThemes = DivElement()..classes = ['sidebar-section'];
    addSampleTheme(sampleThemes, "default");
    addSampleTheme(sampleThemes, "solarized");
    addSampleTheme(sampleThemes, "monochrome");
    addSampleTheme(sampleThemes, "monochrome-dark");
    addSampleTheme(sampleThemes, "go-bears");
    sidebar.append(sampleThemes);
  }

  /// Adds an entry to the sidebar section [container].
  addEntry(Element container, String text, Function onClick) {
    container.append(DivElement()
      ..classes = ['sidebar-entry']
      ..text = text
      ..onClick.listen((e) => onClick()));
  }

  /// Adds a sample app to the sidebar.
  addSampleApp(Element container, String id) {
    addEntry(container, '$id.scm', () async {
      var text = await HttpRequest.getString('scm/apps/$id.scm');
      newTab(text: text);
    });
  }

  /// Adds a sample theme to the sidebar.
  addSampleTheme(Element container, String id) {
    addEntry(container, '$id.scm', () async {
      var text = await HttpRequest.getString('scm/theme/$id.scm');
      newTab(text: text);
    });
  }

  /// Listens for keyboard shortcuts and adds links to the sidebar.
  setupKeyboardShortcuts() {
    altW() => closeTab(buffers[activeTab]);
    altT() => newTab();
    altR() => buffers[activeTab].run();
    altV() => buffers[activeTab].visualize();
    ctrlS() => buffers[activeTab].save();
    shiftTab(int amount) {
      activeTab += amount;
      if (activeTab >= buffers.length) activeTab = 0;
      if (activeTab < 0) activeTab = buffers.length - 1;
      replaceBuffer(buffers[activeTab]);
    }

    container.onKeyDown.listen((e) {
      print('${e.keyCode} ${e.key} ${e.ctrlKey} ${e.shiftKey} ${e.altKey}');
      if (e.altKey) {
        if (e.keyCode == KeyCode.W) {
          e.preventDefault();
          closeTab(buffers[activeTab]);
        } else if (e.keyCode == KeyCode.T) {
          e.preventDefault();
          newTab();
        } else if (e.keyCode == KeyCode.R) {
          e.preventDefault();
          buffers[activeTab].run();
        } else if (e.keyCode == KeyCode.V) {
          e.preventDefault();
          buffers[activeTab].visualize();
        }
      } else if (e.ctrlKey) {
        if (e.keyCode == KeyCode.S) {
          e.preventDefault();
          ctrlS();
        } else if (e.keyCode == KeyCode.APOSTROPHE) {
          e.preventDefault();
          shiftTab(e.shiftKey ? -1 : 1);
        }
      }
    });

    sidebar.append(DivElement()
      ..classes = ['sidebar-header']
      ..text = 'Keyboard Shortcuts');
    var shortcuts = DivElement()..classes = ['sidebar-section'];
    addEntry(shortcuts, "Close Tab (Alt-W)", altW);
    addEntry(shortcuts, "New Tab (Alt-T)", altT);
    addEntry(shortcuts, "Save (Ctrl-S)", ctrlS);
    addEntry(shortcuts, "Next Tab (Ctrl-`)", () => shiftTab(1));
    addEntry(shortcuts, "Previous Tab (Ctrl-Shift-`)", () => shiftTab(-1));
    addEntry(shortcuts, "Run Code (Alt-R)", altR);
    addEntry(shortcuts, "Visualize (Alt-V)", altV);
    sidebar.append(shortcuts);
  }
}

/// An editor window built on [CodeInput].
class Buffer {
  /// The editor this buffer is attached to.
  final Editor editor;

  /// The DOM element for this buffer.
  Element element;

  /// The input field for this buffer.
  CodeInput input;

  /// The DOM element for this buffer's drawer.
  Element drawer;

  /// The DOM element for the handle to adjust the height of the drawer.
  Element drawerAdjust;

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
    drawerAdjust = DivElement()..classes = ['drawer-adjust'];
    element.append(drawerAdjust);
    drawer = DivElement()..classes = ['drawer'];
    element.append(drawer);
    var buttonContainer = DivElement()..classes = ['buttons'];
    setupButtons(buttonContainer);
    element.append(buttonContainer);
  }

  /// Deserializes a previously serialized buffer.
  Buffer.deserialize(Map serialized, this.editor) {
    element = DivElement()..classes = ['buffer'];
    var inputElement = DivElement()..classes = ['input-wrapper'];
    element.append(inputElement);
    input = CodeInput(inputElement, null, editor.docs);
    input.text = serialized['text'];
    title = serialized['title'];
    drawerAdjust = DivElement()..classes = ['drawer-adjust'];
    element.append(drawerAdjust);
    drawer = DivElement()..classes = ['drawer'];
    element.append(drawer);
    var buttonContainer = DivElement()..classes = ['buttons'];
    setupButtons(buttonContainer);
    element.append(buttonContainer);
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

  /// Sets up the buttons at the bottom of the buffer.
  setupButtons(Element buttonContainer) {
    buttonContainer.append(AnchorElement()
      ..classes = ['button']
      ..text = 'Save'
      ..onClick.listen(save));
    runButton = AnchorElement()
      ..classes = ['button']
      ..text = 'Run'
      ..onClick.listen(run);
    buttonContainer.append(runButton);
    vizButton = AnchorElement()
      ..classes = ['button']
      ..text = 'Visualize'
      ..onClick.listen(visualize);
    buttonContainer.append(vizButton);
    drawerAdjust.onMouseDown.listen((e) {
      var listeners = [
        element.onMouseMove.listen((e) {
          editor.drawerHeight = element.clientHeight - e.client.y;
          drawer.style.height = '${editor.drawerHeight}px';
        })
      ];
      var cancelAll = (e) {
        for (var listener in listeners) {
          listener.cancel();
        }
        editor.saveState();
      };
      listeners.add(element.onMouseUp.listen(cancelAll));
      listeners.add(element.onMouseLeave.listen(cancelAll));
    });
  }

  /// Saves this buffer. Not yet implemented.
  save([_]) {
    // TODO(jathak): Implement files
    window.alert("Your work is automatically saved. "
        "Saving to a file is not yet supported.");
  }

  /// Opens a REPL in the drawer and runs the code currently in this buffer.
  ///
  /// If a REPL is already open, this instead closes the drawer.
  run([_]) {
    if (isReplOpen) {
      closeDrawer();
    } else {
      openDrawer();
      runButton.text = 'Close';
      isReplOpen = true;
      var repl = Repl(editor.interpreter.clone(), drawer);
      repl.interpreter.onExit = closeDrawer;
      repl.runCode(input.text, fromTool: true);
      repl.activeInput.highlight();
    }
  }

  /// Runs the visualizer and displays the result in the drawer.
  ///
  /// If the visualization is already open, this instead closes the drawer.
  visualize([_]) {
    if (isVizOpen) {
      closeDrawer();
    } else {
      openDrawer();
      vizButton.text = 'Close';
      isVizOpen = true;
      var renderBox = DivElement();
      drawer.append(renderBox);
      var interpreter = editor.interpreter.clone();
      var code = <Expression>[];
      var tokens = tokenizeLines(input.text.split('\n')).toList();
      while (tokens.isNotEmpty) {
        code.add(schemeRead(tokens, interpreter));
      }
      var viz = Visualization(code, interpreter.globalEnv);
      viz.goto(viz.diagrams.length - 1);
      render(viz, renderBox);
    }
  }

  Element runButton, vizButton;

  bool isReplOpen = false, isVizOpen = false;

  /// Opens the drawer.
  openDrawer() async {
    runButton.text = 'Run';
    vizButton.text = 'Visualize';
    isReplOpen = false;
    isVizOpen = false;
    drawer.children.clear();
    drawer.style.height = '${editor.drawerHeight}px';
    drawerAdjust.style.display = 'block';
    await delay(100);
    drawerAdjust.style.display = 'block';
  }

  /// Closes the drawer.
  ///
  /// This also hides the turtle canvas if it's open.
  closeDrawer() async {
    runButton.text = 'Run';
    vizButton.text = 'Visualize';
    isReplOpen = false;
    isVizOpen = false;
    drawer.style.height = '0';
    drawer.children.clear();
    await delay(100);
    drawerAdjust.style.display = 'none';
    querySelector('#turtle').style.display = 'none';
  }

  /// Serializes this buffer.
  serialize() => {'title': title, 'text': input.text};
}
