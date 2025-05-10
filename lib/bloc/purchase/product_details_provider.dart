import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/domain/config/store_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'product_details_provider.g.dart';

@riverpod
Future<ProductDetailsResponse> productDetails(Ref ref) async {
  final config = ref.watch(configProvider).value!;

  final productIds = config.storeItems.values
      .expand((siList) => siList)
      .whereType<StoreItemIAP>()
      .map((si) => si.id)
      .toSet();

  return InAppPurchase.instance.queryProductDetails(productIds);
}
