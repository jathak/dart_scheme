library cs61a_scheme.core.serialization;

import 'dart:convert' show JSON;

import 'expressions.dart';
import 'ui.dart';

final Map<String, Serializable> deserializers = {
  'Number': Number.ZERO,
  'Boolean': schemeTrue,
  'SchemeSymbol': const SchemeSymbol('x'),
  'SchemeString': const SchemeString('x'),
  'Anchor': new Anchor(),
};

abstract class Serializable<T extends Expression> extends Expression {
  Map serialize();
  T deserialize(Map data);
}

class Serialization {
  static String serializeToJson(Serializable expr) {
    return JSON.encode(expr.serialize());
  }

  static Expression deserialize(Map data) {
    return deserializers[data['type']].deserialize(data);
  }

  static Expression deserializeFromJson(String json) {
    return deserialize(JSON.decode(json));
  }
}
