import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/inventory/inventory_bloc.dart';
import 'package:package_flutter/bloc/notifications/notifications_bloc.dart';
import 'package:package_flutter/bloc/user/create_user/create_user_bloc.dart';
import 'package:package_flutter/bloc/user/user_provider.dart';
import 'package:package_flutter/domain/user/create_user_failure.dart';
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
                    switch (state.failureOrNull!) {
                      TooLongNickname(maxSize: final maxSize) =>
                        'Company name is too long. Maximal size $maxSize',
                      NoAvatar() => "You haven't selected an avatar",
                      InvalidNickname() =>
                        'Your company name contains invalid characters',
                      NicknameAlreadyInUse() =>
                        'Company name is busy, please enter another.',
                      ServerFailure(message: final message) => message,
                      TooShortNickname(minSize: final minSize) =>
                        'Company name is too short. Minimal size $minSize',
                      InvalidAccessToken() => 'Invalid access token',
                    },
                  ),
                );
          }
        },
        child: const CreateUserBody(),
      ),
    );
  }
}
