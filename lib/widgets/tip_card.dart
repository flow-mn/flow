import "dart:async";

import "package:flow/data/flow_icon.dart";
import "package:flow/l10n/extensions.dart";
import "package:flow/services/in_app_purchase.dart";
import "package:flow/theme/theme.dart";
import "package:flow/utils/utils.dart";
import "package:flow/widgets/action_card.dart";
import "package:flow/widgets/general/button.dart";
import "package:flutter/material.dart";
import "package:in_app_purchase/in_app_purchase.dart";
import "package:material_symbols_icons_flow/symbols.dart";

class TipCard extends StatefulWidget {
  const TipCard({super.key});

  @override
  State<TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> {
  final TipService _tipService = TipService();

  StreamSubscription<ProductDetails>? _onTipSubscription;

  @override
  void initState() {
    super.initState();

    _onTipSubscription = _tipService.onTip.listen(_handleTip);

    if (_tipService.products.value == null) {
      unawaited(_tipService.init());
    }
  }

  @override
  void dispose() {
    _onTipSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProductDetails>?>(
      valueListenable: _tipService.products,
      builder: (context, products, _) {
        if (products == null || products.isEmpty) {
          return const SizedBox.shrink();
        }

        return ActionCard(
          title: "support.donateDeveloper".t(context),
          subtitle: "support.donateDeveloper.description".t(context),
          icon: FlowIconData.icon(Symbols.favorite_rounded),
          trailing: ValueListenableBuilder<String?>(
            valueListenable: _tipService.pending,
            builder: (context, pending, _) {
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  for (final ProductDetails product in products)
                    Button(
                      backgroundColor: context.colorScheme.surface,
                      onTap: pending == null ? () => _tip(product) : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: pending == product.id ? 0.0 : 1.0,
                            child: Text(product.price),
                          ),
                          if (pending == product.id)
                            const SizedBox.square(
                              dimension: 16.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _tip(ProductDetails product) async {
    try {
      await _tipService.tip(product);
    } catch (e) {
      if (!mounted) return;
      context.showErrorToast(error: "support.tip.error".t(context));
    }
  }

  void _handleTip(ProductDetails product) {
    if (!mounted) return;
    context.showToast(text: "support.tip.thankYou".t(context));
  }
}
