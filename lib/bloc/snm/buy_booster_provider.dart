import 'package:package_flutter/domain/purchase/purchase_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'buy_booster_provider.g.dart';

@riverpod
class BuyBooster extends _$BuyBooster {
  @override
  FutureOr<void> build(String boosterName) {
    return null;
  }

  Future<void> buy() async {
    state = const AsyncValue.loading();

    final purchaseRepository = ref.read(purchaseRepositoryProvider);

    state = await AsyncValue.guard(
      () => purchaseRepository.buyBooster(boosterName),
    );
  }
}
