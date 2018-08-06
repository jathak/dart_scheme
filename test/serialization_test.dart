import 'package:test/test.dart';

import 'package:cs61a_scheme/cs61a_scheme_extra.dart';

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
