/// Defines some basic UI interfaces to allow for integration with the
/// core interpreter. Implementation is in cs61a_scheme.extra.ui.
library cs61a_scheme.core.ui;

import 'expressions.dart';
import 'logging.dart';

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
}

abstract class UIElement extends SelfEvaluating {
  UIElement();
  toJS() => this;
  Map<Direction, Anchor> _anchors = {};
  Anchor anchor(Direction dir) => _anchors.putIfAbsent(dir, () => new Anchor());
  Iterable<Direction> get anchoredDirections => _anchors.keys;
  toString() => "#[UIElement]";
  // If true, element should be invisible but take up the same amount of space.
  bool spacer = false;
}

class Anchor extends UIElement {
  static int nextId = 1;
  final int id;
  Anchor() : id = nextId++;
  toString() => "#[Anchor:$id]";
}

class TextElement extends UIElement {
  final String text;
  TextElement(this.text);
  toString() => "#[TextElement:$text]";
}

class Strike extends UIElement {
  Strike();
  toString() => "#[Strike]";
}

class BlockType {
  final String id;
  const BlockType._(this.id);
  // Letters represent different shapes. Numbers represent different colors.
  static const BlockType a1 = const BlockType._("a1");
  static const BlockType a2 = const BlockType._("a2");
  static const BlockType b1 = const BlockType._("b1");
  static const BlockType b2 = const BlockType._("b2");
  toString() => "#[BlockType.$id]";
}

class Block extends UIElement {
  final BlockType type;
  final UIElement inside;
  Block._(this.type, this.inside);
  Block.a1(this.inside) : type = BlockType.a1;
  Block.a2(this.inside) : type = BlockType.a2;
  Block.b1(this.inside) : type = BlockType.b1;
  Block.b2(this.inside) : type = BlockType.b2;
  toString() => "#[Block.${type.id}:$inside]";
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
      if (row.length != _columns) throw new SchemeException("Jagged block grid");
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
  BlockGrid toSpacer() => new BlockGrid(_grid.map((row)=>row.map((item) {
    if (item is Anchor) return new TextMessage("x");
    return item;
  }).toList()).toList())..spacer = true;
  toString() => "#$_grid";
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
