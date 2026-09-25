import "package:flow/widgets/insights/insight_formatter.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  const InsightFormatter format = InsightFormatter(currency: "USD");

  test("small amounts keep their cents", () {
    expect(format.money(11.99), "\$11.99");
  });

  test("amounts over 100 drop the cents", () {
    expect(format.money(1905.4), "\$1,905");
  });

  test("big amounts are abbreviated unless full amounts are preferred", () {
    expect(format.money(12400.0), "\$12.4K");
    expect(
      const InsightFormatter(
        currency: "USD",
        preferFullAmounts: true,
      ).money(12400.0),
      "\$12,400",
    );
  });

  test("amounts are always positive", () {
    expect(format.money(-226.0), "\$226");
  });

  test("privacy mode hides the digits", () {
    expect(
      const InsightFormatter(currency: "USD", obscure: true).money(486.0),
      "\$***",
    );
  });

  test("percents and ratios", () {
    expect(format.percent(-0.274), "27%");
    expect(format.ratio(1.87), "1.9×");
  });
}
