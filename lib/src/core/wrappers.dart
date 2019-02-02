library cs61a_scheme.core.wrappers;

import 'dart:collection' show IterableBase;

import 'expressions.dart';
import 'logging.dart';
import 'values.dart';

class SchemeList<T extends Value> extends IterableBase<T> {
  final PairOrEmpty _list;

  SchemeList(this._list) {
    if (!_list.wellFormed) {
      throw SchemeException("$_list is not a Scheme list.");
    }
    if (T != Value) {
      for (Value val in this) {
        if (val is! T) throw SchemeException("Wrong type in Scheme list.");
      }
    }
  }

  SchemeList._noCheck(this._list);

  factory SchemeList.fromValue(Value value) {
    if (value is PairOrEmpty) return SchemeList<T>(value);
    throw SchemeException('$value is not a Scheme list');
  }

  /// Creates a Scheme list from the given Dart iterable.
  factory SchemeList.fromIterable(Iterable<T> iterable) {
    PairOrEmpty result = nil;
    for (T item in iterable.toList().reversed) {
      result = Pair(item, result);
    }
    return SchemeList<T>._noCheck(result);
  }

  PairOrEmpty get list => _list;

  SchemeList<T> get rest => isNotEmpty
      ? SchemeList<T>._noCheck(_list.pair.second)
      : throw SchemeException('No more items in list.');

  Iterator<T> get iterator => _SchemeListIterator<T>(_list);

  String toString() => list.toString();
}

class _SchemeListIterator<T extends Value> extends Iterator<T> {
  T current;
  Pair pair;
  _SchemeListIterator(PairOrEmpty list) {
    if (list is Pair) {
      pair = list;
    }
  }
  bool moveNext() {
    if (pair != null) {
      current = pair.first;
      pair = pair.second is Pair ? pair.second : null;
      return true;
    }
    return false;
  }
}
