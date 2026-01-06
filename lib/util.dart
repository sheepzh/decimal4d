import 'dart:math' as math;

/// Calculate 10 raised to the power of [exponent]
BigInt pow10(int exponent) {
  if (exponent == 0) return BigInt.one;
  return BigInt.from(math.pow(10, exponent));
}

/// Calculate the greatest common divisor (GCD) of [a] and [b]
(BigInt a, BigInt b) gcd(BigInt a, BigInt b) {
  if (a == BigInt.zero ||
      b == BigInt.zero ||
      a == BigInt.one ||
      b == BigInt.one) {
    return (a, b);
  }

  final gcd = a.gcd(b);
  a = a ~/ gcd;
  b = b ~/ gcd;
  return (a, b);
}
