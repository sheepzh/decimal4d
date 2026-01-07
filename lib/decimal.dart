import 'dart:math' as math;
import 'dart:math';

import 'package:decimal4d/rational.dart';
import 'package:decimal4d/util.dart';

final _bi2 = BigInt.from(2);
final _bi5 = BigInt.from(5);

BigInt _parseBigInt(String value) {
  return value.isEmpty ? BigInt.zero : BigInt.parse(value);
}

/// Rounding modes for decimal operations
enum RoundingMode {
  /// Upward rounding (away from zero)
  /// Examples for integers:
  /// + -2.3 -> -3
  /// + 2.3 -> 3
  /// + 0.0 -> 0
  /// + 0.0000001 -> 1
  /// + -0.0000001 -> -1
  up,

  /// Downward rounding (towards zero)
  /// Examples for integers:
  /// + -2.3 -> -2
  /// + 2.3 -> 2
  /// + 0.0 -> 0
  /// + 0.0000001 -> 0
  /// + -0.0000001 -> 0
  down,

  /// Ceiling rounding (towards positive infinity)
  /// Examples for integers:
  /// + -2.3 -> -2
  /// + 2.3 -> 3
  /// + 0.0 -> 0
  /// + 0.0000001 -> 1
  /// + -0.0000001 -> 0
  ceiling,

  /// Floor rounding (towards negative infinity)
  /// Examples for integers:
  /// + -2.3 -> -3
  /// + 2.3 -> 2
  /// + 0.0 -> 0
  /// + 0.0000001 -> 0
  /// + -0.0000001 -> -1
  floor,

  /// Five up six down (round towards nearest integer, if equidistant round up)
  /// Examples for integers:
  /// + -2.5 -> -3
  /// + 2.5 -> 3
  /// + -2.4 -> -2
  /// + 2.4 -> 2
  /// + 0.5 -> 1
  /// + -0.5 -> -1
  halfUp,

  /// Five down six up (round towards nearest integer, if equidistant round down)
  /// Examples for integers:
  /// + -2.5 -> -2
  /// + 2.5 -> 2
  /// + -2.6 -> -3
  /// + 2.6 -> 3
  /// + 0.5 -> 0
  /// + -0.5 -> 0
  halfDown,

  /// Five to even (round towards nearest integer, if equidistant round to even)
  /// Examples for integers:
  /// + -2.5 -> -2
  /// + 2.5 -> 2
  /// + -3.5 -> -4
  /// + 3.5 -> 4
  /// + -2.6 -> -3
  /// + 2.6 -> 3
  /// + 0.5 -> 0
  /// + 1.5 -> 2
  halfEven,

  /// Assert that no rounding is necessary
  /// Examples for integers:
  /// + -2.0 -> -2
  /// + 2.0 -> 2
  /// + -2.3 -> throws ArgumentError
  /// + 2.3 -> throws ArgumentError
  unnecessary,
}

/// ## Decimal
/// ```dart
/// var a = Decimal.parse("12.34");
/// var b = Decimal.fromInt(5);
/// var c = a + b; // 17.34
/// var d = a / Decimal.parse("3"); // 867/25 (Rational representation)
/// var e = d.withScale(2, RoundingMode.halfUp); // 34.68
/// ```
class Decimal implements Comparable<Decimal> {
  final BigInt _value;
  final int _scale;

  int get scale => _scale;

  Decimal(this._value, this._scale);

  /// Zero without decimal places
  /// "0"
  static final Decimal zero = Decimal.fromInt(0);

  /// One without decimal places
  /// "1"
  static final Decimal one = Decimal.fromInt(1);

  factory Decimal.fromInt(int value) {
    return Decimal(BigInt.from(value), 0);
  }

  factory Decimal.intFraction(int numerator, int denominator) {
    return Decimal.fraction(BigInt.from(numerator), BigInt.from(denominator));
  }

  factory Decimal.fraction(BigInt numerator, BigInt denominator) {
    var (gcdNumerator, gcdDenominator) = gcd(numerator, denominator);
    // Judge the denominator only contains factors of 2 and 5
    BigInt temDenominator = gcdDenominator;
    int scale = 0;
    int tempScale = 0;
    while (temDenominator % _bi2 == BigInt.zero) {
      temDenominator = temDenominator ~/ _bi2;
      tempScale += 1;
    }
    scale = max(scale, tempScale);
    while (temDenominator % _bi5 == BigInt.zero) {
      temDenominator = temDenominator ~/ _bi5;
      tempScale += 1;
    }
    scale = max(scale, tempScale);

    if (temDenominator == BigInt.one) {
      // Not infinite decimal
      final decimalNumerator = gcdNumerator * pow10(scale);
      final decimalDenominator = gcdDenominator;
      if (decimalNumerator % decimalDenominator != BigInt.zero) {
        throw ArgumentError('Unexpected error');
      }

      return Decimal(decimalNumerator ~/ decimalDenominator, scale);
    }

    return Rational.fraction(gcdNumerator, gcdDenominator, reduce: false);
  }

