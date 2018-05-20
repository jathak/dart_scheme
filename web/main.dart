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
    """[Editor](https://scheme-legacy.apps.cs61a.org/editor.html)*

""";

main() async {
  String css = await HttpRequest.getString('assets/style.css');
  var style = querySelector('#theme');
  var diagramBox = querySelector('#diagram');
  var webLibrary = new WebLibrary(diagramBox, context['jsPlumb'], css, style);
  if (window.location.href.contains('logic')) {
    await startLogic(webLibrary);
  } else {
    await startScheme(webLibrary);
  }
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
}

startScheme(WebLibrary webLibrary) async {
  var inter = new Interpreter(new StaffProjectImplementation());
  var normals = inter.globalEnv.bindings.keys.toSet();
  var extra = new ExtraLibrary();
  inter.importLibrary(extra);
  inter.importLibrary(webLibrary);
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
  addDemo(
      demos,
      'try-viz',
      """(define (fact n)
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

const String logicMotd = "**61A Logic Web Interpreter**"
    "                                     <small>"
    "[View Source on GitHub](https://github.com/Cal-CS-61A-Staff/dart_scheme)"
    """</small>
--------------------------------------------------------------------------------
**Themes**
[default](:default) [solarized](:solarized) [monochrome](:monochrome) """
    """[monochrome-dark](:monochrome-dark) [go-bears](:go-bears)

**Usage**
`(fact consequent hypothesis1 ...)` or `(! consequent hypothesis1 ...)`:
  Assert a consequent, followed by zero or more hypotheses.
`(query clause1 clause2 ...)` or `(? clause1 clause2 ...)`
  Query zero or more relations simultaneously.
`(query-one clause1 clause2 ...)`
  Like query, but finds at most one solution.

""";

startLogic(WebLibrary webLibrary) {
  document.title = 'Logic Interpreter';
  var inter = new Interpreter(new StaffProjectImplementation());
  new Repl(inter, document.body, prompt: 'logic> ');
  inter.globalEnv.bindings.clear();
  inter.specialForms.clear();
  inter.importLibrary(new LogicLibrary());
  var keywords = inter.globalEnv.bindings.keys.toSet();
  context.callMethod('hljsRegister', [
    new JsObject.jsify({'builtin-special': keywords.join(' ')})
  ]);
  var themeInter = new Interpreter(new StaffProjectImplementation());
  themeInter.importLibrary(new ExtraLibrary());
  themeInter.importLibrary(webLibrary);
  addTheme(themeInter, webLibrary, const SchemeSymbol('default'));
  addTheme(themeInter, webLibrary, const SchemeSymbol('solarized'));
  addTheme(themeInter, webLibrary, const SchemeSymbol('monochrome'));
  addTheme(themeInter, webLibrary, const SchemeSymbol('monochrome-dark'));
  addTheme(themeInter, webLibrary, const SchemeSymbol('go-bears'));
  inter.logger(new MarkdownElement(logicMotd, env: themeInter.globalEnv), true);
}

addTheme(Interpreter inter, WebLibrary web, SchemeSymbol themeName) {
  addPrimitive(inter.globalEnv, themeName, (_, __) {
    web.theme(themeName, inter.globalEnv);
    return undefined;
  }, 0);
}
