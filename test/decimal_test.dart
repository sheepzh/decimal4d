import 'package:decimal4d/decimal.dart';
import 'package:decimal4d/rational.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group("Decimal Tests", () {
    test("Constructor", () {
      expect(Decimal.fromInt(2).toString(), "2");
      expect(Decimal.parse("0.2").toString(), "0.2");
      expect(Decimal.parse(".2").toString(), "0.2");
      expect(Decimal.parse("-.2").toString(), "-0.2");
      expect(Decimal.parse("-.2000").toString(), "-0.2000");
      expect(Decimal.parse("+.2000").toString(), "0.2000");
      expect(Decimal.parse("1.").toString(), "1");
      expect(Decimal.parse(".").toString(), "0");
      expect(Decimal.parse("+.230").toString(), "0.230");

      expect(Decimal.intFraction(1, 3).toString(), "1/3");
      expect(Decimal.intFraction(1, 2).toString(), "0.5");

      // From double
      expect(0.234.toDecimal().toString(), "0.234");
      expect(0.234000.toDecimal().toString(), "0.234");
      expect(0.0.toDecimal().toString(), "0.0");
      expect(
        0.234.toDecimal(scale: 10, mode: RoundingMode.unnecessary).toString(),
        "0.2340000000",
      );
    });

    test("Comparison and Equals", () {
      expect(Decimal.parse("0.2") == Decimal.parse("0.20"), isTrue);
      expect(Decimal.parse("0.2").compareTo(Decimal.parse("0.20")), 0);
      expect(Decimal.parse("0.2") < Decimal.parse("0.20"), isFalse);
      expect(Decimal.parse("0.2") <= Decimal.parse("0.20"), isTrue);
      expect(Decimal.parse("0.2") > Decimal.parse("0.20"), isFalse);
      expect(Decimal.parse("0.2") >= Decimal.parse("0.20"), isTrue);
      expect(Decimal.parse("0.2").strictEquals(Decimal.parse("0.20")), isFalse);

      expect(
        Decimal.parse("0.2") == Rational.intFraction(1, 5),
        isTrue,
      );
      expect(
        Decimal.parse("0.2").strictEquals(Rational.intFraction(1, 5)),
        isFalse,
      );
    });

    test("+-*/", () {
      var tmp = Decimal.fromInt(10) / Decimal.fromInt(4);
      expect(tmp.toString(), "2.5");
      tmp += Decimal.fromInt(10);
      expect(tmp.toString(), "12.5");
      tmp /= Decimal.fromInt(3);
      expect(tmp.toString(), "25/6");
      tmp = -tmp;
      expect(tmp.toString(), "-25/6");
      tmp *= Decimal.fromInt(18);
      expect(tmp.toString(), "-75");

      expect(() => tmp / Decimal.zero, throwsArgumentError);
    });

    test("withScale", () {
      var pos = Decimal.parse("0.12345");
      var neg = Decimal.parse("-0.12345");

      // Digit 5 = 5 (exactly at midpoint), scale to 4 places
      expect(neg.withScale(4, RoundingMode.up).toString(), "-0.1235");
      expect(neg.withScale(4, RoundingMode.down).toString(), "-0.1234");
      expect(pos.withScale(4, RoundingMode.up).toString(), "0.1235");
      expect(pos.withScale(4, RoundingMode.down).toString(), "0.1234");
      expect(neg.withScale(4, RoundingMode.floor).toString(), "-0.1235");
      expect(neg.withScale(4, RoundingMode.ceiling).toString(), "-0.1234");
      expect(pos.withScale(4, RoundingMode.floor).toString(), "0.1234");
      expect(pos.withScale(4, RoundingMode.ceiling).toString(), "0.1235");

      // halfEven with exact midpoint (digit 4 is even, should not round)
      var mid1 = Decimal.parse("0.12345");
      expect((-mid1).withScale(4, RoundingMode.halfEven).toString(), "-0.1234");
      expect(mid1.withScale(4, RoundingMode.halfEven).toString(), "0.1234");

      // halfEven when exceeds midpoint (should round)
      var over = Decimal.parse("0.123456789");
      expect((-over).withScale(4, RoundingMode.halfEven).toString(), "-0.1235");
      expect(over.withScale(4, RoundingMode.halfEven).toString(), "0.1235");

      // halfUp/halfDown at midpoint
      expect(neg.withScale(4, RoundingMode.halfUp).toString(), "-0.1235");
      expect(neg.withScale(4, RoundingMode.halfDown).toString(), "-0.1234");
      expect(pos.withScale(4, RoundingMode.halfUp).toString(), "0.1235");
      expect(pos.withScale(4, RoundingMode.halfDown).toString(), "0.1234");

      // unnecessary mode should throw when rounding is needed
      expect(() => pos.withScale(3, RoundingMode.unnecessary),
          throwsArgumentError);
      expect(pos.withScale(5, RoundingMode.unnecessary).toString(), "0.12345");
      expect(
        pos.withScale(20, RoundingMode.unnecessary).toString(),
        "0.12345000000000000000",
      );
    });
  });
}
