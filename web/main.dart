import 'dart:html';
import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_web.dart';
import 'package:cs61a_scheme_impl/impl.dart' show StaffProjectImplementation;

import 'package:cs61a_scheme/web_repl.dart';

const String motd = "**61A Scheme Web Interpreter 2.0.0-beta**"
    "                         <small>"
    "[View Source on GitHub](https://github.com/Cal-CS-61A-Staff/dart_scheme)"
    """</small>
--------------------------------------------------------------------------------
**Diagramming**
`(draw some-pair)` to create a box-and-pointer diagram [Try It](:try-draw)
`(autodraw)` to start drawing diagrams for any returned list [Try It](:try-ad)
`(visualize some-code)` to create an environment diagram [Try It](:try-viz)

**Other Useful Commands**
`(clear)` to clear all output on the screen
`(theme 'id)` to change the interpreter's theme
[default](:try-default) [solarized](:try-solarized) """
    "[monochrome](:try-monochrome) [monochrome-dark](:try-monochrome-dark) "
    """[go-bears](:try-go-bears)
`(bindings)` returns a list of all names bound in the current environment
`(import 'scm/apps/chess)` to play a game of chess (missing some features) """
    """[Try It](:try-chess)

**Keyboard Shortcuts**
Up/Down to scroll through history (Hold Ctrl to scroll past multiline entry)
Shift+Enter to add missing parens and run the current input

*Looking for the old version? """
    """[Interpreter](https://scheme-legacy.apps.cs61a.org) &mdash; """
    """[Editor](https://scheme-legacy-apps.cs61a.org/editor.html)*

""";

main() async {
  var inter = new Interpreter(new StaffProjectImplementation());
  var normals = inter.globalEnv.bindings.keys.toSet();
  var extra = new ExtraLibrary();
  var logic = new LogicLibrary();
  var diagramBox = querySelector('#diagram');
  String css = await HttpRequest.getString('assets/style.css');
  var style = querySelector('#theme');
  var web = new WebLibrary(diagramBox, context['jsPlumb'], css, style);
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
  inter.importLibrary(extra);
  inter.importLibrary(logic);
  inter.importLibrary(web);
  new Repl(inter, document.body);
  var specials = inter.globalEnv.bindings.keys.toSet().difference(normals);
  inter.importLibrary(new TurtleLibrary(querySelector('canvas'), inter));
  var turtles = inter.globalEnv.bindings.keys
      .toSet()
      .difference(specials)
      .difference(normals);
  var demos = new Frame(inter.globalEnv, inter);
  addDemo(demos, 'try-draw', "(draw '(1 2 3))");
  addDemo(demos, 'try-chess', "(import 'scm/apps/chess)");
  addDemo(demos, 'try-ad', "(autodraw)");
  addDemo(demos, 'try-default', "(theme 'default)");
  addDemo(demos, 'try-solarized', "(theme 'solarized)");
  addDemo(demos, 'try-monochrome', "(theme 'monochrome)");
  addDemo(demos, 'try-monochrome-dark', "(theme 'monochrome-dark)");
  addDemo(demos, 'try-go-bears', "(theme 'go-bears)");
  addDemo(demos, 'try-viz', """(define (fact n)
       (if (= n 0)
           1
           (* n (fact (- n 1)))))

     (visualize (fact 5))
""");
  context.callMethod('hljsRegister', [
    new JsObject.jsify({
      'builtin-normal':
          normals.union(inter.specialForms.keys.toSet()).join(' '),
      'builtin-special': specials.join(' '),
      'builtin-turtle': turtles.join(' ')
    })
  ]);
  inter.logger(new MarkdownElement(motd, env: demos), true);
}

addDemo(Frame env, String demoName, String code) {
  addPrimitive(env, new SchemeSymbol.runtime(demoName), (_, __) {
    var prompt = "<span class='repl-prompt'>scm></span> `$code`";
    env.interpreter.logger(new MarkdownElement(prompt), true);
    env.interpreter.run(code);
    return undefined;
  }, 0);
}
