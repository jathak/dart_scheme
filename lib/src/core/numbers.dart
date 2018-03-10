library cs61a_scheme.core.numbers;

import 'package:rational/bigint.dart';
import 'package:quiver_hashcode/hashcode.dart';

import 'expressions.dart';
import 'logging.dart';
import 'serialization.dart';

class Number extends SelfEvaluating implements Serializable<Number> {
  final inlineUI = true;
  final bool isInteger;
  final double doubleValue;
  final BigInt bigInt;
  const Number.fromDouble(this.doubleValue)
      : isInteger = false,
        bigInt = null;
  const Number.fromBigInt(this.bigInt)
      : isInteger = true,
        doubleValue = null;

  factory Number.fromInt(int value) {
    return new Number.fromBigInt(new BigInt.fromJsInt(value));
  }

  factory Number.fromNum(num value) {
    if (value is int) return new Number.fromInt(value);
    return new Number.fromDouble(value);
  }

  static final zero = new Number.fromInt(0);
  static final one = new Number.fromInt(1);
  static final two = new Number.fromInt(2);

  factory Number.fromString(String numString) {
    try {
      return new Number.fromBigInt(BigInt.parse(numString));
    } catch (e) {
      return new Number.fromDouble(double.parse(numString));
    }
  }

  String toString() => isInteger ? "$bigInt" : "$doubleValue";

  num toJS() => isInteger ? num.parse("$bigInt") : doubleValue;

  Map serialize() => {'type': 'Number', 'data': toString()};

  Number deserialize(Map data) => new Number.fromString(data['data']);

  static Number _operation(Number a, Number b, Function fn) {
    if (a.isInteger && b.isInteger) {
      return new Number.fromBigInt(fn(a.bigInt, b.bigInt));
    } else if (!a.isInteger && !b.isInteger) {
      return new Number.fromDouble(fn(a.doubleValue, b.doubleValue));
    }
    num aNum = a.isInteger ? num.parse("$a") : a.doubleValue;
    num bNum = b.isInteger ? num.parse("$b") : b.doubleValue;
    num result = fn(aNum, bNum);
    if (result is int) return new Number.fromInt(result);
    return new Number.fromDouble(result);
  }

  int compareTo(Number other) {
    if (isInteger && other.isInteger) return bigInt.compareTo(other.bigInt);
    if (!isInteger && !other.isInteger) {
      return doubleValue.compareTo(other.doubleValue);
    }
    num a = this.isInteger ? num.parse("$this") : this.doubleValue;
    num b = other.isInteger ? num.parse("$other") : other.doubleValue;
    return a.compareTo(b);
  }

  operator +(Number other) => _operation(this, other, (a, b) => a + b);
  operator -(Number other) => _operation(this, other, (a, b) => a - b);
  operator -() => isInteger
      ? new Number.fromBigInt(-bigInt)
      : new Number.fromDouble(-doubleValue);
  operator /(Number other) {
    if (other == zero) throw new SchemeException("cannot divide by zero");
    if (!this.isInteger && !other.isInteger) {
      return new Number.fromDouble(this.doubleValue / other.doubleValue);
    } else if (this.isInteger && other.isInteger) {
      if ((this.bigInt % other.bigInt).is0) return this ~/ other;
    }
    num a = this.isInteger ? num.parse("$this") : this.doubleValue;
    num b = other.isInteger ? num.parse("$other") : other.doubleValue;
    return new Number.fromDouble(a / b);
  }

  operator ~/(Number other) {
    if (other == zero) throw new SchemeException("cannot divide by zero");
    return _operation(this, other, (a, b) => a ~/ b);
  }

  operator *(Number other) => _operation(this, other, (a, b) => a * b);
  operator %(Number other) => _operation(this, other, (a, b) => a % b);
  operator <(Number other) => compareTo(other) < 0;
  operator <=(Number other) => compareTo(other) <= 0;
  operator >(Number other) => compareTo(other) > 0;
  operator >=(Number other) => compareTo(other) >= 0;
  operator ==(dynamic other) {
    if (other is int) return this == new Number.fromInt(other);
    if (other is double) return this == new Number.fromDouble(other);
    if (other is Number) return compareTo(other) == 0;
    return false;
  }

  @override
  int get hashCode => hash3(isInteger, doubleValue, bigInt);
}

Iterable<Number> allNumbers(List<Expression> expr) {
  return expr.map((ex) =>
      ex is Number ? ex : throw new SchemeException("$ex is not a number."));
}
