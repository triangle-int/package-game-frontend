import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/domain/config/store_item.dart';

final productDetailsProvider = FutureProvider((ref) async {
  final config = ref.watch(configProvider).value!;

  final productIds = config.storeItems.values
      .expand((siList) => siList)
      .whereType<StoreItemIAP>()
      .map((si) => si.id)
      .toSet();

  return InAppPurchase.instance.queryProductDetails(productIds);
});
