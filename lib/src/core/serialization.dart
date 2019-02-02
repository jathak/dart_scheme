library cs61a_scheme.core.serialization;

import 'dart:convert' show json;

import 'expressions.dart';
import 'logging.dart';
import 'numbers.dart';
import 'values.dart';

final Map<String, Serializable> deserializers = {
  'Integer': Number.zero,
  'Double': Double(1.5),
  'Boolean': schemeTrue,
  'SchemeSymbol': const SchemeSymbol('x'),
  'SchemeString': const SchemeString('x')
};

abstract class Serializable<T extends Value> extends Value {
  Map serialize();
  T deserialize(Map data);
}

class Serialization {
  static String serializeToJson(Serializable expr) =>
      json.encode(expr.serialize());

  static Value deserialize(Map data) {
    if (!data.containsKey('type')) {
      throw SchemeException("Invalid serialized expression");
    } else if (!deserializers.containsKey(data['type'])) {
      throw SchemeException("Can't find ${data['type']} deserializer");
    }
    return deserializers[data['type']].deserialize(data);
  }

  static Value deserializeFromJson(String data) =>
      deserialize(json.decode(data));
}
