/// This is designed to be run from a web worker
import 'dart:js';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';
import 'package:cs61a_scheme_impl/impl.dart';

main() {
  var inter = new Interpreter(new StaffProjectImplementation());
  inter.importLibrary(new ExtraLibrary());
  inter.importLibrary(new LogicLibrary());
  inter.logger = (e, newline) => context.callMethod('postMessage', [
        new JsObject.jsify(['output', e.toString(), newline])
      ]);
  context['onmessage'] = (e) {
    var data = e.data;
    var command = data[0];
    if (command == 'run') {
      inter.run(data[1]);
    } else if (command == 'eval') {
      var expr = schemeRead(tokenizeLine(data[1]).toList(), inter.impl);
      var result = schemeEval(expr, inter.globalEnv);
      if (result is Serializable) {
        var serialized = Serialization.serializeToJson(result);
        context.callMethod('postMessage', [
          new JsObject.jsify(['result', serialized, data[2]])
        ]);
      } else {
        context.callMethod('postMessage', [
          new JsObject.jsify(['result-string', result.toString(), data[2]])
        ]);
      }
    }
  };
}
