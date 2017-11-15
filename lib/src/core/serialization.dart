library cs61a_scheme.core.serialization;

import 'dart:convert' show JSON;

import 'expressions.dart';
import 'logging.dart';
import 'interpreter.dart' show Interpreter;
import 'ui.dart';

final Map<String, Serializable> deserializers = {
  'Number': Number.ZERO,
  'Boolean': schemeTrue,
  'SchemeSymbol': const SchemeSymbol('x'),
  'SchemeString': const SchemeString('x'),
  'EmptyList': nil,
  'Pair': new Pair(nil, nil),
  'Frame': new Frame(null, null),
  'Promise': new Promise(null, null),
  'DiagramStub': new DiagramStub(null)
};

abstract class Serializable<T extends Expression> {
  Map serialize(Serializer s);
  T deserialize(Map data, Deserializer d);
}

abstract class Stubber implements Serializable<DiagramStub> {
  String get stubText => toString();
  Map serialize(Serializer s) => {
    'type': 'DiagramStub',
    'stubText': stubText,
  };
  DiagramStub deserialize(Map data, Deserializer d) {
    return new DiagramStub(data['stubText']);
  }
}

/// For serializers (such as procedures) that only serialize metadata for
/// diagramming, and can't be reconstructed during deserialization
class DiagramStub extends SelfEvaluating with Stubber {
  final String stubText;
  DiagramStub(this.stubText);

  @override
  UIElement draw(diag) => new TextElement(stubText);
}

class Serializer {
  Map<Serializable, String> _objIds = new Map.identity();
  Map<String, Map> _serializedObjs = {};
  List<String> _rootIds;
  int _nextObjId = 0;

  Serializer(Serializable root) : this.multiple([root]);

  Serializer.multiple(Iterable<Serializable> roots) {
    _rootIds = roots.map((root) => serialize(root)['id']).toList();
  }

  Map serialize(dynamic item) {
    if (item == null) return null;
    if (item is! Serializable) {
      throw new SchemeException('$item is not serializable');
    }
    if (_objIds.containsKey(item)) {
      return {'type': 'reference', 'id': _objIds[item]};
    }
    var data = item.serialize(this);
    String id = "${_nextObjId++}";
    _objIds[item] = id;
    _serializedObjs[id] = data;
    return {'type': 'reference', 'id': id};
  }

  String toJSON() => JSON.encode({
    'roots': _rootIds,
    'objects': _serializedObjs
  });
}

class Deserializer {
  Map<String, Expression> _objs = {};
  Map<String, Map> _serializedObjs;
  List<String> _rootIds;
  Interpreter interpreter;

  Deserializer(String data, this.interpreter) {
    var dataMap = JSON.decode(data);
    _serializedObjs = dataMap['objects'];
    _rootIds = dataMap['roots'];
  }

  Expression get expression => expressions.first;

  Iterable<Expression> get expressions =>
    _rootIds.map((id) => _deserializeId(id));

  Expression _deserializeId(String id) {
    if (!_objs.containsKey(id)) {
      _objs[id] = _deserializeData(_serializedObjs[id]);
    }
    return _objs[id];
  }

  Expression _deserializeData(Map data) {
    if (data == null) return null;
    if (deserializers.containsKey(data['type'])) {
      return deserializers[data['type']].deserialize(data, this);
    }
    throw new SchemeException('Invalid serialized data');
  }

  Expression deserialize(Map ref) {
    if (ref == null) return null;
    if (ref['type'] != 'reference') {
      throw new SchemeException('Invalid serialized reference');
    }
    return _deserializeId(ref['id']);
  }
}