  /// Parse from string
  ///
  /// Examples:
  /// + "2" -> 2
  /// + "0.2" -> 0.2
  /// + "-0.2000" -> -0.2000
  /// + ".0" -> 0.0
  /// + "-.25" -> -0.25
  /// + "1." -> 1
  /// + "-0." -> 0
  /// + "+.230" -> 0.230
  /// + "1/3" -> Rational(1, 3)
  factory Decimal.parse(String value) {
    value = value.trim();
    if (value.isEmpty) {
      throw FormatException('Empty string cannot be parsed as Decimal');
    }
    if (value.contains("/")) {
      return Rational.parse(value);
    }

    final isNegative = value.startsWith('-');
    if (isNegative || value.startsWith('+')) {
      value = value.substring(1);
    }

    final parts = value.split('.');
    if (parts.length > 2) {
      throw FormatException('Invalid decimal format: $value');
    }

    final integerPart = parts[0];
    final fractionalPart = parts.length == 2 ? parts[1] : '';
    final scale = fractionalPart.length;

    final integer = _parseBigInt(integerPart);
    final fractional = _parseBigInt(fractionalPart);
    final totalValue = integer * pow10(scale) + fractional;

    return Decimal(isNegative ? -totalValue : totalValue, scale);
  }

  /// Convert to plain string representation. <br/>
  /// Examples:
  /// + Decimal.parse("2").toString() -> "2"
  /// + Decimal.parse("0.2").toString() -> "0.2"
  /// + Decimal.parse("-0.2000").toString() -> "-0.2000"
  /// + Decimal.parse(".0").toString() -> "0.0"
  /// + Decimal.parse("-.25").toString() -> "-0.25"
  /// + Decimal.parse("1.").toString() -> "1"
  /// + Decimal.parse("-0.").toString() -> "0"
  /// + Decimal.parse("+.230").toString() -> "0.230"
  @override
  String toString() {
    final isNegative = _value < BigInt.zero;
    final absValue = _value.abs();

    if (_scale == 0) {
      return isNegative ? '-$absValue' : absValue.toString();
    }

    final valueStr = absValue.toString();
    if (valueStr.length <= _scale) {
      final padded = valueStr.padLeft(_scale, '0');
      final integerPart = '0';
      final fractionalPart = padded;
      final result = '$integerPart.$fractionalPart';
      return isNegative ? '-$result' : result;
    } else {
      final integerPart = valueStr.substring(0, valueStr.length - _scale);
      final fractionalPart = valueStr.substring(valueStr.length - _scale);
      final result = '$integerPart.$fractionalPart';
      return isNegative ? '-$result' : result;
    }
  }

  /// Convert to int (truncating decimal part)
  int toInt() {
    return (_value / pow10(_scale)).toInt();
  }

  /// Convert to BigInt (truncating decimal part)
  BigInt toBigInt() {
    return _value ~/ pow10(_scale);
  }

  /// Convert to double (may lose precision)
  double toDouble() {
    return _value.toDouble() / pow10(scale).toDouble();
  }

  /// Addition
  Decimal operator +(Decimal other) {
    final maxScale = math.max(_scale, other._scale);
    final thisValue = _value * pow10(maxScale - _scale);
    final otherValue = other._value * pow10(maxScale - other._scale);
    return Decimal(thisValue + otherValue, maxScale);
  }

  /// Subtraction
  Decimal operator -(Decimal other) {
    final maxScale = math.max(_scale, other._scale);
    final thisValue = _value * pow10(maxScale - _scale);
    final otherValue = other._value * pow10(maxScale - other._scale);
    return Decimal(thisValue - otherValue, maxScale);
  }

  /// Multiplication
  Decimal operator *(Decimal other) {
    return Decimal(_value * other._value, _scale + other._scale);
  }

  /// Division, may return Rational if not exact decimal<br />
  /// Examples:
  /// + Decimal.parse("10") / Decimal.parse("4") -> "2.5"
  /// + Decimal.parse("1") / Decimal.parse("3") -> "1/3" (Rational representation)
  /// + Decimal.parse("2") / Decimal.parse("6") -> "1/3" (Rational representation)
  /// + Decimal.parse("1") / Decimal.parse("8") -> "0.125"
  /// + Decimal.parse("1") / Decimal.parse("0") -> throws ArgumentError
  Decimal operator /(Decimal other) {
    return this.divide(other);
  }

  Rational toRational() {
    return Rational.fraction(_value, pow10(_scale));
  }

  Decimal divide(Decimal other, {int? scale, RoundingMode? mode}) {
    if (other == Decimal.zero) {
      throw ArgumentError('Divided by zero');
    }

    final thisRational = this.toRational();
    final otherRational = other.toRational();

    var res = thisRational / otherRational;
    return scale != null && mode != null ? res.withScale(scale, mode) : res;
  }

