import "package:flow/data/flow_icon.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("Legacy brand code points resolve to slugs", () {
    final FlowIconData? paypal = FlowIconData.tryParse(
      "IconFlowIcon:SimpleIcons,simple_icons,f228",
    );

    expect(paypal, isA<SimpleIconFlowIcon>());
    expect((paypal as SimpleIconFlowIcon).slug, equals("paypal"));
    expect(paypal.iconData, isNotNull);
  });

  test("Brands removed upstream don't resolve to another brand", () {
    final FlowIconData? amazon = FlowIconData.tryParse(
      "IconFlowIcon:SimpleIcons,simple_icons_flow,ea78",
    );

    expect(amazon, isA<SimpleIconFlowIcon>());
    expect((amazon as SimpleIconFlowIcon).iconData, isNull);
  });

  test("Material Symbols stay code point based", () {
    final FlowIconData? icon = FlowIconData.tryParse(
      "IconFlowIcon:MaterialSymbolsRounded,material_symbols_icons,e5ca",
    );

    expect(icon, isA<IconFlowIcon>());
    expect((icon as IconFlowIcon).iconData.codePoint, equals(0xe5ca));
    expect(icon.iconData.fontPackage, equals("material_symbols_icons_flow"));
  });
}
