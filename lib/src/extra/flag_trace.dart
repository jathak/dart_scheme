/// This implements the necessary tracing into the Scheme backend that can be
/// serialized and sent to Semaphore. Semaphore depends on this library, so it
/// will be able to use these classes, but it does not depend on the private
/// implementation library, so it can't actually run the traces itself.
///
/// Pyagram should use the same format when serializing traces for Semaphore.
library cs61a_scheme.extra.flag_diagrams;

import 'package:cs61a_scheme/cs61a_scheme.dart';

import 'diagramming.dart';

class FlagTrace {
  List<FlagStep> steps = [];
  String code;
  String language;
  FlagTrace(this.code, [this.language = 'scheme']);

  Map serialize() => {
        'type': 'FlagTrace',
        'code': code,
        'language': language,
        'steps': steps.map((s) => s.serialize()).toList()
      };

  FlagTrace deserialize(Map data) {
    var trace = new FlagTrace(data['code'], data['language']);
    trace.steps = data['steps'].map(Serialization.deserialize).toList();
    return trace;
  }
}

class FlagStep extends SelfEvaluating with Serializable<FlagStep> {
  Diagram diagram;
  List<Flag> flags;
  FlagStep(this.diagram, this.flags);

  Map serialize() => {
        'type': 'FlagStep',
        'diagram': diagram.serialize(),
        'flags': flags.map((f) => f.serialize()).toList()
      };

  FlagStep deserialize(Map data) => new FlagStep(Serialization.deserialize(data['diagram']),
      data['flags'].map(Serialization.deserialize).toList());
}

class Flag extends SelfEvaluating with Serializable<Flag> {
  String callExpression;
  List<Flag> operands = [];
  int frameId;
  List<Flag> body = [];
  Flag(this.callExpression, this.frameId);

  Map serialize() => {
        'type': 'Flag',
        'callExpression': callExpression,
        'operands': operands.map((f) => f.serialize()).toList(),
        'frameId': frameId,
        'body': body.map((f) => f.serialize()).toList()
      };

  Flag deserialize(Map data) {
    var flag = new Flag(data['callExpression'], data['frameId']);
    flag.operands = data['operands'].map(Serialization.deserialize).toList();
    flag.body = data['body'].map(Serialization.deserialize).toList();
    return flag;
  }
}