  /// Compare two Decimals<br/>
  /// **NOTES:**
  /// + This comparison ignores trailing zeros. If you need strict equality (including scale), use [strictEquals] method.
  /// + If other is a [Rational], it will be converted to [Rational] for comparison.
  @override
  int compareTo(Decimal other) {
    if (other is Rational) {
      return this.toRational().compareTo(other);
    }
    final maxScale = math.max(_scale, other._scale);
    final thisValue = _value * pow10(maxScale - _scale);
    final otherValue = other._value * pow10(maxScale - other._scale);
    return thisValue.compareTo(otherValue);
  }

  /// Less than
  bool operator <(Decimal other) => compareTo(other) < 0;

  /// Less than or equal to
  bool operator <=(Decimal other) => compareTo(other) <= 0;

  /// Greater than
  bool operator >(Decimal other) => compareTo(other) > 0;

  /// Greater than or equal to
  bool operator >=(Decimal other) => compareTo(other) >= 0;

  /// Equal to
  @override
  bool operator ==(Object other) {
    if (other is! Decimal) return false;
    return compareTo(other) == 0;
  }

  @override
  int get hashCode => _value.hashCode ^ _scale.hashCode;

  /// Negation
  Decimal operator -() {
    return Decimal(-_value, _scale);
  }

  /// Absolute value
  Decimal abs() {
    return _value < BigInt.zero ? Decimal(-_value, _scale) : this;
  }

  /// Rounds to specified scale using half-up rounding mode
  Decimal halfUp(int scale) {
    return withScale(scale, RoundingMode.halfUp);
  }

  /// Convert to Decimal with specified scale and rounding mode
  Decimal withScale(int scale, RoundingMode mode) {
    if (_scale == scale) {
      return this;
    }

    if (_scale < scale) {
      final factor = pow10(scale - _scale);
      return Decimal(_value * factor, scale);
    }

    final factor = pow10(_scale - scale);
    var rounded = _value ~/ factor;

    final remainder = _value.remainder(factor);
    final half = factor ~/ BigInt.two;
    final isNegative = _value < BigInt.zero;
    final absRemainder = remainder.abs();

    switch (mode) {
      case RoundingMode.up:
        if (remainder != BigInt.zero) {
          rounded = isNegative ? rounded - BigInt.one : rounded + BigInt.one;
        }
        break;
      case RoundingMode.down:
        break;
      case RoundingMode.ceiling:
        if (remainder != BigInt.zero && !isNegative) {
          rounded = rounded + BigInt.one;
        }
        break;
      case RoundingMode.floor:
        if (remainder != BigInt.zero && isNegative) {
          rounded = rounded - BigInt.one;
        }
        break;
      case RoundingMode.halfUp:
        if (absRemainder >= half) {
          rounded = isNegative ? rounded - BigInt.one : rounded + BigInt.one;
        }
        break;
      case RoundingMode.halfDown:
        if (absRemainder > half) {
          rounded = isNegative ? rounded - BigInt.one : rounded + BigInt.one;
        }
        break;
      case RoundingMode.halfEven:
        if (absRemainder > half) {
          rounded = isNegative ? rounded - BigInt.one : rounded + BigInt.one;
        } else if (absRemainder == half) {
          if (rounded.isOdd) {
            rounded = isNegative ? rounded - BigInt.one : rounded + BigInt.one;
          }
        }
        break;
      case RoundingMode.unnecessary:
        if (remainder != BigInt.zero) {
          throw ArgumentError(
            'Rounding necessary: value cannot be represented exactly with scale $scale',
          );
        }
        break;
    }

    return Decimal(rounded, scale);
  }

  /// Strict equality check (including scale)
  /// + returns false if other is a [Rational]
  /// + returns true only if both value and scale are equal
  /// + returns false otherwise
  bool strictEquals(Decimal other) {
    if (other is Rational) return false;
    return _value == other._value && _scale == other._scale;
  }
}

/// Extension to convert double to Decimal
extension DoubleToDecimal on double {
  Decimal toDecimal({int? scale, RoundingMode? mode}) {
    // Special handling for integer-valued doubles (e.g., 0.0, 1.0, 2.0)
    final isIntegerValued = this == truncateToDouble();

    // Convert double to string, then parse
    final str = this.toString();
    var parsed = Decimal.parse(str);

    // Remove trailing zeros but keep at least one decimal place for integer-valued doubles
    if (parsed._scale > 1) {
      var valueStr = parsed._value.abs().toString();
      var trailingZeros = 0;
      for (var i = valueStr.length - 1; i >= 0 && valueStr[i] == '0'; i--) {
        trailingZeros++;
      }
      if (trailingZeros > 0) {
        // Keep at least one decimal place
        final newScale = math.max(1, parsed._scale - trailingZeros);
        final factor = pow10(parsed._scale - newScale);
        final newValue = parsed._value ~/ factor;
        parsed = Decimal(newValue, newScale);
      }
    } else if (parsed._scale == 0 && isIntegerValued && this.abs() < 1e15) {
      // For integer-valued doubles, keep one decimal place
      parsed = Decimal(BigInt.from((this * 10).round()), 1);
    }

    if (scale != null && mode != null) {
      return parsed.withScale(scale, mode);
    }
    return parsed;
  }
}
