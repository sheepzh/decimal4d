# Decimal for Dart

A comprehensive decimal library for Dart that provides precise decimal arithmetic with support for infinite repeating decimals. Built for high-precision calculations without floating-point errors.

## Features

- **Precise Decimal Arithmetic**: Exact arithmetic operations without floating-point precision loss
- **Infinite Repeating Decimals**: Automatic detection and representation of repeating decimals using rational numbers
- **Multiple Rounding Modes**: 8 different rounding strategies (up, down, ceiling, floor, halfUp, halfDown, halfEven, unnecessary)
- **Flexible Parsing**: Parse decimals from strings with various formats
- **Rational Number Support**: Seamlessly work with both terminating and non-terminating decimals
- **Full Test Coverage**: Comprehensive test suite ensuring reliability

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  decimal4d: [latestVersion]
```

Then run:

```bash
flutter pub get
# or
dart pub get
```

## Quick Start

### Basic Operations

```dart
import 'package:decimal4d/decimal.dart';

void main() {
  // Create decimals
  var a = Decimal.parse("12.34");           // 12.34
  var b = Decimal.fromInt(5);               // 5
  var c = Decimal.intFraction(10, 20);      // 0.5
  var d = 0.123.toDecimal();                // 0.123
  // Create rationals
  var e = Decimal.intFraction(1, 3);        // 1/3
  var f = Rational.intFraction(1, 2);       // 1/2,  Not decimal 0.5

  // Arithmetic operations
  var sum = a + b;          // 17.34
  var diff = a - b;         // 7.34
  var product = a * b;      // 61.70
  var division = a / c;     // 12.34 / 0.5 = 1234 / 50 = 617/25

  // Arithmetic operations among rationals
  sum = a + e;              // 1234/100 + 1/3 = (1234*3+100*1)/(3*100) = 1901/150
  diff = e - f;             // 1/3 - 1/2 = -1/6
  product = b * f;          // 5 * 1/2 = 5/2 = 2.5

  // Comparison
  var g = Decimal.parse("1.2");
  var gg = Decimal.parse("1.200");
  var h = Rational.intFraction(6, 5);
  var hh = Rational.intFraction(24, 20);
  g == gg;                  // True
  g.strictEquals(gg);       // false
  g == h;                   // True
  
  // Convert to other types
  int intValue = a.toInt();             // 12 (truncates decimal part)
  double doubleValue = a.toDouble();    // 12.34
}
```

### Rounding Operations

```dart
import 'package:decimal4d/decimal.dart';

void main() {
  var value = Decimal.parse("2.5");

  // Using halfUp rounding (default)
  var rounded = value.halfUp(0);  // 3

  // Using different rounding modes
  var result = value.withScale(0, RoundingMode.halfUp);     // 3
  var down = value.withScale(0, RoundingMode.down);         // 2
  var ceiling = value.withScale(0, RoundingMode.ceiling);   // 3
  var floor = value.withScale(0, RoundingMode.floor);       // 2

  // Rational
  var rational = Decimal.intFraction(4, 3);                 // 4/3
  rational.withScale(0, RoundingMode.down);                 // 1
  rational.withScale(1, RoundingMode.floor);                // 1.3
  rational.withScale(2, RoundingMode.ceiling);              // 1.34
}
```

## API Reference

### Decimal Class

Main class for decimal arithmetic. Represents fixed-scale decimals with unlimited precision.

#### Static Properties

- `Decimal.zero` - Returns a Decimal with value 0
- `Decimal.one` - Returns a Decimal with value 1

#### Constructors

- `Decimal(BigInt value, int scale)` - Direct constructor with BigInt value and scale
- `Decimal.fromInt(int value)` - Create from integer
- `Decimal.intFraction(int numerator, int denominator)` - Create from integer fraction
- `Decimal.fraction(BigInt numerator, BigInt denominator)` - Create from BigInt fraction
- `Decimal.parse(String value)` - Parse from string

**Parse Examples:**
- `"2"` → 2
- `"0.2"` → 0.2
- `"-0.2000"` → -0.2000 (preserves scale)
- `".0"` → 0.0
- `"-.25"` → -0.25
- `"1."` → 1
- `"-0."` → 0
- `"+.230"` → 0.230

#### Properties

- `int scale` - Number of decimal places
- `bool operator ==(Object other)` - Equality (ignores trailing zeros)
- `int compareTo(Decimal other)` - Comparison

#### Methods

- `String toString()` - Convert to plain string representation
- `int toInt()` - Convert to int (truncates decimal part)
- `BigInt toBigInt()` - Convert to BigInt (truncates decimal part)
- `double toDouble()` - Convert to double (may lose precision)
- `Rational toRational()` - Convert to Rational representation

#### Arithmetic Operations

- `Decimal operator +(Decimal other)` - Addition
- `Decimal operator -(Decimal other)` - Subtraction
- `Decimal operator *(Decimal other)` - Multiplication
- `Decimal operator /(Decimal other)` - Division (may return Rational)
- `Decimal operator -()` - Negation
- `Decimal abs()` - Absolute value

#### Division

- `Decimal divide(Decimal other, {int? scale, RoundingMode? mode})` - Division with optional rounding

**Division Examples:**
- `Decimal.parse("10") / Decimal.parse("4")` → Decimal("2.5")
- `Decimal.parse("1") / Decimal.parse("3")` → Rational("1/3")
- `Decimal.parse("1") / Decimal.parse("8")` → Decimal("0.125")
- `Decimal.parse("1") / Decimal.parse("0")` → throws ArgumentError

#### Comparison Operators

- `bool operator <(Decimal other)` - Less than
- `bool operator <=(Decimal other)` - Less than or equal to
- `bool operator >(Decimal other)` - Greater than
- `bool operator >=(Decimal other)` - Greater than or equal to
- `bool strictEquals(Decimal other)` - Strict equality check including scale or infraction of rational

#### Rounding

- `Decimal withScale(int scale, RoundingMode mode)` - Convert to specified scale with rounding
- `Decimal halfUp(int scale)` - Rounds to specified scale using half-up rounding

#### Extensions

- `Decimal toDecimal({int? scale, RoundingMode? mode})` - Extension on double to convert to Decimal

### Rational Class

Represents rational numbers (fractions) with automatic simplification.

#### Constructors

- `Rational.intFraction(int numerator, int denominator)` - Create from integer fraction
- `Rational.fraction(BigInt numerator, BigInt denominator, {bool reduce = true})` - Create from BigInt fraction

#### Methods

All methods from Decimal class, including:
- Arithmetic operations: `+`, `-`, `*`, `/`
- Comparison: `compareTo`, `<`, `<=`, `>`, `>=`
- Type conversion: `toString()`, `toDouble()`, `withScale()`
- Negation: `operator -()`

## Testing

Run the test suite:

```bash
dart test
# or
flutter test
```

## License

See LICENSE file for details.

## Repository

[https://github.com/sheepzh/decimal4d](https://github.com/sheepzh/decimal4d)
