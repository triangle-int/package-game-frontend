import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/business/business_bloc.dart';
import 'package:package_flutter/bloc/business/upgrade/business_upgrade_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/sidebar/effects_volume_provider.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/building/building_repository.dart';
import 'package:package_flutter/domain/business/business_repository.dart';
import 'package:package_flutter/presentation/business/business_body.dart';
import 'package:package_flutter/presentation/business/business_body_other.dart';
import 'package:package_flutter/presentation/business/business_loading.dart';

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
          state.maybeMap(
            loadSuccess: (s) async {
              context.read<BusinessBloc>().add(
                    BusinessEvent.businessGot(s.building),
                  );
              final player = AudioPlayer();
              await player.setVolume(ref.read(effectsVolumeProvider));
              AudioPlayer().play(
                AssetSource(
                  'sounds/upgrade_business.wav',
                ),
              );
            },
            loadFailure: (s) {
              context
                  .read<NotificationsBloc>()
                  .add(NotificationsEvent.warningAdded(s.failure.getMessage()));
            },
            orElse: () {},
          );
        },
        child: BlocConsumer<BusinessBloc, BusinessState>(
          listener: (context, state) {
            state.mapOrNull(
              loadFailure: (s) => context
                  .read<NotificationsBloc>()
                  .add(NotificationsEvent.warningAdded(s.failure.getMessage())),
            );
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: state.map(
                initial: (_) => const BusinessLoading(),
                loadInProgress: (_) => const BusinessLoading(),
                loadFailure: (_) => const BusinessLoading(),
                loadSuccess: (s) => s.businessAndTax.business.ownerId == user.id
                    ? const BusinessBody()
                    : const BusinessBodyOther(),
              ),
            );
          },
        ),
      ),
    );
  }
}
