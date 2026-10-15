import "package:flow/entity/transaction/extensions/default/foreign_currency.dart";
import "package:flow/entity/transaction/extensions/default/transfer.dart";
import "package:flow/entity/transaction/wrapper.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("ForeignCurrency survives a serialization round trip", () {
    final String? serialized = ExtensionsWrapper([
      ForeignCurrency(uuid: "a", amount: -10.5, currency: "USD"),
    ]).serialize();

    final ForeignCurrency? parsed = ExtensionsWrapper.parse(
      serialized,
    ).foreignCurrency;

    expect(parsed?.uuid, "a");
    expect(parsed?.amount, -10.5);
    expect(parsed?.currency, "USD");
  });

  test("ExtensionsWrapper setters replace the existing extension", () {
    final ExtensionsWrapper wrapper = ExtensionsWrapper([
      ForeignCurrency(uuid: "a", amount: 1, currency: "USD"),
    ]);

    wrapper.foreignCurrency = ForeignCurrency(
      uuid: "b",
      amount: 2,
      currency: "EUR",
    );
    wrapper.transfer = Transfer(
      uuid: "c",
      fromAccountUuid: "x",
      toAccountUuid: "y",
      relatedTransactionUuid: null,
    );

    expect(wrapper.data.length, 2);
    expect(wrapper.foreignCurrency?.currency, "EUR");
    expect(wrapper.transfer?.uuid, "c");

    wrapper.foreignCurrency = null;

    expect(wrapper.foreignCurrency, isNull);
  });
}
