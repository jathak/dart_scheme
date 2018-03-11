library cs61a_scheme.core.numbers;

import 'package:rational/bigint.dart';

import 'expressions.dart';
import 'logging.dart';
import 'serialization.dart';

abstract class Number extends SelfEvaluating {
  final inlineUI = true;
  dynamic get value;

  Number();

  factory Number.fromNum(num value) {
    if (value.floor() == value) return new Integer(value.floor());
    return new Double(value);
  }

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

class Double extends Number implements Serializable<Double> {
  double value;

  Double(this.value);

  Double deserialize(Map data) => new Double(data['value']);

  Map serialize() => {'type': 'Double', 'value': value};

  operator -() => new Double(-value);
}

Iterable<Number> allNumbers(List<Expression> expr) {
  return expr.map((ex) =>
      ex is Number ? ex : throw new SchemeException("$ex is not a number."));
}
