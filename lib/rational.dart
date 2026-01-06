import 'package:decimal4d/decimal.dart';
import 'package:decimal4d/util.dart';

/// Rational number represented as a fraction of two BigInts
class Rational extends Decimal {
  final BigInt _numerator;
  final BigInt _denominator;

  factory Rational.intFraction(int numerator, int denominator) {
    return Rational.fraction(BigInt.from(numerator), BigInt.from(denominator));
  }

  factory Rational.fraction(BigInt numerator, BigInt denominator,
      {bool reduce = true}) {
    if (!reduce) {
      return Rational._(numerator, denominator);
    }
    var (gcdNumerator, gcdDenominator) = gcd(numerator, denominator);
    // Ensure the denominator is positive
    if (gcdDenominator < BigInt.zero) {
      gcdNumerator = -gcdNumerator;
      gcdDenominator = -gcdDenominator;
    }
    return Rational._(gcdNumerator, gcdDenominator);
  }

  Rational._(this._numerator, this._denominator) : super(BigInt.one, 0);

  @override
  Rational toRational() {
    return this;
  }

  @override
  operator +(Decimal other) {
    final otherRational = other.toRational();

    final newNumerator = otherRational._numerator * this._denominator +
        _numerator * otherRational._denominator;
    final newDenominator = _denominator * otherRational._denominator;
    return Rational.fraction(newNumerator, newDenominator);
  }

  @override
  operator -(Decimal other) {
    return this + (-other);
  }

  Decimal operator -() {
    return Rational._(-this._numerator, _denominator);
  }

  @override
  operator *(Decimal other) {
    final otherRational = other.toRational();

    final newNumerator = _numerator * otherRational._numerator;
    final newDenominator = _denominator * otherRational._denominator;
    return Decimal.fraction(newNumerator, newDenominator);
  }

  @override
  operator /(Decimal other) {
    if (other == Decimal.zero) {
      throw ArgumentError('Divided by zero');
    }

    final otherRational = other.toRational();

    final newNumerator = _numerator * otherRational._denominator;
    final newDenominator = _denominator * otherRational._numerator;
    return Decimal.fraction(newNumerator, newDenominator);
  }

  @override
  int compareTo(Decimal other) {
    final otherOptional = other.toRational();

    final crossProduct1 = _numerator * otherOptional._denominator;
    final crossProduct2 = otherOptional._numerator * _denominator;
    return crossProduct1.compareTo(crossProduct2);
  }

  @override
  double toDouble() {
    return _numerator.toDouble() / _denominator.toDouble();
  }

  @override
  Decimal withScale(int scale, RoundingMode mode) {
    return toDouble().toDecimal(scale: scale, mode: mode);
  }

  @override
  String toString() {
    return "$_numerator/$_denominator";
  }

  @override
  operator ==(Object other) {
    Rational? rational = null;
    if (other is Decimal) {
      rational = other.toRational();
    } else if (other is Rational) {
      rational = other;
    } else {
      return false;
    }
    return this.compareTo(rational) == 0;
  }

  @override
  bool strictEquals(Decimal other) {
    if (other is! Rational) {
      return false;
    }
    return _numerator == other._numerator && _denominator == other._denominator;
  }
}
