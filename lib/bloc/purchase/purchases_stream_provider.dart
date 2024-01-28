import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/purchase/purchase_repository.dart';

final purchasesStreamProvider = StreamProvider((Ref ref) {
  return ref.watch(purchaseRepositoryProvider).purchasesStream();
});
