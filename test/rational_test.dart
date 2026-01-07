import 'package:decimal4d/decimal.dart';
import 'package:decimal4d/rational.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group("Rational", () {
    test("Constructor and toString", () {
      expect(Rational.intFraction(1, 3).toString(), "1/3");
      expect(Rational.intFraction(-1, 3).toString(), "-1/3");
      expect(Rational.intFraction(1, -3).toString(), "-1/3");
      expect(Rational.intFraction(-1, -3).toString(), "1/3");
      expect(Rational.intFraction(10, 20).toString(), "1/2");

      expect(Rational.parse("-1/3").toString(), "-1/3");
      expect(Rational.parse("  4  /  -8  ").toString(), "-1/2");
    });

    test("+-*/", () {
      var r1 = Rational.intFraction(1, 2);
      var r2 = Rational.intFraction(1, 3);

      expect((r1 + r2).toString(), "5/6");
      expect((r1 - r2).toString(), "1/6");
      expect((r1 * r2).toString(), "1/6");
      expect((r1 / r2).toString(), "1.5");
      expect((r2 / r1).toString(), "2/3");

      expect(
        () => Rational.intFraction(1, 3) / Decimal.zero,
        throwsArgumentError,
      );
    });

    test("withScale", () {
      var r = Rational.intFraction(1, 3);
      expect(r.toString(), "1/3");
      expect(r.withScale(2, RoundingMode.halfUp).toString(), "0.33");
      expect(r.withScale(3, RoundingMode.halfUp).toString(), "0.333");
      expect(r.withScale(4, RoundingMode.halfUp).toString(), "0.3333");
    });

    test("Comparison and Equals", () {
      var a = Rational.intFraction(1, 2);
      var b = Rational.intFraction(2, 4);
      var c = Decimal.parse("1.50000");

      expect(a == b, isTrue);
      expect(a.strictEquals(b), isTrue);
      expect(a < c, isTrue);
      expect(a <= c, isTrue);
      expect(a > c, isFalse);
      expect(a >= c, isFalse);
      expect(a.compareTo(b), 0);

      a = Rational.intFraction(1, 3);
      b = Rational.intFraction(2, 6);
      c = Decimal.parse("0.3333");
      var d = Decimal.parse("0.3334");
      expect(a == b, isTrue);
      expect(a.strictEquals(b), isTrue);
      expect(a > c, isTrue);
      expect(a < d, isTrue);

      b = Rational.fraction(BigInt.from(2), BigInt.from(6), reduce: false);
      expect(a == b, isTrue);
      expect(a.strictEquals(b), isFalse);
    });
  });
}
