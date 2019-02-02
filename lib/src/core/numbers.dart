library cs61a_scheme.core.numbers;

import 'expressions.dart';
import 'frame.dart';
import 'logging.dart';
import 'serialization.dart';
import 'values.dart';

/// Base class for both Scheme number types.
///
/// Supports most arithmetic operations. For arithmetic operations that include
/// a [Double] the result will typically be another [Double] unless the value
/// can be represented as an integer (like `1.0`).
///
/// With the exception of true division, all arithmetic operations between two
/// [Integer] expressions should return another [Integer].
abstract class Number extends Expression {
  Number();

  /// Create a new [Number] from a Dart [num].
  ///
  /// Note that whole number [double] values like `1.0` will yield an [Integer],
  /// not a [Double].
  factory Number.fromNum(num value) {
    if (value.floor() == value) return Integer(value.floor());
    return Double(value);
  }

  /// Attempts to create a new [Number] from a string.
  ///
  /// Note that strings like `"1.0"` will yield an [Integer], not a [Double].
  factory Number.fromString(String numString) {
    try {
      return Integer.fromBigInt(BigInt.parse(numString));
    } on FormatException {
      return Number.fromNum(num.parse(numString));
    }
  }

  bool get inlineInDiagram => true;
  dynamic get value;

  Value evaluate(Frame env) => this;

  Number _operation(Number other, Function fn) {
    num myNum = this is Double ? value : num.parse("$this");
    num otherNum = other is Double ? other.value : num.parse("$other");
    return Number.fromNum(fn(myNum, otherNum));
  }

  int compareTo(Number other) {
    num myNum = this is Double ? value : num.parse("$this");
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
    if (other == zero) throw SchemeException("cannot divide by zero");
    return _operation(other, (a, b) => a ~/ b);
  }

  operator <(Number other) => compareTo(other) < 0;
  operator <=(Number other) => compareTo(other) <= 0;
  operator >(Number other) => compareTo(other) > 0;
  operator >=(Number other) => compareTo(other) >= 0;
  operator ==(other) {
    if (other is num) return this == Number.fromNum(other);
    if (other is Number) return compareTo(other) == 0;
    return false;
  }

  int get hashCode => value.hashCode;

  toString() => value.toString();

  static final zero = Integer(0);
  static final one = Integer(1);
  static final two = Integer(2);
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

  factory Integer(int value) => Integer.fromBigInt(BigInt.from(value));

  Integer deserialize(Map data) =>
      Integer.fromBigInt(BigInt.parse(data['value']));

  Map serialize() => {'type': 'Integer', 'value': value.toString()};

  operator -() => Integer.fromBigInt(-value);

  @override
  operator /(Number other) {
    if (other == Number.zero) {
      throw SchemeException("cannot divide by zero");
    }
    if (other is Integer && (value % other.value) == BigInt.zero) {
      return this ~/ other;
    }
    return super._operation(other, (a, b) => a / b);
  }

  @override
  Number _operation(Number other, Function fn) {
    if (other is Integer) return Integer.fromBigInt(fn(value, other.value));
    return super._operation(other, fn);
  }

  @override
  int compareTo(Number other) {
    if (other is Integer) return value.compareTo(other.value);
    return super.compareTo(other);
  }

  @override
  num toJS() => value.isValidInt ? value.toInt() : value.toDouble();
}

/// A Scheme double-precision floating point number.
///
/// Simple wrapper around a Dart [double].
class Double extends Number implements Serializable<Double> {
  double value;

  Double(this.value);

  Double deserialize(Map data) => Double(data['value']);

  Map serialize() => {'type': 'Double', 'value': value};

  operator -() => Double(-value);

  @override
  double toJS() => value;
}
