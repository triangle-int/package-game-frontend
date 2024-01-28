import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/domain/config/store_item.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchase_repository.g.dart';

@riverpod
PurchaseRepository purchaseRepository(PurchaseRepositoryRef ref) {
  return PurchaseRepository(ref.watch(dioProvider), ref);
}

class PurchaseRepository {
  final Dio _dio;
  final Ref _ref;

  PurchaseRepository(
    this._dio,
    this._ref,
  );

  Future<void> buyProduct(ProductDetails productDetails) async {
    final config = _ref.read(configProvider).value!;

    final isConsumable = config.storeItems.values
        .expand((e) => e)
        .whereType<StoreItemIAP>()
        .firstWhere((e) => e.id == productDetails.id)
        .isConsumable;
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    if (isConsumable) {
      InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    } else {
      InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<bool> validateReceipt(PurchaseDetails purchaseDetails) async {
    Logger().d(purchaseDetails.verificationData.serverVerificationData);
    try {
      _dio.post(
        '/payment/check-apple-receipt',
        data: {
          'transactionReceipt':
              purchaseDetails.verificationData.serverVerificationData,
        },
      );
      return true;
    } on DioException {
      return false;
    }
  }

  Stream<List<PurchaseDetails>> purchasesStream() {
    return InAppPurchase.instance.purchaseStream;
  }

  Future<void> buyBooster(String boosterName) async {
    await _dio.post(
      '/booster/buy-booster',
      data: {
        'boosterType': boosterName,
      },
    );
  }
}
