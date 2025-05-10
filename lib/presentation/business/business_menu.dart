import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/business/business_bloc.dart';
import 'package:package_flutter/bloc/business/upgrade/business_upgrade_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/business/business_repository.dart';
import 'package:package_flutter/presentation/business/business_body.dart';
import 'package:package_flutter/presentation/business/business_body_other.dart';
import 'package:package_flutter/presentation/business/business_loading.dart';
import 'package:package_flutter/presentation/core/root/sfx_volume.dart';

class BusinessMenu extends HookConsumerWidget {
  const BusinessMenu(this.businessId, {super.key});

  final int businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value!;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BusinessBloc(
            ref.watch(buildingRepositoryProvider),
            ref.watch(businessRepositoryProvider),
          )..add(BusinessEvent.businessRequested(businessId, user)),
        ),
        BlocProvider(
          create: (context) =>
              BusinessUpgradeBloc(ref.watch(businessRepositoryProvider)),
        ),
      ],
      child: BlocListener<BusinessUpgradeBloc, BusinessUpgradeState>(
        listener: (context, state) {
          switch (state) {
            case LoadSuccess(:final building):
              context.read<BusinessBloc>().add(
                    BusinessEvent.businessGot(building),
                  );
              final player = AudioPlayer();
              player.setVolume(ref.read(sfxVolumeProvider));
              AudioPlayer().play(
                AssetSource(
                  'sounds/upgrade_business.wav',
                ),
              );
            case LoadFailure(:final failure):
              context
                  .read<NotificationsBloc>()
                  .add(NotificationsEvent.warningAdded(failure.getMessage()));
            case Initial():
              break;
            case LoadInProgress():
              break;
          }
        },
        child: BlocConsumer<BusinessBloc, BusinessState>(
          listener: (context, state) {
            switch (state) {
              case BusinessStateLoadFailure(:final failure):
                context
                    .read<NotificationsBloc>()
                    .add(NotificationsEvent.warningAdded(failure.getMessage()));
              case BusinessStateInitial():
                break;
              case BusinessStateLoadInProgress():
                break;
              case BusinessStateLoadSuccess():
                break;
            }
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: switch (state) {
                BusinessStateInitial() => const BusinessLoading(),
                BusinessStateLoadInProgress() => const BusinessLoading(),
                BusinessStateLoadFailure() => const BusinessLoading(),
                BusinessStateLoadSuccess() =>
                  state.businessAndTax.business.ownerId == user.id
                      ? const BusinessBody()
                      : const BusinessBodyOther(),
              },
            );
          },
        ),
      ),
    );
  }
}
