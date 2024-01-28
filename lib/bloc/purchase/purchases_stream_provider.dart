import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_flutter/domain/purchase/purchase_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'purchases_stream_provider.g.dart';

@riverpod
Stream<List<PurchaseDetails>> purchasesStream(PurchasesStreamRef ref) {
  return ref.watch(purchaseRepositoryProvider).purchasesStream();
}
