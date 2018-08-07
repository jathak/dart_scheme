/// Defines some basic rendering primitives to allow for integration with the
/// core interpreter. More rendering code is in extra/diagramming.dart.
library cs61a_scheme.core.widgets;

import 'dart:async';

import 'expressions.dart';
import 'logging.dart';
import 'procedures.dart' show Procedure;
import 'utils.dart' show schemeApply;

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

/// The base class for any expressions that can be rendered.
///
/// Whenever something extending [Widget] is logged, the web REPL will render it
/// instead of just printing it. Used primarily for diagramming.
abstract class Widget extends SelfEvaluating {
  Widget();
  toJS() => this;
  Map<Direction, Anchor> _anchors = {};
  Anchor anchor(Direction dir) => _anchors.putIfAbsent(dir, () => new Anchor());
  Iterable<Direction> get anchoredDirections => _anchors.keys;
  toString() => '#[UIElement]';
  // If true, element should be invisible but take up the same amount of space.
  bool spacer = false;
  // Elements should call this when their contents update and they need to be
  // redrawn.
  void update() => _controller.add(null);
  StreamController _controller = new StreamController.broadcast();
  Stream get onUpdate => _controller.stream;
}

class Anchor extends Widget {
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

class TextWidget extends Widget {
  final String text;
  TextWidget(this.text);
  toString() => text;
}

class MarkdownWidget extends TextWidget {
  bool inline;

  Frame env;

  MarkdownWidget(String text, {this.inline: true, this.env}) : super(text);

  void runLink(String name) {
    if (env == null) return;
    var proc = env.lookup(new SchemeSymbol.runtime(name));
    if (proc is Procedure) {
      schemeApply(proc, nil, env);
    }
  }
}

class Strike extends Widget {
  Strike();

  toString() => "#[Strike]";
}

class Block extends Widget {
  final String type;
  final Widget inside;
  Block._(this.type, this.inside);
  Block.pair(this.inside) : type = "pair";
  Block.vector(this.inside) : type = "vector";
  Block.promise(this.inside) : type = "promise";
  Block.asynch(this.inside) : type = "async";
  toString() => "#[Block:$type:$inside]";
}

class BlockGrid extends Widget {
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

  BlockGrid toSpacer() => BlockGrid(_grid
      .map((row) => row
          .map((item) => Block._(
              item.type, item.inside is Anchor ? TextWidget("x") : item.inside))
          .toList())
      .toList())
    ..spacer = true;

  toString() => "#$_grid";
}

abstract class DiagramInterface extends Widget {
  int get currentRow;

  /// If expression.inlineInDiagram is true, returns expression.draw(this).
  /// If not, returns an anchor that is linked to expression.draw(this).
  /// If parentRow is set, the new object will be on a new line, with spacing
  /// based on the parentRow.
  Widget pointTo(Expression expression, [int parentRow]);
}
