library cs61a_scheme.core.serialization;

import 'dart:convert' show json;

import 'expressions.dart';
import 'numbers.dart';
import 'logging.dart';

final Map<String, Serializable> deserializers = {
  'Integer': Number.zero,
  'Double': new Double(1.5),
  'Boolean': schemeTrue,
  'SchemeSymbol': const SchemeSymbol('x'),
  'SchemeString': const SchemeString('x')
};

abstract class Serializable<T extends Expression> extends Expression {
  Map serialize();
  T deserialize(Map data);
}

class Serialization {
  static String serializeToJson(Serializable expr) {
    return json.encode(expr.serialize());
  }

  static Expression deserialize(Map data) {
    if (!data.containsKey('type')) {
      throw new SchemeException("Invalid serialized expression");
    } else if (!deserializers.containsKey(data['type'])) {
      throw new SchemeException("Can't find ${data['type']} deserializer");
    }
    return deserializers[data['type']].deserialize(data);
  }

  static Expression deserializeFromJson(String data) {
    return deserialize(json.decode(data));
  }
}
