library cs61a_scheme.core.serialization;

import 'dart:convert' show JSON;

import 'expressions.dart';
import 'logging.dart';
import 'ui.dart';

final Map<String, Serializable> deserializers = {
  'Number': Number.zero,
  'Boolean': schemeTrue,
  'SchemeSymbol': const SchemeSymbol('x'),
  'SchemeString': const SchemeString('x'),
  'Anchor': new Anchor(),
  'TextElement': new TextElement(""),
  'Strike': new Strike(),
  'Block': new Block.pair(null),
  'BlockGrid': new BlockGrid([[]])
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
    if (!data.containsKey('type')) {
      throw new SchemeException("Invalid serialized expression");
    } else if (!deserializers.containsKey(data['type'])) {
      throw new SchemeException("Can't find ${data['type']} deserializer");
    }
    return deserializers[data['type']].deserialize(data);
  }

  static Expression deserializeFromJson(String json) {
    return deserialize(JSON.decode(json));
  }
}
