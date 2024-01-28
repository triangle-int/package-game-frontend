import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/user/create_user/create_user_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/user/user.dart';
import 'package:package_flutter/domain/user/user_repository.dart';
import 'package:package_flutter/presentation/user/create_user_body.dart';

class CreateUserPage extends HookConsumerWidget {
  const CreateUserPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<User>>(userProvider, (prev, next) {
      next.map(
        loading: (_) {},
        error: (_) {},
        data: (_) {
          context
              .read<InventoryBloc>()
              .add(const InventoryEvent.listenInventoryRequested());
        },
      );
    });

    return BlocProvider(
      create: (context) => CreateUserBloc(ref.watch(userRepositoryProvider)),
      child: BlocListener<CreateUserBloc, CreateUserState>(
        listener: (context, state) {
          if (state.failureOrNull != null) {
            context.read<NotificationsBloc>().add(
                  NotificationsEvent.warningAdded(
                    state.failureOrNull!.when(
                      tooLongNickname: (maxSize) =>
                          'Company name is too long. Maximal size $maxSize',
                      noAvatar: () => "You haven't selected an avatar",
                      invalidNickname: () =>
                          'Your company name contains invalid characters',
                      // accountExists: () =>
                      //     'You already have an account. Something goes wrong.',
                      nicknameAlreadyInUse: () =>
                          'Company name is busy, please enter another.',
                      serverFailure: (String message) => message,
                      // TODO(P5ina): Minimal size from config
                      tooShortNickname: (minSize) =>
                          'Company name is too short. Minimal size $minSize',
                      invalidAccessToken: () => 'Invalid access token',
                    ),
                  ),
                );
          }
        },
        child: const CreateUserBody(),
      ),
    );
  }
}
