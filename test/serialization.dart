import 'package:test/test.dart';

import 'package:cs61a_scheme/cs61a_scheme.dart';

main() {
  group("serialization", () {
    test("works for Boolean", () {
      expect(remake(schemeTrue), same(schemeTrue));
      expect(remake(schemeFalse), same(schemeFalse));
    });
    test("works for SchemeSymbol", () {
      stable(new SchemeSymbol("test"));
    });
    test("works for SchemeString", () {
      stable(new SchemeString("this is a test"));
    });
    test("works for Integer", () {
      stable(new Integer(42));
      stable(new Number.fromString("12345" * 10000) as Integer);
    });
    test("works for Double", () {
      stable(new Double(1.6));
    });
    test("works for Anchor", () {
      var a = new Anchor();
      var b = remake(a);
      expect(b.id, equals(a.id));
    });
    test("works for TextElement", () {
      var a = new TextElement("abc");
      var b = remake(a);
      expect(b.text, equals(a.text));
    });
    test("works for Strike", () {
      expect(remake(new Strike()), new isInstanceOf<Strike>());
    });
    test("works for Block", () {
      var a = new Block.pair(new Strike());
      var b = remake(a);
      expect(b.type, equals(a.type));
      expect(b.inside, new isInstanceOf<Strike>());
    });
    test("works for BlockGrid", () {
      var a = new BlockGrid.row([
        new Block.pair(new TextElement("1")),
        new Block.vector(new Strike())
      ]);
      var b = remake(a);
      expect(b.rowCount, equals(1));
      expect(b.columnCount, equals(2));
      expect(b.rowAt(0).first.type, "pair");
      expect(b.rowAt(0).first.inside.text, "1");
      expect(b.rowAt(0).last.type, "vector");
      expect(b.rowAt(0).last.inside, new isInstanceOf<Strike>());
    });
  });
}

/// Checks that an expression that is serialized and then deserialized
/// is equivalent to the original.
stable(Serializable expr) {
  expect(expr, equals(remake(expr)));
}

/// Serializes and then immediately deserializes an expression.
remake(Serializable expr) {
  return Serialization.deserialize(expr.serialize());
}
