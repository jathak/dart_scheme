library cs61a_scheme.core.numbers;

import 'package:rational/bigint.dart';

import 'expressions.dart';
import 'logging.dart';
import 'serialization.dart';

/// Base class for both Scheme number types.
///
/// Supports most arithmetic operations. For arithmetic operations that include
/// a [Double] the result will typically be another [Double] unless the value
/// can be represented as an integer (like `1.0`).
///
/// With the exception of true division, all arithmetic operations between two
/// [Integer] expressions should return another [Integer].
abstract class Number extends SelfEvaluating {
  final inlineUI = true;
  dynamic get value;

  Number();

  /// Create a new [Number] from a Dart [num].
  ///
  /// Note that whole number [double] values like `1.0` will yield an [Integer],
  /// not a [Double].
  factory Number.fromNum(num value) {
    if (value.floor() == value) return new Integer(value.floor());
    return new Double(value);
  }

  /// Attempts to create a new [Number] from a string.
  ///
  /// Note that strings like `"1.0"` will yield an [Integer], not a [Double].
  factory Number.fromString(String numString) {
    try {
      return new Integer.fromBigInt(BigInt.parse(numString));
    } catch (e) {
      return new Number.fromNum(num.parse(numString));
    }
  }

  Number _operation(Number other, Function fn) {
    num myNum = this is Double ? this.value : num.parse("$this");
    num otherNum = other is Double ? other.value : num.parse("$other");
    return new Number.fromNum(fn(myNum, otherNum));
  }

  int compareTo(Number other) {
    num myNum = this is Double ? this.value : num.parse("$this");
    num otherNum = other is Double ? other.value : num.parse("$other");
    return myNum.compareTo(otherNum);
  }

  operator +(Number other) => _operation(other, (a, b) => a + b);
  operator -(Number other) => _operation(other, (a, b) => a - b);
  operator -();
  operator *(Number other) => _operation(other, (a, b) => a * b);
  operator %(Number other) => _operation(other, (a, b) => a % b);
  operator /(Number other) => _operation(other, (a, b) => a / b);
  operator ~/(Number other) {
    if (other == zero) throw new SchemeException("cannot divide by zero");
    return _operation(other, (a, b) => a ~/ b);
  }

  operator <(Number other) => compareTo(other) < 0;
  operator <=(Number other) => compareTo(other) <= 0;
  operator >(Number other) => compareTo(other) > 0;
  operator >=(Number other) => compareTo(other) >= 0;
  operator ==(dynamic other) {
    if (other is num) return this == new Number.fromNum(other);
    if (other is Number) return compareTo(other) == 0;
    return false;
  }

  toString() => value.toString();

  static final zero = new Integer(0);
  static final one = new Integer(1);
  static final two = new Integer(2);
}

/// A Scheme integer.
///
/// Scheme [Integer] values are built-in on the [BigInt] class, allowing for
/// arbitrary-length integers even in the browser.
///
/// Once updated for Dart 2, the [BigInt] class from the rational library should
/// be replaced with the built-in class.
class Integer extends Number implements Serializable<Integer> {
  BigInt value;

  Integer.fromBigInt(this.value);

  factory Integer(int value) =>
      new Integer.fromBigInt(new BigInt.fromJsInt(value));

  Integer deserialize(Map data) =>
      new Integer.fromBigInt(BigInt.parse(data['value']));

  Map serialize() => {'type': 'Integer', 'value': value.toString()};

  operator -() => new Integer.fromBigInt(-value);

  @override
  operator /(Number other) {
    if (other == Number.zero) {
      throw new SchemeException("cannot divide by zero");
    }
    if (other is Integer && (value % other.value).is0) return this ~/ other;
    return super._operation(other, (a, b) => a / b);
  }

  @override
  Number _operation(Number other, Function fn) {
    if (other is Integer) return new Integer.fromBigInt(fn(value, other.value));
    return super._operation(other, fn);
  }

  @override
  int compareTo(Number other) {
    if (other is Integer) return value.compareTo(other.value);
    return super.compareTo(other);
  }
}

/// A Scheme double-precision floating point number.
///
/// Simple wrapper around a Dart [double].
class Double extends Number implements Serializable<Double> {
  double value;

  Double(this.value);

  Double deserialize(Map data) => new Double(data['value']);

  Map serialize() => {'type': 'Double', 'value': value};

  operator -() => new Double(-value);
}

/// Given an iterable of [Expression] objects, checks that they are all numbers
/// and returns a new iterable will all of them casted as such.
Iterable<Number> allNumbers(Iterable<Expression> expr) {
  return expr.map((ex) =>
      ex is Number ? ex : throw new SchemeException("$ex is not a number."));
}
