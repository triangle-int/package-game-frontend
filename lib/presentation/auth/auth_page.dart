import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/auth/auth_bloc.dart';
import 'package:package_flutter/bloc/auth/auth_page/auth_page_bloc.dart';
import 'package:package_flutter/domain/auth/auth_repository.dart';
import 'package:package_flutter/presentation/auth/auth_page_body.dart';

class AuthPage extends HookConsumerWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.map(
          initial: (_) {},
          loadInProgress: (_) {},
          loadFailure: (_) {},
          loadSuccess: (_) {},
        );
      },
      child: BlocProvider(
        create: (context) => AuthPageBloc(ref.watch(authRepositoryProvider)),
        child: const AuthPageBody(),
      ),
    );
  }
}
