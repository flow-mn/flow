import "dart:async";

import "package:flow/constants.dart";
import "package:flutter/foundation.dart";
import "package:in_app_purchase/in_app_purchase.dart";
import "package:logging/logging.dart";

final Logger _log = Logger("TipService");

class TipService {
  static TipService? _instance;

  factory TipService() => _instance ??= TipService._internal();

  TipService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final ValueNotifier<List<ProductDetails>?> products =
      ValueNotifier<List<ProductDetails>?>(null);

  final ValueNotifier<String?> pending = ValueNotifier<String?>(null);

  final StreamController<ProductDetails> _onTipController =
      StreamController<ProductDetails>.broadcast();

  Stream<ProductDetails> get onTip => _onTipController.stream;

  bool _available = false;
  bool get available => _available;

  Future<void> init() async {
    _available = await _iap.isAvailable();

    if (!_available) {
      _log.info("In-app purchases are not available on this device");
      products.value = const [];
      return;
    }

    _subscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object error) => _log.warning("Purchase stream error", error),
    );

    await loadProducts();
  }

  Future<void> loadProducts() async {
    if (!_available) return;

    final ProductDetailsResponse response = await _iap.queryProductDetails(
      tipProductIds,
    );

    if (response.error != null) {
      _log.warning("Failed to query tip products", response.error);
    }
    if (response.notFoundIDs.isNotEmpty) {
      _log.warning("Tip products not found: ${response.notFoundIDs}");
    }

    products.value = response.productDetails
      ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
  }

  Future<void> tip(ProductDetails product) async {
    if (!_available || pending.value != null) return;

    pending.value = product.id;

    try {
      await _iap.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      _log.warning("Failed to start purchase for ${product.id}", e);
      pending.value = null;
      rethrow;
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccess(purchase);
        case PurchaseStatus.error:
          _log.warning("Purchase error", purchase.error);
          pending.value = null;
        case PurchaseStatus.canceled:
          pending.value = null;
      }

      // Consumables MUST be completed, otherwise StoreKit keeps redelivering
      // the transaction on every launch.
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  void _handleSuccess(PurchaseDetails purchase) {
    pending.value = null;

    _log.info("Tip received: ${purchase.productID}");

    final ProductDetails? product = products.value
        ?.where((p) => p.id == purchase.productID)
        .firstOrNull;

    if (product != null) {
      _onTipController.add(product);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _onTipController.close();
  }
}
