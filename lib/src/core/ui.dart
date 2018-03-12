/// Defines some basic UI interfaces to allow for integration with the
/// core interpreter. Implementation is in cs61a_scheme.extra.ui.
library cs61a_scheme.core.ui;

import 'dart:async';

import 'expressions.dart';
import 'logging.dart';
import 'serialization.dart';

class Direction extends SelfEvaluating {
  final String _id;
  toJS() => this;
  const Direction._(this._id);
  toString() => "#[Direction.$_id]";
  static const Direction left = const Direction._("left");
  static const Direction right = const Direction._("right");
  static const Direction top = const Direction._("top");
  static const Direction bottom = const Direction._("bottom");
  static const Direction topLeft = const Direction._("topLeft");
  static const Direction topRight = const Direction._("topRight");
  static const Direction bottomLeft = const Direction._("bottomLeft");
  static const Direction bottomRight = const Direction._("bottomRight");

  factory Direction(String id) {
    switch (id) {
      case 'left':
        return left;
      case 'right':
        return right;
      case 'top':
        return top;
      case 'bottom':
        return bottom;
      case 'topLeft':
        return topLeft;
      case 'topRight':
        return topRight;
      case 'bottomLeft':
        return bottomLeft;
      case 'bottomRight':
        return bottomRight;
      default:
        throw new UnsupportedError('Invalid direction $id');
    }
  }
}

abstract class UIElement extends SelfEvaluating implements Serializable {
  UIElement();
  toJS() => this;
  Map<Direction, Anchor> _anchors = {};
  Anchor anchor(Direction dir) => _anchors.putIfAbsent(dir, () => new Anchor());
  Iterable<Direction> get anchoredDirections => _anchors.keys;
  // If true, element should be invisible but take up the same amount of space.
  bool spacer = false;
  // Elements should call this when their contents update and they need to be
  // redrawn.
  void update() => _controller.add(null);
  StreamController _controller = new StreamController.broadcast();
  Stream get onUpdate => _controller.stream;

  Map finishSerialize(Map data) {
    if (_anchors.isNotEmpty) {
      data['anchors'] = new Map<String, dynamic>.fromIterables(
          _anchors.keys.map((k) => k._id),
          _anchors.values.map((v) => v.serialize()));
    }
    if (spacer) data['spacer'] = spacer;
    return data;
  }

  void finishDeserialize(Map data) {
    if (data.containsKey('anchors')) {
      _anchors = new Map<Direction, Anchor>.fromIterables(
          data['anchors'].keys.map((k) => new Direction(k)),
          data['anchors'].values.map(Serialization.deserialize));
    }
    if (data.containsKey('spacer')) spacer = data['spacer'];
  }
}

class Anchor extends UIElement {
  static int nextId = 1;
  final int id;
  Anchor() : id = nextId++;
  Anchor.withId(this.id);
  Anchor anchor(dir) =>
      throw new UnimplementedError('Anchors cannot have anchors of their own.');

  toString() => "#[Anchor:$id]";

  Map serialize() => {
        'type': 'Anchor',
        'id': id,
      };
  Anchor deserialize(Map data) {
    return new Anchor.withId(data['id']);
  }
}

class TextElement extends UIElement {
  final String text;
  TextElement(this.text);
  toString() => "#[TextElement:$text]";

  Map serialize() => finishSerialize({
        'type': 'TextElement',
        'text': text,
      });
  TextElement deserialize(Map data) {
    return new TextElement(data['text'])..finishDeserialize(data);
  }
}

class Strike extends UIElement {
  Strike();

  Map serialize() => finishSerialize({'type': 'Strike'});
  Strike deserialize(Map data) {
    return new Strike()..finishDeserialize(data);
  }
}

class Block extends UIElement {
  final String type;
  final UIElement inside;
  Block._(this.type, this.inside);
  Block.pair(this.inside) : type = "pair";
  Block.vector(this.inside) : type = "vector";
  Block.promise(this.inside) : type = "promise";
  Block.async(this.inside) : type = "async";
  toString() => "#[Block:$type:$inside]";
  Map serialize() => finishSerialize(
      {'type': 'Block', 'blockType': type, 'inside': inside.serialize()});
  Block deserialize(Map data) {
    return new Block._(
        data['blockType'], Serialization.deserialize(data['inside']))
      ..finishDeserialize(data);
  }
}

class BlockGrid extends UIElement {
  final List<List<Block>> _grid;
  int _columns, _rows;
  int get columnCount => _columns;
  int get rowCount => _rows;
  BlockGrid(this._grid) {
    if (_grid.isEmpty) throw new SchemeException("Empty block grid");
    _rows = _grid.length;
    for (List<Block> row in _grid) {
      if (_columns == null) _columns = row.length;
      if (row.length != _columns)
        throw new SchemeException("Jagged block grid");
    }
  }
  BlockGrid.row(List<Block> row) : _grid = new List.filled(1, row) {
    if (row.isEmpty) throw new SchemeException("Empty block row");
    _rows = 1;
    _columns = row.length;
  }
  BlockGrid.column(List<Block> col)
      : _grid = new List.from(col.map((b) => new List.filled(1, b))) {
    if (col.isEmpty) throw new SchemeException("Empty block column");
    _rows = col.length;
    _columns = 1;
  }
  BlockGrid.pair(Block a, Block b) : this.row(new List.from([a, b]));

  Iterable<Block> rowAt(int index) sync* {
    yield* _grid[index];
  }

  Iterable<Block> columnAt(int index) sync* {
    for (List<Block> row in _grid) {
      yield row[index];
    }
  }

  BlockGrid toSpacer() => new BlockGrid(_grid
      .map((row) => row.map((item) {
            if (item is Anchor) return new TextMessage("x");
            return item;
          }).toList())
      .toList())
    ..spacer = true;
  toString() => "#$_grid";

  Map serialize() => finishSerialize({
        'type': 'BlockGrid',
        'grid': _grid
            .map((row) => row.map((item) => item.serialize()).toList())
            .toList()
      });
  BlockGrid deserialize(Map data) {
    return new BlockGrid(data['grid'].map((row) {
      return row.map((item) => Serialization.deserialize(item)).toList();
    }).toList())
      ..finishDeserialize(data);
  }
}

abstract class DiagramInterface extends UIElement {
  int get currentRow;

  /// If expression.inlineUI is true, returns expression.draw(this).
  /// If not, returns an anchor that is linked to expression.draw(this).
  /// If parentRow is set, the new object will be on a new line, with spacing
  /// based on the parentRow.
  UIElement pointTo(Expression expression, [int parentRow]);
}

typedef void Renderer(UIElement);
