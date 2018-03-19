import 'dart:html';
import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_web.dart';
import 'package:cs61a_scheme_impl/impl.dart' show StaffProjectImplementation;

import 'package:cs61a_scheme/web_repl.dart';

const String motd = "<strong>61A Scheme Web Interpreter 2.0.0-beta</strong>"
    "                         "
    """<small><a id='github' target='_blank'>View Source on GitHub</a></small>
********************************************************************************
<strong>Diagramming</strong>
(draw &lt;any list>) to create a box-and-pointer diagram
(autodraw) to start drawing diagrams for any returned list
(visualize &lt;some code>) to create an environment diagram

<strong>Other Useful Commands</strong>
(clear) to clear all output on the screen
(theme 'id) to change the interpreter's theme
    default, solarized, monochrome, monochrome-dark, and go-bears available
(bindings) returns a list of all names bound in the current environment
(import 'scm/apps/chess) to play a game of chess (missing some features)

<strong>Keyboard Shortcuts</strong>
Up/Down to scroll through history (Hold Ctrl to scroll past multiline entry)
Shift+Enter to add missing parens and run the current input

<i>Looking for the old version? """
    """<a id='legacy-interpreter' target="_blank">Interpreter</a> &mdash; """
    """<a id='legacy-editor' target="_blank">Editor</a></i>

""";

main() async {
  var inter = new Interpreter(new StaffProjectImplementation());
  var normals = inter.globalEnv.bindings.keys.toSet();
  inter.importLibrary(new ExtraLibrary());
  var diagramBox = querySelector('#diagram');
  String css = await HttpRequest.getString('assets/style.css');
  var style = querySelector('style');
  var web = new WebLibrary(diagramBox, context['jsPlumb'], css, style);
  inter.importLibrary(web);
  var specials = inter.globalEnv.bindings.keys.toSet().difference(normals);
  inter.importLibrary(new TurtleLibrary(querySelector('canvas'), inter));
  var turtles = inter.globalEnv.bindings.keys
      .toSet()
      .difference(specials)
      .difference(normals);
  context.callMethod('hljsRegister', [
    new JsObject.jsify({
      'builtin-normal':
          normals.union(inter.specialForms.keys.toSet()).join(' '),
      'builtin-special': specials.join(' '),
      'builtin-turtle': turtles.join(' ')
    })
  ]);
  if (window.localStorage.containsKey('#scheme-theme')) {
    try {
      var expr = Serialization
          .deserializeFromJson(window.localStorage['#scheme-theme']);
      if (expr is Theme) {
        applyTheme(expr, css, style, false);
      }
    } catch (e) {
      print("Saved theme invalid. Removing...");
      window.localStorage.remove("#scheme-theme");
    }
  }
  onThemeChange.listen((Theme theme) {
    window.localStorage['#scheme-theme'] = Serialization.serializeToJson(theme);
  });
  var repl = new Repl(inter, document.body);
  var motdElement = new SpanElement()..innerHtml = motd;
  motdElement.querySelector('#github').attributes['href'] =
      "https://github.com/Cal-CS-61A-Staff/dart_scheme";
  motdElement.querySelector('#legacy-interpreter').attributes['href'] =
      "https://scheme-legacy.apps.cs61a.org";
  motdElement.querySelector('#legacy-editor').attributes['href'] =
      "https://scheme-legacy.apps.cs61a.org/editor.html";
  repl.logElement(motdElement);
}
