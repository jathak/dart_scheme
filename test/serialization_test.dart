import 'package:test/test.dart';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

main() {
  group("serialization", () {
    test("works for Boolean", () {
      expect(remake(schemeTrue), same(schemeTrue));
      expect(remake(schemeFalse), same(schemeFalse));
    });
    test("works for SchemeSymbol", () {
      stable(const SchemeSymbol("test"));
    });
    test("works for SchemeString", () {
      stable(const SchemeString("this is a test"));
    });
    test("works for Integer", () {
      stable(Integer(42));
      stable(Number.fromString("12345" * 10000) as Integer);
    });
    test("works for Double", () {
      stable(Double(1.6));
    });
  });
}

/// Checks that an expression that is serialized and then deserialized
/// is equivalent to the original.
stable(Serializable expr) {
  expect(expr, equals(remake(expr)));
}

/// Serializes and then immediately deserializes an expression.
remake(Serializable expr) => Serialization.deserialize(expr.serialize());
