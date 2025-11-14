import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/business/business_bloc.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/domain/building/building.dart';
import 'package:package_flutter/domain/building/get_business_response.dart';
import 'package:package_flutter/presentation/core/emoji_image.dart';

class BusinessBodyOther extends HookConsumerWidget {
  const BusinessBodyOther({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider).value!;

    return BlocBuilder<BusinessBloc, BusinessState>(
      builder: (context, businessState) {
        final businessAndTaxes = switch (businessState) {
          BusinessStateLoadSuccess(:final businessAndTax) => businessAndTax,
          _ => GetBusinessResponse(
              business: Building.business(
                id: 0,
                geohex: '',
                geohash: '',
                level: 0,
                ownerId: 0,
                updatedAt: DateTime.now(),
                resourceToUpgrade1: 'wheel',
              ) as BusinessBuilding,
              tax: 0,
            ),
        };

        final businessEmoji =
            config.getBusinessEmoji(businessAndTaxes.business.level);
        return Container(
          height: 312 + 60,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                height: 312,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60 + 12),
                child: Column(
                  children: [
                    Text(
                      'Level ${businessAndTaxes.business.level}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Sansation',
                        fontSize: 48,
                      ),
                    ),
                    EmojiImage(
                      emoji: businessAndTaxes.business.owner!.avatar,
                      size: 48,
                    ),
                    Text(
                      businessAndTaxes.business.owner!.nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      width: 12,
                      color: const Color(0xFF373EBA),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: EmojiImage(emoji: businessEmoji),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
