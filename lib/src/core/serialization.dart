library cs61a_scheme.core.serialization;

import 'dart:convert' show JSON;

import 'expressions.dart';
import 'logging.dart';
import 'ui.dart';

final Map<String, Serializable> deserializers = {
  'Number': Number.ZERO,
  'Boolean': schemeTrue,
  'SchemeSymbol': const SchemeSymbol('x'),
  'SchemeString': const SchemeString('x'),
  'Anchor': new Anchor(),
};

abstract class Serializable<T extends Expression> {
  Map serialize();
  T deserialize(Map data);
}

class Serialization {
  static Map serialize(Expression expr) {
    if (expr is! Serializable) {
      throw new SchemeException('$expr is not serializable');
    }
    return (expr as Serializable).serialize();
  }

  static String serializeToJson(Expression expr) {
    return JSON.encode(serialize(expr));
  }

  static Expression deserialize(Map data) {
    return deserializers[data['type']].deserialize(data);
  }

  static Expression deserializeFromJson(String json) {
    return deserialize(JSON.decode(json));
  }
}
