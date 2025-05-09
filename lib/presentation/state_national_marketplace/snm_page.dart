import 'package:auto_route/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/purchase/product_details_provider.dart';
import 'package:package_flutter/bloc/purchase/purchases_stream_provider.dart';
import 'package:package_flutter/bloc/snm/buy_booster_provider.dart';
import 'package:package_flutter/domain/config/item.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/purchase/purchase_repository.dart';
import 'package:package_flutter/presentation/noodle/browser_bar.dart';
import 'package:package_flutter/presentation/state_national_marketplace/snm_product.dart';
import 'package:package_flutter/presentation/state_national_marketplace/snm_user_status.dart';

@RoutePage()
class SNMPage extends HookConsumerWidget {
  const SNMPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    ref.listen<AsyncValue<ProductDetailsResponse>>(
      productDetailsProvider,
      (previous, next) {
        next.when(
          data: (d) {
            Logger().d('Products loaded! ${d.productDetails}');
            if (d.notFoundIDs.isNotEmpty) {
              Logger().w("Can't found products: ${d.notFoundIDs}");
            }
          },
          error: (e, st) => Logger().e('No products loaded', e, st),
          loading: () => Logger().d('Loading products...'),
        );
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const BrowserBar(
        icon: Icons.arrow_back,
        link: 'httgs://state-national-marketplace.net/',
      ),
      body: ListView(
        children: [
          Container(
            height: 150,
            color: Colors.black,
            child: const Center(
              child: Text(
                'State National Marketplace',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SNMUserStatus(),
                ...config.storeItems.keys.map(
                  (c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 14),
                      SNMCategory(c.toUpperCase()),
                      ...config.storeItems[c]!.map((i) {
                        return Column(
                          children: [
                            const SizedBox(height: 14),
                            i.map(
                              iap: (i) {
                                final productPrice =
                                    ref.watch(productDetailsProvider).when(
                                          data: (data) => data.productDetails
                                              .where((pd) => pd.id == i.id)
                                              .firstOrNull
                                              ?.price,
                                          error: (_, __) => 'error',
                                          loading: () => '...',
                                        );
                                final purchaseDetails = ref
                                    .watch(purchasesStreamProvider)
                                    .when(
                                      data: (data) {
                                        final pds = data.where(
                                          (pd) => pd.productID == i.id,
                                        );
                                        return pds.isEmpty ? null : pds.first;
                                      },
                                      error: (_, __) => null,
                                      loading: () => null,
                                    );
                                return SNMProduct(
                                  isLoading: purchaseDetails?.status ==
                                      PurchaseStatus.pending,
                                  icon: i.icon,
                                  amount: i.amount,
                                  price: productPrice ?? '???',
                                  onPressed: () {
                                    ref.watch(productDetailsProvider).maybeWhen(
                                          data: (data) {
                                            ref
                                                .read(
                                                    purchaseRepositoryProvider)
                                                .buyProduct(
                                                  data.productDetails
                                                      .firstWhere(
                                                    (pd) => pd.id == i.id,
                                                  ),
                                                );
                                          },
                                          orElse: () {},
                                        );
                                  },
                                  description: 'Just Gems, change this later',
                                );
                              },
                              booster: (i) {
                                final buyBooster =
                                    ref.watch(buyBoosterProvider(i.name));
                                final emoji = config.items
                                    .firstWhere((e) => e.name == i.name)
                                    .emoji;

                                ref.listen<AsyncValue<void>>(
                                  buyBoosterProvider(i.name),
                                  (previous, next) {
                                    next.when(
                                      data: (_) =>
                                          context.read<NotificationsBloc>().add(
                                                NotificationsEvent.successAdded(
                                                  'Bought booster $emoji',
                                                ),
                                              ),
                                      error: (e, st) {
                                        if (e is DioException) {
                                          final failure =
                                              ServerFailure.fromError(e);
                                          context.read<NotificationsBloc>().add(
                                                NotificationsEvent.warningAdded(
                                                  failure.getMessage(),
                                                ),
                                              );
                                          return;
                                        }
                                        Logger().e('Can\'t buy booster',
                                            error: e, stackTrace: st);
                                      },
                                      loading: () {},
                                    );
                                  },
                                );

                                return SNMProduct(
                                  isLoading: buyBooster.isLoading,
                                  icon: emoji,
                                  amount: i.amount,
                                  price: i.price,
                                  description: config.items
                                      .whereType<ItemBooster>()
                                      .firstWhere((e) => e.name == i.name)
                                      .description
                                      .replaceAll('{duration}',
                                          '${config.boosterDuration} hour'),
                                  onPressed: () {
                                    ref
                                        .read(
                                          buyBoosterProvider(i.name).notifier,
                                        )
                                        .buy();
                                  },
                                );
                              },
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SNMCategory extends StatelessWidget {
  const SNMCategory(
    this.name, {
    super.key,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
